//
//  newNotificationCell.swift
//  logos2
//
//  Created by SHIRLY Fang on 5/4/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit

class newNotificationCell : UITableViewCell
{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var endorsement: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var notifbar: UIView!
    @IBOutlet weak var shadow: UIView!
    @IBOutlet weak var photo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //  super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
