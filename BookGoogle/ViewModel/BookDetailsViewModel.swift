//
//  BookDetailsViewModel.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 05/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import Differentiator
import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct ImageBook {
  let image: String?
  init(image: String?) {
    self.image = image
  }
}

class BookDetailsViewModel: UIViewModelType {

  let input: Input
  let output: Output
  let disposeBag = DisposeBag()

  struct Input {
    let book: AnyObserver<BookModel>
  }

  struct Output {
    var sections: Driver<[BookSectionModel]>
  }

  private let modelSubject = ReplaySubject<BookModel>.create(bufferSize: 1)

  init() {
    let result = modelSubject
      .flatMapLatest { (book) -> Observable<[BookSectionModel]> in
        let results: [BookSectionModel] = [
          .imageProvidableSection(
            items: [.imageSectionItem(image: ImageBook(image: book.thumbnail))]),
          .infoSection(
            items: [
              .infoSectionItem(
                info: InfoBook(
                  title: book.title,
                  subtitle: book.subtitle,
                  authors: book.authors ?? []))]),
          .descriptionSection(
            items: [.descriptionSectionItem(bookDescription: book.textSnippet)])]
        return Observable.just(results)
    }

    self.input = Input(book: modelSubject.asObserver())
    self.output = Output(sections: result.asDriver(onErrorJustReturn: []))
  }
}

enum SectionIdentifier: String {
  case imageCellIdentifier
  case infoCellIdentifier
  case descriptionCellIdentifier
}

enum BookSectionModel {
  case imageProvidableSection(items: [SectionItem])
  case infoSection(items: [SectionItem])
  case descriptionSection(items: [SectionItem])
}

enum SectionItem {
  case imageSectionItem(image: ImageBook)
  case infoSectionItem(info: InfoBook)
  case descriptionSectionItem(bookDescription: String?)
}

struct InfoBook {
  let title: String?
  let subtitle: String?
  let authors: [String]

  init(title: String?, subtitle: String?, authors: [String]) {
    self.title = title
    self.subtitle = subtitle
    self.authors = authors
  }
}

extension BookSectionModel: SectionModelType {
  typealias Item = SectionItem

  var items: [SectionItem] {
    switch  self {
    case .imageProvidableSection(items: let items):
      return items.map {$0}
    case .infoSection(items: let items):
      return items.map {$0}
    case .descriptionSection(items: let items):
      return items.map {$0}
    }
  }

  init(original: BookSectionModel, items: [Item]) {
    switch original {
    case let .imageProvidableSection(items: items):
      self = .imageProvidableSection(items: items)
    case let .infoSection(items):
      self = .infoSection(items: items)
    case let .descriptionSection(items: items):
      self = .descriptionSection(items: items)
    }
  }
}
