//
//  KnowsAbout.swift
//  logos2
//
//  Created by Mansi on 24/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
class  KnowsAbout{
    var name:String
    var photo:UIImage
    var points:String
    init?(name:String,photo:UIImage,points:String)
    {
        if name.isEmpty{
            return nil
        }
        self.name=name
        self.photo=photo
        self.points=points
    }
}
class  AuthorKnowsAbout{
    var name:String
    var photo:UIImage
    var points:String
    var isEndorsed:Bool
    var id:String
    var isKnowsAbout:Bool
    init?(name:String,photo:UIImage,points:String,isEndorsed:Bool,id:String,isKnowsAbout:Bool)
    {
        if name.isEmpty{
            return nil
        }
        self.name=name
        self.photo=photo
        self.points=points
        self.isEndorsed=isEndorsed
        self.id = id
        self.isKnowsAbout = isKnowsAbout
    }
}
