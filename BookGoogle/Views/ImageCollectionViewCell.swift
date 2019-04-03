//
//  ImageCollectionViewCell.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 04/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()
  var imageBook: ImageBook? {
    didSet{
      if let image = imageBook?.image, let url = URL(string:image) {
        self.imageView.kf.setImage(with: url)
      }
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(imageView)
    imageView.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(self)
      make.center.equalTo(self.center)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

