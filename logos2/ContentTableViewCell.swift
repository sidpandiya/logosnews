//
//  ContentTableViewCell.swift
//  logos2
//
//  Created by Katherine Miao on 5/12/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photo:UIImageView!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var time:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //let photo1=UIImage(named:"user25")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
