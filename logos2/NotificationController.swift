//
//  newNotificationController.swift
//  logos2
//
//  Created by SHIRLY Fang on 5/4/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Toast_Swift
import SwiftyJSON
import FirebaseDatabase
import SwiftMoment
struct changeBell{
    static var bell = false
}
class newNotificationController : UIViewController, UITableViewDataSource, UITableViewDelegate

{
   
    @IBOutlet weak var refreshbutton: UIButton!
   
    @IBOutlet weak var shadow1: UIView!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var newBell: UITabBarItem!
    @IBOutlet weak var header: UIView!
    
    var userId: String = ""
    var notification=[newNotification]()
    let cellIdentifier="newNotificationCell"
    
    var loadingCompleted = false;
    var isFirstLoad = true;
    var newid : String!
    
    var gotNewsId : String!
     let defaultImageUrl : String = "https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/default_news_image.png?alt=media&token=293cd97b-77a4-4c4d-91df-f1c03fc1cc0e"
    // for pull to refresh
    private let refreshController = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeBell.bell = false
        let whitenotif = scaleUIImageToSize(image: UIImage(named:"whitebell")!, size: CGSize(width: 18, height: 22))
        let greynotif = scaleUIImageToSize(image: UIImage(named: "greynotif")!, size: CGSize(width: 18, height: 22))
        if(changeBell.bell == false)
        {
            newBell.selectedImage = whitenotif
            newBell.image = greynotif
            
        }
        newBell.badgeValue = nil 
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait 
        //let refreshcolor = hexStringToUIColor(hex:"#5AC8FA") //blue
        //let origImage = UIImage(named: "refresh1")
        //let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        //refreshbutton.setImage(tintedImage, for: .normal)
        //refreshbutton.tintColor = refreshcolor
        table.separatorStyle = .none
     /*   shadow1.layer.masksToBounds = false
        shadow1.layer.shadowColor = UIColor.darkGray.cgColor
        shadow1.layer.shadowOpacity = 0.6;
        shadow1.layer.shadowOffset = CGSize.zero
        shadow1.layer.shadowRadius = 4
*/
        
        // for pull to refresh
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshController
        } else {
            table.addSubview(refreshController)
        }
        refreshController.addTarget(self, action: #selector(refreshNotificationData(_:)), for: .valueChanged)
        //call n first load
        let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getNotifications"
        var userData = UserDefaults.standard
        var userId = userData.object(forKey: "userId")
        let data = ["userId":"\(userId as! String)","start":0,"offset":10] as [String : Any]
        self.notification.removeAll()
        self.table.reloadData()
        print("calling fetch News with data \(data)")
       // self.fetchNotifications(url: url, data: data)
        self.table.delegate = self
        self.table.dataSource = self
        //loadSample()
        
        self.loadNotifications()
        
    }
    
    
    
    /*Function to load user's notifications @Author subodh3344 */
    func loadNotifications(){
        print("in loadNotifications function")
        var userData = UserDefaults.standard
        var userId = userData.object(forKey: "userId")
        self.notification.removeAll()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("userNotification").queryOrdered(byChild: "toUser").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: {(notificationDataSnap) in
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
                    UserDefaults.standard.set(counter, forKey: "numNotifs")
                    
                    print("got not \(notifDict)")
                    let fromUser = notifDict["fromUser"] as! String
                    let userQuery = ref.child("user").child(fromUser).observe(.value, with: {(userSnapshot) in
                        print(userSnapshot)
                        let userDict = userSnapshot.value as! NSDictionary
                        let fromUserName = userDict["name"] as! String // we need this
                        let fromUserPhotoString = userDict["photo"] as! String
                        let userImageUrl : URL = URL(string:fromUserPhotoString)!
                        let userImageData : NSData = NSData(contentsOf:userImageUrl)!
                        let fromUserImage = UIImage(data:userImageData as Data) // we need this
                        let newsdate = notifDict["createdOn"] as! String
                        let clippedDate = newsdate.prefix(10)
                        let year = clippedDate.prefix(4)
                        let startMonth = clippedDate.index((clippedDate.startIndex), offsetBy: 5)
                        let endMonth = clippedDate.index((clippedDate.endIndex), offsetBy: -3)
                        let monthRange = startMonth..<endMonth
                        let subMonth = clippedDate[monthRange] // month
                        let month = String(subMonth)
                        let day = clippedDate.suffix(2)
                        var createdOn = moment(notifDict["createdOn"] as! String)?.fromNow()
                        let timeText = createdOn as! String
                        //counter = counter + 1
                        guard let noti9=newNotification(
                            name:fromUserName as! String,
                            details: notifDict["body"] as! String,
                            time: timeText,
                            endorsment: userDict["highEndorsmentName"] as! String,
                            photo: fromUserImage as! UIImage,
                            id :notiId as! String,
                            title:notifDict["title"] as! String,
                            type:notifDict["type"] as! Int,
                            newsId:notifDict["newsId"] as! String,
                            fromUserId: notifDict["fromUser"] as! String,
                            isRead : isRead
                            )
                            else{
                                fatalError("error")
                        }
                        self.notification.append(noti9)
                        print("noti is \(self.notification)")
                        print("counter == notificationDataSnap.childrenCount is \(counter) == \(notificationDataSnap.childrenCount)")
                        if counter == notificationDataSnap.childrenCount {
                            print("reloading data")
                            self.table.reloadData()
                            // for pull to refresh
                            self.updateView()
                            self.refreshController.endRefreshing()
                            
                            //self.hideLoading()
                            self.loadingCompleted = true
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    
                }
                
            }
            else{
                print("Notifications not available")
            }
            
            
        }){(notificationError) in
            print("ERROR : Error in fech notificatio \(notificationError.localizedDescription)")
        }
        
    }
    
    

    // for pull to refresh
    private func updateView() {
        let hasDays = self.notification.count > 0
        table.isHidden = !hasDays
        
        
        if hasDays {
            table.reloadData()
        }
    }
    
    @objc private func refreshNotificationData(_ sender: Any) {
        self.notification.removeAll()
        self.loadNotifications()
    }
    
    
    @objc private func refreshNotificationDataOld(_ sender: Any) {
        // Fetch Weather Data
        let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getNotifications"
        var userData = UserDefaults.standard
        var userId = userData.object(forKey: "userId")
        let data = ["userId":"\(userId as! String)","start":0,"offset":10] as [String : Any]
        self.notification.removeAll()
        self.table.reloadData()
        print("calling fetch News with data \(data)")
        self.fetchNotifications(url: url, data: data)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
 func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notification.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as?
            newNotificationCell 
            else{
                fatalError("error")
        }
        let color1 = hexStringToUIColor(hex:"#8E8E93")// gray
        let notifcolor = hexStringToUIColor(hex: "#FF6B0F")
        // Configure the cell...
        let noti=notification[indexPath.row]
        print("name \(noti.name)")
        let firstNameOnly = noti.name.components(separatedBy: " ")
        cell.name.text = firstNameOnly[0]
        cell.photo.image=noti.photo
        cell.endorsement.text=noti.endorsment
        cell.details.text=noti.details
        cell.time.text=noti.time
        cell.endorsement.textColor = color1
        cell.time.textColor = color1;
        cell.endorsement.adjustsFontSizeToFitWidth = true
        cell.name.adjustsFontSizeToFitWidth = true
        
        if(!noti.isRead){
            cell.notifbar.backgroundColor = notifcolor
        }
        else{
            cell.notifbar.backgroundColor = hexStringToUIColor(hex:"#ffffff")
        }
        
   /*     cell.shadow.layer.masksToBounds = false
        cell.shadow.layer.shadowColor = UIColor.darkGray.cgColor
        cell.shadow.layer.shadowOpacity = 20;
        cell.shadow.layer.shadowOffset = CGSize.zero
        cell.shadow.layer.shadowRadius = 5;*/
        
        cell.photo.layer.borderWidth = 0.5
        cell.photo.layer.masksToBounds = false
        cell.photo.layer.borderColor = UIColor.lightGray.cgColor
        cell.photo.layer.cornerRadius = cell.photo.frame.height/2
        cell.photo.clipsToBounds = true
        let tap = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
        tap.id = noti.fromUserId
        let tap2 = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
        tap2.id = noti.fromUserId
        cell.name.addGestureRecognizer(tap)
        cell.photo.addGestureRecognizer(tap2)
        
        if (indexPath.row == 0)
        {
            cell.shadow.backgroundColor = UIColor.white
            
            
        }
        
        return cell
    }
    
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     
     */
    
    /*Notification list
     need to fetch from datbase
     */
    
    
    
    /*Function to show pop up on click of notification */
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell=tableView.cellForRow(at: indexPath!)as! newNotificationCell
        if currentCell.notifbar.isHidden == false {
            currentCell.notifbar.isHidden = true 
        }
        ///////////////////////////////////////////////
        let selectedNotification = notification[(indexPath?.row)!]
        print("selected notification id is \(selectedNotification.id)")
        //  to update read flag of notification @Author subodh3344
        ref.child("userNotification").child(selectedNotification.id as! String).updateChildValues(["isRead":true])
        
        
        self.newid=selectedNotification.newsId
        print("news id is \(self.newid)")
        self.gotNewsId = selectedNotification.newsId
        let details=currentCell.details?.text
        
        let msg = details!
        
        print("selectedNotification.type \(self.newid)")
        if selectedNotification.type as! Int == 2 || selectedNotification.type as! Int == 6 {
            print("in if ")
            //loading sign
            var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            indicator.center = view.center
            self.view.addSubview(indicator)
            self.view.bringSubview(toFront: indicator)
            indicator.startAnimating()
            // performSegue(withIdentifier: "showDetails", sender: self)
            //  fetch news info Optimization @Author subodh3344
            //fetch news
            ref.child("posts").child(self.gotNewsId).observeSingleEvent(of: .value, with: {(gotNewsSnap) in
                if(gotNewsSnap.exists()){
                    let gotNewsDict = gotNewsSnap.value as![String:Any]
                    let postedByUser = gotNewsDict["userId"] as! String
                    // fetch user
                    ref.child("user").child(postedByUser).observeSingleEvent(of: .value, with: {(postedByUserSnap) in
                        if(postedByUserSnap.exists()){
                            let postedByUserDict = postedByUserSnap.value as! [String:Any]
                            // fetch reacts
                            
                            
                            let mediaImage : UIImage
                            let newsmediaImage : UIImage
                            
                            let newsImageUrl:URL = URL(string:gotNewsDict["media"] as! String)!
                            let mediaImageData:NSData = NSData(contentsOf : newsImageUrl)!
                            mediaImage = UIImage(data:mediaImageData as Data)!
                            
                            let userImage : UIImage
                            let userImageUrl:URL = URL(string:postedByUserDict["photo"] as! String)!
                            let userImageData:NSData = NSData(contentsOf: userImageUrl)!
                            userImage = UIImage(data:userImageData as Data)!
                            
                            var neutralCount = 0
                            var agreeCount = 0
                            var disAgreeCount = 0
                            
                             var newsLrCount:Float = 0.0
                            
                            ref.child("postreacts").queryOrdered(byChild: "postId").queryEqual(toValue: self.gotNewsId).observeSingleEvent(of: .value, with: {(gotPostReactsSnap) in
                                if(gotPostReactsSnap.exists()){
                                    var reactCount = 0
                                   
                                    for postReacts in gotPostReactsSnap.children{
                                        reactCount = reactCount + 1
                                        let reactSnap = postReacts as! DataSnapshot
                                        let reactDict = reactSnap.value as! [String:Any]
                                        switch(reactDict["openion"] as! String){
                                        case "0" :
                                            // Neutral
                                            neutralCount = neutralCount + 1
                                            break;
                                        case "1" :
                                            // Agree
                                            agreeCount = agreeCount + 1
                                            break;
                                        case "2":
                                            // DisAgree
                                            disAgreeCount = disAgreeCount + 1
                                            break;
                                        default:
                                            break;
                                        }
                                        if(reactCount == gotPostReactsSnap.childrenCount){
                                            // loop completed
                                           
                                            
                                            // fetch news LR count
                                            ref.child("newslrcount").queryOrdered(byChild: "newsId").queryEqual(toValue: self.gotNewsId).observeSingleEvent(of: .value, with: {(newsLrSnap) in
                                               
                                                if(newsLrSnap.exists()){
                                                    var lrCount = 0
                                                    for lrSnap in newsLrSnap.children{
                                                        lrCount = lrCount + 1
                                                        let dataSnap = lrSnap as! DataSnapshot
                                                        let dataDict = dataSnap.value as! [String:Any]
                                                        let gotLrFloat : Float = dataDict["Rcount"] as! Float
                                                        newsLrCount = newsLrCount + gotLrFloat
                                                        if(lrCount == newsLrSnap.childrenCount){
                                                            let total : Float = newsLrSnap.childrenCount as! Float
                                                            let finalLrCount = newsLrCount/total
                                                            print("final lrcount is \(finalLrCount)")
                                                            guard let newDataForView = newzListData(
                                                                userName:postedByUserDict["name"] as! String ,
                                                                userEndorsment:postedByUserDict["highEndorsmentName"] as! String,
                                                                userProfileImage:userImage,
                                                                newsImage: mediaImage,
                                                                newsTitle:gotNewsDict["title"] as! String,
                                                                agreeCount:agreeCount,
                                                                disAgreeCount:disAgreeCount,
                                                                nutralCount:neutralCount,
                                                                minBiasedValue:finalLrCount ,
                                                                id:self.gotNewsId as! String,
                                                                time: "2min" as! String,
                                                                AuthorId: postedByUserSnap.key
                                                                )else{
                                                                    fatalError("Error while creating newsDataForView")
                                                            }
                                                            
                                                            indicator.stopAnimating()
                                                            let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"ArticleViewController") as! ArticleViewController
                                                            mainTabController.id=self.gotNewsId
                                                            mainTabController.news = newDataForView
                                                            
                                                            self.present(mainTabController, animated: true, completion: nil)
                                                        }
                                                    }
                                                }
                                                else{
                                                    // no lr count present
                                                    guard let newDataForView = newzListData(
                                                        userName:postedByUserDict["name"] as! String ,
                                                        userEndorsment:postedByUserDict["highEndorsmentName"] as! String,
                                                        userProfileImage:userImage,
                                                        newsImage: mediaImage,
                                                        newsTitle:gotNewsDict["title"] as! String,
                                                        agreeCount:agreeCount,
                                                        disAgreeCount:disAgreeCount,
                                                        nutralCount:neutralCount,
                                                        minBiasedValue:newsLrCount ,
                                                        id:self.gotNewsId as! String,
                                                        time: "2min" as! String,
                                                        AuthorId: postedByUserSnap.key
                                                        )else{
                                                            fatalError("Error while creating newsDataForView")
                                                    }
                                                    
                                                    indicator.stopAnimating()
                                                    let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"ArticleViewController") as! ArticleViewController
                                                    mainTabController.id=self.gotNewsId
                                                    mainTabController.news = newDataForView
                                                    
                                                    self.present(mainTabController, animated: true, completion: nil)
                                                }
                                                
                                            }){(newsLRError) in
                                                print("ERROR : error in fetch news Lr count in notification controller \(newsLRError.localizedDescription)")
                                            }
                                        }
                                        
                                    }
                                }
                                else{
                                    // no post reacts available
                                    guard let newDataForView = newzListData(
                                        userName:postedByUserDict["name"] as! String ,
                                        userEndorsment:postedByUserDict["highEndorsmentName"] as! String,
                                        userProfileImage:userImage,
                                        newsImage: mediaImage,
                                        newsTitle:gotNewsDict["title"] as! String,
                                        agreeCount:agreeCount,
                                        disAgreeCount:disAgreeCount,
                                        nutralCount:neutralCount,
                                        minBiasedValue:newsLrCount ,
                                        id:self.gotNewsId as! String,
                                        time: "2min" as! String,
                                        AuthorId: postedByUserSnap.key
                                        )else{
                                            fatalError("Error while creating newsDataForView")
                                    }
                                    
                                    indicator.stopAnimating()
                                    let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"ArticleViewController") as! ArticleViewController
                                    mainTabController.id=self.gotNewsId
                                    mainTabController.news = newDataForView
                                    
                                    self.present(mainTabController, animated: true, completion: nil)
                                }
                                
                            }){(postReactError) in
                                print("ERROR : Error while fetching news reacts \(postReactError.localizedDescription)")
                            }
                        }
                        else{
                            print("Posted by user snap doesnt exists for user id \(postedByUser)")
                        }
                    }){(fetchUserError) in
                        print("ERROR : error in fetch user in notification controller \(fetchUserError.localizedDescription)")
                    }
                }
                else{
                    print("news doesnt exixts for news id \(self.gotNewsId)")
                }
            
            }){(fetchNewsError) in
                print("ERROR : Error while fetching news in notification controller \(fetchNewsError.localizedDescription)")
            }
        }
        else{
            print("in didselected function \(msg)")
            let alertController = UIAlertController(title: selectedNotification.title, message: msg , preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        
        
        
    }
    
    func fetchNotifications(url : String , data : Any){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var notificationsRef = ref.child("userNotification")
        
        //self.showLoading()
        print("in fetch notifications ")
        
        notificationsRef.observeSingleEvent(of: .value, with: { (notifsSnapshot) in
            // Get user value
            var allNotifs = notifsSnapshot.value as? NSDictionary
            allNotifs = allNotifs?.reversed() as? NSDictionary
            if (allNotifs == nil)  {
                self.showToaster(msg: "No notifications found", type: 0)
                return
            }
            var userData = UserDefaults.standard
            var userId = userData.object(forKey: "userId") as! String
            var counter = 0 as! Int
            for(randomID, singleNotif) in allNotifs!
            {
                print("the current notification is: ")
                print(singleNotif)
                let notifDict = singleNotif as! [String:Any]
                print("userID is: ")
                print(notifDict["toUser"])
                let fromUser = notifDict["fromUser"] as! String
                if(notifDict["toUser"] as! String == userId)
                {
                    let userQuery = ref.child("user").child(fromUser).observe(.value, with: {(userSnapshot) in
                        print(userSnapshot)
                        let userDict = userSnapshot.value as! NSDictionary
                        let fromUserName = userDict["name"] as! String // we need this
                        let fromUserPhotoString = userDict["photo"] as! String
                        let userImageUrl : URL = URL(string:fromUserPhotoString)!
                        let userImageData : NSData = NSData(contentsOf:userImageUrl)!
                        let fromUserImage = UIImage(data:userImageData as Data) // we need this
                        let newsdate = notifDict["createdOn"] as! String
                        let clippedDate = newsdate.prefix(10)
                        let year = clippedDate.prefix(4)
                        let startMonth = clippedDate.index((clippedDate.startIndex), offsetBy: 5)
                        let endMonth = clippedDate.index((clippedDate.endIndex), offsetBy: -3)
                        let monthRange = startMonth..<endMonth
                        let subMonth = clippedDate[monthRange] // month
                        let month = String(subMonth)
                        let day = clippedDate.suffix(2)
                        var createdOn = moment(notifDict["createdOn"] as! String)?.fromNow()
                        let timeText = "1d" //createdOn as! String
                        counter = counter + 1
                        guard let noti9=newNotification(
                            name:fromUserName as! String,
                            details: notifDict["body"] as! String,
                            time: timeText,
                            endorsment: userDict["highEndorsmentName"] as! String,
                            photo: fromUserImage as! UIImage,
                            id :randomID as! String,
                            title:notifDict["title"] as! String,
                            type:notifDict["type"] as! Int,
                            newsId:notifDict["newsId"] as! String,
                            fromUserId: notifDict["fromUser"] as! String,
                            isRead : false
                            )
                            else{
                                fatalError("error")
                        }
                        self.notification.append(noti9)
                        if counter == self.notification.count {
                            self.table.reloadData()
                            // for pull to refresh
                            self.updateView()
                            self.refreshController.endRefreshing()
                            
                            //self.hideLoading()
                            self.loadingCompleted = true
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                }
                
            }
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
//        let getAllNotiUrl = URL(string:url)
//        var getAllnotiRequest = URLRequest(url:getAllNotiUrl!)
//        getAllnotiRequest.httpMethod = "POST"
//        let json = data
//        print("json \(json)")
//        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//        getAllnotiRequest.httpBody = jsonData
//        getAllnotiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let getNotiTask=URLSession.shared.dataTask(with: getAllnotiRequest){(data:Data?,response:URLResponse?,error:Error?) in
//            if(error != nil){
//                print("error in fetchNews \(error)")
//                DispatchQueue.main.async () {
//                  //  self.hideLoading()
//                }
//            }
//            do{
//                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
//
//                    if(jsonObj != nil){
//                        let code=jsonObj!.value(forKey: "code") as! Int
//                        print("in do \(code)")
//                        // returned success code
//                        if(code == 1){
//                            var counter = 0
//                            DispatchQueue.main.async {
//                                if let notiDataArray = jsonObj!.value(forKey: "data") as? NSArray {
//                                    for noti in notiDataArray{
//                                        if let notiData = noti as? NSDictionary {
//                                            var userImgUrl :String="";
//
//                                            if(notiData.value(forKey: "userPhoto") != nil){
//                                                userImgUrl = notiData.value(forKey: "userPhoto") as! String
//                                            }
//                                            else{
//                                                userImgUrl = self.defaultImageUrl
//                                            }
//                                            //              print("user image url \(userImgUrl)")
//                                            let userImageUrl : URL = URL(string:userImgUrl)!
//                                            let userImageData : NSData = NSData(contentsOf:userImageUrl)!
//                                            let userImage = UIImage(data:userImageData as Data)
//                                            counter = counter + 1
//                                            guard let noti9=newNotification(
//                                                    name:notiData.value(forKey: "userName") as! String,
//                                                    details: notiData.value(forKey: "notiBody") as! String,
//                                                    time: notiData.value(forKey: "timeago") as! String,
//                                                    endorsment: notiData.value(forKey: "userHighEndorsment") as! String,
//                                                    photo: userImage as! UIImage,
//                                                    id :notiData.value(forKey: "notiId")as! String,
//                                                    title:notiData.value(forKey: "notiTitle")as! String,
//                                                    type:notiData.value(forKey: "type")as! Int,
//                                                    newsId:notiData.value(forKey: "newsId")as! String
//                                                )
//                                                else{
//                                                fatalError("error")
//
//
//                                            }
//
//                                            self.notification.append(noti9)
//                                            // self.newsData.append(news2)
//                                            print("Count \(counter)")
//                                            print("self.notification.count \(self.notification.count)")
//                                            if(counter == self.notification.count){
//                                                DispatchQueue.main.async () {
//                                                    self.table.reloadData()
//                                                    // for pull to refresh
//                                                    self.updateView()
//                                                    self.refreshController.endRefreshing()
//
//                                                    //self.hideLoading()
//                                                    self.loadingCompleted = true
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                                        self.isFirstLoad = false
//                                                    }
//                                                }
//                                            }
//                                                 //   print("news data is \(self.notification)")
//
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        else{
//                            if(code == 2){
//                                DispatchQueue.main.async () {
//                                    self.showToaster(msg:"\(jsonObj!.value(forKey: "msg") as! String)",type: 0)
//                                    self.table.reloadData()
//                                   // self.hideLoading()
//                                }
//
//                            }
//                        }
//                    }
//                }
//
//            }catch let error as NSError{
//                print("Error in get posts url \(error.localizedDescription)")
//                DispatchQueue.main.async () {
//                   // self.hideLoading()
//                }
//            }
//        }
//        getNotiTask.resume()
    }
    // lazy loading function
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("loadingData is : \(loadingCompleted) indexPath is : \(indexPath.row) and newsFinal count : \(notification.count)")
        if(indexPath.row == notification.count-1 && loadingCompleted && !isFirstLoad){
            print("call refresh")
            self.refreshData(id: self.notification[indexPath.row].id)
        }
        //        if !loadingData && indexPath.row == newsFinalData.count-1{
        //            loadingData=true;
        //            self.refreshData(id: self.newsFinalData[indexPath.row].id)
        //        }
        
    }
    func refreshData(id:String){
        print("in refresData function")
        DispatchQueue.main.async {
            let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getNotifications"
            var userData = UserDefaults.standard
            var userId = userData.object(forKey: "userId")
            let data = ["userId":"\(userId as! String)","start":id,"offset":10] as [String : Any]
            //self.notification.removeAll()
            //self.table.reloadData()
            print("calling fetch notification in refreshdata function with data \(data)")
            self.fetchNotifications(url: url, data: data)
            
            self.loadingCompleted=false
            
        }
    }
    
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    func hideLoading(){
       // self.activityIndicator.stopAnimating()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("segue.identifier \(segue.identifier)")
        switch (segue.identifier ?? "") {
        case "authorDetails":
            //   os_log("show news details",log:OSLog.default,type:.debug)
            guard let articleController = segue.destination as? AuthorDetailsViewController else{
                fatalError("unexpected destination :\(segue.destination)")
            }
            articleController.userId=self.userId
        default:
            print("defualt case")
            fatalError("unexpected segue indentiifer \(segue.identifier)")
            //default case
        }
    }

    @objc func goTOAuthorDetails(_sender:labelGesture1){
        var id=_sender.id
        print("id \(id)")
        self.userId=id
        performSegue(withIdentifier: "authorDetails", sender: self)
        // fromViewController.performSegueWithIdentifier("segue_id", sender: fromViewController)
    }
}

