//
//  UIScrollView.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 05/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit
import RxSwift

extension UIScrollView {
  public var rxReachedBottom: Observable<Void> {
    return self.rx.contentOffset
      .map { contentOffset in
        var responder: UIResponder = self
        var viewController: UIViewController? = nil
        while let next = responder.next {
          viewController = next as? UIViewController
          if viewController != nil {
            break
          }
          responder = next
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = viewController?.navigationController?.navigationBar.bounds.height ?? 0
        let tabBarHeight = viewController?.tabBarController?.tabBar.bounds.height ?? 0
        let bottomOffset = contentOffset.y + self.contentInset.top + self.bounds.height
          - statusBarHeight - navigationBarHeight - tabBarHeight
        return bottomOffset >= self.contentSize.height - self.bounds.height / 2
      }
      .distinctUntilChanged()
      .filter { $0 }
      .map { _ in Void() }
  }
}
