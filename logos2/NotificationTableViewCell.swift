//
//  NotificationTableViewCell.swift
//  logos2
//
//  Created by Mansi on 23/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var authorEndorsment: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

