//
//  ReplyTableViewCell.swift
//  logos2
//
//  Created by SAGAR  GAIKWAD  on 22/08/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {


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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
