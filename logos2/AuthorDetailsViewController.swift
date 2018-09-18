//
//  AuthorDetailsViewController.swift
//  logos2
//
//
//  AuthorDetailsViewController.swift
//  logos2
//
//  Created by Mansi on 04/06/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON
import FirebaseDatabase
class AuthorDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var articlesTableView: UITableView!

    @IBOutlet weak var authorsArticles: UILabel!

    @IBOutlet weak var activityLoading: UIActivityIndicatorView!
    @IBOutlet weak var userDetailsLoading: UIActivityIndicatorView!

    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var activityTable: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    var userId : String?
    @IBOutlet weak var userSubscribers: UILabel!
    @IBOutlet weak var credetialsTableView: UITableView!
    @IBOutlet weak var userPoints: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var authorProfileImage: UIImageView!
    @IBOutlet weak var authorEndorsments: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet weak var credentialsHeight: NSLayoutConstraint!
    @IBOutlet weak var knowsHeight: NSLayoutConstraint!
    @IBOutlet weak var articlesHeight: NSLayoutConstraint!
    var cred=[Credentials]()
    var knowsAbout=[AuthorKnowsAbout]()
    var newsList = [newzListData]()
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    let loggedInUserId = UserDefaults.standard.object(forKey: "userId") as! String
    //   @IBOutlet weak var authorName: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait 
        authorName.text = ""
        authorName.font = UIFont.boldSystemFont(ofSize: 18.0)
        userSubscribers.text = ""
        userPoints.text = ""
        authorEndorsments.text = ""
  //      authorProfileImage.frame = CGRectMake(5, 10, 65, 65)
        //authorProfileImage.layer.borderWidth=1.0
    //    subscribeButton.imageView!.layer.cornerRadius = 5
  //      subscribeButton.layer.cornerRadius = 5

        self.credetialsTableView.delegate=self
        self.credetialsTableView.dataSource=self
        self.activityTable.delegate=self
        self.activityTable.dataSource=self

        self.reloadDataFunction()


        self.activityLoading.isHidden=true
        self.userDetailsLoading.isHidden=true
        if loggedInUserId == self.userId{
            self.subscribeButton.isHidden=true
        }
        else{
            self.subscribeButton.isHidden=false
        }

        // Do any additional setup after loading the view.
    }

    func reloadDataFunction(){


        self.loadUserData(id: self.userId!) // basic + cred
        self.knowsAbout.removeAll()
        self.cred.removeAll()
        self.newsList.removeAll()

        self.loadKnowsAbout(id: self.userId!) // knows abt
        DispatchQueue.main.async {
            self.activityTable.reloadData()
        }
        self.loadArticles(id: self.userId!) //
        self.loadActivities(id: self.userId!)

    }


    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
       // scrollView.contentSize = CGSize(width: 375, height: 1000)
    }
    override func viewDidLayoutSubviews() {
        authorProfileImage.layer.masksToBounds = false
        authorProfileImage.layer.cornerRadius = authorProfileImage.frame.size.height/2
        authorProfileImage.clipsToBounds = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func backButtonPressed(_ sender: Any) {
        dismissDetail()
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    /* New function to load user Data @Author subodh3344
     consists of : user Education,user Employment,user Location,user Language
     
     */
    func loadUserData(id:String){
        self.userDetailsLoading.isHidden=false
        self.userDetailsLoading.startAnimating()
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
                self.authorProfileImage.image = profilePic
                // set user Name
                self.authorName.text = userDataDict["name"] as! String
                let firstNameOnly = self.authorName.text?.components(separatedBy: " ")
                self.authorsArticles.text = firstNameOnly![0] + "'s Articles"
                // set highEndorsment
                self.authorEndorsments.text = userDataDict["highEndorsmentName"] as! String
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
                var count = 0
                for userSub in userSubscriptionSnap.children{
                    count = count + 1
                    let userSubscriberSnap = userSub as! DataSnapshot
                    let userSubscriberDict = userSubscriberSnap.value as! [String:Any]
                    print("3344 : userSubscriberDict is \(userSubscriberDict)")
                    let loggedInUserId = UserDefaults.standard.object(forKey: "userId") as! String
                    if(userSubscriberDict["userId"] as! String == loggedInUserId){
                        self.subscribeButton.setImage(UIImage(named:"subscribedbutton2"), for: .normal)
                        self.subscribeButton.tag=2
                    }
                    else{
                        if(count == userSubscriptionSnap.childrenCount){
                            self.subscribeButton.setImage(UIImage(named:"subscribedbutton2"), for: .normal)
                            self.subscribeButton.tag=1
                        }
                    }
                }
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
                self.cred.append(credential)
                
                
                
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
                        self.cred.append(credential)
                        if(countCred == userCredSnap.childrenCount){
                            self.credetialsTableView.reloadData()
                            self.credentialsHeight.constant = CGFloat(self.cred.count * 40)
                            self.credetialsTableView.layoutIfNeeded()
                            self.credentialsHeight.constant = self.credetialsTableView.contentSize.height
                        }
                    }
                }
                    // user credentials doesn't found
                
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
                    self.cred.append(languages)
                    self.credetialsTableView.reloadData()
                    self.credentialsHeight.constant = CGFloat(self.cred.count * 40)
                    self.credetialsTableView.layoutIfNeeded()
                    self.credentialsHeight.constant = self.credetialsTableView.contentSize.height
                    
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
                self.cred.append(noLanguages)
            }
           
            self.fillInCreds()
        }){(userLanguageError) in
            print("Error : Error while getting userLanguages \(userLanguageError.localizedDescription)")
        }
        
        
    }
    
    

    func loadUserDataOld(id:String){

        self.userDetailsLoading.isHidden=false
        self.userDetailsLoading.startAnimating()

        var ref: DatabaseReference!
        ref = Database.database().reference()

        let userID = self.loggedInUserId as! String
        ref.child("usercreadentials").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let recentPostsQuery = ref.child("user").child(id).observe(.value, with: {(userSnapshot) in
                //                print("the user is")
                //                print(userSnapshot)
                var userData = userSnapshot.value as! [String:Any]
                let imageUrl:URL = URL(string: userData["photo"] as! String)!
                let imageData:NSData = NSData(contentsOf: imageUrl)!
                let image = UIImage(data: imageData as Data)
                self.authorProfileImage.image=image

                self.authorName.text=userData["name"] as! String
                var city = userData["currentCity"] as! String
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
                if(credDict["userId"] as! String == id)
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
                    self.cred.append(cred1)
                }
                self.credetialsTableView.reloadData()
                self.credentialsHeight.constant = CGFloat(self.cred.count * 40)
                self.credetialsTableView.layoutIfNeeded()
                self.credentialsHeight.constant = self.credetialsTableView.contentSize.height
            }
            let emptyCred2 =  Credentials (
                name:"  ",
                photo:UIImage()
            )
            let emptyCred =  Credentials (
                name:"No credentials found",
                photo:UIImage())
            switch (self.cred.count) {
            case 0: self.cred.append(emptyCred!)
                    self.cred.append(emptyCred2!)
                    self.cred.append(emptyCred2!)
                    break
            case 1: self.cred.append(emptyCred2!)
                    self.cred.append(emptyCred2!)
                    break
            case 2: self.cred.append(emptyCred2!)
                    break
            default:
                let grouping = Dictionary(grouping: self.cred, by: { $0.photo })
                
                self.cred.removeAll()
                
                for (key, value) in grouping {
                    for (index, element) in value.enumerated() {
                        self.cred.append(element);
                    }
                    
                }
                break

            }
                self.credetialsTableView.reloadData()
                self.credentialsHeight.constant = CGFloat(self.cred.count * 40)
                self.credetialsTableView.layoutIfNeeded()
                self.credentialsHeight.constant = self.credetialsTableView.contentSize.height
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        self.userDetailsLoading.stopAnimating()
        self.userDetailsLoading.isHidden = true

        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserByIdAndSubscriptionDetails")
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "userToBeSubscribe":"\(userId)","userId":"\(self.userId!)"] as[String : Any]
                print("json  getUserByIdAndSubscriptionDetails\(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            //
            //            if (error != nil){
            //
            //                self.userDetailsLoading.stopAnimating()
            //
            //                self.userDetailsLoading.isHidden=true
            //
            //            }
            //
           // let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
           // print("reposnString \(responseSting)")
            //
            //
            var error=NSError?.self
            //
            do {

                if data != nil{
                    print(data!);
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    //                    print("code \(code!)")
                    if code==1{
                        DispatchQueue.main.async{
                            //                            self.userDetailsLoading.stopAnimating()
                            //                            self.userDetailsLoading.isHidden=true
                            var userData2=jsonobj["data"]
                            //                            self.authorName.text=userData2["userName"].string
                            //                            print("endorsee:" + userData2["userEndorsment"].string!)
                            self.authorEndorsments.text=userData2["userEndorsment"].string
                            //                            print(userData2["userpoints"].intValue)
                            self.userPoints.text="\(userData2["userpoints"].intValue) points"
                            self.userSubscribers.text="\(userData2["userSubscribers"].intValue) subscribers"
                            //                            var number = -1
                            //                            var i = 0
                            //                            for (key, subJson) in userData2["userCredDetails"]  {
                            //                                if let title = subJson["type"].number {
                            //                                    if(title == 2){
                            //                                        number = i;
                            //                                        break
                            //                                    }
                            //                                }
                            //                                //print(subJson["type"].string! + "\(subJson["name"].string!) subjson")
                            //                                i = i + 1
                            //                            }


                            //                            if(number != -1){
                            //                                self.userLocation.text = userData2["userCredDetails"][number]["name"].string!.replacingOccurrences(of: "From", with: "", options: .literal, range: nil)
                            //                            }
                            //                            else{
                            //                                self.userLocation.text = "Unknown"
                            //                            }

                            //                            let imageUrl:URL = URL(string: userData2["userProfile"].string!)!
                            //
                            //                            let imageData:NSData = NSData(contentsOf: imageUrl)!
                            //
                            //                            let image = UIImage(data: imageData as Data)
                            //                            self.authorProfileImage.image=image
                            print("is subscribe \(userData2["isSubscribe"].bool!)")
                            let isSubscribe=userData2["isSubscribe"].bool!
                              print("is subscribe \(isSubscribe)")
                            if isSubscribe {
                                self.subscribeButton.setImage(UIImage(named:"subscribedbutton2"), for: .normal)
                                self.subscribeButton.tag=2
                            }
                            else{
                                self.subscribeButton.setImage(UIImage(named:"subscribebutton2"), for: .normal)
                                self.subscribeButton.tag=1
                            }
                            //                            var credData=userData2["userCredDetails"].arrayValue
                            //                            for cred in credData{
                            //                                var photo3=UIImage(named:"user3")
                            //                                var type = cred["type"].intValue
                            //                                if type==0{
                            //                                    photo3=UIImage(named:"educationIcon")
                            //                                }
                            //                                else if type==1{
                            //                                    photo3=UIImage(named:"employmentIcon")
                            //                                }
                            //                                else if type==2{
                            //                                    photo3=UIImage(named:"locationIcon")
                            //                                }
                            //                                else if type==3{
                            //                                    photo3=UIImage(named:"languagesIcon")
                            //                                }
                            //                                else{
                            //                                    photo3=UIImage(named:"user3")
                            //                                }
                            //                                guard let cred1=Credentials (
                            //                                    name:cred["name"].string!,
                            //                                    photo:photo3!)
                            //                                    else {
                            //                                    fatalError("error")
                            //                                }
                            //                                self.cred.append(cred1)
                            //
                            //                            }
                            //                            print("cred \(self.cred)")
                            //                            self.credetialsTableView.reloadData()
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            print("inuserdata")
                            self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.userDetailsLoading.stopAnimating()
                        print("inuserdata")
                        self.userDetailsLoading.isHidden=true
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }

            } catch let error as NSError {
                self.userDetailsLoading.stopAnimating()

                self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()
    }
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return self.cred.count
        }
        else if tableView.tag == 1{
            return self.knowsAbout.count
        }
        else if tableView.tag == 2{
            return self.newsList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // print("THIS IS COUNT", knowsAbout.count, cred.count)
        if tableView.tag == 0{

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorCredentialsViewCell", for: indexPath) as?
                AuthorCredentialsViewCell else{
                    fatalError("error")
            }
            let credentials=cred[indexPath.row]
            print("subodh ::: \(credentials.name)")
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
           // print("id \(credentials.photo) is")
            let scaledImage = scaleUIImageToSize(image: credentials.photo, size: cell.endorsmentLogo.frame.size)
            cell.endorsmentLogo.image = scaledImage
            cell.endorsmentTitle.text=credentials.name
            cell.endorsmentPoints.text=credentials.points
            let flagButton = subscrbeButton.init()

          //  if credentials.isKnowsAbout {

                if self.loggedInUserId != self.userId {
                    if credentials.isEndorsed {
                     //   print("in if ")
                       cell.starIcon.isHidden = true
                        cell.yellowStarIcon.isHidden = false
                        var smallEndorsed = UIImage(named: "isEndorsed")?.resizeImage(15.0, opaque: false)
                        cell.yellowStarIcon.frame=CGRect(x:cell.frame.width - 40,y:0,width:40, height:40)
                        cell.yellowStarIcon.setImage(UIImage(named: "isEndorsed")?.resizeImage(15.0, opaque: false), for: .normal)
                        cell.yellowStarIcon.id = credentials.id as! String
                        cell.yellowStarIcon.addTarget(self, action: #selector(self.unEndorse), for: .touchUpInside)

                    }
                    else{
                     //    print("in else ")
                        cell.starIcon.isHidden = false
                        cell.yellowStarIcon.isHidden = true
                        let photo1=UIImage(named:"whiteStarIcon")

                        cell.starIcon.frame=CGRect(x:cell.frame.width - 40,y:0,width:40, height:40)
                        cell.starIcon.setImage(UIImage(named:"whiteStarIcon"), for: .normal)
                        cell.starIcon.id = credentials.id as! String

                        cell.starIcon.addTarget(self, action: #selector(self.endorse), for: .touchUpInside)
                        //cell.addSubview(flagButton)
                        //cell.starIcon = flagButton

                    }
                }
            if credentials.id == "" || (self.loggedInUserId == self.userId) {
                cell.yellowStarIcon.isHidden = true
                cell.starIcon.isHidden = true
                
            }
                //cell.endorsmentTitle.text = "points"
//            }
//            else{
//                cell.starIcon.setImage(UIImage(), for: .normal)
//                //cell.endorsmentTitle.text = "views"
//            }


            return cell
        }
        else if tableView.tag == 2{

           // print("calling tableView **************")
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

           // print("agree \(newsList[indexPath.row].agreeCount) neutral \(newsList[indexPath.row].nutralCount) disAgrecount \(newsList[indexPath.row].disAgreeCount)")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "showArticle":

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
            print("THIS NEWS",newsList[indexPath.row], indexPath.row)
            articleController.news=selectedNews
        //self.updateNewsView(id:selectedNews.id);
        default:
            print("defualt case")
            fatalError("unexpected segue indentiifer \(String(describing: segue.identifier))")
            //default case
        }
    }


    @IBAction func onChange(_ sender: Any) {

        switch  self.segment.selectedSegmentIndex {
        case 0:

            loadKnowsAbout(id: self.userId!)
            self.activityTable.reloadData()
            break
        case 1:
            loadActivities(id: self.userId!);
            self.activityTable.reloadData()
            break
        case 2:
            loadArticles(id: self.userId!);
            self.articlesTableView.reloadData()
            self.articlesHeight.constant = CGFloat(self.newsList.count * 150)
            self.articlesTableView.layoutIfNeeded()
            self.articlesHeight.constant = self.articlesTableView.contentSize.height
            break
        default:
            print("nothing ")

        }
    }
    func loadActivities(id:String!){
        self.activityLoading.isHidden=false
        print("loadeng")
        self.activityLoading.startAnimating()
        self.knowsAbout.removeAll()
        self.newsList.removeAll()

        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserActivityById?key=\(id!)")

        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                self.activityLoading.stopAnimating()
                self.activityLoading.isHidden=true

            }

//            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
//            print("reposnString for activities \(responseSting)")


            var error=NSError?.self

            do {

                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.activityLoading.stopAnimating()
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
                                //self.newsList.append(new2)
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
                            self.activityLoading.stopAnimating()
                            self.activityLoading.isHidden=true
                            print("inloadactivities")
                            self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.activityLoading.stopAnimating()
                        self.activityLoading.isHidden=true
                        print("inloadactivities")
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }

            } catch let error as NSError {
                self.activityLoading.stopAnimating()
                self.activityLoading.isHidden=true

                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()
    }
    func loadKnowsAboutOld(id:String!){
        self.activityLoading.isHidden=false

        self.activityLoading.startAnimating()
        self.knowsAbout.removeAll()
        var ref: DatabaseReference!
        ref = Database.database().reference()

        //        let userID = self.loggedInUserId as! String
        //        ref.child("userknowsabout").observeSingleEvent(of: .value, with: { (snapshot) in
        //            // Get user value
        //            let allKnowsAbout = snapshot.value as? NSDictionary
        //            print(allKnowsAbout)
        //
        //            //            var newsofpost: [String] = []
        //            for(randomid, singleKnowsAbout) in allKnowsAbout!
        //            {
        //                print(singleKnowsAbout)
        //                let knowsAboutDict = singleKnowsAbout as! [String:Any]
        //                print("part 1")
        //                print(knowsAboutDict["userId"])
        //                if(knowsAboutDict["userId"] as! String == id)
        //                {
        //                    //                    newsofpost.append(evrythingdict["content"]!)
        //                    let endorsementCount = String(describing: knowsAboutDict["endorsementCount"] as! Int)
        //                    print("\(endorsementCount)")
        //                    print("found a knows about of this user")
        //                    guard  let kn1=AuthorKnowsAbout(
        //                        name:knowsAboutDict["knowledge"] as! String ,
        //                        photo:UIImage(named: "whiteBulbIcon")!,
        //                        points:"\(endorsementCount) points",
        //                        isEndorsed:false,//endorsment["isEndorsed"].boolValue,
        //                        id:randomid as! String,
        //                        isKnowsAbout:true)
        //                        else {
        //                            fatalError("error")
        //                    }
        //                    self.knowsAbout.append(kn1);
        //                }
        //            }
        //            self.activityTable.reloadData()
        //            // ...
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }

        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserEndorsmentsDetailsById")

        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "userId":"\(userId)","endorsUserId":"\(id!)"] as[String : Any]
        print("json  getUserEndorsmentsDetailsById \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                DispatchQueue.main.async {
                    self.activityLoading.stopAnimating()
                    self.activityLoading.isHidden=true
                }

            }

//            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
//            print("reposnString for ka \(responseSting)")


            var error=NSError?.self

            do {

                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    self.knowsAbout.removeAll()
                    print("code in loaduserKnows about is  \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.activityLoading.stopAnimating()
                            self.activityLoading.isHidden=true
                            var endorsmentData=jsonobj["data"].arrayValue
                            for endorsment in endorsmentData{
                                print("post \(endorsment)")
                                let photo1=UIImage(named:"newlightbulb")
                                let endorsmentDetails=endorsment["endorsmentData"]
                                print("3344 is endorsed is \(endorsment["isEndorsed"])")
                                if endorsment["isEndorsed"].boolValue{
                                    let photo1=UIImage(named:"bulbIcon")
                                    print("3344 ading ")

                                }
                                else {
                                    let photo1=UIImage(named:"newlightbulb")

                                }
                                guard  let kn1=AuthorKnowsAbout(
                                    name:endorsmentDetails["knowledge"].string! ,photo:photo1!,
                                    points:"\(endorsmentDetails["endorsementCount"].intValue) points",
                                    isEndorsed:endorsment["isEndorsed"].boolValue,
                                    id:"\(endorsment["endorsmentId"].string!)",
                                    isKnowsAbout:true)
                                    else {
                                        fatalError("error")
                                }
                                self.knowsAbout.append(kn1);
                            }
                            let emptyKnow = AuthorKnowsAbout(name:" ",photo:UIImage(), points:"",isEndorsed:false,id:"",isKnowsAbout:false)
                            switch (self.knowsAbout.count) {
                            case 1: self.knowsAbout.append(emptyKnow!)
                                    self.knowsAbout.append(emptyKnow!)
                                    break
                            case 2: self.knowsAbout.append(emptyKnow!)
                                    break
                            default:
                                    break
                            }
                            self.activityTable.reloadData()
                            self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                            self.activityTable.layoutIfNeeded()
                            self.knowsHeight.constant = self.activityTable.contentSize.height
                          //  print ( "THIS IS TABLE",self.activityTable.contentSize.height, self.activityTable.frame.height)

                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            self.activityLoading.stopAnimating()
                            self.activityLoading.isHidden=true
                            print("inknowsabout1" + jsonobj["msg"].string!)
                            if(jsonobj["msg"].string != "No Endorsments found for user"){
                                self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                            }
                            guard  let kn1=AuthorKnowsAbout(name:"No endorsements found",photo:UIImage(), points:"",isEndorsed:false,id:"",isKnowsAbout:false) else {
                                fatalError("error")
                            }
                            let emptyKnow = AuthorKnowsAbout(name:" ",photo:UIImage(), points:"",isEndorsed:false,id:"",isKnowsAbout:false)
                            self.knowsAbout.append(kn1);
                            self.knowsAbout.append(emptyKnow!)
                            self.knowsAbout.append(emptyKnow!)
                            self.activityTable.reloadData()
                            self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                            self.activityTable.layoutIfNeeded()
                            self.knowsHeight.constant = self.activityTable.contentSize.height
                        //    print ( "THIS IS TABLE", self.activityTable.contentSize.height, self.knowsHeight.constant)

                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.activityLoading.stopAnimating()
                        self.activityLoading.isHidden=true
                        print("inknowsabout2")
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }

            } catch let error as NSError {
                self.activityLoading.stopAnimating()
                self.activityLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()

    }
    
    func loadKnowsAbout(id:String!){
        self.activityLoading.isHidden=false
        
        self.activityLoading.startAnimating()
        self.knowsAbout.removeAll()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let loginUserID = self.loggedInUserId as! String
        print("login user UID \(loginUserID) and get knows abt for user \(id)")
        
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
                    
                    // fetch if already endorsed by some one
                    print("caliing get end from userEndorsedTo knwBt Key \(knwAbtKey)")
                    ref.child("userEndorsedTo").queryOrdered(byChild: "endorsmentID").queryEqual(toValue: knwAbtKey).observeSingleEvent(of: .value, with: {(gotKnowsAbtSnapshot) in
                        if(gotKnowsAbtSnapshot.exists()){
                            var count = 0
                            var dataIsPushed = false
                            for endorsment in gotKnowsAbtSnapshot.children{
                                let endorsemtnSnap = endorsment as! DataSnapshot
                                let endKey = endorsemtnSnap.key as! String
                                let endDict = endorsemtnSnap.value as! [String:Any]
                                let endrosedByUsedId = endDict["EndorsFromUserId"] as! String
                                print(" endrosedByUsedId is \(endrosedByUsedId) and loginUserID is \(loginUserID)")
                                if(endrosedByUsedId == loginUserID){
                                    print("yesssss 3344")
                                    // push into knows Abt
                                    let photo1=UIImage(named:"bulbIcon")
                                    guard  let kn1=AuthorKnowsAbout(
                                        name:knAbtDict["knowledge"] as! String ,
                                        photo:photo1!,
                                        points:"\(endCount) points",
                                        isEndorsed:true,
                                        id:knwAbtKey,
                                        isKnowsAbout:true)
                                        else {
                                            fatalError("error")
                                    }
                                    print("appending 1")
                                    self.knowsAbout.append(kn1);
                                    dataIsPushed = true
                                }
                                else{
                                    count = count + 1
                                    if(count == gotKnowsAbtSnapshot.childrenCount){
                                        let photo1=UIImage(named:"newlightbulb")
                                        guard  let kn1=AuthorKnowsAbout(
                                            name:knAbtDict["knowledge"] as! String ,
                                            photo:photo1!,
                                            points:"\(endCount) points",
                                            isEndorsed:false,
                                            id:knwAbtKey,
                                            isKnowsAbout:true)
                                            else {
                                                fatalError("error")
                                        }
                                        print("appending 2")
                                        self.knowsAbout.append(kn1);
                                        dataIsPushed = true;
                                    }
                                    
                                }
                                if(!dataIsPushed && count == gotKnowsAbtSnapshot.childrenCount){
                                    // push into knows Abt
                                    let photo1=UIImage(named:"newlightbulb")
                                    guard  let kn1=AuthorKnowsAbout(
                                        name:knAbtDict["knowledge"] as! String ,
                                        photo:photo1!,
                                        points:"\(endCount) points",
                                        isEndorsed:false,
                                        id:knwAbtKey,
                                        isKnowsAbout:true)
                                        else {
                                            fatalError("error")
                                    }
                                    print("appending 3")
                                    self.knowsAbout.append(kn1);
                                }
                                print("3344 : knowsAbout is \(self.knowsAbout)")
                                print("\(mainCount) == \(knowsAbtSnapshot.childrenCount)")
                                if(mainCount == knowsAbtSnapshot.childrenCount){
                                    DispatchQueue.main.async {
                                        self.activityTable.reloadData()
                                        self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                                        self.activityTable.layoutIfNeeded()
                                        self.knowsHeight.constant = self.activityTable.contentSize.height
                                        self.activityLoading.stopAnimating()
                                        self.activityLoading.isHidden=true
                                    }
                                }
                            }
                       
                        }//end of if gotKnowsAbtSnapshot.exist
                        else{
                            // no endorsment found
                            print("no endorsment found")
                            let photo1=UIImage(named:"newlightbulb")
                            let filledStart = UIImage(named: "star")
                            guard  let kn1=AuthorKnowsAbout(
                                name:knAbtDict["knowledge"] as! String ,
                                photo:photo1!,
                                points:"\(endCount) points",
                                isEndorsed:false,
                                id:knwAbtKey,
                                isKnowsAbout:true)
                                else {
                                    fatalError("error")
                            }
                            print("appending 4")
                            self.knowsAbout.append(kn1);
                        }// end of else gotKnowsAbtSnapshot.exist
                        print("3344 : knowsAbout is 90\(self.knowsAbout)")
                        print("\(mainCount) == \(knowsAbtSnapshot.childrenCount)")
                        if(mainCount == knowsAbtSnapshot.childrenCount){
                            print("reload dataaaaa")
                            DispatchQueue.main.async {
                                self.activityTable.reloadData()
                                self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                                self.activityTable.layoutIfNeeded()
                                self.knowsHeight.constant = self.activityTable.contentSize.height
                                self.activityLoading.stopAnimating()
                                self.activityLoading.isHidden=true
                                self.fillInKnowAbout()
                            }
                        }
                        
                    })
                    {(error) in
                        print("Error in fetch data from userEndorsedTo table \(error.localizedDescription)")
                        DispatchQueue.main.async{
                            self.activityLoading.stopAnimating()
                            self.activityLoading.isHidden=true
                            print("inknowsabout2")
                            self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                        }
                    }
                
                }
            }
            else{
                print("Dont have any knows about")
                DispatchQueue.main.async{
                    self.activityLoading.stopAnimating()
                    self.activityLoading.isHidden=true
                   
                    guard  let kn1=AuthorKnowsAbout(name:"No endorsements found",photo:UIImage(), points:"",isEndorsed:false,id:"",isKnowsAbout:false) else {
                        fatalError("error")
                    }
                    let emptyKnow = AuthorKnowsAbout(name:" ",photo:UIImage(), points:"",isEndorsed:false,id:"",isKnowsAbout:false)
                    self.knowsAbout.append(kn1);
                    self.knowsAbout.append(emptyKnow!)
                    self.knowsAbout.append(emptyKnow!)
                    self.activityTable.reloadData()
                    self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
                    self.activityTable.layoutIfNeeded()
                    self.knowsHeight.constant = self.activityTable.contentSize.height
                   // print ( "THIS IS TABLE", self.activityTable.contentSize.height, self.knowsHeight.constant)
                    
                }
            }
       
        
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                    DispatchQueue.main.async{
                        self.activityLoading.stopAnimating()
                        self.activityLoading.isHidden=true
                        print("inknowsabout2")
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }
        
    }
    func fillInKnowAbout() {
    //    print ("THIS IS COUNT FOR KNOWS", self.knowsAbout.count)
        let emptyKnow = AuthorKnowsAbout(name:" ", photo:UIImage(), points:"", isEndorsed: false, id: "", isKnowsAbout: true)
        switch (self.knowsAbout.count) {
        case 1: self.knowsAbout.append(emptyKnow!)
        self.knowsAbout.append(emptyKnow!)
            break
        case 2: self.knowsAbout.append(emptyKnow!)
            break
        default:
            break
        }
        self.activityTable.reloadData()
        self.knowsHeight.constant = CGFloat(self.knowsAbout.count * 40)
        self.activityTable.layoutIfNeeded()
        self.knowsHeight.constant = self.activityTable.contentSize.height
     //   print ( "THIS IS TABLE",self.activityTable.contentSize.height, self.activityTable.frame.height)
    }
    
    @objc func endorse (_sender: subscrbeButton){
        print("calling endorse 3344")
        self.userDetailsLoading.isHidden=false
        self.userDetailsLoading.startAnimating()
        var endorsmentId:String=_sender.id
        print("credentials id \(endorsmentId)")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/endorseUser")

        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "endorsementId":"\(endorsmentId  as String)","userId":"\(userId)"] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                self.userDetailsLoading.stopAnimating()
                self.userDetailsLoading.isHidden=true
            }

//            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
//            print("reposnString \(responseSting)")


            var error=NSError?.self

            do {

                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.showToaster(msg: "Endorsed", type: 1)
                            //self.loadKnowsAbout(id: self.userId)
                            self.reloadDataFunction()

                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.showToaster(msg: "Error while endorsing", type: 0)
                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.userDetailsLoading.stopAnimating()
                        self.userDetailsLoading.isHidden=true
                        self.showToaster(msg: "Error while endorsing", type: 0)
                    }
                }

            } catch let error as NSError {
                self.userDetailsLoading.stopAnimating()
                self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()
    }

    func loadArticles(id:String!){
        self.activityLoading.isHidden=false
        self.activityLoading.startAnimating()
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
                    let userQuery = ref.child("user").child(id).observe(.value, with: {(userSnapshot) in
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

    @objc func unEndorse(_sender: subscrbeButton){
        print("calling unendorse 3344")
        self.userDetailsLoading.isHidden=false
        self.userDetailsLoading.startAnimating();
        print("credentials id \(_sender.id)")
        var endorsmentId=_sender.id as! String
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/unEndorseUser")

        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "endorsementId":"\(endorsmentId)","userId":"\(userId)"] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                DispatchQueue.main.async{
                    self.userDetailsLoading.stopAnimating()
                    self.userDetailsLoading.isHidden=true
                }
            }

           // let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            //print("reposnString \(responseSting)")


            var error=NSError?.self

            do {

                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.userDetailsLoading.isHidden=true
                            //self.loadKnowsAbout(id: self.userId)
                            self.reloadDataFunction()
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "Error while Removing Endorsed skill...", type: 0)
                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.userDetailsLoading.stopAnimating()
                        self.userDetailsLoading.isHidden=true
                        self.showToaster(msg: "Error while Removing Endorsed skill...", type: 0)
                    }
                }

            } catch let error as NSError {
                self.userDetailsLoading.stopAnimating()
                self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()
    }
    @IBAction func subscribeUser(_ sender: Any) {
        print("checking subs")
        if self.subscribeButton.tag == 1{
            self.subscrie()
        }
        else if self.subscribeButton.tag == 2{
            self.unsubscribe()
        }
    }
    func subscrie(){
        print("starting subs")
        self.userDetailsLoading.isHidden=false
        self.userDetailsLoading.startAnimating();

        //var endorsmentId=_sender.id as! String
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addUserSubscription")

        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "subscribeTo":"\(userId)","userId":"\(self.userId!)"] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                self.userDetailsLoading.stopAnimating()
                self.userDetailsLoading.isHidden=true
            }

//            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
//            print("reposnString \(responseSting)")
//

            var error=NSError?.self

            do {

                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "Subscribed", type: 1)
                            self.subscribeButton.setImage(UIImage(named:"subscribedIcon"), for: .normal)
                            self.subscribeButton.tag=2
                            self.addPointToUser()

                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "Error while Subscribing user..", type: 0)
                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.userDetailsLoading.stopAnimating()
                        self.showToaster(msg: "Error while Subscribing user...", type: 0)
                    }
                }

            } catch let error as NSError {
                self.userDetailsLoading.stopAnimating()
                self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()
    }
    func unsubscribe(){
        self.userDetailsLoading.isHidden=false
        self.userDetailsLoading.startAnimating();

        //var endorsmentId=_sender.id as! String
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/removeUserSubscription")

        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(self.userId!)","subscribeTo":"\(userId)"] as [String:Any]

        print("json removeUserSubscription\(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in

            if (error != nil){
                DispatchQueue.main.async {
                    self.userDetailsLoading.stopAnimating()
                    self.userDetailsLoading.isHidden=true
                }
            }

//            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
//            print("reposnString \(responseSting)")
//

            var error=NSError?.self

            do {

                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")

                    if code==1{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "Unsubscribed", type: 1)
                            self.subscribeButton.setImage(UIImage(named:"subscribebutton2"), for: .normal)
                            self.subscribeButton.tag=1
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            self.userDetailsLoading.stopAnimating()
                            self.userDetailsLoading.isHidden=true
                             self.showToaster(msg: "Error while Subscribing user..", type: 0)
                        }

                    }
                }
                else{
                    DispatchQueue.main.async{
                        self.userDetailsLoading.stopAnimating()
                        self.showToaster(msg: "Error while Subscribing user...", type: 0)
                    }
                }

            } catch let error as NSError {
                self.userDetailsLoading.stopAnimating()
                self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }


        }
        task.resume()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func addPointToUser(){
        /* Add user poins after success of subscribing to user
         @Author Mansi 25.6.18 */
        // add points for user
        let addPointUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/adduserPoint")
        var addPointRequest = URLRequest(url:addPointUrl!)
        addPointRequest.httpMethod = "POST"


        let addPointsJson = ["userId":"\(self.userId)","type":"Subscriber"] as[String : Any]
        print("json \(addPointsJson)")
        let jsonData = try? JSONSerialization.data(withJSONObject: addPointsJson, options: .prettyPrinted)
        addPointRequest.httpBody = jsonData
        addPointRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let addPointsTask=URLSession.shared.dataTask(with: addPointRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error while posting points to user ")
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                    print("user point added succesfully.. ")

                    DispatchQueue.main.async () {


                    }
                }
            }catch let error as NSError {
                print("Failed to load add point Function : \(error.localizedDescription)")
            }
        }
        addPointsTask.resume()
    }
    func fillInCreds() {
        let emptyCred2 =  Credentials (
            name:"  ",
            photo:UIImage()
        )
        let emptyCred =  Credentials (
            name:"No credentials found",
            photo:UIImage())
        switch (self.cred.count) {
        case 0: self.cred.append(emptyCred!)
        self.cred.append(emptyCred2!)
        self.cred.append(emptyCred2!)
            break
        case 1: self.cred.append(emptyCred2!)
        self.cred.append(emptyCred2!)
            break
        case 2: self.cred.append(emptyCred2!)
            break
        default:
            let grouping = Dictionary(grouping: self.cred, by: { $0.photo })
            
            self.cred.removeAll()
            
            for (key, value) in grouping {
                for (index, element) in value.enumerated() {
                    self.cred.append(element);
                }
                
            }
            break
            
        }
        self.credetialsTableView.reloadData()
        self.credentialsHeight.constant = CGFloat(self.cred.count * 40)
        self.credetialsTableView.layoutIfNeeded()
        self.credentialsHeight.constant = self.credetialsTableView.contentSize.height
        
        
    }
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
}

class subscrbeButton: UIButton {
    var id: String!

}

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIViewContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage

        let size = self.size
        let aspectRatio =  size.width/size.height

        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }

        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }

        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
}
return newImage
    }
}
