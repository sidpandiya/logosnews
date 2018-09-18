//
//  AuthorKnowsAboutTableViewCell.swift
//  logos2
//
//  Created by subodh-mac on 21/06/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class AuthorKnowsAboutTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var yellowStarIcon: subscrbeButton!
    @IBOutlet weak var starIcon: subscrbeButton!
    @IBOutlet weak var endorsmentPoints: UILabel!
    @IBOutlet weak var endorsmentTitle: UILabel!
    @IBOutlet weak var endorsmentLogo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
