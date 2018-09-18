//
//  ViewController.swift
//  logos2
//
//  Created by Mansi on 16/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
//import LinkedinSwift
import SwiftyJSON


import CoreLocation
import UIKit
import Crashlytics

import Toast_Swift
class finaluser{
    
    var displayName = String()
    var email = String()
    var userID = String()
    var photoURL = String()
    var phoneNumber = String()
    var cred = NSArray()
    
    init?(displayName:String,userID:String,email:String,photoURL:String,phoneNumber:String,cred:NSArray)
    {
        self.displayName=displayName
        self.userID=userID
        self.email=email
        self.phoneNumber=phoneNumber
        self.photoURL=photoURL
        self.cred=cred
    }
    
}
class LoginViewController: UIViewController,CLLocationManagerDelegate,GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate
    {
    var lat = Double()
    var long = Double()
     var locationManager:CLLocationManager!
    @IBOutlet weak var gSignInBtn: UIButton!
    var selectedPostCountry :Any = ""
    var selectedPostCity :Any = ""
    
  //  private let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "81pww8bebuozor", clientSecret: "wut7LyGCQy0SDG2l", state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl:"https://com.logos.linkedin.oauth/oauth"))
    
    let loginButton = FBSDKLoginButton()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
//        loginButton.delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().delegate=self
        
        // to get user's location
        self.getLocation()
        
        // to check if user is already loggedin
        let userData = UserDefaults.standard
        
        if(userData.object(forKey: "isLoggedIn") != nil){
            var userIsLoggedIn = userData.object(forKey: "isLoggedIn") as! Bool
            print("userLoggedIn is \(userIsLoggedIn)")
            if (userIsLoggedIn) {
                // user is logged in
                // redirect user to main feed
//                let mainTabController = storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
//                present(mainTabController, animated: true, completion: nil)
               gotToMain()
            }
            else{
                // got key but user is not logged in
                // add facebook button on view
//                loginButton.center = view.center
//                loginButton.delegate = self
//                view.addSubview(loginButton)
            }
        }
        else{
            //got nil so user is not logged in
            // add facebook button on view
            var user = Auth.auth().currentUser   // to check if user is logged in using social login
            print("user after auth is \(user)")
            if(user != nil){
                // user is logged in
                print("sending to main tab")
                userData.set(true, forKey: "isLoggedIn")
//                let mainTabController = storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
//                present(mainTabController, animated: true, completion: nil)
                gotToMain()
                
            }
            else{
                print("got nil user data")
//                loginButton.center = view.center
//                loginButton.delegate = self
//                view.addSubview(loginButton)
            }
        }
        

        
       
      
        // Do any additional setup after loading the view, typically from a nib.
        
        // Test Crashlytics
//        let button = UIButton(type: .roundedRect)
//        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
//        button.setTitle("Crash", for: [])
//        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
//        view.addSubview(button)
    }

  
    // custom fb login function
    @IBAction func FbLoginBtn(_ sender: UIButton) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self){
            (result, error) -> Void in
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if result!.isCancelled
                {
                    return
                }
                
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData(){
        // showIndicator()
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
            completionHandler: { (connection, result, error) -> Void in
             //   self.hideIndicator()
             if (error == nil){
                print(result!)
                var userData=JSON(result!)
                print("name \(userData["name"].string!)")
                var photoUlrData = JSON( userData["picture"])
                var urlData=JSON(photoUlrData["data"])
                var phototURl = urlData["url"].string!
                print("phototURl \(phototURl)")
                let fu=finaluser(displayName: userData["name"].string! ,userID: userData["id"].string!,email: userData["email"].string!,photoURL: "" ,phoneNumber: "" ,cred: [] as NSArray);
                
                print("finaluser \(fu?.email)")
                
                let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/CheckUserAlreadyPresent")
                var request=URLRequest(url:url!)
                request.httpMethod="POST"
                
                let json = [
                    "socialId":"\(fu?.userID)",
                    "email":"\(fu?.email)"
                    ] as [String : Any]
                print("json \(json)")
                let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                request.httpBody = jsonData
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                    
                    if (error != nil){
                        self.view.makeToast("Something Went Wrong ... Try again")
                    }
                    
                    let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                    //print("reposnString \(responseSting)")
                    
                    //parese json
                    var error=NSError?.self
                    // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                        print("sral 1 \(json)")
                        let code = json["code"] as? Int
                        
                        print("names \(code)")
                        if code == 1 {
                            DispatchQueue.main.async () {
                                //self.addUser(user: user, loginType: loginType,photo:photo)
                                let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addUser")
                                var request=URLRequest(url:url!)
                                request.httpMethod="POST"
                                
                                var email=fu?.email
                                
                                let pathURL = fu?.photoURL // URL
                                
                                
                                var userId=fu?.userID
                                var name=fu?.displayName as! String
                                var cred=fu?.cred as! NSArray
                                print("crede \(cred)")
                                
                                var uData = UserDefaults.standard
                                var APNToken = uData.object(forKey: "userAPNToken")
                                print("APNToken is \(APNToken)")
                                
                                
                                let json = [
                                    "APNToken":APNToken,
                                    "name" : name,
                                    "email" : email,
                                    "contact" : 1234567890,
                                    "longitude" : "\(self.long)",
                                    "latitude":"\(self.lat)",
                                    "socialId":userId,
                                    "photoUrl":phototURl,
                                    "isDeleted":0,
                                    "logginType":2 as Int,
                                    "isNormalUser":1,
                                    "creadentials":cred,
                                    "highEndorsmentName":"",
                                    "highEndorsmentCount":0,
                                    "city" : "\(self.selectedPostCity as! String)",
                                    "country" : "\(self.selectedPostCountry as! String)",
                                    "currentCity" :"\(self.selectedPostCity as! String)",
                                    "currentCountry" : "\(self.selectedPostCountry as! String)",
                                    "politicalOrientation" : "Center(moderate)",
                                    "knowsAbout":[
                                        
                                    ] ] as [String : Any]
                                print("json \(json)")
                                let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                                request.httpBody = jsonData
                                
                                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                                    
                                    if (error != nil){
                                        self.view.makeToast("Something Went Wrong ... Try again")
                                    }
                                    
                                    let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                                    print("reposnString \(responseSting)")
                                    
                                    //parese json
                                    var error=NSError?.self
                                    // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
                                    do {
                                        
                                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                                        print("sral 1 \(json)")
                                        let code = json["code"] as? Int
                                        
                                        print("names \(code)")
                                        if code == 1 {
                                            DispatchQueue.main.async () {
                                                var  userId = json["userId"] as? String
                                                var userData=json["userData"] as? NSDictionary
                                                let user = UserDefaults.standard
                                                user.set(userId, forKey: "userId")
                                                user.set(userData?.value(forKey: "name"), forKey: "userName")
                                                user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                                                user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                                                user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                                                user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                                                user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                                                user.set(self.lat, forKey: "currentLatitude")
                                                user.set(self.long, forKey: "currentLongitude")
                                                user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                                                let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                                                mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                                                self.present(mainTabController, animated: true, completion: nil)
                                            }
                                            
                                        }
                                        else{
                                            //add error toaster
                                            self.view.makeToast("Something Went Wrong ... Try again")
                                        }
                                        
                                    } catch let error as NSError {
                                        print("Failed to load: \(error.localizedDescription)")
                                    }
                                    
                                    
                                }
                                task.resume()
                            }
                            
                            
                            
                        }
                        else if code == 2{
                            var  userId = json["userId"] as? String
                            var userData=json["userData"] as? NSDictionary
                            DispatchQueue.main.async () {
                                //set user details in local storage
                                let user = UserDefaults.standard
                                user.set(userId, forKey: "userId")
                                user.set(userData?.value(forKey: "name"), forKey: "userName")
                                user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                                user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                                user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                                user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                                user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                                user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                                user.set(self.lat, forKey: "currentLatitude")
                                user.set(self.long, forKey: "currentLongitude")
                                user.set(true, forKey: "isLoggedIn")
                                /*   Get values from local Storage
                                 let defaults = UserDefaults.standard
                                 if let stringOne = defaults.string(forKey:"userName") {
                                 print("userName \(stringOne)") // Some String Value
                                 }*/
                                
                                let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                                mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                                
                                self.present(mainTabController, animated: true, completion: nil)
                                
                                
                            }
                        }
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                }
                task.resume()
                
             }
            })
        }
    }
    
    // custom google login function
    @IBAction func GoogleLoginBtn(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
   
    @IBAction func goClicked(_ sender: Any) {
        print("in goclicked function ")
        // to navigate from login to tab bar controller
        UserDefaults.standard.set("-LCs9UnX5qiVhChsoudZ", forKey: "userId")
        let mainTabController = storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
        
        present(mainTabController, animated: true, completion: nil)
    }
    
    func gotToMain(){
        print("in go to main function")
        let mainTabController = storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
        
        present(mainTabController, animated: true, completion: nil)
    }
   
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        //<#code#>
//    }
//    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
//       // self.sign(signIn, present: viewController)
//    }
//
//    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
//        //self.sign(signIn, dismiss: viewController)
//    }
    
   
    
   
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error == nil){
            let authentication=user.authentication
            let crdential=GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
            Auth.auth().signIn(with: crdential, completion: {(user,error)in
                print("user logged in")
                print ("user photo \(user!.photoURL!.absoluteString)")
                /*print ("user id \(user?.email)")
                print ("user name \(user?.displayName)")
                
                print ("user phone number \(user?.phoneNumber)")
                
                print("user \(user?.description)")
                print("user \(user?.uid)")*/
                self.checkuserIsAlredyPresentOrnot(user: user!,loginType: 0,photo:user!.photoURL!.absoluteString)
            })
            /*let mainTabController = storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
            
            present(mainTabController, animated: true, completion: nil)*/
        }else{
            print("error \(error.localizedDescription)")
        }
    }

   /** @IBAction func loggedInUsingLinkdin(_ sender: Any) {
        print("in linkdin loggin")
         linkedinHelper.authorizeSuccess({ (token) in
            
            print("Got token :\(token)");
            let linkdinToken  = "\(token)"
            //This token is useful for fetching profile info from LinkedIn server.
            //            ,educations:(school-name,field-of-study,start-date,end-date,degree,activities)
            self.linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location,skills:(id,skill:(name)),educations:(school-name,field-of-study,start-date,end-date,degree,activities))?format=json",
                                           requestType: LinkedinSwiftRequestGet,
                                           success: { (response) -> Void in
                                            var cred=[Any]()
                                            //Request success response
                                                  print("response \(response)")
                                            var positions=response.jsonObject["positions"]
                                            if let positionDataDict = positions as? NSDictionary {
                                                
                                                let  values = positionDataDict.value(forKey: "values") as! NSArray
                                            
                                                for value in values {
                                                      print("values \(value)")
                                                    
                                                    if let valuesDataDict = value as? NSDictionary {
                                                        //     print("valuesDataDict \(valuesDataDict)")
                                                        let title = valuesDataDict.value(forKey: "title")
                                                        print("title \(title)")
                                                      
                                                        let comapny=valuesDataDict.value(forKey: "company")
                                                        if let companyDataDict = comapny as? NSDictionary {
                                                            
                                                            let name = companyDataDict.value(forKey: "name")
                                                            print("name \(name)")
                                                            let credName="working at \(name as! String) as \(title as! String)"
                                                          //  print("test \(test)")
                                                            var test=["name":credName]
                                                           cred.append(test)
                                                        }
                                                    
                                                    }
                                                }
                                                
                                                
                                            
                                               
                                            }
                                          
                                            var uid=response.jsonObject["id"]
                                            var email=response.jsonObject["emailAddress"]
                                            var firsname=response.jsonObject["firstName"]
                                              var lastname=response.jsonObject["lastName"]
                                           var fullName="\(firsname as! String) \(lastname as! String)"
                                            print("ffull name \(cred)")
                                            //signin with user email and password
                                           Auth.auth().signIn(withEmail: email as! String, password: "LogosApp2018", completion: {(user,error)in
                                                print("user  \(user)")
                                                if user==nil{
                                                    //register new user if not registred
                                                    Auth.auth().createUserAndRetrieveData(withEmail: email as! String, password: "LogosApp2018"    , completion: {(user,error)in
                                                        
                                                        let fu=finaluser(displayName: fullName ,userID: user?.user.uid as! String,email: email as! String,photoURL: "" ,phoneNumber: "" ,cred: cred as NSArray);
                                                     
                                                        print("finaluser \(fu?.email)")
                                                      
                                                        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/CheckUserAlreadyPresent")
                                                        var request=URLRequest(url:url!)
                                                        request.httpMethod="POST"
                                                        
                                                        let json = [
                                                            "socialId":"\(fu?.userID)",
                                                            "email":"\(fu?.email)"
                                                            ] as [String : Any]
                                                        print("json \(json)")
                                                        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                                                        request.httpBody = jsonData
                                                        
                                                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                                                            
                                                            if (error != nil){
                                                                self.view.makeToast("Something Went Wrong ... Try again")
                                                            }
                                                            
                                                            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                                                            print("reposnString \(responseSting)")
                                                            
                                                            //parese json
                                                            var error=NSError?.self
                                                            // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
                                                            do {
                                                                
                                                                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                                                                print("sral 1 \(json)")
                                                                let code = json["code"] as? Int
                                                                
                                                                print("names \(code)")
                                                                if code == 1 {
                                                                    DispatchQueue.main.async () {
                                                                        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addUser")
                                                                        var request=URLRequest(url:url!)
                                                                        request.httpMethod="POST"
                                                                        
                                                                        var email=fu?.email
                                                                        
                                                                        let pathURL = fu?.photoURL // URL
                                                                        
                                                                        
                                                                        var userId=fu?.userID
                                                                        var name=fu?.displayName as! String
                                                                        var cred=fu?.cred as! NSArray
                                                                        print("crede \(cred)")
                                                                        let json = [
                                                                            
                                                                            "name" : name,
                                                                            "email" : email,
                                                                            "contact" : 1234567890,
                                                                            "longitude" : "\(self.long)",
                                                                            "latitude":"\(self.lat)",
                                                                            "socialId":userId,
                                                                            "photoUrl":pathURL,
                                                                            "isDeleted":0,
                                                                            "logginType":2 as Int,
                                                                            "isNormalUser":1,
                                                                            "creadentials":cred,
                                                                            "highEndorsmentName":"",
                                                                            "highEndorsmentCount":0,
                                                                            "city" : "\(self.selectedPostCity as! String)",
                                                                            "country" : "\(self.selectedPostCountry as! String)",
                                                                            "currentCity" :"\(self.selectedPostCity as! String)",
                                                                            "currentCountry" : "\(self.selectedPostCountry as! String)",
                                                                            "politicalOrientation" : "Center(moderate)",
                                                                            "knowsAbout":[
                                                                                
                                                                            ] ] as [String : Any]
                                                                        print("json \(json)")
                                                                        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                                                                        request.httpBody = jsonData
                                                                        
                                                                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                                         let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                                                                         
                                                                         if (error != nil){
                                                                            self.view.makeToast("Something Went Wrong ... Try again")
                                                                         }
                                                                         
                                                                         let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                                                                         print("reposnString \(responseSting)")
                                                                         
                                                                         //parese json
                                                                         var error=NSError?.self
                                                                         // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
                                                                         do {
                                                                         
                                                                         let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                                                                         print("sral 1 \(json)")
                                                                         let code = json["code"] as? Int
                                                                         
                                                                         print("names \(code)")
                                                                         if code == 1 {
                                                                         DispatchQueue.main.async () {
                                                                            var  userId = json["userId"] as? String
                                                                            var userData=json["userData"] as? NSDictionary
                                                                            let user = UserDefaults.standard
                                                                            user.set(userId, forKey: "userId")
                                                                            user.set(userData?.value(forKey: "name"), forKey: "userName")
                                                                            user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                                                                            user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                                                                            user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                                                                            user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                                                                            user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                                                                            user.set(self.lat, forKey: "currentLatitude")
                                                                            user.set(self.long, forKey: "currentLongitude")
                                                                            user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                                                                            let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                                                                                     mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                                                                            self.present(mainTabController, animated: true, completion: nil)
                                                                         }
                                                                         
                                                                         }
                                                                         else{
                                                                            //add error toaster
                                                                              self.view.makeToast("Something Went Wrong ... Try again")
                                                                         }
                                                                         
                                                                         } catch let error as NSError {
                                                                         print("Failed to load: \(error.localizedDescription)")
                                                                         }
                                                                         
                                                                         
                                                                         }
                                                                         task.resume()
                                                                    }
                                                                    
                                                                }
                                                                else if code == 2{
                                                                    var  userId = json["userId"] as? String
                                                                    var userData=json["userData"] as? NSDictionary
                                                                    DispatchQueue.main.async () {
                                                                        //set user details in local storage
                                                                        let user = UserDefaults.standard
                                                                        user.set(userId, forKey: "userId")
                                                                        user.set(userData?.value(forKey: "name"), forKey: "userName")
                                                                        user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                                                                        user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                                                                        user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                                                                        user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                                                                        user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                                                                        user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                                                                        user.set(self.lat, forKey: "currentLatitude")
                                                                        user.set(self.long, forKey: "currentLongitude")
                                                                        /*   Get values from local Storage
                                                                         let defaults = UserDefaults.standard
                                                                         if let stringOne = defaults.string(forKey:"userName") {
                                                                         print("userName \(stringOne)") // Some String Value
                                                                         }*/
                                                                        
                                                                        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                                                                        mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                                                                        
                                                                        self.present(mainTabController, animated: true, completion: nil)
                                                                        
                                                                        
                                                                    }
                                                                }
                                                                
                                                            } catch let error as NSError {
                                                                print("Failed to load: \(error.localizedDescription)")
                                                            }
                                                            
                                                            
                                                        }
                                                        task.resume()
                                                    }  )
                                                    
                                                }
                                                else{
                                                    
                                                   
                                                    let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                                                    mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                                                    
                                                    self.present(mainTabController, animated: true, completion: nil)
                                                }
                                            })
                                          
               
                                            
              
                                            
            }) { [unowned self] (error) -> Void in
                //Encounter error
            }
           /* self.linkedinHelper.requestURL("https://api.linkedin.com/v2/skills?format=json", requestType: LinkedinSwiftRequestGet, success: { (response)->Void in
                print("skills are :\(response)")
            }, error: { (error) in
                print("error in skill \(error)")
            })*/
        }, error: { (error) in
            
            print("error 32 is \(error.localizedDescription)")
            //show respective error
        }) {
            //show sign in cancelled event
        }
    }
    */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        
       /* if LinkedinSwiftHelper.shouldHandle(url) {
            return LinkedinSwiftHelper.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }*/
        
        return true
    }
 
 
    /*FaceBook login code :*/
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error=error{
            print("error \(error.localizedDescription)")
        }
        else{
            let credetials=FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credetials){(authResult,error) in
                if let error=error{
                    print("error \(error)")
                }
                else{
                    print ("user id \(authResult?.user.email)")
                    print ("user name \(authResult?.user.displayName)")
                    
                    print ("user phone number \(authResult?.user.phoneNumber)")
                    print ("user photo \(authResult?.user.photoURL)")
                    print("user \(authResult?.user.description)")
                    self.checkuserIsAlredyPresentOrnot(user: (authResult?.user)!,loginType: 1,photo:(authResult?.user.photoURL!.absoluteString)!)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //  <#code#>
    }
    func loginFBFireb() {
        print("in logins")
        let credetials=FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credetials, completion: {(user,error)in
            print("user logged in")
            print ("user id \(user?.email)")
            print ("user name \(user?.displayName)")
            
            print ("user phone number \(user?.phoneNumber)")
            print ("user photo \(user!.photoURL)")
            print("user \(user?.description)")
            self.checkuserIsAlredyPresentOrnot(user: user!,loginType: 1,photo:(user!.photoURL?.absoluteString)!)
        })
    }
    
    
    // get current location
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
       
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        var latitude=userLocation.coordinate.latitude
        var longitude=userLocation.coordinate.longitude
        self.lat=userLocation.coordinate.latitude
        self.long=userLocation.coordinate.longitude
        let location = CLLocation(latitude: self.lat, longitude: self.long)
        var geocoder = CLGeocoder()
        // to get current location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            var currentlocation=self.processResponse(withPlacemarks: placemarks, error: error)
            print("lcation \(currentlocation)")
            
            // storing selected location's country and city
            
            if (placemarks?.first?.country != nil){
                self.selectedPostCountry = placemarks!.first!.country
            }
            if (placemarks?.first?.locality != nil){
                self.selectedPostCity = placemarks!.first!.locality
            }
            print("selected city :\(self.selectedPostCity as! String) and country : \(self.selectedPostCountry as! String)")
        }
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
    //function to check  user is already present in logos App Database or not
    func checkuserIsAlredyPresentOrnot(user:AnyObject,loginType:Int,photo:String){
        print("in addUser function \(user.email)")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/CheckUserAlreadyPresent")
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        var email=user.email as! String
          var userId=user.uid as! String
        let json = [
            "socialId":userId,
            "email":email
            ] as [String : Any]
        print("json \(json)")
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
              //  self.view.makeToast("Something Went Wrong ... Try again")
            }
            
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            //print("reposnString \(responseSting)")
            
            //parese json
            var error=NSError?.self
            // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("sral 1 \(json)")
                let code = json["code"] as? Int
                
                print("names \(code)")
                if code == 1 {
                    DispatchQueue.main.async () {
                        self.addUser(user: user, loginType: loginType,photo:photo)
                       
                    }
                    
                }
                else if code == 2{
                  var  userId = json["userId"] as? String
                 var userData=json["userData"] as? NSDictionary
                    DispatchQueue.main.async () {
                        //set user details in local storage
                        let user = UserDefaults.standard
                        user.set(userId, forKey: "userId")
                        user.set(userData?.value(forKey: "name"), forKey: "userName")
                        user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                        user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                        user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                        user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                        user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                        user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                        user.set(self.lat, forKey: "currentLatitude")
                        user.set(self.long, forKey: "currentLongitude")
                         user.set(true, forKey: "isLoggedIn")
                     /*   Get values from local Storage
                         let defaults = UserDefaults.standard
                        if let stringOne = defaults.string(forKey:"userName") {
                            print("userName \(stringOne)") // Some String Value
                        }*/
                        
                        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                        mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                        
                        self.present(mainTabController, animated: true, completion: nil)
                        
                        
                    }
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
        }
    
    //function to add user in Logos App Database
    func addUser(user:AnyObject,loginType:Int,photo:String){
        
        // get apn token from local storage
        var uData = UserDefaults.standard
        var APNToken = uData.object(forKey: "userAPNToken")
        print("APNToken is \(APNToken)")
        
        print("photo \(photo)")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addUser")
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
       
        var email=user.email
        var pathURL : String = ""
        var userId=user.uid
        var name=user.displayName as String
        var cred=user.credentials
        print("crede \(cred)")
       
        
        let json = [
        
            "name" : name,
            "email" : email,
            "contact" : 1234567890,
            "longitude" : "\(self.long)",
            "latitude":"\(self.lat)",
            "socialId":userId,
            "photoUrl":"\(photo)",
            "isDeleted":0,
            "logginType":loginType,
            "isNormalUser":1,
            "highEndorsmentName":"",
            "highEndorsmentCount":0,
            // add APN token key
            "APNToken":"\(APNToken)",
            "city" : "\(self.selectedPostCity as! String)",
            "country" : "\(self.selectedPostCountry as! String)",
            "currentCity" :"\(self.selectedPostCity as! String)",
            "currentCountry" : "\(self.selectedPostCountry as! String)",
            "politicalOrientation" : "Center(moderate)",
            "creadentials":[
                
            ],
            "knowsAbout":[
                
        ] ] as [String : Any]
        print("json \(json)")
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            
            if (error != nil){
                self.view.makeToast("Something Went Wrong ... Try again")
            }
            
            let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
            print("reposnString \(responseSting)")
            
            //parese json
            var error=NSError?.self
            // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("sral 1 \(json)")
                let code = json["code"] as? Int
                
               
                if code  ==  1 {
                 
                    DispatchQueue.main.async () {
                        var  userId = json["userId"] as? String
                        var userData=json["userData"] as? NSDictionary
                        let user = UserDefaults.standard
                        user.set(userId, forKey: "userId")
                        user.set(userData?.value(forKey: "name"), forKey: "userName")
                        user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                        user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                        user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                        user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                        user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                        user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                        user.set(self.lat, forKey: "currentLatitude")
                        user.set(self.long, forKey: "currentLongitude")
                        user.set(true, forKey: "isLoggedIn")
                        /*Get values from local Storage
                         let defaults = UserDefaults.standard
                         if let stringOne = defaults.string(forKey:"userName") {
                         print("userName \(stringOne)") // Some String Value
                         }*/

                        
                        
                        let mainTabController = self.storyboard?.instantiateViewController(withIdentifier:"MainTabController") as! MainTabController
                        mainTabController.Data = (cityLat:self.lat ,cityLong:self.long)
                        
                        self.present(mainTabController, animated: true, completion: nil)
                    }
                    
                }
                else{
                    //error in user creation
                    self.view.makeToast("Something Went Wrong ... Try again")
                    
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
    }

    
}


