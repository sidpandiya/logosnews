//
//  newzListData.swift
//  logos2
//
//  Created by Mansi on 26/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
class newzListData {
    var userName:String
    var userEndorsment:String
    var userProfileImage:UIImage
    var newsImage:UIImage
    var newsTitle:String
    var agreeCount:Int
    var nutralCount:Int
    var disAgreeCount:Int
    var minBiasedValue:Float
    var id:String
    var time : String
    var AuthorId: String
    
    init?(userName:String,userEndorsment:String,userProfileImage:UIImage,newsImage:UIImage,newsTitle:String,agreeCount:Int,disAgreeCount:Int,nutralCount:Int,minBiasedValue:Float,id:String,time:String, AuthorId:String){
        
        if userName.isEmpty || userEndorsment.isEmpty || newsTitle.isEmpty {
            return nil
        }
        
        self.userName=userName
        self.userEndorsment=userEndorsment
        self.userProfileImage=userProfileImage
        self.newsImage=newsImage
        self.newsTitle=newsTitle
        self.agreeCount=agreeCount
        self.disAgreeCount=disAgreeCount
        self.minBiasedValue=minBiasedValue
        self.id=id
        self.nutralCount=nutralCount
        self.time = time
        self.AuthorId = AuthorId
    }
}
