//
//  commentData.swift
//  logos2
//
//  Created by Mansi on 04/06/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
class commentData{
    var commentId :String
    var authorId : String
    var authorName:String
    var authorImage:UIImage
    var authorEndorsment:String
    var comment:String
    var noOfReply :Int
    var opinion : Int
    var isReply : Bool
    var isEdited :Bool
    var noOfAgrees:Int
    var noOfDisagrees:Int
    var noOfNeutrals:Int
    var actualID : String
    var isEditable : Bool
    var timeAgo : String

    // var replyData = [ReplyData]()

    init?(commentId:String,authorId : String,authorName:String,authorImage:UIImage,authorEndorsment:String,comment:String,noOfReply:Int,opinion :Int,isReply : Bool,isEdited:Bool,noOfAgrees:Int,noOfDisagrees:Int,noOfNeutrals:Int, actualID: String, isEditable: Bool, timeAgo: String)
    {
        self.commentId = commentId
        self.authorId = authorId
        if authorName.isEmpty{
            return nil
        }
        self.authorName=authorName
        self.authorImage=authorImage
        self.authorEndorsment=authorEndorsment
        self.comment=comment
        self.noOfReply=noOfReply
        self.opinion = opinion
        self.isReply = isReply
        self.isEdited = isEdited
        self.noOfAgrees = noOfAgrees
        self.noOfNeutrals = noOfNeutrals
        self.noOfDisagrees = noOfDisagrees
        self.actualID = actualID
        self.isEditable = isEditable
        self.timeAgo = timeAgo

        //self.replyData = replyData
    }
}
class ReplyData{
    var authorName:String
    var authorImage:UIImage
    var authorEndorsment:String
    var comment:String
    var noOfReply :String
    var opinion : Int
    var isEditable : Bool

    init?(authorName:String,authorImage:UIImage,authorEndorsment:String,comment:String,noOfReply:String,opinion :Int,isEditable : Bool)
    {
        if authorName.isEmpty{
            return nil
        }
        self.authorName=authorName
        self.authorImage=authorImage
        self.authorEndorsment=authorEndorsment
        self.comment=comment
        self.noOfReply=noOfReply
        self.opinion = opinion
        self.isEditable = isEditable
    }
}
