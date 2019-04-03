//
//  DescriptionCollectionViewCell.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 04/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit

class DescriptionCollectionViewCell: UICollectionViewCell {
  let descriptionLabel = UILabel()
  var descriptionString: String? {
    didSet{
      descriptionLabel.text = descriptionString?.htmlToString
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    descriptionLabel.font = UIFont.systemFont(ofSize: 18)
    descriptionLabel.numberOfLines = 0
    self.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(self.snp.width)
      make.top.equalTo(self.snp.top).offset(5)
      make.left.equalTo(self.snp.left).offset(10)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
