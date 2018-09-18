//
//  Notification.swift
//  logos2
//
//  Created by Mansi on 23/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
class newNotification {
    var name:String
    var details:String
    var time:String
    var endorsment:String
    var photo:UIImage?
    var id:String
    var title:String
    var type:Int
    var newsId:String
    var fromUserId: String
    var isRead : Bool
    init?(name:String,details:String,time:String,endorsment:String,photo:UIImage,id:String,title:String,type:Int,newsId:String, fromUserId: String,isRead : Bool) {
        if name.isEmpty || details.isEmpty || time.isEmpty || endorsment.isEmpty{
            return nil
        }
        self.name=name
        self.details=details
        self.time=time
        self.endorsment=endorsment
        self.photo=photo
        self.id=id
        self.title=title
        self.type=type
        self.newsId=newsId
        self.fromUserId = fromUserId
        self.isRead = isRead
    }
}


