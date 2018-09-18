//
//  CredentialsViewCell.swift
//  logos2
//
//  Created by Mansi on 23/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class CredentialsViewCell: UITableViewCell {

    @IBOutlet weak var crName: UILabel!
    @IBOutlet weak var crIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
