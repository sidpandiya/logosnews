//
//  KnowsAboutTableViewCell.swift
//  logos2
//
//  Created by Mansi on 24/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class KnowsAboutTableViewCell: UITableViewCell {

    //@IBOutlet weak var kaIcon: UIImageView!
  
    
    @IBOutlet weak var endorsementPoints: UILabel!
    @IBOutlet weak var endorsmentName: UILabel!
    // @IBOutlet weak var endorsementPoints: UILabel!
    @IBOutlet weak var kaIcon: UIImageView!
   // @IBOutlet weak var endorsmentName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
