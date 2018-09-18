//
//  EditProfileViewController.swift
//  logos2
//
//  Created by subodh-mac on 25/06/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON
import GooglePlacePicker
import CoreLocation
import RSSelectionMenu
import Firebase
import FirebaseDatabase
import Foundation

class labelGesture2:UITapGestureRecognizer{
    var id = String()
}
class editlangbtn:UIButton{
    var id = String()
    var name = String()
}

class EditProfileViewController: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var editProfileActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userName: UILabel!
    //@IBOutlet weak var userName: UITextField!
    @IBOutlet weak var chnageProifleButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changePoliticalOrientationBtn: UIButton!
    @IBOutlet weak var languagesTitle: UILabel!
    @IBOutlet weak var changeCurrentLocationBtn: UIButton!
    @IBOutlet weak var userCurrentLocation: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chnageLocationButton: UIButton!
    @IBOutlet weak var chnageNameButton: UIButton!
    @IBOutlet weak var userProfilePhoto: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var langLable: UILabel!
    @IBOutlet weak var userPoliticalOrientation: UILabel!
    @IBOutlet weak var userCurrentLocationButton: UIButton!
    //@IBOutlet weak var userCurrentLocation: UILabel!
    //@IBOutlet weak var userLocation: UILabel!
    var selectedCountry :Any = ""
    var selectedCity :Any = ""
    var type :Int = 1
    var education=[JSON]()
    var experience=[JSON]()
    
    let simpleDataArray = ["Left (liberal)", "Right (conservative)", "Center (moderate)"]
    var simpleSelectedArray = [String]()
    
    var langDataArray = [String]()
    var selectedLang=[String]()
    
    var firstRowSelected = true
    
    var knowsAboutDataArray=[String]()
    var selectedKnowsAbout=[String]()
    let loggedInUserId = UserDefaults.standard.object(forKey: "userId") as! String
    
    var imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    
    
    /* Variable to fetch dynamic height of languageLable*/
    var languageLabelObject = UILabel.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        self.imagePicker.delegate = self
        self.loadUserData(id:self.loggedInUserId);
       // self.loadLanguages(id:self.loggedInUserId);
        self.languages(id:self.loggedInUserId);
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Do any additional setup after loading the view.
        

        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("knowsAbout").observeSingleEvent(of: .value, with: { (snapshot) in
            let knowsAboutList = snapshot.value as? NSDictionary
            for (knowsAboutID, singleKnowsAbout) in knowsAboutList! {
                let knowsAboutDict = singleKnowsAbout as! [String:Any]
//                self.knowsAboutDataArray.append(singleKnowsAbout["name"] as! String)
                self.knowsAboutDataArray.append(knowsAboutDict["name"] as! String)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    override func viewDidLayoutSubviews() {
        userProfilePhoto.layer.cornerRadius = userProfilePhoto.frame.height / 2
        userProfilePhoto.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func loadUserData(id:String){
        // clear prev data
        self.education.removeAll()
        self.experience.removeAll()
        
        //   self.userDetailsLoading.isHidden=false
        // self.userDetailsLoading.startAnimating()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        print(knowsAboutDataArray)
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
                self.userProfilePhoto.image=image

                self.userName.text=userData["name"] as! String
                var city = userData["city"] as! String
                var country = userData["country"] as! String
                var Location:String = city + "," + country
                self.userLocation.text = Location
                var currentCity = userData["currentCity"] as! String
                var currentCountry = userData["currentCountry"] as! String
                var currentLocation:String = currentCity + ", " + currentCountry
                print(" currentLocation \(currentLocation)")
                self.userCurrentLocation.text=currentLocation
                self.userPoliticalOrientation.text = userData["politicalOrientation"] as! String
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
                    var toBePushed = JSON(credDict)
                    // 0:educational  1:Experince
                    if type == 0 {
                        self.education.append(toBePushed)
                    }
                    else if type == 1 {
                        self.experience.append(toBePushed)
                    }
                }
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        self.loadLanguages(id: self.loggedInUserId)
        
    }
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    ///function to load user languages
    func loadLanguages(id:String){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserLanguagesById?key=\(id)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                // self.userDetailsLoading.stopAnimating()
                //  self.userDetailsLoading.isHidden=true
            }
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            print("reposnString \(responseSting)")
            var error=NSError?.self
            do {
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")
                   // DispatchQueue.main.async{
                        var count:Int = 0
                        var xOrigin=CGFloat(self.langLable.frame.origin.y)
                    
                    if code==1{
                        DispatchQueue.main.async{
                            //    self.userDetailsLoading.stopAnimating()
                            //    self.userDetailsLoading.isHidden=true
                            var langData=jsonobj["data"].arrayValue
                          
                            for lang in langData{
                                count = count + 1
                              var langId=lang["languageId"].string
                              var languageData=lang["languageData"]
                                var langName=languageData["name"].string
                                let language=UILabel.init()
                                // 3 tag is for language view
                                language.tag = 3
                                language.frame = CGRect(x: CGFloat(self.userCurrentLocation.frame.origin.x), y: CGFloat(xOrigin + 8), width: UIScreen.main.bounds.size.width - 20.0, height: 80.0)
                                
                                let editLangBtn=editlangbtn.init()
                                editLangBtn.tag = 3
                                editLangBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x), y: CGFloat(language.frame.origin.y - language.frame.size.height/2) + 8.0, width: self.changeCurrentLocationBtn.frame.width, height: 80.0)
                                
                                language.text = langName
                                language.textAlignment = .left
                                language.font = UIFont (name: "HelveticaNeue", size: 15)
                                language.textColor = UIColor.black
                                language.numberOfLines = 0
                                language.sizeToFit()
//                                NSLayoutConstraint(item: language, attribute: .leading, relatedBy: .equal, toItem: self.languagesTitle, attribute: .trailingMargin, multiplier: 1.0, constant: 28.0).isActive = true
                                self.contentView.addSubview(language)
                                
                               
                                editLangBtn.setImage(UIImage(named:"edit"), for: .normal)
                                editLangBtn.id=langId!
                                editLangBtn.name=langName!
                                editLangBtn.addTarget(self, action: #selector(self.editLang), for: .touchUpInside)
//                                NSLayoutConstraint(item: editLangBtn, attribute: .leading, relatedBy: .equal, toItem: language, attribute: .trailingMargin, multiplier: 1.0, constant: 28.0).isActive = true
                                self.contentView.addSubview(editLangBtn)
                                 xOrigin=CGFloat(xOrigin)+language.frame.size.height+10
                            }
                            
                            var y :CGFloat =  0
                            print("count \(count)")
                            if count == 0 {
                                y = self.langLable.frame.origin.y
                            }
                            else {
                                y = xOrigin
                            }
                            let addLangBtn=UIButton.init()
                            addLangBtn.tag = 3
                            addLangBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x), y: CGFloat(y) + 20, width: self.changeCurrentLocationBtn.frame.width, height: 20.0)
                            addLangBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
                            addLangBtn.addTarget(self, action: #selector(self.addLang), for: .touchUpInside)
                            self.contentView.addSubview(addLangBtn)
                            
                            let addLangLable=UILabel.init()
                            addLangLable.tag = 3
                            addLangLable.frame = CGRect(x: CGFloat(self.userCurrentLocation.frame.origin.x), y: CGFloat(y) + 20, width: self.userCurrentLocation.frame.width, height: 80.0)
                            addLangLable.text = "Add Language"
                            addLangLable.font = UIFont (name: "HelveticaNeue", size: 15)
                            addLangLable.textAlignment = .right
                            addLangLable.textColor = UIColor.gray
                            addLangLable.numberOfLines = 0
                            addLangLable.sizeToFit()
                           
                            self.contentView.addSubview(addLangLable)
                            self.loadCredetialsDetaisl(y:addLangLable.frame.origin.y,height: addLangLable.frame.size.height + addLangLable.frame.origin.y)
                            
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            // self.userDetailsLoading.stopAnimating()
                            
                            // self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "No language details found...", type: 0)
                            var y :CGFloat =  0
                           
                            if count == 0 {
                                y = self.langLable.frame.origin.y
                            }
                            else {
                                y = xOrigin
                            }
                            let addLangBtn=UIButton.init()
                            addLangBtn.tag = 3
                            addLangBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28 ), y: CGFloat(y) + 20, width: UIScreen.main.bounds.size.width - 20.0, height: 20.0)
                            addLangBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
                              addLangBtn.addTarget(self, action: #selector(self.addLang), for: .touchUpInside)
                            self.contentView.addSubview(addLangBtn)
                            
                            let addLangLable=UILabel.init()
                            addLangLable.tag = 3
                            addLangLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 53 ), y: CGFloat(y) + 20, width: UIScreen.main.bounds.size.width - 20.0, height: 80.0)
                            addLangLable.text = "Add Language"
                            addLangLable.textAlignment = .right
                            addLangLable.textColor = UIColor.gray
                            addLangLable.font = UIFont (name: "HelveticaNeue", size: 15)
                            addLangLable.numberOfLines = 0
                            addLangLable.sizeToFit()
                            self.contentView.addSubview(addLangLable)
                            self.languageLabelObject = addLangLable
                            
                            // After loading languages load credentials
                            self.loadCredetialsDetaisl(y:addLangLable.frame.origin.y,height: addLangLable.frame.size.height + addLangLable.frame.origin.y)
                           
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        //   self.userDetailsLoading.stopAnimating()
                        
                        //   self.userDetailsLoading.isHidden=true
                        self.showToaster(msg: "Error while fetching user details...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                // self.userDetailsLoading.stopAnimating()
                
                // self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    //load cred lables
    func loadCredetialsDetaisl(y:CGFloat,height:CGFloat){
        print("in loadCre \(self.education)")
        self.ShowLoading()
        //credential label
        let credLable=UILabel.init()
        credLable.tag = 3
        credLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(height + 10), width: 500, height: 80.0)
        credLable.text = "Credentials"
        credLable.textAlignment = .left
        credLable.textColor = UIColor.black
        credLable.font = UIFont (name: "HelveticaNeue-Bold", size: 15)
        credLable.numberOfLines = 0
        credLable.frame.size = credLable.intrinsicContentSize
        credLable.sizeToFit()
        self.contentView.addSubview(credLable)
        
        //educations label
        let eduLable=UILabel.init()
        eduLable.tag = 3
        eduLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(credLable.frame.origin.y+credLable.frame.size.height) + 15, width: self.contentView.frame.size.width / 2, height: 80.0)
        eduLable.text = "Education"
        eduLable.textAlignment = .left
        eduLable.textColor = UIColor.gray
        eduLable.font = UIFont (name: "HelveticaNeue", size: 15)
        eduLable.numberOfLines = 0
        eduLable.frame.size = eduLable.intrinsicContentSize
        eduLable.sizeToFit()
        
        self.contentView.addSubview(eduLable)
        
        let addEduLable=UILabel.init()
        addEduLable.tag = 3
        /*addEduLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 53 ), y: CGFloat(eduLable.frame.origin.y+eduLable.frame.size.height) + 15, width: UIScreen.main.bounds.size.width - 20.0, height: 80.0)*/
        addEduLable.frame = CGRect(x: CGFloat(self.userCurrentLocation.frame.origin.x), y: CGFloat(credLable.frame.origin.y+credLable.frame.size.height + 5 ) + 15, width: self.userCurrentLocation.frame.width, height: 80.0)
        addEduLable.text = "Add Education"
        addEduLable.textAlignment = .right
        addEduLable.textColor = UIColor.gray
        addEduLable.font = UIFont (name: "HelveticaNeue", size: 15)
        addEduLable.numberOfLines = 0
        addEduLable.sizeToFit()
        //        NSLayoutConstraint(item: addEduLable, attribute: .trailing, relatedBy: .equal, toItem: addEduBtn, attribute: .leading, multiplier: 1.0, constant: 10.0).isActive = true
        self.contentView.addSubview(addEduLable)
       
        //add education button
        let addEduBtn=UIButton.init()
        addEduBtn.tag = 3
        addEduBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x), y: CGFloat(credLable.frame.origin.y+credLable.frame.size.height + 5)+15, width: self.changeCurrentLocationBtn.frame.width, height: 20.0)
        addEduBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
        addEduBtn.addTarget(self, action: #selector(self.showAddEdupopuo), for: .touchUpInside)
        self.contentView.addSubview(addEduBtn)
        //add education button
//        let addEduBtn=UIButton.init()
//        addEduBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28 ), y: CGFloat(credLable.frame.origin.y+credLable.frame.size.height) + 15, width: self.contentView.frame.size.width / 2, height: 80.0)
//        addEduBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
//      //  addEduBtn.tintColor(UIColor(named: "red"))
//        addEduBtn.addTarget(self, action: #selector(self.showAddEdupopuo), for: .touchUpInside)
//        self.contentView.addSubview(addEduBtn)
        
       
     
        
         var yPosition = addEduLable.frame.size.height + addEduLable.frame.origin.y + 20
        for edu in self.education  {
            print("name \(edu["name"])")
            let edutitileLable=UILabel.init()
            edutitileLable.tag = 3
            edutitileLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(yPosition), width: self.view.frame.size.width/3, height: 80.0)
            edutitileLable.text = edu["creadentials"].string
            edutitileLable.textAlignment = .left
            edutitileLable.textColor = UIColor.black
            edutitileLable.numberOfLines = 0
            edutitileLable.sizeToFit()
            edutitileLable.font = UIFont (name: "HelveticaNeue", size: 15)
            edutitileLable.frame.size = edutitileLable.intrinsicContentSize
            self.contentView.addSubview(edutitileLable)
    
            let editEduBtn=editlangbtn.init()
            editEduBtn.tag = 3
            editEduBtn.frame = CGRect(x: CGFloat(self.chnageNameButton.frame.origin.x), y: CGFloat(yPosition + eduLable.frame.size.height - 25), width: self.changeCurrentLocationBtn.frame.width, height: 40.0)
            editEduBtn.id=edu["userId"].string!
            editEduBtn.name=edu["creadentials"].string!
            editEduBtn.setImage(UIImage(named:"edit"), for: .normal)
            editEduBtn.addTarget(self, action: #selector(self.showEditEdupop), for: .touchUpInside)
            self.contentView.addSubview(editEduBtn)
            
            yPosition = yPosition + edutitileLable.frame.size.height+10
            print("y :\(yPosition)")
        }
        
  
        
        //experience label
       let exYposition = yPosition + 10
        let expLable=UILabel.init()
        expLable.tag = 3
        expLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(exYposition), width: self.contentView.frame.size.width, height: 80.0)
        expLable.text = "Experience"
        expLable.textAlignment = .left
        expLable.textColor = UIColor.gray
        expLable.font = UIFont (name: "HelveticaNeue", size: 15)
        expLable.numberOfLines = 0
        expLable.frame.size = expLable.intrinsicContentSize
        expLable.sizeToFit()
        self.contentView.addSubview(expLable)
        
        let addExpBtn=UIButton.init()
        addExpBtn.tag = 3
        //        addExpBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28 ), y: CGFloat(yExpPosition), width: UIScreen.main.bounds.size.width - 20.0, height: 20.0)
        addExpBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x), y: CGFloat(expLable.frame.origin.y+expLable.frame.size.height+5.0), width: self.changeCurrentLocationBtn.frame.width, height: 20.0)
        addExpBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
        addExpBtn.addTarget(self, action: #selector(self.showAddExpPopuo), for: .touchUpInside)
        self.contentView.addSubview(addExpBtn)
        
        let addExpLable=UILabel.init()
        addExpLable.tag = 3
        addExpLable.frame = CGRect(x: CGFloat(self.userCurrentLocation.frame.origin.x), y: CGFloat(expLable.frame.origin.y+expLable.frame.size.height+5.0), width: self.langLable.frame.width, height: 80.0)
        addExpLable.text = "Add Experience"
        addExpLable.textAlignment = .right
        addExpLable.textColor = UIColor.gray
        addExpLable.font = UIFont (name: "HelveticaNeue", size: 15)
        addExpLable.numberOfLines = 0
        addExpLable.sizeToFit()
        
        self.contentView.addSubview(addExpLable)
        
       // let addExpBtn=UIButton.init()
//        addExpBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28 ), y: CGFloat(yExpPosition), width: UIScreen.main.bounds.size.width - 20.0, height: 20.0)
      

       
        //aray of experience
        var yExpPosition = addExpLable.frame.size.height + addExpLable.frame.origin.y + 15
        
        for exp in self.experience  {
            print("name \(exp["creadentials"])")
            let exptitileLable=UILabel.init()
            exptitileLable.tag = 3
            exptitileLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(yExpPosition), width: self.view.frame.size.width/3, height: 80.0)
            exptitileLable.text = exp["creadentials"].string
            exptitileLable.textAlignment = .left
            exptitileLable.textColor = UIColor.black
            exptitileLable.numberOfLines = 0
            exptitileLable.sizeToFit()
            exptitileLable.font = UIFont (name: "HelveticaNeue", size: 15)
            exptitileLable.frame.size = exptitileLable.intrinsicContentSize
            self.contentView.addSubview(exptitileLable)
            
            
            let editExpBtn=editlangbtn.init()
            editExpBtn.tag = 3
            editExpBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x), y: CGFloat(yExpPosition) - 10, width: self.changeCurrentLocationBtn.frame.width, height: 40.0)
            editExpBtn.id=exp["userId"].string!
            editExpBtn.name=exp["creadentials"].string!
            editExpBtn.setImage(UIImage(named:"edit"), for: .normal)
            editExpBtn.addTarget(self, action: #selector(self.showEditEdupop), for: .touchUpInside)
            self.contentView.addSubview(editExpBtn)
           
            yExpPosition = yExpPosition + exptitileLable.frame.size.height+10
            print("y :\(yExpPosition)")
        }
        //add experienc button
//        let addExpBtn=UIButton.init()
//        addExpBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28 ), y: CGFloat(yExpPosition), width: UIScreen.main.bounds.size.width - 20.0, height: 20.0)
//        addExpBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
//        addExpBtn.addTarget(self, action: #selector(self.showAddExpPopuo), for: .touchUpInside)
//        self.contentView.addSubview(addExpBtn)
//
//        let addExpLable=UILabel.init()
//        addExpLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 53 ), y: CGFloat(yExpPosition), width: UIScreen.main.bounds.size.width - 20.0, height: 80.0)
//        addExpLable.text = "Add Experience"
//        addExpLable.textAlignment = .right
//        addExpLable.textColor = UIColor.gray
//        addExpLable.font = UIFont (name: "HelveticaNeue", size: 15)
//        addExpLable.numberOfLines = 0
//        addExpLable.sizeToFit()
//
//        self.contentView.addSubview(addExpLable)
        

        
        //knows about lable
        let knAbtLable=UILabel.init()
        knAbtLable.tag = 3
        knAbtLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(yExpPosition + 10 ), width: self.langLable.frame.width, height: 80.0)
        knAbtLable.text = "Knows About"
        knAbtLable.textAlignment = .left
        knAbtLable.textColor = UIColor.black
        knAbtLable.font = UIFont (name: "HelveticaNeue-Bold", size: 15)
        knAbtLable.numberOfLines = 0
        knAbtLable.frame.size = expLable.intrinsicContentSize
        knAbtLable.sizeToFit()
        
        self.contentView.addSubview(knAbtLable)
        
        
        let addknAbtBtn=UIButton.init()
        addknAbtBtn.tag = 3
        addknAbtBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x), y: CGFloat(yExpPosition) + 15, width: self.changeCurrentLocationBtn.frame.width, height: 20.0)
        addknAbtBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
        
        addknAbtBtn.addTarget(self, action: #selector(self.showAddKnAbtPopuo), for: .touchUpInside)
        self.contentView.addSubview(addknAbtBtn)
        
        let addknAbtLable=UILabel.init()
        addknAbtLable.tag = 3
        addknAbtLable.frame = CGRect(x: CGFloat(self.userCurrentLocation.frame.origin.x), y: CGFloat(yExpPosition) + 15, width: self.userCurrentLocation.frame.width, height: 80.0)
        addknAbtLable.text = "Add Knows About"
        addknAbtLable.textAlignment = .right
        addknAbtLable.textColor = UIColor.gray
        addknAbtLable.font = UIFont (name: "HelveticaNeue", size: 15)
        addknAbtLable.numberOfLines = 0
        addknAbtLable.sizeToFit()
        self.contentView.addSubview(addknAbtLable)
        
        self.loadPreDefinedKnowsAbout(id:self.loggedInUserId)
        
        self.loadKnowsAbout(id: self.loggedInUserId,height:knAbtLable.frame.size.height, yPos: knAbtLable.frame.origin.y )
        self.HideLoading()
    }
    
    // load user's knows about
    func loadPreDefinedKnowsAbout(id:String){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let userID = self.loggedInUserId as! String
        ref.child("userknowsabout").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let knowsAboutList = snapshot.value as? NSDictionary
//            print(knowsABoutList)
            //            var newsofpost: [String] = []
            if (knowsAboutList == nil) {
                self.showToaster(msg: "No Knows About Found", type: 0)
                return
            }
            for(knowsAboutID, singleKnowsAbout) in knowsAboutList!
            {
                print(singleKnowsAbout)
                let knowsAboutDict = singleKnowsAbout as! [String:Any]
                print("part 1")
                print(knowsAboutDict["userId"])
                if(knowsAboutDict["userId"] as! String == userID)
                {
                    //                    newsofpost.append(evrythingdict["content"]!)
                    var knowsAboutName = knowsAboutDict["knowledge"] as! String
                    self.selectedKnowsAbout.append(knowsAboutName)
//                    self.newsList.append(new2)
                }
            }
//            self.articlesTableView.reloadData()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    
    }
    @objc func showAddExpPopuo(_sender:UIButton){
        let alertController = UIAlertController(title: "Save", message: "Please Enter Experience Details:", preferredStyle: .alert)
        let cancelAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
     
        alertController.addAction(cancelAction1)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            
            
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.addEducation(name: fNameField.text!,type: 1)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter Experience Details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // function to load user's knows about
    func loadKnowsAbout(id:String,height:CGFloat,yPos:CGFloat){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getUserEndorsmentsById?key=\(self.loggedInUserId)")
        
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
            }
            
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
           // print("reposnString \(responseSting)")
            
            
            var error=NSError?.self
            
            do {
                
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                   // print("code \(code)")
                    var yExpPosition = height +  yPos
                    if code==1{
                        DispatchQueue.main.async{
                            //self.showToaster(msg: "Language added Successfully", type: 1)
                            let data=jsonobj["data"].arrayValue
                            
                            for knowsAbt in data{
                                var knowsAbtData=knowsAbt["endorsmentData"]
                                let knowsAbtLable=UILabel.init()
                                knowsAbtLable.tag = 3
                                knowsAbtLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x), y: CGFloat(yExpPosition) + 10, width: self.view.frame.size.width/3, height: 10.0)
                                knowsAbtLable.text = knowsAbtData["knowledge"].string
                                knowsAbtLable.textAlignment = .left
                                knowsAbtLable.textColor = UIColor.black
                                knowsAbtLable.numberOfLines = 0
                                knowsAbtLable.sizeToFit()
                                knowsAbtLable.font = UIFont (name: "HelveticaNeue", size: 15)
                                knowsAbtLable.frame.size = knowsAbtLable.intrinsicContentSize
                                self.contentView.addSubview(knowsAbtLable)
                                
                                
                                let editKnowsAbtBtn=editlangbtn.init()
                                editKnowsAbtBtn.tag = 3
                                editKnowsAbtBtn.frame = CGRect(x: CGFloat(self.changeCurrentLocationBtn.frame.origin.x ), y: CGFloat(yExpPosition-22), width: self.changeCurrentLocationBtn.frame.width, height: 80.0)
                                editKnowsAbtBtn.id=knowsAbt["endorsmentId"].string!
                                editKnowsAbtBtn.name=knowsAbtData["knowledge"].string!
                                editKnowsAbtBtn.setImage(UIImage(named:"edit"), for: .normal)
                                editKnowsAbtBtn.addTarget(self, action: #selector(self.showEditKnAbtpop), for: .touchUpInside)
                                self.contentView.addSubview(editKnowsAbtBtn)
                                
                                yExpPosition = yExpPosition + knowsAbtLable.frame.size.height+5
                              //  print("y :\(yExpPosition)")
                            }
                            // add user knows about button
                            //add experienc button
//                            let addknAbtBtn=UIButton.init()
//                            addknAbtBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28 ), y: CGFloat(yExpPosition) + 15, width: UIScreen.main.bounds.size.width - 20.0, height: 20.0)
//                            addknAbtBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
//
//                            addknAbtBtn.addTarget(self, action: #selector(self.showAddKnAbtPopuo), for: .touchUpInside)
//                            self.contentView.addSubview(addknAbtBtn)
//
//                            let addknAbtLable=UILabel.init()
//                            addknAbtLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 53), y: CGFloat(yExpPosition) + 15, width: UIScreen.main.bounds.size.width - 20.0, height: 80.0)
//                            addknAbtLable.text = "Add Knows About"
//                            addknAbtLable.textAlignment = .right
//                            addknAbtLable.textColor = UIColor.gray
//                            addknAbtLable.font = UIFont (name: "HelveticaNeue", size: 15)
//                            addknAbtLable.numberOfLines = 0
//                            addknAbtLable.sizeToFit()
//                            self.contentView.addSubview(addknAbtLable)
                            
                            var contentRect = CGRect.zero
                            
                            for view in self.contentView.subviews {
                                contentRect = contentRect.union(view.frame)
                            }
                            self.scrollView.contentSize = contentRect.size
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            // add user knows about button
                            //add experienc button
//                            let addknAbtBtn=UIButton.init()
//                            addknAbtBtn.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 28.0), y: CGFloat(yExpPosition) + 10, width: UIScreen.main.bounds.size.width - 20.0, height: 20.0)
//                            addknAbtBtn.setImage(UIImage(named:"addeditprofile"), for: .normal)
//                            addknAbtBtn.addTarget(self, action: #selector(self.showAddKnAbtPopuo), for: .touchUpInside)
//                            self.contentView.addSubview(addknAbtBtn)
//
//                            let addknAbtLable=UILabel.init()
//                            addknAbtLable.frame = CGRect(x: CGFloat(self.langLable.frame.origin.x + self.langLable.frame.width + 53 ), y: CGFloat(yExpPosition), width: UIScreen.main.bounds.size.width - 20.0, height: 80.0)
//                            addknAbtLable.text = "Add Knows About"
//                            addknAbtLable.textAlignment = .left
//                            addknAbtLable.textColor = UIColor.gray
//                            addknAbtLable.font = UIFont (name: "HelveticaNeue", size: 15)
//                            addknAbtLable.numberOfLines = 0
//                            addknAbtLable.sizeToFit()
//                            self.contentView.addSubview(addknAbtLable)
                            
                            var contentRect = CGRect.zero
                            
                            for view in self.contentView.subviews {
                                contentRect = contentRect.union(view.frame)
                            }
                            self.scrollView.contentSize = contentRect.size
                            // self.showToaster(msg: "Error while adding language...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        //self.showToaster(msg: "Error while adding language...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    //function to add knows about details
    @objc func showAddKnAbtPopuo(_sender:UIButton){
        let selectionMenu =  RSSelectionMenu(selectionType: .Multiple, dataSource: self.knowsAboutDataArray, cellType: .SubTitle) { (cell, object, indexPath) in
//            let firstName = object.components(separatedBy: " ").first
//            let lastName = object.components(separatedBy: " ").last
            cell.textLabel?.text = object
//            cell.detailTextLabel?.text = lastName
        }
        selectionMenu.setSelectedItems(items: self.selectedKnowsAbout) { (text, selected, selectedItems) in
            // self.selectedLang = selectedItems
            //self.addNewLang()
        }
        selectionMenu.addFirstRowAs(rowType: .All, showSelected:self.firstRowSelected) { (text, isSelected) in
            self.firstRowSelected = isSelected
        }
        selectionMenu.showSearchBar { (searchtext) -> ([String]) in
            return self.knowsAboutDataArray.filter({ $0.lowercased().hasPrefix(searchtext.lowercased()) })
        }
        selectionMenu.setNavigationBar(title: "Select Knows About", attributes: nil, barTintColor: UIColor.gray.withAlphaComponent(0.5), tintColor: UIColor.white)
        selectionMenu.rightBarButtonTitle = "Submit"
        // get on dismiss event with selected items
        selectionMenu.onDismiss = { selectedItems in
            self.selectedKnowsAbout = selectedItems
            self.addKnowsAbout()
        }
        selectionMenu.show(from: self)
       /* let alertController = UIAlertController(title: "Save", message: "Please Enter Knows About Details to be add:", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            
            
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.addKnowsAbout(name: fNameField.text!)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please Enter Knows About Details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Knows About"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)*/
    }
    func addKnowsAbout(){
        var count = 0
        for name in self.selectedKnowsAbout{
            let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addUserKnowsAbout")
            
            var request=URLRequest(url:url!)
            request.httpMethod="POST"
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            let data = ["userId":"\(userId)",  "name":"\(name)"] as[String : Any]
            print("json \(data)")
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                }
            var error=NSError?.self
            do {
                    if data != nil{
                        var jsonobj=JSON(data!)
                        let code=jsonobj["code"].int!
                        print("code 3344\(code)")
                        
                        if code == 1{
                           // DispatchQueue.main.async{
                                
                                //self.loadUserData(id: self.loggedInUserId)
                                print("adding count")
                                count = count + 1
                                
                           // }
                        }
                        else{
                            DispatchQueue.main.async{
                                
                                self.showToaster(msg: "Error while adding knows about...", type: 0)
                            }
                            
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while adding knows about...", type: 0)
                        }
                    }
                    print("count \(count) == \(self.selectedKnowsAbout.count)")
                    if count == self.selectedKnowsAbout.count {
                        DispatchQueue.main.async {
                            self.showToaster(msg: "Knows About added Successfully", type: 1)
                            // Reload all data function
                            self.reloadUserProfileData()

                            
                        }
                       
                    }
                    else{
                        DispatchQueue.main.async {
                            self.showToaster(msg: "Error while adding knows about ...", type: 0)
                        }
                    }
                    
                } /*catch let error as NSError {
                 
                 print("Failed to load: \(error.localizedDescription)")
                 }*/
                
                
            }
            task.resume()
            
        }// end for
      
        
    }
    //function to edit knows about
    @objc func showEditKnAbtpop(_sender:editlangbtn){
        let selectionMenu =  RSSelectionMenu(selectionType: .Multiple, dataSource: self.knowsAboutDataArray, cellType: .SubTitle) { (cell, object, indexPath) in
//            let firstName = object.components(separatedBy: " ").first
//            let lastName = object.components(separatedBy: " ").last
//            cell.textLabel?.text = firstName
//            cell.detailTextLabel?.text = lastName
            cell.textLabel?.text = object
        }
        selectionMenu.setSelectedItems(items: self.selectedKnowsAbout) { (text, selected, selectedItems) in
            // self.selectedLang = selectedItems
            //self.addNewLang()
        }
        selectionMenu.addFirstRowAs(rowType: .All, showSelected:self.firstRowSelected) { (text, isSelected) in
            self.firstRowSelected = isSelected
        }
        selectionMenu.showSearchBar { (searchtext) -> ([String]) in
            return self.knowsAboutDataArray.filter({ $0.lowercased().hasPrefix(searchtext.lowercased()) })
        }
        selectionMenu.setNavigationBar(title: "Select Knows About", attributes: nil, barTintColor: UIColor.gray.withAlphaComponent(0.5), tintColor: UIColor.white)
        selectionMenu.rightBarButtonTitle = "Submit"
        // get on dismiss event with selected items
        selectionMenu.onDismiss = { selectedItems in
            self.selectedKnowsAbout = selectedItems
            self.editKnowsAbout(name:selectedItems[0],id:_sender.id)
        }
        selectionMenu.show(from: self)
       /* let alertController = UIAlertController(title: "Save", message: "Please Enter knows About Details to be edit:", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            
            
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.editKnowsAbout(name: fNameField.text!,id:_sender.id)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter Enter knows About Details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)*/
    }
    func editKnowsAbout(name:String,id:String){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateKnowsAbout")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "credNo":"\(id)","name":"\(name)" ] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                            self.showToaster(msg: "knows about edited Successfully", type: 1)
                           // Reload all data function
                                self.reloadUserProfileData()
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                             self.showToaster(msg: "Error while adding language...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        //self.showToaster(msg: "Error while adding language...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    //show pop up to edit edcation
    @objc func showEditEdupop(_sender:editlangbtn){
        let alertController = UIAlertController(title: "Save", message: "Edit details:", preferredStyle: .alert)
        
        let cancelAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        
        alertController.addAction(cancelAction1)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            
            
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.editEducation(name: fNameField.text!,id:_sender.id)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter Education Details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
    func editEducation(name:String,id:String){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateCredentials")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = [ "credNo":"\(id)","name":"\(name)" ] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                            //self.showToaster(msg: "Language added Successfully", type: 1)
                            // self.loadUserData(id: self.loggedInUserId)
                            
                          
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            // self.showToaster(msg: "Error while adding language...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        //self.showToaster(msg: "Error while adding language...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    //show pop up to get new education deatils
    @objc func showAddEdupopuo(_sender:UIButton){
        let alertController = UIAlertController(title: "Save", message: "Add education details:", preferredStyle: .alert)
        let cancelAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        
        alertController.addAction(cancelAction1)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            
            
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.addEducation(name: fNameField.text!,type:0)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please Enter Education Details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Education Details"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
    func addEducation(name:String,type:Int){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addCredentials")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(userId)",  "name":"\(name)","type":"\(type)", ] as[String : Any]
        print("json \(data)")
        print("subodh \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
            }
            
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            //print("reposnString \(responseSting)")
            
            
            var error=NSError?.self
            
            do {
                
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("add education code is\(String(describing: code))")
                    
                    if code==1{
                        DispatchQueue.main.async{
                            self.showToaster(msg: "Details added Successfully", type: 1)
                            // Reload all data function
                            self.reloadUserProfileData()
                            
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                             self.showToaster(msg: "Error while adding language...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        self.showToaster(msg: "Error while adding language...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    @IBAction func chnagePhoto(_ sender: Any) {
        // Create the alert controller
        print("in chose photo from gallary")
        let alertController = UIAlertController(title: "Photos", message: "Choose Photo", preferredStyle: .alert)
        
        // Create the actions
        let photoAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                // var imagePicker = UIImagePickerController()
                //imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
               // print("image picked :\(self.imagePicked.image)")
            }
        }
        let cancelAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(photoAction)
        alertController.addAction(cancelAction1)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("in on click function")
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType  == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            print("Image Selected")
            
            print("data \(image)")
            let storageRef = storage.reference()
            var data = NSData()
            data = UIImageJPEGRepresentation(image, 0.8)! as NSData
            // set upload path
            let ticks = self.loggedInUserId
            print(ticks)
            let filePath = "User/\(ticks)" // path where you wanted to store img in storage
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/jpg"
            
            var storageRef1 = Storage.storage().reference()
            storageRef1.child(filePath).putData(data as Data, metadata: nil){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.dismiss(animated:true, completion: nil)
                    return
                }else{
                    storageRef1.child(filePath).downloadURL { (url, error) in
                        
                        print("error \(url)")
                        guard let downloadURL = url else {
                            fatalError("error ")
                            return
                        }
                        print("download \(url?.absoluteString)")
                        print("download \(url!.absoluteURL)")
                        var phototurl=url!.absoluteString as String
                        let userImageUrl:URL = URL(string:phototurl)!
                        let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                        self.userProfilePhoto.image = UIImage(data:userImageData as Data)!
                        self.saveUserPhoto(downloadURL:(url?.absoluteString)!)
                        self.dismiss(animated:true, completion: nil)
                        
                    }
                }
            }
        }
    }
        func saveUserPhoto(downloadURL:String){
            let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateUser")
            
            var request=URLRequest(url:url!)
            request.httpMethod="POST"
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            let data = ["userId":"\(userId)","data":["photo":"\(downloadURL as! String)"]] as[String : Any]
            print("json \(data)")
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                
                if (error != nil){
                    //self.userDetailsLoading.stopAnimating()
                    //self.userDetailsLoading.isHidden=true
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
                                self.showToaster(msg: "Profile photo changed", type: 1)
                                self.loadUserData(id: self.loggedInUserId)
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                
                               self.showToaster(msg: "Error while updating user profile", type: 0)
                            }
                            
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while updating user profile", type: 0)
                        }
                    }
                    
                } catch let error as NSError {
                    
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                
            }
            task.resume()
        }
        
        
    
    @IBAction func changeUserName(_ sender: Any) {
        let alertController = UIAlertController(title: "Save", message: "Please Enter Name to be Changed:", preferredStyle: .alert)
        let cancelAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        
        alertController.addAction(cancelAction1)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            
            
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.saveName(name: fNameField.text!)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please Enter Name", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }
    func saveName(name:String){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateUser")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(userId)","data":["name":"\(name)"]] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                           self.showToaster(msg: "Name Changed Successfully", type: 1)
                            self.loadUserData(id: self.loggedInUserId)
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while chnaging name...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        self.showToaster(msg: "Error while chnaging name...", type: 0)
                    }
                }
                
            } catch let error as NSError {
               
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    @IBAction func chnageUserLocation(_ sender: Any) {
        self.type = 1
        self.searchLocationFunction()
    }

    @IBAction func chnageUserCurrentLocation(_ sender: Any) {
        self.type = 2
        self.searchLocationFunction()
    }
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?)->String {
        // Update View
        var location="NA"
        
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            //    locationLabel.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                
                location=placemark.locality!
                
            } else {
                
            }
        }
        return location
    }
    


    func searchLocationFunction(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as! GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true, completion: nil)
    }
    func saveUserLocation(city:String,country:String,latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        print("in saveuserLocation function")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateUser")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(userId)","data":["city":"\(city)","country":"\(country)","latitude":"\(latitude)","longitude":"\(longitude)" ]] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                            self.showToaster(msg: "Location Details Changed Successfully", type: 1)
                            self.loadUserData(id: self.loggedInUserId)
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while chnaging location...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        self.showToaster(msg: "Error while chnaging location...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    func saveUserCurrentLocation(city:String,country:String){
        print("in saveUserCurrentLocation function")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateUser")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(userId)","data":["currentCity":"\(city)","currentCountry":"\(country)"]] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                            self.showToaster(msg: "Location Details Changed Successfully", type: 1)
                            self.loadUserData(id: self.loggedInUserId)
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while chnaging location...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        self.showToaster(msg: "Error while chnaging location...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    @IBAction func changePoliticalOrientation(_ sender: Any) {
        print("in change orientation function")
        self.showAsPopover(self.view)
    }
    func showAsPopover(_ sender: UIView) {
        print("in show as popover")
        let selectionMenu = RSSelectionMenu(dataSource: simpleDataArray) { (cell, object, indexPath) in
            cell.textLabel?.text = object
        }
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            print("selcted \(selectedItems)")
            self.updatePoliticalOrientation(name: selectedItems[0])
        }
        print("selcted \(self.simpleSelectedArray)")
        //selectionMenu.show(style: .Formsheet, from: self)
        selectionMenu.show(style: .Popover(sourceView: self.contentView, size: nil), from: self)
    }
    func updatePoliticalOrientation(name:String){
        print("in saveUserCurrentLocation function")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateUser")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(userId)","data":["politicalOrientation":"\(name)",]] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                            self.showToaster(msg: "Political Orientation Changed Successfully", type: 1)
                            self.loadUserData(id: self.loggedInUserId)
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while chnaging Political Orientation...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        self.showToaster(msg: "Error while chnaging Political Orientation...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load Political Orientation: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    @objc func editLang(_sender:editlangbtn){
       let selectionMenu =  RSSelectionMenu(selectionType: .Single, dataSource: langDataArray, cellType: .SubTitle) { (cell, object, indexPath) in
            
            let firstName = object.components(separatedBy: " ").first
            let lastName = object.components(separatedBy: " ").last
            
            cell.textLabel?.text = firstName
            cell.detailTextLabel?.text = lastName
        }
//
//        selectionMenu.setSelectedItems(items: self.selectedLang) { (text, selected, selectedItems) in
//            self.selectedLang = selectedItems
//            self.savelanguage(id:_sender.id,name:selectedItems[0])
//        }
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            print("selcted \(selectedItems)")
           self.savelanguage(id:_sender.id,name:selectedItems[0])
        }
        selectionMenu.addFirstRowAs(rowType: .Custom(value: _sender.name), showSelected:self.firstRowSelected) { (text, isSelected) in
            self.firstRowSelected = isSelected
        }
        
        selectionMenu.showSearchBar { (searchtext) -> ([String]) in
            return self.langDataArray.filter({ $0.lowercased().hasPrefix(searchtext.lowercased()) })
        }
        
        selectionMenu.setNavigationBar(title: "Select Language", attributes: nil, barTintColor: UIColor.orange.withAlphaComponent(0.5), tintColor: UIColor.white)
     
        selectionMenu.rightBarButtonTitle = "Submit"
     
        selectionMenu.show(from: self)
    }
    //function to edit user language
    func savelanguage(id:String,name:String){
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateLanguage")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["id":"\(id)","data":["name":"\(name)"]] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                //self.userDetailsLoading.stopAnimating()
                //self.userDetailsLoading.isHidden=true
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
                            self.showToaster(msg: "Language Edited Successfully", type: 1)
                            //self.loadUserData(id: self.loggedInUserId)
                            DispatchQueue.main.async{
                                self.showToaster(msg: "Language added Successfully", type: 1)
                                
                                // Reload all data function
                                self.reloadUserProfileData()
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            self.showToaster(msg: "Error while editing language...", type: 0)
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        
                        self.showToaster(msg: "Error while adding language...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
    //on click of add language buttob
    @objc func addLang(_sender:UIButton){
        let selectionMenu =  RSSelectionMenu(selectionType: .Multiple, dataSource: langDataArray, cellType: .SubTitle) { (cell, object, indexPath) in
            let firstName = object.components(separatedBy: " ").first
            let lastName = object.components(separatedBy: " ").last
            cell.textLabel?.text = firstName
            cell.detailTextLabel?.text = lastName
        }
       selectionMenu.setSelectedItems(items: self.selectedLang) { (text, selected, selectedItems) in
               // self.selectedLang = selectedItems
                //self.addNewLang()
              }
           selectionMenu.addFirstRowAs(rowType: .All, showSelected:self.firstRowSelected) { (text, isSelected) in
            self.firstRowSelected = isSelected
        }
        selectionMenu.showSearchBar { (searchtext) -> ([String]) in
            return self.langDataArray.filter({ $0.lowercased().hasPrefix(searchtext.lowercased()) })
        }
        selectionMenu.setNavigationBar(title: "Select Language", attributes: nil, barTintColor: UIColor.gray.withAlphaComponent(0.5), tintColor: UIColor.white)
        selectionMenu.rightBarButtonTitle = "Submit"
        // get on dismiss event with selected items
        selectionMenu.onDismiss = { selectedItems in
            self.selectedLang = selectedItems
            self.addNewLang()
        }
        selectionMenu.show(from: self)
    }
    //function to add lang n db
    func addNewLang(){
        print("in add lang selected lenaguage count is \(self.selectedLang.count)")
        var count = 0
       
        for lang in self.selectedLang {
            let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addUserLanguages")
            
            var request=URLRequest(url:url!)
            request.httpMethod="POST"
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            let data = ["userId":"\(userId)",  "name":"\(lang)" ] as[String : Any]
            print("json \(data)")
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                
                if (error != nil){
                    //self.userDetailsLoading.stopAnimating()
                    //self.userDetailsLoading.isHidden=true
                }
                
                let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                print("reposnString \(responseSting)")
                
                
                var error=NSError?.self
                
                do {
                    print("in add language do...")
                    if data != nil{
                        var jsonobj=JSON(data!)
                        let code=jsonobj["code"].int
                        print("code in add language.. \(code)")
                        
                        if code==1{
                            DispatchQueue.main.async{
                                //self.showToaster(msg: "Language added Successfully", type: 1)
                               // self.loadUserData(id: self.loggedInUserId)
                                count = count + 1
                                print("count in add language \(count) and language length is \(self.selectedLang.count)")
                                if count == self.selectedLang.count {
                                    DispatchQueue.main.async{
                                        self.showToaster(msg: "Language added Successfully", type: 1)
                                     
                                        // Reload all data function
                                       self.reloadUserProfileData()
                                    }
                                }
                                else{
                                    DispatchQueue.main.async{
                                        
                                        self.showToaster(msg: "Error while adding language...", type: 0)
                                    }
                                }
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                
                               // self.showToaster(msg: "Error while adding language...", type: 0)
                            }
                            
                        }
                    }
                    else{
                        print("got data nil in else of add language..")
                        DispatchQueue.main.async{
                            
                            //self.showToaster(msg: "Error while adding language...", type: 0)
                        }
                    }
                    
                } catch let error as NSError {
                    
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                
            }
            task.resume()
        }
        
    }
    func languages(id:String){
        print("in language functions")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getAllLanguages?key=\(id)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                // self.userDetailsLoading.stopAnimating()
                //  self.userDetailsLoading.isHidden=true
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
                            //    self.userDetailsLoading.stopAnimating()
                            //    self.userDetailsLoading.isHidden=true
                            var langData=jsonobj["data"].arrayValue
                            for lang in langData {
                                var name=lang["name"].string
                                self.langDataArray.append(name!);
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            // self.userDetailsLoading.stopAnimating()
                            // self.userDetailsLoading.isHidden=true
                            self.showToaster(msg: "No language Details found...", type: 0)
                            
                        }
                        
                    }
                }
                else{
                    DispatchQueue.main.async{
                        //   self.userDetailsLoading.stopAnimating()
                        
                        //   self.userDetailsLoading.isHidden=true
                        self.showToaster(msg: "Error while Fetching User Details...", type: 0)
                    }
                }
                
            } catch let error as NSError {
                // self.userDetailsLoading.stopAnimating()
                
                // self.userDetailsLoading.isHidden=true
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }
}


/*Google's API to search locations
 @Author Subodh3344
 */
extension EditProfileViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Lat : \(place.coordinate.latitude) and Long : \(place.coordinate.longitude)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        // assign selected lat and long for post(if user search location)
        var selectedPostLat = place.coordinate.latitude
      var selectedPostLong = place.coordinate.longitude
        
        
        // reverse geocoding for getting country and city
        
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        // Geocode Location
        var geocoder = CLGeocoder()
        // to get current location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            var currentlocation=self.processResponse(withPlacemarks: placemarks, error: error)
            print("lcation \(currentlocation)")
            
            // storing selected location's country and city
            
            if (placemarks?.first?.country != nil){
                self.selectedCountry = placemarks!.first!.country
            }
            if (placemarks?.first?.locality != nil){
                self.selectedCity = placemarks!.first!.locality
            }
            print("selected city :\(self.selectedCity as! String) and country : \(self.selectedCountry as! String)")
            if self.type == 1 {
                 self.saveUserLocation(city: self.selectedCity as! String, country: self.selectedCountry as! String, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            }
            else if self.type == 2 {
                self.saveUserCurrentLocation(city: self.selectedCity as! String, country: self.selectedCountry as! String)
            }
            
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func reloadUserProfileData(){
        var subViewsCount = self.contentView.subviews.count
        var countSub  = 0
        for subView in self.contentView.subviews {
            countSub = countSub + 1
            if(subView.tag == 3){
                subView.removeFromSuperview()
            }
            print("Removint view count is \(countSub) and total count \(subViewsCount)")
            if(countSub == subViewsCount){
                print("done.. calling loadUser data now ")
                self.loadUserData(id: self.loggedInUserId)
            }
        }
    }
    
    func ShowLoading(){
        self.editProfileActivityIndicator.startAnimating()
        self.editProfileActivityIndicator.isHidden=false
    }
    func HideLoading() {
        self.editProfileActivityIndicator.stopAnimating()
        self.editProfileActivityIndicator.isHidden = true
    }
    
}
