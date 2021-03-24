//
//  User.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/06/27.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var objectId : String
    var userName: String
    var displayName: String?
    var introduction: String?

    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }

}
