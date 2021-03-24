//
//  Post.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/27.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit

class Post: NSObject {
    
          var objectId: String
          var user: User
          var imageUrl: String
          var text: String
          var createDate: Date
          var isLiked: Bool?
          var comments: [Comment]?
          var likeCount: Int = 0
            var posttime : String

    init(objectId: String, user: User, imageUrl: String, text: String, createDate: Date,posttime:String) {
              self.objectId = objectId
              self.user = user
              self.imageUrl = imageUrl
              self.text = text
              self.createDate = createDate
            self.posttime = posttime

            
       }
}
