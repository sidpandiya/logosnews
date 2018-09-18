//
//  UserProfileViewController.swift
//  logos2
//
//  Created by Mansi on 17/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Toast_Swift
import FirebaseDatabase

class UserProfileViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate {
    
    var creadentials=[Credentials]()
    var knowsAbout=[KnowsAbout]()
    var newsList = [newzListData]()
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userEndorsment: UILabel!
    @IBOutlet weak var userActivitySegment: UISegmentedControl!
    
    @IBOutlet weak var detailsLoading: UIActivityIndicatorView!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet var userSubscribers: UILabel!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var editProfile: UIButton!
    @IBOutlet weak var settings: UIButton!
    @IBOutlet weak var credentialTableView: UITableView!
    @IBOutlet weak var articlesTableView: UITableView!
    
    @IBOutlet weak var credentialsHeight: NSLayoutConstraint!
    @IBOutlet weak var knowsHeight: NSLayoutConstraint!
    @IBOutlet weak var articlesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var authorsArticles: UILabel!
    @IBOutlet weak var noOfSubscribers: UILabel!
    @IBOutlet weak var noOfPoints: UILabel!
    
    
    var loggedInUserId : String = ""
    
    let cellIdentifier="CredentialsViewCell"
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    override func viewDidLoad() {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        newsList.removeAll()
        credentialTableView.delegate = self
        credentialTableView.dataSource = self
        activityTableView.dataSource=self
        activityTableView.delegate=self
        userImage.image = UIImage();
        userPoints.text = "";
        userSubscribers.text = "";
        userName.text = "";
        userName.font = UIFont.boldSystemFont(ofSize: 18.0)
        userEndorsment.text = "";
        userImage.frame = CGRectMake(5, 10, 65, 65)
        //userImage.layer.borderWidth=1.0
        userImage.layer.masksToBounds = false
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.clipsToBounds = true
  //      editProfile.imageView!.layer.cornerRadius = 5
    //    editProfile.layer.cornerRadius = 5
        //  editProfile.tintColor=UIColor.black
        //  settings.tintColor=UIColor.black
        /// settings.layer.borderWidth=2
        //settings.layer.cornerRadius=25
        //editProfile.layer.borderWidth=2
        //editProfile.layer.cornerRadius=5
        activityTableView.tintColor=UIColor.black
        if(UserDefaults.standard.object(forKey: "userId") != nil){
            self.loggedInUserId = UserDefaults.standard.object(forKey: "userId") as! String
            
           loadActivities()
            loadKnowsAbout()
            self.loadUserData(id: self.loggedInUserId)
            loadArticles(id: self.loggedInUserId)
        }
        else{
            let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"LoginViewController") as! LoginViewController
            self.present(mainTabController, animated: true, completion: nil)
        }
        
        
        
        
        super.viewDidLoad()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 0)
        {
            return creadentials.count
        }
        else if(tableView.tag==1){
            return knowsAbout.count
        }
        else if(tableView.tag == 2){
            return newsList.count
        }
        return 0
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
     //   scrollView.contentSize = CGSize(width: 375, height: 1000)
    }
    override func viewDidLayoutSubviews() {
        userImage.layer.masksToBounds = false
        userImage.layer.cornerRadius =  userImage.frame.size.height/2
        userImage.clipsToBounds = true
    }
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorCredentialsViewCell", for: indexPath) as?
                AuthorCredentialsViewCell else{
                    fatalError("error")
            }
            let credentials=creadentials[indexPath.row]
            
            cell.crName.text=credentials.name
            cell.crImage.image=credentials.photo
            
            return cell
        }
        else if tableView.tag == 1{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorKnowsAboutTableViewCell", for: indexPath) as?
                AuthorKnowsAboutTableViewCell else{
                    fatalError("error")
            }
            let credentials=knowsAbout[indexPath.row]
            print("id \(credentials.photo) is")
            let scaledImage = scaleUIImageToSize(image: credentials.photo, size: cell.endorsmentLogo.frame.size)
            cell.endorsmentLogo.image = scaledImage
            cell.endorsmentTitle.text=credentials.name
            cell.endorsmentPoints.text=credentials.points
            cell.yellowStarIcon.isHidden = true
            cell.starIcon.isHidden = true 
            let flagButton = subscrbeButton.init()
            return cell
        }
        else if tableView.tag == 2{
            
            print("calling tableView **************")
            let cellIdentifier = "NewsListViewCell"
            guard let cell = articlesTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NewsListViewCell else {
                fatalError("The deqeued cell is not a instance of NewsListViewCell")
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            let bordColor = UIColor(red: 128.0/255.0, green: 203.0/255.0, blue: 196.0/255.0, alpha: 1.0) //#80cbc4
            let grayColor = hexStringToUIColor(hex: "#8E8E93")
            
            cell.layoutSubviews()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            cell.cellBound.layer.borderWidth = 0.1
            cell.cellBound.layer.borderColor = grayColor.cgColor
            cell.cellBound.layer.cornerRadius = 5
            cell.cellBound.layoutSubviews()
            cell.cellBound.setNeedsLayout()
            cell.cellBound.layoutIfNeeded()
            cell.cellBound.addshadow(top: false, left: true, bottom: true, right: true)
            
            
            cell.articleLabel.text = newsList[indexPath.row].newsTitle
            cell.articleImage.image = newsList[indexPath.row].newsImage
            cell.articleImage.layer.borderWidth = 0.5
            cell.articleImage.layer.borderColor = grayColor.cgColor
            
            cell.articleCategory.text = newsList[indexPath.row].userEndorsment
            
            let firstNameOnly = newsList[indexPath.row].userName.components(separatedBy: " ")
            cell.posterName.text = firstNameOnly[0]
            
            cell.profilePic.layer.borderWidth = 0.5
            cell.profilePic.layer.masksToBounds = false
            cell.profilePic.layer.borderColor = bordColor.cgColor
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height/2
            cell.profilePic.clipsToBounds = true
            // slider properties
            cell.lrCountSlider.minimumValue = -100
            cell.lrCountSlider.maximumValue = 0
            cell.rCountSlider.minimumValue = 0
            cell.rCountSlider.maximumValue = 100
            cell.lrCountSlider.setMinimumTrackImage(UIImage(named: "biasBar3"), for: UIControlState.normal)
            cell.lrCountSlider.setMaximumTrackImage(UIImage(named: "centerleft"), for: UIControlState.normal)
            cell.rCountSlider.setMaximumTrackImage(UIImage(named:"biasBar3"), for: UIControlState.normal)
            cell.rCountSlider.setMinimumTrackImage(UIImage(named:"centerright"), for: UIControlState.normal)
            let scaledThumb = scaleUIImageToSize(image: UIImage(named:"circleslider4")!, size: CGSize(width: 11, height: 11))
            let rightSize = cell.rCountSlider.currentMinimumTrackImage?.size
            let barSize = cell.rCountSlider.currentMaximumTrackImage?.size
            let leftSize = cell.lrCountSlider.currentMaximumTrackImage?.size
            let barSize2 = cell.lrCountSlider.currentMinimumTrackImage?.size
            
            
            let scaledRight = scaleUIImageToSize(image: UIImage(named:"centerright3")!, size: rightSize!)
            let scaledBar =  scaleUIImageToSize(image: UIImage(named:"biasBar4")!, size: barSize!)
            let scaledLeft = scaleUIImageToSize(image: UIImage(named:"centerleft3")!, size: leftSize!)
            let scaledBar2 =  scaleUIImageToSize(image: UIImage(named:"biasBar4")!, size: barSize2!)
            
            cell.rCountSlider.setMinimumTrackImage(scaledRight, for: .normal)
            cell.rCountSlider.setMaximumTrackImage(scaledBar, for: .normal)
            cell.lrCountSlider.setMinimumTrackImage(scaledBar2, for: .normal)
            cell.lrCountSlider.setMaximumTrackImage(scaledLeft, for: .normal)
            cell.lrCountSlider.isContinuous = false
            cell.rCountSlider.isContinuous = false
            
            let biasLevel = newsList[indexPath.row].minBiasedValue
            
            if biasLevel < 0.0 {
                cell.rCountSlider.value = 0
                cell.lrCountSlider.value = Float(biasLevel)
                cell.lrCountSlider.setThumbImage(scaledThumb, for: .normal)
                cell.rCountSlider.setThumbImage(UIImage(), for: .normal)
                
            }
            else if biasLevel == 0.0 {
                cell.rCountSlider.value = 0
                cell.lrCountSlider.value = 0
                cell.lrCountSlider.setThumbImage(UIImage(), for: .normal)
                cell.rCountSlider.setThumbImage(UIImage(), for: .normal)
            }
            else if biasLevel > 0.0 {
                cell.rCountSlider.value = Float(biasLevel)
                cell.lrCountSlider.value = 0
                cell.rCountSlider.setThumbImage(scaledThumb, for: .normal)
                cell.lrCountSlider.setThumbImage(UIImage(), for: .normal)
            }
            
            
            cell.lrCountSlider.isUserInteractionEnabled=false
            cell.rCountSlider.isUserInteractionEnabled = false
            // to hide slider thumb
            
            print("agree \(newsList[indexPath.row].agreeCount) neutral \(newsList[indexPath.row].nutralCount) disAgrecount \(newsList[indexPath.row].disAgreeCount)")
            let agreeCount :Int = newsList[indexPath.row].agreeCount
            let neutralCount :Int = newsList[indexPath.row].nutralCount
            let disAgreeCount :Int = newsList[indexPath.row].disAgreeCount
            cell.newsAgreeCountText.text = "\(agreeCount) Agree"
            cell.newsNeutralCountText.text = "\(neutralCount) Neutral"
            cell.newsDisAgreeCountText.text = "\(disAgreeCount) Disagree"
            cell.profilePic.image=newsList[indexPath.row].userProfileImage
            cell.time.text = newsList[indexPath.row].time
            print("succesS")
            return (cell)
        }
        return UITableViewCell()
    }
    
    /*
     To load knows about @Author subodh3344 */
    
    
    func loadKnowsAbout(){
        self.knowsAbout.removeAll()
        let id =  UserDefaults.standard.object(forKey: "userId") as! String
        self.knowsAbout.removeAll()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("userknowsabout").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value, with: { (knowsAbtSnapshot) in
            // Get user value
            if(knowsAbtSnapshot.exists()){
                var mainCount = 0
                for knwAbt in knowsAbtSnapshot.children{
                    mainCount = mainCount + 1
                    let knAbtsnap = knwAbt as! DataSnapshot
                    let knAbtDict = knAbtsnap.value as! [String:Any]
                    let knwAbtKey = knAbtsnap.key as! String
                    print("key is \(knwAbtKey)")
                    print("knw is \(knAbtDict["knowledge"])")
                    let endCount = knAbtDict["endorsementCount"] as! NSNumber
                    
                    var photo1 = UIImage(named:"newlightbulb")
                    if endCount != 0{
                         photo1=UIImage(named:"bulbIcon")
                    }
                    else {
                         photo1=UIImage(named:"newlightbulb")
                    }
                    guard  let kn1=KnowsAbout(
                        name:knAbtDict["knowledge"] as! String,
                        photo:photo1!,
                        points:"\(endCount) Points")
                    else {
                        fatalError("error")
                        
                    }
                    self.knowsAbout.append(kn1);
                    if(mainCount == knowsAbtSnapshot.childrenCount){
                        self.activityTableView.reloadData()
                        self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                        self.activityTableView.layoutIfNeeded()
                        self.knowsHeight.constant = self.activityTableView.contentSize.height
                        self.fillInKnowsAbout()
                    }
                    
                }
            
            }
            else{
                print("Dont have any knows about")
                DispatchQueue.main.async{
                    let emptyKnow = KnowsAbout(name:" ", photo:UIImage(), points:"")
                    let firstKnow = KnowsAbout(name:"No endorsements found", photo:UIImage(), points:"")
                    self.knowsAbout.append(firstKnow!)
                    self.knowsAbout.append(emptyKnow!)
                    self.knowsAbout.append(emptyKnow!)
                    
                    self.activityTableView.reloadData()
                    self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                    self.activityTableView.layoutIfNeeded()
                    self.knowsHeight.constant = self.activityTableView.contentSize.height
                }
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
            DispatchQueue.main.async{
                print("inknowsabout2")
                self.showToaster(msg: "Error while Fetching User Details...", type: 0)
            }
        }
      
    }
    
    func fillInKnowsAbout() {
        
        let emptyKnow = KnowsAbout(name:" ", photo:UIImage(), points:"")
        switch (self.knowsAbout.count) {
        case 1: self.knowsAbout.append(emptyKnow!)
        self.knowsAbout.append(emptyKnow!)
            break
        case 2: self.knowsAbout.append(emptyKnow!)
            break
        default:
            break
        }
        self.activityTableView.reloadData()
        self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
        self.activityTableView.layoutIfNeeded()
        self.knowsHeight.constant = self.activityTableView.contentSize.height
        
    }
    
    func loadKnowsAboutOld(){
        
        knowsAbout.removeAll()
        /*  print("in loadKnowsAbout")
         let photo1=UIImage(named:"user25")
         guard  let kn1=KnowsAbout(name:"International Affairs",photo:photo1!, points:"23.6k") else {
         fatalError("error")
         }
         guard  let kn2=KnowsAbout(name:"Indian History ",photo:photo1!, points:"23.6k") else {
         fatalError("error")
         }
         guard  let kn3=KnowsAbout(name:"American History ",photo:photo1!, points:"23.6k") else {
         fatalError("error")
         }
         guard  let kn4=KnowsAbout(name:"Us Government ",photo:photo1!, points:"23.6k") else {
         fatalError("error")
         }
         knowsAbout += [kn1,kn2,kn3,kn4]*/
        
        
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserEndorsmentsById?key=\(self.loggedInUserId)")
        
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.activityLoading.stopAnimating()
                //self.activityLoading.isHidden=true
                
            }
            
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            print("reposnString \(responseSting)")
            var error=NSError?.self
            do {
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")
                    
                    if code==1{
                        DispatchQueue.main.async{
                            //  self.activityLoading.stopAnimating()
                            var count=0;
                            var endorsmentData=jsonobj["data"].arrayValue
                            for endorsment in endorsmentData{
                                count = count + 1
                                print("post \(endorsment)")
                                let photo1=UIImage(named:"newlightbulb")
                                let endorsmentDetails=endorsment["endorsmentData"]
                                if count == 1{
                                    let photo1=UIImage(named:"bulbIcon")
                                }
                                else {
                                    let photo1=UIImage(named:"newlightbulb")
                                }
                                guard  let kn1=KnowsAbout(name:endorsmentDetails["knowledge"].string!,photo:photo1!, points:"\(endorsmentDetails["endorsementCount"].intValue) Points") else {
                                    fatalError("error")
                                    
                                }
                                self.knowsAbout.append(kn1);
                            }
                            let emptyKnow = KnowsAbout(name:" ", photo:UIImage(), points:"")
                            switch (self.knowsAbout.count) {
                            case 1: self.knowsAbout.append(emptyKnow!)
                            self.knowsAbout.append(emptyKnow!)
                                break
                            case 2: self.knowsAbout.append(emptyKnow!)
                                break
                            default:
                                break
                            }
                            self.activityTableView.reloadData()
                            self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                            self.activityTableView.layoutIfNeeded()
                            self.knowsHeight.constant = self.activityTableView.contentSize.height
                            print ( "THIS IS TABLE",self.activityTableView.contentSize.height, self.activityTableView.frame.height)

                            
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            //self.activityLoading.stopAnimating()
                            //self.activityLoading.isHidden=true
                            print("inknowsabout1" + jsonobj["msg"].string!)
                            if(jsonobj["msg"].string != "No Endorsments found for user"){
                                self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                            }
                            let emptyKnow = KnowsAbout(name:" ", photo:UIImage(), points:"")
                            let firstKnow = KnowsAbout(name:"No endorsements found", photo:UIImage(), points:"")
                            self.knowsAbout.append(firstKnow!)
                            self.knowsAbout.append(emptyKnow!)
                            self.knowsAbout.append(emptyKnow!)
                            self.activityTableView.reloadData()
                            self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                            self.activityTableView.layoutIfNeeded()
                            self.knowsHeight.constant = self.activityTableView.contentSize.height
                            print ( "THIS IS TABLE",self.activityTableView.contentSize.height, self.activityTableView.frame.height)
                            
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        //self.activityLoading.stopAnimating()
                        //self.activityLoading.isHidden=true
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                //self.activityLoading.stopAnimating()
                //  self.activityLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    func loadActivities(){
        //self.activityLoading.isHidden=false
        print("loadeng")
        //self.activityLoading.startAnimating()
        self.knowsAbout.removeAll()
        self.newsList.removeAll()
        
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserActivityById?key=\(loggedInUserId)")
        
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.activityLoading.stopAnimating()
                //self.activityLoading.isHidden=true
                
            }
            
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            print("reposnString for activities \(responseSting)")
            
            
            var error=NSError?.self
            
            do {
                
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")
                    
                    if code==1{
                        DispatchQueue.main.async{
                            //self.activityLoading.stopAnimating()
                            var postData=jsonobj["data"].arrayValue
                            for post in postData{
                                print("post \(post)")
                                let photo1=UIImage(named:"newlightbulb")
                                guard let new2=newzListData(
                                    userName:" ",
                                    userEndorsment:" ",
                                    userProfileImage:UIImage(),
                                    newsImage:UIImage(),
                                    newsTitle:post["postTitle"].string!,
                                    agreeCount:0,
                                    disAgreeCount:0,
                                    nutralCount:0,
                                    minBiasedValue:0,
                                    id:"\(post["endorspostIdmentId"].string!)",
                                    time : "",
                                    AuthorId: ""
                                    )
                                    
                                    else{
                                        fatalError("Error")
                                }
                            //    self.newsList.append(new2)
                                /*                                guard  let kn1=AuthorKnowsAbout(name:post["postTitle"].string! ,photo:photo1!, points:"\(post["postViews"].intValue) points",isEndorsed:false,id:"\(post["endorspostIdmentId"].string!)",isKnowsAbout: false) else {
                                 fatalError("error")
                                 }
                                 self.knowsAbout.append(kn1);*/
                            }
                            //self.activityTable.reloadData()
                            self.articlesTableView.reloadData()
                            self.articlesHeight.constant = CGFloat(self.newsList.count * 150)
                            self.articlesTableView.layoutIfNeeded()
                            self.articlesHeight.constant = self.articlesTableView.contentSize.height
                            print("article size", self.newsList.count)
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            //self.activityLoading.stopAnimating()
                            //self.activityLoading.isHidden=true
                            print("inloadactivities")
                            self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        //self.activityLoading.stopAnimating()
                        //self.activityLoading.isHidden=true
                        print("inloadactivities")
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                //self.activityLoading.stopAnimating()
                //self.activityLoading.isHidden=true
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
        
    }
    @IBAction func onSegmentChange(_ sender: Any) {
        print("selected segment \(userActivitySegment.selectedSegmentIndex)")
        
        switch userActivitySegment.selectedSegmentIndex {
            
        case 0:
            
            loadKnowsAbout()
            self.activityTableView.reloadData()
            break
        case 1:
            loadActivities();
            self.activityTableView.reloadData()
            break
            
            
        default:
            print("nothing ")
        }
    }
    func loadArticles(id:String!){
        knowsAbout.removeAll()
        newsList.removeAll()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        //        let userID = self.loggedInUserId as! String
        ref.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let posts = snapshot.value as? NSDictionary
            print(posts)
            for(randomid, singlePost) in posts!
            {
                print(singlePost)
                let postDict = singlePost as! [String:Any]
                print("part 1")
                print(postDict["userId"])
                if(postDict["userId"] as! String == id)
                {
                    //                    newsofpost.append(evrythingdict["content"]!)
                    print("found a post by this user")
                    let userQuery = ref.child("user").child(id).observeSingleEvent(of: .value, with: {(userSnapshot) in
                        let userDict = userSnapshot.value as? NSDictionary
                        let userPhotoString = userDict!["photo"] as! String
                        let userImageUrl : URL = URL(string:userPhotoString)!
                        let userImageData : NSData = NSData(contentsOf:userImageUrl)!
                        let userImage = UIImage(data:userImageData as Data)
                        let postPhotoString = postDict["media"] as! String
                        let postImageUrl : URL = URL(string:postPhotoString)!
                        let postImageData : NSData = NSData(contentsOf:postImageUrl)!
                        let postImage = UIImage(data:postImageData as Data)
                        ref.child("postreacts").queryOrdered(byChild: "postId").queryEqual(toValue: randomid).observeSingleEvent(of: .value, with: { (reactSnapshot) in
                            var agreeCount = 0
                            var disagreeCount = 0
                            var neutralCount = 0
                            for reactValue in reactSnapshot.children {
                                let reactSnap = reactValue as! DataSnapshot
                                let reactDict = reactSnap.value as! [String:Any]
                                
                                let opinion = Int (reactDict["openion"] as! String)
                                if opinion == 0 {
                                    neutralCount = neutralCount + 1
                                }
                                else if opinion == 1{
                                    agreeCount = agreeCount + 1
                                }
                                else if opinion == 2{
                                    disagreeCount = disagreeCount + 1
                                }
                            }
                            //get news LR Count details
                            ref.child("newslrcount").queryOrdered(byChild: "newsId").queryEqual(toValue: randomid).observeSingleEvent(of: .value, with: { (lrCountSnapshot) in
                                var avg : Float = 0
                                var total : Int = 0
                                var lrCount : Float = 0
                                for lrValue in lrCountSnapshot.children {
                                    let lrSnap = lrValue as! DataSnapshot
                                    let lrDict = lrSnap.value as! [String:Any]
                                    
                                    //                                    print("lr count \(Float(lrDict["lRcount"] as! String)!)")
                                    var lrvalue = (lrDict["lRcount"] as! NSString).floatValue
                                    lrCount = lrCount + Float(lrvalue )
                                    total = total + 1
                                }
                                if lrCount != 0 {
                                    avg=(lrCount / Float(total) )
                                }
                                guard let new2=newzListData(
                                    userName:userDict!["name"] as! String,
                                    userEndorsment:userDict!["highEndorsmentName"] as! String,
                                    userProfileImage:userImage as! UIImage,
                                    newsImage:postImage as! UIImage,
                                    newsTitle:postDict["title"] as! String,
                                    agreeCount:Int(agreeCount),
                                    disAgreeCount:Int(disagreeCount),
                                    nutralCount:Int(neutralCount),
                                    minBiasedValue:avg,
                                    id:randomid as! String,
                                    time : "",
                                    AuthorId: id
                                    )
                                    else{
                                        fatalError("Error")
                                }

                        
                        self.newsList.append(new2)
                        print("I ENTERED HERE AGAIN",  self.newsList.count)
                        self.articlesTableView.reloadData()
                        self.articlesHeight.constant = CGFloat(self.newsList.count * 150)
                        self.articlesTableView.layoutIfNeeded()
                        self.articlesHeight.constant = self.articlesTableView.contentSize.height
                            })
                        })
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    func loadUserData(id:String){
      
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var userOriginalCity = ""
        // fetch user's basic information
        ref.child("user").child(id).observeSingleEvent(of: .value, with: {(userDataSnap) in
            if(userDataSnap.exists()){
                let userDataDict = userDataSnap.value as! [String:Any]
                print("3344 : got user Data \(userDataDict)")
                let userProfImageUrl:URL = URL(string:userDataDict["photo"] as! String)!
                let userProfImageData:NSData = NSData(contentsOf: userProfImageUrl)!
                let profilePic = UIImage(data:userProfImageData as Data)
                // set profile pic
                self.userImage.image = profilePic
                // set user Name
                self.userName.text = userDataDict["name"] as! String
                let firstNameOnly = self.userName.text?.components(separatedBy: " ")
                self.authorsArticles.text = firstNameOnly![0] + "'s Articles"
                // set highEndorsment
                self.userEndorsment.text = userDataDict["highEndorsmentName"] as! String
                // set user location
                self.userLocation.text = userDataDict["currentCity"] as! String
                userOriginalCity = userDataDict["city"] as! String
            }
            else{
                print("Error : UserDataSnap doesn't exists ")
            }
        }){(error) in
            print("Error in loadUserData ref user \(error.localizedDescription)")
        }
        
        // fetch user Subscription Data
        ref.child("userSubscription").queryOrdered(byChild: "subscribeTo").queryEqual(toValue: id).observeSingleEvent(of: .value, with: {(userSubscriptionSnap) in
            if(userSubscriptionSnap.exists()){
                self.userSubscribers.text = "\(userSubscriptionSnap.childrenCount) subscribers"
            }
            else{
                self.userSubscribers.text = "0 subscribers"
                print("user subscription doesn't exists")
            }
            
        }){(userSubError) in
            print("Error : Error while fetching userSubscription data \(userSubError.localizedDescription)")
        }
        
        // fetch user points
        ref.child("userpoints").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value, with: {(userPointSnap) in
            var userPoint = 0
            var count = 0
            for userPtSnap in userPointSnap.children{
                count = count + 1
                let usrPtSnap = userPtSnap as! DataSnapshot
                let usrPtDict = usrPtSnap.value as! [String:Any]
                let gotPoint = usrPtDict["points"] as! Int
                userPoint = userPoint + gotPoint
                print("userPoint is \(userPoint)")
                if(count == userPointSnap.childrenCount){
                    self.userPoints.text = "\(userPoint) Points"
                }
            }
        }){(userPointError) in
            print("Error : Error while fetching userpoints \(userPointError.localizedDescription)")
        }
        
        //fetch user credentials
        ref.child("usercreadentials").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value
            , with: {(userCredSnap) in
                var countCred = 0
                
                // to add oroginal city in credentials list
                
                var locImg = UIImage(named:"locationIcon")
                guard let credential=Credentials (
                    name:userOriginalCity as! String,
                    photo:locImg!)
                    else {
                        fatalError("error")
                }
                self.creadentials.append(credential)
                
                if(userCredSnap.exists()){
                    for userCrSnap in userCredSnap.children{
                        countCred = countCred + 1
                        let usrCredSnp = userCrSnap as! DataSnapshot
                        let userCredDict = usrCredSnp.value as! [String:Any]
                        print("userCredDict is \(userCredDict)")
                        let credType = (userCredDict["type"] as! NSString).intValue
                        var credImage = UIImage(named: "user3")
                        switch(credType){
                        case 0 :
                            credImage = UIImage(named:"educationIcon")
                            break;
                        case 1 :
                            credImage = UIImage(named:"employmentIcon")
                            break;
                        case 2 :
                            credImage = UIImage(named:"locationIcon")
                            break;
                        case 3 :
                            credImage = UIImage(named:"languagesicon2")
                            break;
                        default:
                            print("default switch for cred type")
                            break;
                        }// switch ends
                        
                        guard let credential=Credentials (
                            name:userCredDict["creadentials"] as! String,
                            photo:credImage!)
                            else {
                                fatalError("error")
                        }
                        self.creadentials.append(credential)
                        if(countCred == userCredSnap.childrenCount){
                            self.credentialTableView.reloadData()
                            self.credentialsHeight.constant = CGFloat(self.creadentials.count * 40)
                            self.credentialTableView.layoutIfNeeded()
                            self.credentialsHeight.constant = self.credentialTableView.contentSize.height
                        }
                    }
                }
                self.fillInCreds()
        }){(userCredError) in
            print("Error : Error in fetching user credentials \(userCredError.localizedDescription)")
        }
        
        // fetch user languages
        ref.child("userLanguages").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value, with: {(userLanguageSnap) in
            //        ref.child("userLanguages").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value, with: {(userLanguageSnap) in
            if(userLanguageSnap.exists()){
                var languageCount = 0
                for userLanguage in userLanguageSnap.children{
                    languageCount = languageCount + 1
                    let userLanguageSnap = userLanguage as! DataSnapshot
                    let userlanguageDict = userLanguageSnap.value as! [String:Any]
                    print("Got languagess \(userlanguageDict)")
                    var languageImage = UIImage(named:"languagesicon2")
                    guard let languages=Credentials (
                        name:userlanguageDict["name"] as! String,
                        photo:languageImage!)
                        else {
                            fatalError("error")
                    }
                    self.creadentials.append(languages)
                    
                    self.credentialTableView.reloadData()
                    self.credentialsHeight.constant = CGFloat(self.creadentials.count * 40)
                    self.credentialTableView.layoutIfNeeded()
                    self.credentialsHeight.constant = self.credentialTableView.contentSize.height
                    
                }
            }
            else{
                print("No languages found")
                guard let noLanguages=Credentials (
                    name:"No language available",
                    photo:UIImage())
                    else {
                        fatalError("error")
                }
                self.creadentials.append(noLanguages)
            }
            
            
        }){(userLanguageError) in
            print("Error : Error while getting userLanguages \(userLanguageError.localizedDescription)")
        }
        
        
    }
    
    func loadUserDataOld(id:String){
        
        //   self.userDetailsLoading.isHidden=false
        // self.userDetailsLoading.startAnimating()
        
        
//        self.userName.text=userData["userName"].string
//        self.userEndorsment.text=userData["userEndorsment"].string
//        print(userData["userpoints"].intValue)
//        self.userPoints.text="\(userData["userpoints"].intValue) points"
//        self.userSubscribers.text="\(userData["userSubscribers"].intValue) points"
//        let imageUrl:URL = URL(string: userData["userProfile"].string!)!
//
//        let imageData:NSData = NSData(contentsOf: imageUrl)!
//
//        let image = UIImage(data: imageData as Data)
//        self.userImage.image=image
//
//        var credData=userData["userCredDetails"].arrayValue
//        for cred in credData{
//            var photo3=UIImage(named:"user3")
//            var type = cred["type"].intValue
//            if type==0{
//                photo3=UIImage(named:"educationIcon")
//            }
//            else if type==1{
//                photo3=UIImage(named:"employmentIcon")
//            }
//            else if type==2{
//                photo3=UIImage(named:"locationIcon")
//            }
//            else if type==3{
//                photo3=UIImage(named:"languagesIcon")
//            }
//            else{
//                photo3=UIImage(named:"user3")
//            }
//            guard let cred1=Credentials(name:cred["name"].string!,photo:photo3!)else{
//                fatalError("error")
//
//            }
//            self.creadentials.append(cred1)
//
//        }
//        print("cred \(self.creadentials)")
//        self.credentialTableView.reloadData()
        
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let userID = self.loggedInUserId as! String
        ref.child("usercreadentials").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let recentPostsQuery = ref.child("user").child(userID).observe(.value, with: {(userSnapshot) in
                //                print("the user is")
                //                print(userSnapshot)
                var userData = userSnapshot.value as! [String:Any]
                let imageUrl:URL = URL(string: userData["photo"] as! String)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                let image = UIImage(data: imageData as Data)
                self.userImage.image=image

                self.userName.text=userData["name"] as! String
                var city = userData["city"] as! String
                //                var country = userData["country"] as! String
                var Location:String = city // + ", " + country
                self.userLocation.text = Location
                //                var currentCity = userData["currentCity"] as! String
                //                var currentCountry = userData["currentCountry"] as! String
                //                var currentLocation:String = currentCity + ", " + currentCountry
                //                print(" currentLocation \(currentLocation)")
                //                self.userCurrentLocation.text=currentLocation
                //                self.userPoliticalOrientation.text = userData["politicalOrientation"] as! String
            }) { (error) in
                print(error.localizedDescription)
            }
            let credList = snapshot.value as? NSDictionary
            //            print(knowsABoutList)
            for(credID, singleCredential) in credList!
            {
                print(singleCredential)
                let credDict = singleCredential as! [String:Any]
                print("part 1")
                print(credDict["userId"])
                if(credDict["userId"] as! String == userID)
                {
                    var type = (credDict["type"] as! NSString).intValue
                    var photo3=UIImage(named:"user3")
                    if type==0{
                        photo3=UIImage(named:"educationIcon")
                    }
                    else if type==1{
                        photo3=UIImage(named:"employmentIcon")
                    }
                    else if type==2{
                        photo3=UIImage(named:"locationIcon")
                    }
                    else if type==3{
                        photo3=UIImage(named:"languagesicon2")
                    }
                    else{
                        photo3=UIImage(named:"user3")
                    }
                    guard let cred1=Credentials (
                        name:credDict["creadentials"] as! String,
                        photo:photo3!)
                        else {
                            fatalError("error")
                    }
                    self.creadentials.append(cred1)
                }
                self.credentialTableView.reloadData()
                self.credentialsHeight.constant = CGFloat(self.creadentials.count * 40)
                self.credentialTableView.layoutIfNeeded()
                self.credentialsHeight.constant = self.credentialTableView.contentSize.height
                
            }
            let emptyCred2 =  Credentials (
                name:"  ",
                photo:UIImage()
            )
            let emptyCred =  Credentials (
                name:"No credentials found",
                photo:UIImage())
            switch (self.creadentials.count) {
            case 0: self.creadentials.append(emptyCred!)
            self.creadentials.append(emptyCred2!)
            self.creadentials.append(emptyCred2!)
                break
            case 1: self.creadentials.append(emptyCred2!)
            self.creadentials.append(emptyCred2!)
                break
            case 2: self.creadentials.append(emptyCred2!)
                break
            default:
                let grouping = Dictionary(grouping: self.creadentials, by: { $0.photo })
                
                self.creadentials.removeAll()
                
                for (key, value) in grouping {
                    for (index, element) in value.enumerated() {
                        self.creadentials.append(element);
                    }
                    
                }
                break
                
            }
            self.credentialTableView.reloadData()
            self.credentialsHeight.constant = CGFloat(self.creadentials.count * 40)
            self.credentialTableView.layoutIfNeeded()
            self.credentialsHeight.constant = self.credentialTableView.contentSize.height
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
//        self.userDetailsLoading.stopAnimating()
//        self.userDetailsLoading.isHidden = true
        self.detailsLoading.startAnimating()
        self.detailsLoading.isHidden = false
        
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserById?key=\(id)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                self.detailsLoading.stopAnimating()
                self.detailsLoading.isHidden=true
            }

            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            print("reposnString \(responseSting)")
            var error=NSError?.self

            do {
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.detailsLoading.stopAnimating()
                            self.detailsLoading.isHidden=true
                            
                            var userData=jsonobj["data"]
//                            self.userName.text=userData["userName"].string
                            self.userEndorsment.text=userData["userEndorsment"].string
//                            print(userData["userpoints"].intValue)
                            self.userPoints.text="\(userData["userpoints"].intValue) points"
                            self.userSubscribers.text="\(userData["userSubscribers"].intValue) subscribers"
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                             self.detailsLoading.stopAnimating()
                             self.detailsLoading.isHidden=true
                            self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async{
                           self.detailsLoading.stopAnimating()
                           self.detailsLoading.isHidden=true
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }
            } catch let error as NSError {
                 self.detailsLoading.stopAnimating()
                 self.detailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "showDetails":
            
            // os_log("show news details",log:OSLog.default,type:.debug)
            
            guard let articleController = segue.destination as? ArticleViewController else{
                fatalError("unexpected destination :\(segue.destination)")
            }
            
            guard let selectedNewsCell = sender as? NewsListViewCell else{
                fatalError("unexpected sender \(String(describing: sender))")
            }
            guard let indexPath=self.articlesTableView.indexPath(for: selectedNewsCell) else{
                fatalError("Selected Cell is not being displayed by table")
            }
            let selectedNews = newsList[indexPath.row]
            articleController.news=selectedNews
            print("\(selectedNews) selectednews");
        //self.updateNewsView(id:selectedNews.id);
        default:
            var x = 0;
            //default case
        }
    }
    func fillInCreds() {
        
        // user credentials doesn't found
        let emptyCred2 =  Credentials (
            name:"  ",
            photo:UIImage()
        )
        let emptyCred =  Credentials (
            name:"No credentials found",
            photo:UIImage())
        switch (self.creadentials.count) {
        case 0: self.creadentials.append(emptyCred!)
        self.creadentials.append(emptyCred2!)
        self.creadentials.append(emptyCred2!)
            break
        case 1: self.creadentials.append(emptyCred2!)
        self.creadentials.append(emptyCred2!)
            break
        case 2: self.creadentials.append(emptyCred2!)
            break
        default:
            let grouping = Dictionary(grouping: self.creadentials, by: { $0.photo })
            
            self.creadentials.removeAll()
            
            for (key, value) in grouping {
                for (index, element) in value.enumerated() {
                    self.creadentials.append(element);
                }
                
            }
            break
            
        }
        self.credentialTableView.reloadData()
        self.credentialsHeight.constant = CGFloat(self.creadentials.count * 40)
        self.credentialTableView.layoutIfNeeded()
        self.credentialsHeight.constant = self.credentialTableView.contentSize.height
        
        
        
    }
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    @IBAction func goToEditProfile(_ sender: Any) {
    }
    @IBAction func goToSettings(_ sender: Any) {
    }
    
    
    
}
