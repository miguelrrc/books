//
//  BookModelTest.swift
//  BookGoogleTests
//
//  Created by Miguel Rodriguez on 18/07/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import XCTest
import SwiftyJSON

class BookModelTests: XCTestCase {
//    var model: BookModel!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelParser() {
        guard let json = TestUtils.mockJson() else {
            XCTFail("Missing file: books.json")
            return
        }
        let model = BookModel.parse(fromJSON: json)
        XCTAssertEqual(model.count, 10)
    }
}
