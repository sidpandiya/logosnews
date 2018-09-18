//
//  NewsTableViewCell.swift
//  logos2
//
//  Created by subodh-mac on 20/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsLabel: UILabel!

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsId: UITextField!
    @IBOutlet weak var newsAuthorProfileImage: UIImageView!
    @IBOutlet weak var newsAuthorKnowsAbout: UILabel!
    // components from customised cell @Author subodh3344

    
    @IBOutlet weak var newsDisagreeCount: UILabel!
    @IBOutlet weak var newsNeutralCount: UILabel!
    @IBOutlet weak var newsAgreeCount: UILabel!
    @IBOutlet weak var newsLRSlider: UISlider!
    @IBOutlet weak var newsTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
