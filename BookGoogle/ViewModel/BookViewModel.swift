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
  private let showLoadingIndicator = BehaviorRelay<Bool>.init(value: false)
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
    let loadInProgress: Observable<Bool>
  }

  init(apiInit: APIServiceProtocol = APIService()) {
    self.api = apiInit
    let booksRelay: BehaviorRelay<[BookTableViewCellType]> = BehaviorRelay.init(value: [])

    self.input = Input(
      searchText: searchTextSubject.asObserver(),
      search: searchSubject.asObserver(),
      nextPage: nextPageSubject.asObserver())
    self.output = Output(
      books: booksRelay.asDriver(onErrorJustReturn: []), loadInProgress: showLoadingIndicator.asObservable().distinctUntilChanged())
    let results = searchSubject
      .withLatestFrom(searchTextSubject)
      .distinctUntilChanged()
      .flatMapLatest { searchText in
        return self.nextPageSubject.asObservable()
          .startWith(())
          .scan(0) { (pageNumber, _) -> Int in
            pageNumber + 1
          }
          .map { pageNumber in
            (searchText, pageNumber)
        }
      }
      .flatMap { [weak self] text -> Observable<[BookModel]> in
        guard let strongSelf = self else {
          return Observable.just([])
        }

        strongSelf.showLoadingIndicator.accept(true)
        strongSelf.page = text.1 - 1
        let results = strongSelf.api.findBooks(with: text.0, maxResults: strongSelf.itemsPerPage, page: strongSelf.page)
        switch results {
        case .success(payload: let payload):
            return payload
        case .failure(let error):
            print(error ?? "error")
            return Observable.just([])
        }
    }

    results
      .subscribe(onNext: { (newBooks) in
        self.showLoadingIndicator.accept(false)
        if newBooks.count == 0 {
            booksRelay.accept( [BookTableViewCellType.empty])
        } else {
           let books: [BookTableViewCellType] = newBooks.compactMap { .normal(cellViewModel: $0 as BookModel)}
          self.page > 0 ? booksRelay.accept(booksRelay.value + books) : booksRelay.accept(books)
           self.showLoadingIndicator.accept(false)
        }
    }).disposed(by: disposeBag)
  }
}
