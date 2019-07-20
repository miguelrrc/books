//
//  APIService.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 03/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Alamofire
import SwiftyJSON

typealias JSONObject = [String: Any]

enum Result<T, U: Error> {
    case success(payload: T)
    case failure(U?)
}

enum Errors: Error {
    case requestFailed
}
typealias GetBookResults = Result<Observable<[BookModel]>, Errors>

protocol APIServiceProtocol {
    
    func findBooks(with search: String, maxResults: Int, page: Int) -> GetBookResults
}

struct APIParameterKey {
    static let query = "q"
    static let maxResults = "maxResults"
    static let startIndex = "startIndex"
}

struct APIService: APIServiceProtocol {
    typealias ApiRequestParams = [String: String]
    fileprivate enum Version: String {
        case version1 = "v1/"
    }
    fileprivate enum Address: String {
        case volumes = "volumes?"
        private var baseURL: String { return "https://www.googleapis.com/books/" }
        private var version: String { return "v1/"}
        var urlV1: URL? {
            return URL(string: baseURL.appending(Version.version1.rawValue).appending(rawValue))!
        }
    }
    
    fileprivate enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    func findBooks(with search: String, maxResults: Int = 20, page: Int = 0) -> GetBookResults {
        guard  search.count > 0 else {
            return GetBookResults.failure(Errors.requestFailed)
        }
        let url = APIService.Address.volumes
        let page = page
        let parameters = [
            APIParameterKey.query: search,
            APIParameterKey.startIndex: String(page*40),
            APIParameterKey.maxResults: String(maxResults)
        ]
        let response: Observable<JSON> =  request(address: url, method: Method.get, parameters: parameters)
        let books = response.flatMapLatest { (json) -> Observable<[BookModel]> in
            let books = BookModel.parse(fromJSON: json)
            return Observable.just(books)
        }
        return GetBookResults.success(payload: books)
    }
    
    // MARK: - generic request
    private func request<T: Any>( address: Address, method: Method,
                                  parameters: ApiRequestParams = [:]) -> Observable<T> {
        return Observable.create { observer in
            guard
                let urlV1 = address.urlV1,
                var comps = URLComponents(string: urlV1.absoluteString)
                else {
                    return Disposables.create {}
            }
            comps.queryItems = parameters.map(URLQueryItem.init)
            guard let url = try? comps.asURL() else {
                return Disposables.create {}
            }
            var urlRequest =  URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            let request = Alamofire.request(urlRequest)
            request.responseJSON { response in
                guard response.error == nil, let data = response.data,
                    let json =  JSON(data) as? T else {
                        print("error")
                        observer.onError(Errors.requestFailed)
                        return
                }
                observer.onNext(json)
                observer.onCompleted()
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

