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

enum Errors: Error {
  case requestFailed
}

protocol APIServiceProtocol {
  static func findBooks(with search: String, maxResults: Int, page: Int) -> Observable<[BookModel]>
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

  static func findBooks(with search: String, maxResults: Int = 20, page: Int = 0) -> Observable<[BookModel]> {
    guard  search.count > 0 else {
      return Observable.empty()
    }
    let url = APIService.Address.volumes
    let page = page
    let parameters = [
      APIParameterKey.query: search,
      APIParameterKey.startIndex: String(page*40),
      APIParameterKey.maxResults: String(maxResults)
    ]
    let response: Observable<JSON> =  request(address: url, method: Method.get, parameters: parameters)
    return response.flatMapLatest { (json) -> Observable<[BookModel]> in
      let books = BookModel.parse(fromJSON: json)
      return Observable.just(books)
    }
  }

  // MARK: - generic request
  static private func request<T: Any>( address: Address, method: Method, parameters: ApiRequestParams = [:]) -> Observable<T> {
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
