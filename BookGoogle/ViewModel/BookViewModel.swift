//
//  BookViewModel.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 05/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum BookTableViewCellType {
  case normal(cellViewModel: BookModel)
  case empty
}

protocol UIViewModelType {
  associatedtype Input
  associatedtype Output

  var input: Input { get }
  var output: Output { get }

}

class BookViewModel: UIViewModelType {
  let input: Input
  let output: Output

  private let api: APIServiceProtocol
  private let disposeBag = DisposeBag()
  private var page = 0
  private let itemsPerPage = 40
  private let searchTextSubject = ReplaySubject<String>.create(bufferSize: 1)
  private let nextPageSubject = PublishSubject<Void>()
  private let searchSubject = PublishSubject<Void>()

  struct Input {
    let searchText: ReplaySubject<String>
    let search: PublishSubject<Void>
    var nextPage: AnyObserver<Void>
  }

  struct Output {
    var books: Driver<[BookTableViewCellType]>
  }

  init(apiInit: APIServiceProtocol = APIService()) {
    self.api = apiInit
    let booksRelay: BehaviorRelay<[BookTableViewCellType]> = BehaviorRelay.init(value: [])

    self.input = Input(
      searchText: searchTextSubject.asObserver(),
      search: searchSubject.asObserver(),
      nextPage: nextPageSubject.asObserver())
    self.output = Output(books: booksRelay.asDriver(onErrorJustReturn: []))

    let resultsFirstPage = searchSubject
      .withLatestFrom(searchTextSubject)
      .distinctUntilChanged()
      .flatMap { [weak self] text -> Observable<[BookModel]> in
        guard let strongSelf = self else {
          return Observable.just([])
        }
        strongSelf.page = 0
        let results = strongSelf.api.findBooks(with: text, maxResults: strongSelf.itemsPerPage, page: strongSelf.page)
        switch results {
        case .success(payload: let payload):
            return payload
        case .failure(let error):
            print(error ?? "error")
            return Observable.just([])
        }
//        return strongSelf.api.findBooks(with: text, maxResults: strongSelf.itemsPerPage, page: strongSelf.page)
    }

    let resultNextPage = nextPageSubject
      .withLatestFrom(searchTextSubject)
      .flatMapLatest { [weak self] text -> Observable<[BookModel]> in
        guard let strongSelf = self else {
          return Observable.just([])
        }
        strongSelf.page += 1
        let results = strongSelf.api.findBooks(with: text, maxResults: strongSelf.itemsPerPage, page: strongSelf.page)
        switch results {
        case .success(payload: let payload):
            return payload
        case .failure(let error):
            print(error ?? "error")
            return Observable.just([])
        }
    }

    resultsFirstPage.subscribe(onNext: { (newBooks) in
        if newBooks.count == 0 {
            booksRelay.accept( [BookTableViewCellType.empty])
        } else {
            let books: [BookTableViewCellType] = newBooks.compactMap { .normal(cellViewModel: $0 as BookModel)}
            booksRelay.accept(books)
        }
    }).disposed(by: disposeBag)
    resultNextPage.subscribe(onNext: { (newBooks) in
        if newBooks.count == 0 {
            booksRelay.accept( [BookTableViewCellType.empty])
        } else {
            let books: [BookTableViewCellType] = newBooks.compactMap { .normal(cellViewModel: $0 as BookModel)}
            booksRelay.accept(booksRelay.value + books)
        }
    
    }).disposed(by: disposeBag)
  }
}
