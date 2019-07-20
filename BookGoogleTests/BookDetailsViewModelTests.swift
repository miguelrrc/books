//
//  BookGoogleTests.swift
//  BookGoogleTests
//
//  Created by Miguel Rodriguez Rubio on 03/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking

@testable import BookGoogle

class BookGoogleTests: XCTestCase {
    var subject: BookDetailsViewModel!
    private var testScheduler = TestScheduler.init(initialClock: 0)
    private let disposeBag = DisposeBag()

    override func setUp() {
        subject = BookDetailsViewModel()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModel() {
        let observer = testScheduler.createObserver(BookModel.self)
        let models: [BookModel] = BookModel.parse(fromJSON: TestUtils.mockJson()!)
        var iterator = 0
        let events: [Recorded<Event<BookModel>>] = models.map { (model: BookModel) -> Recorded<Event<BookModel>> in
            let nextValue = next(iterator * 10, model)
            iterator += 1
            return nextValue
        }
        let tap = testScheduler.createColdObservable(events)

        tap.bind(to: subject.input.book)
            .disposed(by: disposeBag)
        _ = subject.input.book.asObservable().subscribe(observer)
        testScheduler.start()

        iterator = 0
        let expectedEvents: [Recorded<Event<BookModel>>] =
            models.map { (model: BookModel) -> Recorded<Event<BookModel>> in
            let nextValue = next(iterator * 10, model)
            iterator += 1
            return nextValue
        }
        print("observer-===========", observer.events)
        print("expectedEvents-=------------------", expectedEvents)
//        observer.events.
        XCTAssertEqual(observer.events, expectedEvents)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
