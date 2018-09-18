//
//  MapListTableViewCell.swift
//  logos2
//
//  Created by Mansi on 26/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class MapListTableViewCell: UITableViewCell {
    @IBOutlet weak var disagreeCount: UILabel!
    @IBOutlet weak var nutralCount: UILabel!
    @IBOutlet weak var agreeCount: UILabel!
    @IBOutlet weak var baiseedCount: UISlider!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var userEndorsment: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var id: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
