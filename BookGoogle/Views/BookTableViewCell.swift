//
//  BookTableViewCell.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 03/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit
import SnapKit
    
class BookTableViewCell: UITableViewCell {
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let bookImageView = UIImageView()
  let authorLabel = UILabel()
  
  var viewModel: BookModel? {
    didSet{
      titleLabel.text = viewModel?.title
      subtitleLabel.text = viewModel?.subtitle
      if let thumbnail = viewModel?.thumbnail, let url = URL(string:thumbnail) {
        bookImageView.kf.setImage(with: url)
      }
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.addSubview(bookImageView)
    bookImageView.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(44)
      make.height.equalTo(44)
      make.centerY.equalTo(self.snp.centerY)
    }
    titleLabel.font = UIFont.systemFont(ofSize: 14)
    self.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(20)
      make.top.equalTo(self.snp.top).offset(5)
      make.left.equalTo(self.bookImageView.snp.right).offset(10)
    }
    
    subtitleLabel.font = UIFont.systemFont(ofSize: 10)
    self.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(20)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(2)
      make.left.equalTo(self.titleLabel.snp.left)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}

