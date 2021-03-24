//
//  Comment.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/27.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit

class Comment {
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    
    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
        
    }
}
