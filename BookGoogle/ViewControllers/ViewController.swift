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

class ViewController: UIViewController {
  
  private let tableView = UITableView()
  private let searchBar = UISearchBar()
  private let loadingView = UIView()
  private let disposeBag = DisposeBag()
  let viewModel = BookViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initUI()
    setupViewModel()
  }
  
  private func initUI(){
    self.view.addSubview(tableView)
    searchBar.placeholder = "Books and more books!"
    
    searchBar.delegate = nil
    searchBar.sizeToFit()
    searchBar.showsScopeBar = true
    
    tableView.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leadingMargin)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailingMargin)
    }
    tableView.tableHeaderView = searchBar
    
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableView.automaticDimension
    tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "Cell")
  }
  
  private func setupViewModel(){
    Observable.merge(searchBar.rx.cancelButtonClicked.asObservable(),
                     searchBar.rx.searchButtonClicked.asObservable())
      .bind(to: resignFirstResponder)
      .disposed(by: disposeBag)
    searchBar.rx.text.orEmpty.bind(to: viewModel.input.searchText).disposed(by: disposeBag)
    searchBar.rx.textDidEndEditing.bind(to:viewModel.input.search).disposed(by: disposeBag)
    tableView.rx_reachedBottom.bind(to: viewModel.input.nextPage).disposed(by: disposeBag)
    self.dataSource()
  }
  
  private var resignFirstResponder: AnyObserver<Void> {
    return Binder(self) { me, _ in
      me.searchBar.resignFirstResponder()
      }.asObserver()
  }
}

extension ViewController {
  
  private func dataSource(){
    viewModel.output.books
      .drive(tableView.rx.items) { table, index, element in
        
        switch element {
          case .normal(let viewModel):
            guard let cell = table.dequeueReusableCell(withIdentifier: "Cell") as? BookTableViewCell else{
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
        switch element{
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
