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

struct ImageBook{
  let image: String?
  init(image: String?)
  {
    self.image = image
  }
}

class BookDetailsViewModel:  UIViewModelType{
  
  let input: Input
  let output: Output
  let disposeBag = DisposeBag()
  
  struct Input {
    let book: AnyObserver<BookModel>
  }
  //MARK: OUTPUT
  struct Output{
    var sections: Driver<[BookSectionModel]>
  }
  private let modelSubject = ReplaySubject<BookModel>.create(bufferSize: 1)
  
  init(){
    let result = modelSubject
      .flatMapLatest { (book) -> Observable<[BookSectionModel]> in
        let results:  [BookSectionModel] = [
          .ImageProvidableSection(
            items: [.ImageSectionItem(image: ImageBook(image: book.thumbnail))]),
          .InfoSection(
            items: [.InfoSectionItem(info: InfoBook(title: book.title, subtitle: book.subtitle, authors: book.authors ?? []))]),
          .DescriptionSection(
                              items: [.DescriptionSectionItem(bookDescription: book.textSnippet)])]
        return Observable.just(results)
    }
    
    self.input = Input(book: modelSubject.asObserver())
    self.output = Output(sections: result.asDriver(onErrorJustReturn: []))
  }
}

enum SectionIdentifier: String{
  case imageCellIdentifier
  case infoCellIdentifier
  case descriptionCellIdentifier
}
enum BookSectionModel {
  case ImageProvidableSection(items: [SectionItem])
  case InfoSection(items: [SectionItem])
  case DescriptionSection(items: [SectionItem])
}

enum SectionItem{
  case ImageSectionItem(image: ImageBook)
  case InfoSectionItem(info: InfoBook)
  case DescriptionSectionItem(bookDescription: String?)
}

struct InfoBook{
  let title: String?
  let subtitle: String?
  let authors: [String]
  
  init(title: String?, subtitle: String?, authors: [String]){
    self.title = title
    self.subtitle = subtitle
    self.authors = authors
  }
}

extension BookSectionModel: SectionModelType {
  typealias Item = SectionItem
  
  var items: [SectionItem] {
    switch  self {
    case .ImageProvidableSection(items: let items):
      return items.map {$0}
    case .InfoSection(items: let items):
      return items.map {$0}
    case .DescriptionSection(items: let items):
      return items.map {$0}
    }
  }
  
  init(original: BookSectionModel, items: [Item]) {
    switch original {
    case let .ImageProvidableSection(items: items):
      self = .ImageProvidableSection(items: items)
    case let .InfoSection(items):
      self = .InfoSection(items: items)
    case let .DescriptionSection(items: items):
      self = .DescriptionSection(items: items)
    }
  }
}



