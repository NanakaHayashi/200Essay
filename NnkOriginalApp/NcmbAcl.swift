//
//  NcmbAcl.swift
//  NnkOriginalApp
//
//  Created by 早司菜々花 on 2020/09/15.
//  Copyright © 2020 nanakahayashi. All rights reserved.
//

import UIKit
import NCMB

class NcmbAcl: NCMBACL {
    
    override func setPublicWriteAccess(_ allowed: Bool) {
        true
    }
    
    override func setPublicReadAccess(_ allowed: Bool) {
        true
    }
    

}
