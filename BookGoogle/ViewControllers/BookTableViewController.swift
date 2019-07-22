//
//  ViewController.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 03/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import Kingfisher

class BookTableViewController: UIViewController {

  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableView.automaticDimension
    tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "Cell")
    return tableView
  }()

  private lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Books and more books!"
    searchBar.delegate = nil
    searchBar.sizeToFit()
    searchBar.showsScopeBar = true
    return searchBar
  }()
  private lazy var loadingView: UIActivityIndicatorView = {
    let loadingView = UIActivityIndicatorView.init(style: .gray)
    loadingView.hidesWhenStopped = true
    loadingView.accessibilityIdentifier = "loadingView"
    loadingView.isHidden = true
    return loadingView
  }()

  private let disposeBag = DisposeBag()
  private let viewModel = BookViewModel()
  private let heightRow: CGFloat = 40

  override func viewDidLoad() {
    super.viewDidLoad()
    initUI()
    setupViewModel()
  }

  private func initUI() {
    self.view.addSubview(tableView)
    self.view.addSubview(loadingView)
    tableView.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leadingMargin)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailingMargin)
    }

    tableView.tableHeaderView = searchBar
    tableView.estimatedRowHeight = heightRow
    tableView.rowHeight = UITableView.automaticDimension
    tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "Cell")

    loadingView.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottomMargin)
      make.centerX.equalTo(tableView.snp.centerX)
    }
  }

  private func setupViewModel() {
    Observable.merge(searchBar.rx.cancelButtonClicked.asObservable(),
                     searchBar.rx.searchButtonClicked.asObservable())
      .bind(to: resignFirstResponder)
      .disposed(by: disposeBag)

    viewModel.output
        .loadInProgress
      .map { [weak self] in self?.setLoadingIndicator(visible: $0) }
        .subscribe()
        .disposed(by: disposeBag)

    searchBar.rx.textDidEndEditing.bind(to: viewModel.input.search).disposed(by: disposeBag)
    searchBar.rx.text.orEmpty.bind(to: viewModel.input.searchText).disposed(by: disposeBag)

    searchBar.rx.textDidEndEditing.bind(to: viewModel.input.search).disposed(by: disposeBag)

    tableView.rxReachedBottom.bind(to: viewModel.input.nextPage).disposed(by: disposeBag)

    self.dataSource()
  }

  private var resignFirstResponder: AnyObserver<Void> {
    return Binder(self) { viewController, _ in
      viewController.searchBar.resignFirstResponder()
      }.asObserver()
  }

  private func setLoadingIndicator(visible: Bool) {
    visible ? loadingView.startAnimating() : loadingView.stopAnimating()
  }
}

extension BookTableViewController {

  private func dataSource() {
    viewModel.output.books
      .drive(tableView.rx.items) { table, _, element in
        switch element {
        case .normal(let viewModel):
          guard let cell = table.dequeueReusableCell(withIdentifier: "Cell") as? BookTableViewCell else {
            return UITableViewCell()
          }
          cell.viewModel = viewModel
          return cell
        case .empty:
          let cell = UITableViewCell()
          cell.isUserInteractionEnabled = false
          cell.textLabel?.text = "No data available"
          return cell
        }
      }.disposed(by: disposeBag)

    tableView.rx.modelSelected((BookTableViewCellType.self))
      .subscribe(onNext: { element in
        switch element {
        case .normal(let viewModel):
          let viewController = BookDetailsViewController(book: viewModel)
          self.navigationController?.pushViewController(viewController, animated: true)
        case .empty:
          //Do nothing :)
          return
        }
      }).disposed(by: self.disposeBag)
  }
}
