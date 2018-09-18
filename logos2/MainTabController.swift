//
//  MainTabController.swift
//  logos2
//
//  Created by Mansi on 16/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

class MainTabController : UITabBarController{
    enum tabBarMenu: Int {
        case globe
        case news
        case post
        case notif
        case profile
    }
    // initialization of parameters
    var Data = (cityLat:0.0,cityLong:0.0)

    // MARK: UITabBarController
    override func viewDidLayoutSubviews() {
        let tabHeight = self.tabBarController?.tabBar.frame.height
        let itemHeight = CGFloat(22.0)
        guard let tabBarMenuItem = tabBarMenu(rawValue: 0)
            else { return }
        let greyprof = scaleUIImageToSize(image: UIImage(named: "greyprof")!, size: CGSize(width: 1.05 * itemHeight, height: itemHeight))
        let greyplus = scaleUIImageToSize(image: UIImage(named: "greyplus")!, size: CGSize(width: itemHeight, height: itemHeight))
        let greynotif = scaleUIImageToSize(image: UIImage(named: "greynotif")!, size: CGSize(width: 0.82 * itemHeight, height: itemHeight))
        let greynewsfeed = scaleUIImageToSize(image: UIImage(named: "greynewsfeed")!, size: CGSize(width: itemHeight, height: itemHeight))
        let whiteprof = scaleUIImageToSize(image: UIImage(named: "whiteprof")!, size: CGSize(width: 1.05 * itemHeight, height: itemHeight))
        let whiteplus = scaleUIImageToSize(image: UIImage(named: "whiteplus")!, size: CGSize(width: itemHeight, height: itemHeight))
        let whitenotif = scaleUIImageToSize(image: UIImage(named: "whitebell")!, size: CGSize(width:  0.82 * itemHeight, height: itemHeight))
        let whitenewsfeed = scaleUIImageToSize(image: UIImage(named: "whitenewsfeed")!, size: CGSize(width: itemHeight, height: itemHeight))
        tabBar.items![2].image = greynotif
        tabBar.items![0].image = greynewsfeed
        tabBar.items![1].image = greyplus
        tabBar.items![3].image = greyprof
        
        tabBar.items![2].selectedImage = whitenotif
        tabBar.items![0].selectedImage = whitenewsfeed
        tabBar.items![1].selectedImage = whiteplus
        tabBar.items![3].selectedImage = whiteprof
        loadNotifications()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
             print("hi m here got citydate  in maintab controller \(Data.cityLat)")
        self.Data.cityLong=Data.cityLong
        self.Data.cityLat=Data.cityLat
        
      
        
     /*  setTintColor(forMenuItem: tabBarMenuItem)
        NotificationCenter.default.addObserver(self, selector: #selector(setToAlert(notfication:)), name: NSNotification.Name(rawValue: "alertbell"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setBell(notfication:)), name: NSNotification.Name(rawValue: "bell"), object: nil)
         */
    }
    func loadNotifications(){
        print("in loadNotifications function")
        var userData = UserDefaults.standard
        var userId = userData.object(forKey: "userId")
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("userNotification").queryOrdered(byChild: "toUser").queryEqual(toValue: userId).observe(.value, with: {(notificationDataSnap) in
            var totalNotif = 0
            if(notificationDataSnap.exists()){
                var counter = 0
                for noti in notificationDataSnap.children.reversed(){
                    counter = counter + 1
                    let notiSnap = noti as! DataSnapshot
                    let notifDict = notiSnap.value as! [String:Any]
                    let notiId = notiSnap.key
                    var isRead = false
                    if(notifDict["isRead"] != nil){
                        isRead = notifDict["isRead"] as! Bool
                    }
                }
                totalNotif = counter
                let numNotifs = UserDefaults.standard.object(forKey: "numNotifs") as? Int ?? 0
                
                if totalNotif > numNotifs{
                    let orangebell = UIImage(named: "alertbell")?.withRenderingMode(.alwaysTemplate)
                    let orangenotif = scaleUIImageToSize(image: orangebell!, size: CGSize(width: 23, height: 23))
                    let newOrange = orangenotif.tabBarImageWithCustomTint(tintColor: UIColor.orange)
                    self.tabBar.items![2].image = newOrange
                    self.tabBar.items![2].badgeValue = String(totalNotif - numNotifs)
               //      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notif"), object: nil)
                    changeBell.bell = true
                    
                }
                print("THIS IS NUM", UserDefaults.standard.object(forKey: "numNotifs"), totalNotif)
            }
            else{
                print("Notifications not available")
            }
        }){(notificationError) in
            print("ERROR : Error in fech notificatio \(notificationError.localizedDescription)")
        }
        
    }

 /*   override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard
            let menuItemSelected = tabBar.items?.index(of: item),
            let tabBarMenuItem = tabBarMenu(rawValue: menuItemSelected)
            else { return }
        
        setTintColor(forMenuItem: tabBarMenuItem)
    }
   

    @objc func setToAlert(notfication: NSNotification) {
        let notifcolor = hexStringToUIColor(hex: "#FF6B0F")
        viewControllers?[tabBarMenu.notif.rawValue].tabBarController?.tabBar.tintColor = notifcolor
          changeBell.bell = true;
    }
    @objc func setBell(notfication: NSNotification) {
        let notifcolor = hexStringToUIColor(hex: "#FF6B0F")
         let tabcolor = hexStringToUIColor(hex: "#5AC8FA")
        viewControllers?[tabBarMenu.notif.rawValue].tabBarController?.tabBar.tintColor = tabcolor
        changeBell.bell = false;
        
    }
    */
  /*  func setTintColor(forMenuItem tabBarMenuItem: tabBarMenu) {
        let tabcolor = hexStringToUIColor(hex: "#5AC8FA")
        let notifcolor = hexStringToUIColor(hex: "#FF6B0F")
        switch tabBarMenuItem {
            
        case .globe:
                viewControllers?[tabBarMenuItem.rawValue].tabBarController?.tabBar.tintColor = tabcolor
            
        case .news:
                viewControllers?[tabBarMenuItem.rawValue].tabBarController?.tabBar.tintColor = tabcolor
            
        case .post:
                viewControllers?[tabBarMenuItem.rawValue].tabBarController?.tabBar.tintColor = tabcolor
            
        case .notif:
           viewControllers?[tabBarMenuItem.rawValue].tabBarController?.tabBar.tintColor = tabcolor
         
            
        case .profile:
        viewControllers?[tabBarMenuItem.rawValue].tabBarController?.tabBar.tintColor = tabcolor
        
        }
    }
 
    
  
 }*/
}
extension UIImage {
    func tabBarImageWithCustomTint(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        newImage = newImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        return newImage
    }
}
