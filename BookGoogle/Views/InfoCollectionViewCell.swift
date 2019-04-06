//
//  InfoCollectionViewCell.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 04/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let authorsLabel = UILabel()

  var infoBook: InfoBook? {
    didSet {
      titleLabel.text = infoBook?.title
      subtitleLabel.text = infoBook?.subtitle
      authorsLabel.text = infoBook?.authors.joined(separator: "-")
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    titleLabel.font = UIFont.systemFont(ofSize: 18)
    titleLabel.numberOfLines = 2
    self.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) -> Void in
      make.height.lessThanOrEqualTo(50)
      make.top.equalTo(self.snp.top).offset(5)
      make.left.equalTo(self.snp.left).offset(10)
      make.right.equalTo(self.snp.right).offset(-10)
    }

    subtitleLabel.font = UIFont.systemFont(ofSize: 12)
    subtitleLabel.numberOfLines = 2
    self.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { (make) -> Void in
      make.height.lessThanOrEqualTo(40)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
      make.right.equalTo(self.snp.right).offset(-10)
      make.left.equalTo(self.snp.left).offset(10)
    }

    authorsLabel.font = UIFont.systemFont(ofSize: 12)
    self.addSubview(authorsLabel)
    authorsLabel.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(20)
      make.top.equalTo(self.subtitleLabel.snp.bottom).offset(5)
      make.left.equalTo(self.snp.left).offset(10)
      make.right.equalTo(self.snp.right).offset(-10)
    }

  }

    required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
