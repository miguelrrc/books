//
//  TestUtils.swift
//  BookGoogleTests
//
//  Created by Miguel Rodriguez on 18/07/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import Foundation
import SwiftyJSON
class TestUtils {
    static func mockJson() -> JSON? {
        let bundle = Bundle(for: self)
        guard let path = bundle.path(forResource: "books", ofType: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let json = try JSON(data: data)
            return json
        } catch {
            return nil
        }
    }
    static func models () -> GetBookResults {
        guard let json = TestUtils.mockJson() else {
            return GetBookResults.failure(Errors.requestFailed)
        }
        var books: Observable<[BookModel]> {
            let parsed = BookModel.parse(fromJSON: json)
            return Observable<[BookModel]>.just(parsed)
        }
        return GetBookResults.success(payload: books)
    }

    static func extractModel (results: GetBookResults) -> Observable<[BookModel]> {
        switch results {
        case .failure(let error):
            print(error ?? "Error")
            return Observable.just([])
        case .success(payload: let books):
            return books
        }
    }
}
