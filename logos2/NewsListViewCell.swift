
//
//  NewsListViewCell.swift
//  logos2
//
//  Created by కార్తీక్ సూర్య on 5/6/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class NewsListViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var articleCategory: UILabel!
    @IBOutlet weak var cellBound: UIView!
    @IBOutlet weak var lrCountSlider : UISlider!
    @IBOutlet weak var newsId: UILabel!
    @IBOutlet weak var rCountSlider: UISlider!
    @IBOutlet weak var newsAgreeCountText: UILabel!
    @IBOutlet weak var newsDisAgreeCountText: UILabel!
    @IBOutlet weak var newsNeutralCountText: UILabel!
    @IBOutlet weak var time: UILabel!
    /*
    var mainImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
     
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
