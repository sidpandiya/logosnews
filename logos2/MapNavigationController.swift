//
//  mapnNavigationController.swift
//  logos2
//
//  Created by SHIRLY Fang on 5/9/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
class mapNavigationController: UINavigationController
{
  
    @IBOutlet weak var nav: UINavigationBar!
    
    override func viewDidLoad() {
    
  nav.setBackgroundImage(UIImage(), for: .default)
   nav.shadowImage = UIImage()
    nav.isTranslucent = true
    view.backgroundColor = .clear
    
    }
  
    
    
    
    
}
