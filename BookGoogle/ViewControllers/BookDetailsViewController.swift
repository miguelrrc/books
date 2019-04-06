//
//  BookDetailsViewController.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 04/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class BookDetailsViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let book: BookModel?
  private let bookViewModel = BookDetailsViewModel()
  private let cellHeight: CGFloat = 200
  private lazy var collectionView: UICollectionView = {
    var flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)

    collectionView
      .register(
        ImageCollectionViewCell.self,
        forCellWithReuseIdentifier: SectionIdentifier.imageCellIdentifier.rawValue)
    collectionView
      .register(
      InfoCollectionViewCell.self,
      forCellWithReuseIdentifier: SectionIdentifier.infoCellIdentifier.rawValue)
    collectionView
      .register(
        DescriptionCollectionViewCell.self,
        forCellWithReuseIdentifier: SectionIdentifier.descriptionCellIdentifier.rawValue)
    collectionView.backgroundColor = UIColor.white

    return collectionView
  }()

  convenience init() {
    self.init(book: nil)
  }

  init(book: BookModel?) {
    self.book = book
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initUI()
    setupViewModel()
  }

  private func initUI() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(collectionView)

    collectionView.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leadingMargin)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailingMargin)
    }
  }

  private func setupViewModel() {
    guard let book = book else {
      return
    }
    let dataSource = BookDetailsViewController.dataSource()
    collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    Observable.just(book).bind(to: bookViewModel.input.book).disposed(by: disposeBag)
    bookViewModel.output
      .sections
      .asObservable()
      .bind(to:
        collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}

extension BookDetailsViewController {
  static func dataSource() -> RxCollectionViewSectionedReloadDataSource<BookSectionModel> {
    return RxCollectionViewSectionedReloadDataSource<BookSectionModel>(
      configureCell: { (dataSource, collection, idxPath, _) in
        switch dataSource[idxPath] {
        case let .imageSectionItem(imageBook):
          guard let cell: ImageCollectionViewCell = collection
            .dequeueReusableCell( withReuseIdentifier: SectionIdentifier
              .imageCellIdentifier.rawValue, for: idxPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
          }
          cell.imageBook = imageBook
          return cell
        case let .infoSectionItem(infoBook):
          guard let cell: InfoCollectionViewCell = collection.dequeueReusableCell(
            withReuseIdentifier: SectionIdentifier.infoCellIdentifier.rawValue,
            for: idxPath) as? InfoCollectionViewCell
            else {
            return UICollectionViewCell()
          }
          cell.infoBook = infoBook
          return cell
        case let .descriptionSectionItem(item):
          guard let cell: DescriptionCollectionViewCell = collection
            .dequeueReusableCell( withReuseIdentifier: SectionIdentifier
              .descriptionCellIdentifier.rawValue, for: idxPath) as? DescriptionCollectionViewCell  else {
            return UICollectionViewCell()
          }
          cell.descriptionString = item
          return cell
        }
    }
    )
  }
}

extension BookDetailsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width
    let cellWidth = width
    return CGSize(width: cellWidth, height: cellHeight)
  }
}
