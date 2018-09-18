//
//  BreakViewController.swift
//  logos2
//
//  Created by Samuel J. Lee on 5/10/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GooglePlacePicker
import Toast_Swift
import Firebase

class BreakViewController: UIViewController, CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate {
    
    // for google places
    var placeClient : GMSPlacesClient!
    
    @IBOutlet weak var mainView: UIScrollView!
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    
    @IBOutlet weak var articleView: UIScrollView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var articlelabel: UILabel!
    @IBOutlet weak var articleLocation: UITextField!
    @IBOutlet weak var articleActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mediaLocation: UITextField!
    @IBOutlet weak var mediaBody: UITextView!
    @IBOutlet weak var medialabel: UILabel!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mediaTitleText: UITextView!
    
    
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postlabel: UILabel!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var postTitleText: UITextView!
    
    
    var locationManager:CLLocationManager!
    
    
    
    @IBOutlet weak var bodyText: UITextView!
    
    @IBOutlet weak var addTextSection: UITextView!
    
    
    
    
    // var declarations
    var imagePicked = UIImageView()
    var newsType = 1
    //for selected location for article/media/post
    var selectedPostLat :Any = ""
    var selectedPostLong :Any = ""
    var selectedPostCountry :Any = ""
    var selectedPostCity :Any = ""
    var selectedPostType : String = "Article"
    
    var imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    
    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()
    var lat=String()
    var long=String()
    // TODO : uncomment after real devie testing is done
    //var media:String="phots/mediA/KK"
    
    var media :String = "https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/default_news_image.png?alt=media&token=293cd97b-77a4-4c4d-91df-f1c03fc1cc0e"
    // to fetch user information from local storage
    let userInformation = UserDefaults.standard
    
    //    @IBAction func selectSeg(_ sender: Any) {
    //        switch segmentOutlet.selectedSegmentIndex {
    //        case 0: //Set the Article section to visible and the others to hidden
    //            articlelabel.isHidden = true
    //            medialabel.isHidden = false
    //            postlabel.isHidden = false
    //            articleView.isHidden = false
    //            mediaView.isHidden = true
    //            postView.isHidden = true
    //            newsType = 1
    //        case 1: //set the Media Section to visible and the others to hidden
    //            articlelabel.isHidden = false
    //            medialabel.isHidden = true
    //            postlabel.isHidden = false
    //            articleView.isHidden = true
    //            mediaView.isHidden = false
    //            postView.isHidden = true
    //            addTextSection.layer.borderWidth = 1
    //            addTextSection.layer.borderColor = UIColor.gray.cgColor
    //            newsType = 2
    //        case 2: //set the Post section to visible and the others to hidden
    //            articlelabel.isHidden = false
    //            medialabel.isHidden = false
    //            postlabel.isHidden = true
    //            articleView.isHidden = true
    //            mediaView.isHidden = true
    //            postView.isHidden = false
    //            postText.layer.borderWidth = 1
    //            postText.layer.borderColor = UIColor.gray.cgColor
    //            newsType = 3
    //        default:
    //            break
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait 
        self.imagePicker.delegate = self
        //hide loading signs
        articleActivityIndicator.isHidden=true
        //        mediaActivityIndicator.isHidden=true
        //        postActivityIndicator.isHidden=true
        
        articleLocation.delegate = self
        //        mediaLocation.delegate = self
        titleText.delegate = self
        //        mediaBody.delegate = self
        
        //getLocation()
        //Hide secondary views initially
        //        postView.isHidden = true
        //        mediaView.isHidden = true
        
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        //SETTING BORDERS OF TEXTVIEWS
        titleText.layer.borderWidth = 0.5
        titleText.layer.borderColor = borderColor.cgColor
        titleText.layer.cornerRadius = 5.0; UIColor.gray.cgColor
        
        bodyText.layer.borderWidth = 0.5
        bodyText.layer.borderColor = borderColor.cgColor
        bodyText.layer.cornerRadius = 5.0; UIColor.gray.cgColor
        
        
        articleLocation.layer.borderWidth = 0.5
        articleLocation.layer.borderColor = borderColor.cgColor
        articleLocation.layer.cornerRadius = 5.0; UIColor.gray.cgColor
        
        // Adding shadows to textviews
        titleText.layer.masksToBounds = false
        titleText.layer.shadowRadius = 2.0
        titleText.layer.shadowColor = UIColor.darkGray.cgColor
        titleText.layer.shadowOffset = CGSize(width:1.0, height:1.0)
        titleText.layer.shadowOpacity = 0.5
        
        bodyText.layer.masksToBounds = false
        bodyText.layer.shadowRadius = 2.0
        bodyText.layer.shadowColor = UIColor.darkGray.cgColor
        bodyText.layer.shadowOffset = CGSize(width:1.0, height:1.0)
        bodyText.layer.shadowOpacity = 0.5
        bodyText.clipsToBounds = true
        
        articleLocation.layer.masksToBounds = false
        articleLocation.layer.shadowRadius = 2.0
        articleLocation.layer.shadowColor = UIColor.darkGray.cgColor
        articleLocation.layer.shadowOffset = CGSize(width:1.0, height:1.0)
        articleLocation.layer.shadowOpacity = 0.5
        
        // SETTING BORDERS OF POST TITLE TEXT VIEW
        //        postTitleText.layer.borderWidth = 1
        //        postTitleText.layer.borderColor = UIColor.gray.cgColor
        //        postTitleText.layer.borderWidth = 1
        //        postTitleText.layer.borderColor = UIColor.gray.cgColor
        //
        //        mediaTitleText.layer.borderWidth = 1
        //        mediaTitleText.layer.borderColor = UIColor.gray.cgColor
        //        mediaTitleText.layer.borderWidth = 1
        //        mediaTitleText.layer.borderColor = UIColor.gray.cgColor
        
        
        //Round out the view
        mainView.layer.cornerRadius = 5
        
        //First selection
        //        switch segmentOutlet.selectedSegmentIndex {
        //        case 0:
        //            articlelabel.isHidden = true
        //            medialabel.isHidden = false
        //            postlabel.isHidden = false
        //        case 1:
        //            articlelabel.isHidden = false
        //            medialabel.isHidden = true
        //            postlabel.isHidden = false
        //        case 2:
        //            articlelabel.isHidden = false
        //            medialabel.isHidden = false
        //            postlabel.isHidden = true
        //        default:
        //            break
        //        }
        
        //Set the Segment Control Text to Cyan when selected
        //        let segAttributes: NSDictionary = [
        //            NSAttributedStringKey.foregroundColor: UIColor.cyan,
        //            ]
        //        segmentOutlet.setTitleTextAttributes(segAttributes as [NSObject: AnyObject], for: UIControlState.selected)
        //        // Do any additional setup after loading the view, typically from a nib.
        //
        //Looks for single or multiple taps.
        //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BreakViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        bodyText.layer.masksToBounds = false
        bodyText.layer.shadowRadius = 2.0
        bodyText.layer.shadowColor = UIColor.darkGray.cgColor
        bodyText.layer.shadowOffset = CGSize(width:1.0, height:1.0)
        bodyText.layer.shadowOpacity = 0.5
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        print("KEYBOARD DISMISSED")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
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
                print("image picked :\(self.imagePicked.image)")
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
    
    @IBAction func camera2(_ sender: Any) {
        // Create the alert controller
        print("in chose photo from camera 2")
        let alertController = UIAlertController(title: "Photos", message: "Choose Photo or Video", preferredStyle: .alert)
        
        // Create the actions
        let photoAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                // var imagePicker = UIImagePickerController()
                //imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.allowsEditing = true
                self.imagePicker.mediaTypes = ["public.image", "public.movie"]
                self.present(self.imagePicker, animated: true, completion: nil)
                print("image picked :\(self.imagePicked.image)")
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
            let ticks =  NSDate().timeIntervalSince1970
            print(ticks)
            let filePath = "images/\(ticks)" // path where you wanted to store img in storage
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/jpg"
            
            var storageRef1 = Storage.storage().reference()
            storageRef1.child(filePath).putData(data as Data, metadata: nil){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.dismiss(animated:true, completion: nil)
                    return
                }else{
                    
                    //store downloadURL
                    
                    storageRef1.child(filePath).downloadURL { (url, error) in
                        
                        print("error \(url)")
                        guard let downloadURL = url else {
                            fatalError("error ")
                            return
                        }
                        print("download \(url?.absoluteString)")
                        print("download \(url!.absoluteURL)")
                        self.media=url!.absoluteString
                        self.dismiss(animated:true, completion: nil)
                        
                    }
                    
                    
                    
                }
            }
        }
        
        if mediaType == "public.movie" {
            print("Video Selected")
            if let fileURL =  info[UIImagePickerControllerMediaURL] as? NSURL {
                do {
                    print("vedio url \(fileURL)")
                    let ticks =  NSDate().timeIntervalSince1970
                    print(ticks)
                    let filePath = "Video/\(ticks)" // path where you wanted to store img in storage
                    let metaData = StorageMetadata()
                    let dispatchgroup = DispatchGroup()
                    
                    
                    var data = NSData()
                    // data = UIImageJPEGRepresentation(image, 0.8)! as NSDataputData(fileURL, metadata: nil){(metaData,error) in
                    metaData.contentType = "video/mp4"
                    var storageRef1 = Storage.storage().reference()
                    storageRef1.child(filePath).putFile(from: fileURL as URL, metadata: metaData){(metaData,error) in
                        if let error = error {
                            print(error.localizedDescription)
                            self.dismiss(animated:true, completion: nil)
                            return
                        }else{
                            //store downloadURL
                            
                            storageRef1.child(filePath).downloadURL { (url, error) in
                                
                                print("error \(url)")
                                guard let downloadURL = url else {
                                    fatalError("error ")
                                    return
                                }
                                print("download \(url?.absoluteString)")
                                print("download \(url!.absoluteURL)")
                                self.media=url!.absoluteString
                                self.dismiss(animated:true, completion: nil)
                                
                            }
                        }
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    /*This action is called if user wants to select current location as post location */
    @IBAction func getCurrentLocation(_ sender: Any) {
        getLocation()
    }
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        var latitude=userLocation.coordinate.latitude
        var longitude=userLocation.coordinate.longitude
        self.lat="\(userLocation.coordinate.latitude)"
        self.long="\(userLocation.coordinate.longitude)"
        
        // assign selected lat and long for post(if user selects currant location)
        self.selectedPostLat = self.lat
        self.selectedPostLong = self.long
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        // Geocode Location
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
            
            
            switch(self.newsType) {
            case 1:
                self.articleLocation.text = currentlocation
                break
            case 2:
                self.mediaLocation.text = currentlocation
                break
            case 3:
                self.postLocation.text = currentlocation
            default:
                break
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
        
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
    
    
    func validate()->Bool{
        //print("in validate")
        var result:Bool=true
        if self.newsType==1{
            let newsTitleLength = self.titleText.text?.count
            // print("newsTitleLength\(newsTitleLength)")
            let mainbodyContent = self.bodyText.text
            var mainBodyArray = mainbodyContent?.components(separatedBy: " ")
            var mainArrayLength = mainBodyArray?.count as! Int
            //  print("mainArrayLength \(mainArrayLength)")
            if (self.titleText.text?.isEmpty)! {
                
                //self.nwsTitle.placeholder.
                self.titleText.attributedText = NSAttributedString(string: "Please enter News Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                //self.nwsTitle.placeholder="Please enter News Title"
                result=false
                
            }
            else if ( newsTitleLength! > 80) {
                self.titleText.text=""
                self.titleText.attributedText = NSAttributedString(string: "Title should be max 80 Characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                
                result=false
            }
            else if(self.bodyText.text?.isEmpty)!{
                self.bodyText.attributedText = NSAttributedString(string: "Please enter News Content", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                result=false
            }
            else if( mainArrayLength  > 1501){
                self.bodyText.attributedText = NSAttributedString(string: "Content should be upto 1500 word max", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                result=false
            }
                /*else if media.isEmpty{
                 let alertController = UIAlertController(title: "Choose One", message: "Please Select atleast one media", preferredStyle: .alert)
                 
                 let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                 UIAlertAction in
                 result=false
                 
                 }
                 alertController.addAction(okAction)
                 self.present(alertController, animated: true, completion: nil)
                 }*/
            else{
                result=true
            }
            
            
        }
        else if self.newsType==2{
            let mainBodyLength=self.mediaBody.text?.count as! Int
            //print("newsTitleLength\(newsTitleLength)")
            print("mainBodyLength\(mainBodyLength)")
            if (self.mediaBody.text?.isEmpty)! {
                
                //self.nwsTitle.placeholder.
                self.mediaBody.attributedText = NSAttributedString(string: "Please enter News Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                //self.nwsTitle.placeholder="Please enter News Title"
                result=false
                
            }
            else if ( mainBodyLength > 140) {
                self.mediaBody.text=""
                self.mediaBody.attributedText = NSAttributedString(string: "Post should be maximum 140 characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                
                result=false
            }
                /*else if media.isEmpty{
                 let alertController = UIAlertController(title: "Choose One", message: "Please Select atleast one media", preferredStyle: .alert)
                 
                 let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                 UIAlertAction in
                 result=false
                 
                 }
                 alertController.addAction(okAction)
                 self.present(alertController, animated: true, completion: nil)
                 }*/
            else{
                result=true
            }
            
            
            
        }
        else if self.newsType==3{
            if (self.postText.text?.isEmpty)! {
                
                //self.nwsTitle.placeholder.
                self.postText.attributedText = NSAttributedString(string: "Please enter Content", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                //self.nwsTitle.placeholder="Please enter News Title"
                result=false
            }
            else{
                result=true
            }
            /*else if media.isEmpty{
             let alertController = UIAlertController(title: "Choose One", message: "Please Select atleast one media", preferredStyle: .alert)
             
             let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
             UIAlertAction in
             result=false
             
             }
             alertController.addAction(okAction)
             self.present(alertController, animated: true, completion: nil)
             }*/
        }
        return result
    }
    @IBAction func releaseNews(_ sender: Any) {
        print("in release news function ")
        var validation=validate()
        print("validation \(validation)")
        if(validation){
            self.ShowLoading(type:self.newsType,isStarting:1)
            let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addPost")
            var request=URLRequest(url:url!)
            request.httpMethod="POST"
            
            //let postString="num1=1&num2=6"
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            var newsTitle = ""
            var newsBody = ""
            // determine type of news
            switch(self.newsType){
            case 1:
                newsTitle = self.titleText.text
                print("body  :\(self.bodyText.text)")
                newsBody = self.bodyText.text
                self.selectedPostType = "Article"
                break
            case 2:
                newsTitle = self.postTitleText.text
                newsBody = self.mediaBody.text
                self.selectedPostType = "Post"
                break
            case 3:
                newsTitle = self.mediaTitleText.text
                newsBody = self.postText.text
                self.selectedPostType = "Media"
                break
            default:
                break
            }
            print("newsTitle : \(newsTitle)")
            print("newsBody : \(newsBody)")
            
            let json = ["userId":"\(userId)","title":"\(newsTitle)","des":"\(newsBody)","type":self.newsType,"media":"\(self.media)","latitude":"\(self.selectedPostLat)","longitude":"\(self.selectedPostLong)","city":"\(self.selectedPostCity as! String)","country":"\(self.selectedPostCountry as! String)"] as [String : Any]
            print("json \(json)")
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.httpBody = jsonData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                
                if (error != nil){
                    self.showErrorToaster(msg:"Please try again later..",type: 0,view: self.newsType)
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
                            
                            /* Add user poins after success of news posting
                             @Author subodh3344 26.5.18 */
                            // add points for user
                            let addPointUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/adduserPoint")
                            var addPointRequest = URLRequest(url:addPointUrl!)
                            addPointRequest.httpMethod = "POST"
                            
                            
                            let addPointsJson = ["userId":"\(userId)","type":"\(self.selectedPostType)"] as[String : Any]
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
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)){
                                           // let newsView = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
                                            //self.present(newsView, animated: true, completion: nil)
                                            Post.newPost = true 
                                            self.tabBarController?.selectedIndex = 0
                                            
                                            
                                        }
                                        DispatchQueue.main.async () {
                                            self.ShowLoading(type:self.newsType,isStarting:0)
                                            self.showToaster(msg:"Your article has been posted!",type: 1)
                                            
                                            
                                        }
                                    }
                                }catch let error as NSError {
                                    print("Failed to load add point Function : \(error.localizedDescription)")
                                }
                            }
                            addPointsTask.resume()
                        }
                    }
                    else{
                        
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                
            }
            task.resume()
        }
    }
    
    /* Following actions will be called if user wants to serach POST's location using search box */
    // function to pick location @Auhtor subodh3344
    
    
    // action for search location for POST
    @IBAction func searchLocation(_ sender: UIButton) {
        searchLocationFunction()
    }
    
    // action for search location for article
    @IBAction func articleLocationSearchBtn(_ sender: UIButton) {
        searchLocationFunction()
    }
    
    // action for search location for media
    @IBAction func mediaLocationSearchBtn(_ sender: UIButton) {
        searchLocationFunction()
    }
    
    func searchLocationFunction(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as! GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true, completion: nil)
    }
    
}


/*Google's API to search locations
 @Author Subodh3344
 */
extension BreakViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Lat : \(place.coordinate.latitude) and Long : \(place.coordinate.longitude)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
        // assign selected lat and long for post(if user search location)
        self.selectedPostLat = place.coordinate.latitude
        self.selectedPostLong = place.coordinate.longitude
        
        
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
                self.selectedPostCountry = placemarks!.first!.country
            }
            if (placemarks?.first?.locality != nil){
                self.selectedPostCity = placemarks!.first!.locality
            }
            print("selected city :\(self.selectedPostCity as! String) and country : \(self.selectedPostCountry as! String)")
            
            // to append searched location in selected location text field
            switch(self.newsType){
            case 1:
                self.articleLocation.text = place.name
                break
            case 2:
                self.mediaLocation.text = place.name
                break
            case 3:
                self.postLocation.text = place.name
            default:
                break
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
    func showErrorToaster(msg:String,type:Int,view:Int){
        var style=ToastStyle()
        if type==0{
            style.backgroundColor=UIColor.red
        }
        else{
            style.backgroundColor=UIColor.blue
        }
        style.messageColor=UIColor.white
        style.messageFont=UIFont.systemFont(ofSize: 20)
        if view==1{
            self.articleView.makeToast(msg, duration: 3.0, position: .center, style: style)
            
        }
        else if view==3{
            self.postView.makeToast(msg, duration: 3.0, position: .center, style: style)
        }
        else if view==2{
            self.mediaView.makeToast(msg, duration: 3.0, position: .center, style: style)
        }
    }
    func ShowLoading(type:Int,isStarting:Int){
        
        
        
        if isStarting == 1{
            if type == 1{
                self.articleActivityIndicator.startAnimating()
                self.articleActivityIndicator.isHidden=false
            }
            else if type == 2{
                self.mediaActivityIndicator.startAnimating()
                self.mediaActivityIndicator.isHidden=false
            }
            else if type == 3 {
                self.postActivityIndicator.startAnimating()
                self.postActivityIndicator.isHidden=false
            }
            
        }
        else{
            if type == 1{
                self.articleActivityIndicator.stopAnimating()
                self.articleActivityIndicator.isHidden=true
            }
            else if type == 2{
                self.mediaActivityIndicator.stopAnimating()
                self.mediaActivityIndicator.isHidden=true
            }
            else if type == 3 {
                self.postActivityIndicator.startAnimating()
                self.postActivityIndicator.isHidden=true
            }
        }
    }
    
    //This is for the keyboard to GO AWAYY !! when user clicks anywhere on the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ohh clicked")
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("clicked")
        //        articleLocation.resignFirstResponder()
        //        mediaLocation.resignFirstResponder()
        //        titleText.resignFirstResponder()
        //        mediaBody.resignFirstResponder()
        return true
    }
    
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
}


