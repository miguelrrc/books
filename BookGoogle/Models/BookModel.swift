//
//  BookModel.swift
//  BookGoogle
//
//  Created by Miguel Rodriguez Rubio on 03/04/2019.
//  Copyright © 2019 Miguel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct BookModel {
  typealias Models = [BookModel]
  var title: String?
  var authors: [String]?
  var subtitle: String?
  var textSnippet: String?
  var description: String?
  var averageRating: Double?
  var smallThumbnail: String?
  var thumbnail: String?

  init(title: String?,
       authors: [String]?,
       subtitle: String?,
       textSnippet: String?,
       description: String?,
       averageRating: Double?,
       smallThumbnail: String?,
       thumbnail: String?) {
    self.title = title
    self.authors = authors
    self.subtitle = subtitle
    self.textSnippet = textSnippet
    self.description = description
    self.averageRating = averageRating
    self.smallThumbnail = smallThumbnail
    self.thumbnail = thumbnail
  }

  static func parse(fromJSON json: JSON) -> Models {
    var books = [BookModel]()
    guard let items = json["items"].array else { return books }
    for item in items {
      books.append(BookModel(title: item["volumeInfo"]["title"].string,
                             authors: item["volumeInfo"]["authors"].arrayObject as? [String],
                             subtitle: item["volumeInfo"]["subtitle"].string,
                             textSnippet: item["searchInfo"]["textSnippet"].string,
                             description: item["volumeInfo"]["description"].string,
                             averageRating: item["volumeInfo"]["averageRating"].double,
                             smallThumbnail: item["volumeInfo"]["imageLinks"]["smallThumbnail"].string,
                             thumbnail: item["volumeInfo"]["imageLinks"]["thumbnail"].string))
    }
    return books
  }
}

extension BookModel: Equatable {
    
}
