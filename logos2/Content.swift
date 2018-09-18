 //
//  Content.swift
//  logos2
//
//  Created by Katherine Miao on 5/12/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
class  Content{
    var title:String
    var photo:UIImage
    var time:String
    init?(title:String,photo:UIImage,time:String)
    {
        if title.isEmpty{
            return nil
        }
        self.title=title
        self.photo=photo
        self.time=time
    }
}

