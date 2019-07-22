//
//  BookGoogleUITests.swift
//  BookGoogleUITests
//
//  Created by Miguel Rodriguez on 20/07/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import XCTest

class BookGoogleUITests: XCTestCase {
  var app = XCUIApplication()
  var indicator: XCUIElement!
  override func setUp() {
    app = XCUIApplication()
    indicator = app.activityIndicators["loadingView"]
    continueAfterFailure = false
    app.launch()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testShowingAndDismissingLoader() {
    app.tables.searchFields["Books and more books!"].tap()
    app.tables.searchFields["Books and more books!"].typeText("Henrik")
    app.keyboards.buttons["Search"].tap()
    XCTAssert(indicator.exists)
    XCTAssert(!indicator.waitForExistence(timeout: 5))
  }

  func testTableHasBooks() {
    let tables = app.tables
    tables.searchFields["Books and more books!"].tap()
    tables.searchFields["Books and more books!"].typeText("Henrik")
    app.keyboards.buttons["Search"].tap()
    XCTAssert(!indicator.waitForExistence(timeout: 5))
    XCTAssert(tables.cells.count > 1)
  }

  func testGoToDetailsView() {
    let tables = app.tables
    tables.searchFields["Books and more books!"].tap()
    tables.searchFields["Books and more books!"].typeText("Games")
    app.keyboards.buttons["Search"].tap()
    XCTAssert(!indicator.waitForExistence(timeout: 5))
    tables.cells.element(boundBy: 0).tap()
    //Moving to next view controller
    XCTAssert(app.collectionViews.count > 0)
    let collectionView = app.collectionViews.element(boundBy: 0)
    print("collectionView.cells.count: ", collectionView.cells.count)
    XCTAssertEqual(collectionView.cells.count, 3)
    //    let title = app.staticTexts.matching(identifier: "titleLabel")
    let cell = collectionView.cells.element(boundBy: 1)
    XCTAssert(cell.staticTexts["titleLabel"].exists)
  }

  func testGoBackFromDetailsToListShouldKeepData() {
    let tables = app.tables
    tables.searchFields["Books and more books!"].tap()
    tables.searchFields["Books and more books!"].typeText("Games")
    app.keyboards.buttons["Search"].tap()
    XCTAssert(!indicator.waitForExistence(timeout: 5))
    tables.cells.element(boundBy: 0).tap()
    //Moving to next view controller
    XCTAssert(app.collectionViews.count > 0)
    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssert(tables.cells.count > 1)
  }

  func testGoBackFromDetailsToListAfterClearingSearchShouldKeepData() {
    let tables = app.tables
    tables.searchFields["Books and more books!"].tap()
    tables.searchFields["Books and more books!"].typeText("Games")
    app.keyboards.buttons["Search"].tap()
    XCTAssert(!indicator.waitForExistence(timeout: 5))
    tables.searchFields["Books and more books!"].tap()
    tables.buttons["Clear text"].tap()
    tables.cells.element(boundBy: 0).tap()
    //Moving to next view controller
    XCTAssert(app.collectionViews.count > 0)
    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssert(tables.cells.count > 1)
  }
}
