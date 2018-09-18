//
//  CommentsTableViewCell.swift
//  logos2
//
//  Created by Mansi on 04/06/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var commentProfileImage: UIImageView!
    @IBOutlet weak var comment: UILabel!
    
    @IBOutlet weak var commentBox: UIView!
    @IBOutlet weak var noOfReplies: UILabel!
    @IBOutlet weak var commentEndorsement: UILabel!
    @IBOutlet weak var commentName: UILabel!
    @IBOutlet weak var commentTime: UILabel!
    
    @IBOutlet weak var opinionColor: UIView!
    

    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var edit: editCommentButton!
    @IBOutlet weak var isEdited: UILabel!
    @IBOutlet weak var replyToComment: UIButton!
    
    @IBOutlet weak var agreesOnComment: UIButton!
    
    @IBOutlet weak var neutralsOnComment: UIButton!
    
    @IBOutlet weak var disagreesOnComment: UIButton!
    
    @IBOutlet weak var commentWidth: NSLayoutConstraint!
    
    let imgUser = UIImageView()
    let labUerName = UILabel()
    let labMessage = UILabel()
    let labTime = UILabel()
    var replyTableView = UITableView()
    var replyData=[ReplyData]()
    let commentCellIdentifier = "CommentsTableViewCell"
    let replyCellIdentifier = "ReplyTableViewCell"
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /*
 func setupTable(){
 self.replyTableView = UITableView.init()
 self.replyTableView.frame=CGRect(x:0.2,y:50,width:self.bounds.size.width, height:500)
 //self.replyTableView.frame.height = self.replyTableView.contentSize.height
 self.replyTableView.dataSource=self
 self.replyTableView.delegate=self
 self.replyTableView.rowHeight=UITableViewAutomaticDimension
 self.replyTableView.estimatedRowHeight=250
 self.replyTableView.register(ReplyTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
 self.addSubview(self.replyTableView)
 }
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
 return replyData.count
 }
 
 func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
 return UITableViewAutomaticDimension
 }
 
 // reply table
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 // <#code#>
 print("in tablview Functions")
 guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as?
 ReplyTableViewCell
 else{
 fatalError("error")
 }
 let comment=replyData[indexPath.row]
 print("name \(comment.authorName)")
 cell.authorName.text=comment.authorName
 cell.authorEndorsment.text=comment.authorEndorsment
 cell.authorProfileImage.image=comment.authorImage
 cell.comment.text=comment.comment
 cell.noOfReply.text=comment.noOfReply
 let replyButton = UIButton.init()
 replyButton.frame=CGRect(x: cell.frame.origin.x+10, y: 0, width: 64, height: 64)
 replyButton.setTitle("Reply", for: .normal)
 //replyButton.addTarget(self, action:#selector(self.comments), for: .touchUpInside)
 cell.addSubview(replyButton)
 let flagButton = UIButton.init()
 flagButton.frame=CGRect(x:cell.frame.width - 20,y:0,width:60, height:60)
 flagButton.setImage(UIImage(named:"flag"), for: .normal)
 // flagButton.addTarget(self, action: #selector(self.reportComments), for: .touchUpInside)
 cell.addSubview(flagButton)
 if comment.opinion == 0 {
 cell.backgroundColor = UIColor.blue
 }
 else if comment.opinion == 1 {
 cell.backgroundColor = UIColor.green
 }
 else if comment.opinion == 2 {
 cell.backgroundColor = UIColor.red
 }
 
 return cell
 }
 func loadComments(){
 print("in loadComments")
 
 }
*/
  
}

