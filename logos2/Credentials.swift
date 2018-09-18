//
//  Credentials.swift
//  logos2
//
//  Created by Mansi on 23/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
class Credentials{
    var name:String
    var photo:UIImage
    init?(name:String,photo:UIImage)
    {
        if name.isEmpty{
            return nil
        }
        self.name=name
        self.photo=photo
    }
}
