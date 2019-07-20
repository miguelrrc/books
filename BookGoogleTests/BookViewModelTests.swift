//
//  BookViewModelTest.swift
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

class BookViewModelTests: XCTestCase {
    var subject: BookViewModel!
    let newsLetterString = "A popular columnist of Quilter's Newsletter Magazine offers a collection of stories " +
    "from her everyday life sure to appeal to quilters of all levels, " +
    "dealing with everything from the love of creativity to the pleasure " +
    "of friendship."
    let titleString = "Helen Kelley's Joy of Quilting"
    private var testScheduler = TestScheduler.init(initialClock: 0)
    private var isPlaying: TestableObserver<String>!
    private var isTap: TestableObserver<Void>!
    private let api = APIServiceProtocolStub()
    private let disposeBag = DisposeBag()

    override func setUp() {
        isPlaying = testScheduler.createObserver(String.self)
        isTap = testScheduler.createObserver(Void.self)
        subject = BookViewModel.init(apiInit: api)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInputSearchingText() {
        let search = testScheduler.createObserver(String.self)
        subject = BookViewModel.init(apiInit: api)
        let times = ["miguel"]
        let events: [Recorded<Event<String>>] = times.map { (text) -> Recorded<Event<String>> in
            .next(0, text)
        }
        let tap = testScheduler.createColdObservable(events)

        tap.bind(to: subject.input.searchText)
            .disposed(by: disposeBag)
        testScheduler.start()

        _ = subject.input.searchText.asObservable().subscribe(search)
        XCTAssertEqual(search.events, [
            .next(0, "miguel")
            ])
    }

    func testEmptyResults() {
        let times = ["Error"]
        let events: [Recorded<Event<String>>] = times.map { (text) -> Recorded<Event<String>> in
            .next(0, text)
        }
        let eventsTap: [Recorded<Event<Void>>] = times.map { _ -> Recorded<Event<Void>> in
            .next(0, ())
        }
        let recordedTaps = testScheduler.createColdObservable(eventsTap)
        let searchTexts = testScheduler.createColdObservable(events)

        searchTexts.bind(to: subject.input.searchText)
            .disposed(by: disposeBag)
        recordedTaps.bind(to: subject.input.search)
            .disposed(by: disposeBag)
        testScheduler.start()
        subject.input.searchText.asObservable().subscribe(isPlaying).disposed(by: disposeBag)
        subject.input.search.asObservable().subscribe(isTap).disposed(by: disposeBag)

        do {
//            let value = subject.output.books
            let cell: BookTableViewCellType? = try subject.output.books.toBlocking().first()?.first
            guard case .some(.empty) = cell else {
                XCTFail("error")
                return
            }
            XCTAssert((cell != nil))
        } catch {
             return
        }
    }
}

final class APIServiceProtocolStub: APIServiceProtocol {
    func findBooks(with search: String, maxResults: Int, page: Int) -> GetBookResults {
        if search == "Error" {
         return GetBookResults.failure(Errors.requestFailed)
        }
        return TestUtils.models()
    }
}
