//
//  CreateNewsViewController.swift
//  logos2
//
//  Created by Mansi on 17/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
class CreateNewsViewController : UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
   
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
   
    @IBOutlet weak var textLable: UILabel!
    
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var releaseNewsButton: UIButton!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mainBody: UITextView!
    @IBOutlet weak var bodyLable: UILabel!
    @IBOutlet weak var nwsTitle: UITextField!
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    var newsType:Int=2
    var lat=String()
    var long=String()
    var media:String="phots/mediA/KK"
 
    override func viewDidLoad() {
     
       imagePicker.delegate = self
        locationLable.isHidden=true
        releaseNewsButton.isEnabled=true
        getLocation()
        super.viewDidLoad()
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex{
         
        case 0:
            //post
              self.nwsTitle.text=""
              self.mainBody.text=""
            self.newsType=2
            textLable.text="Up to 64 Character"
            bodyLable.text="Upto 280 Character"
            break
        case 1:
            //article
              self.nwsTitle.text=""
                 self.mainBody.text=""
            self.newsType=1
              textLable.text="Up to 64 Characters"
              bodyLable.text="Upto 1500 Words"
            break
        case 2:
                //media
              self.nwsTitle.text=""
                 self.mainBody.text=""
            self.newsType=3
              textLable.text="Up to 64 Characters"
              bodyLable.text="One line Caption"
            break
            
        default:
            textLable.text="Nothing Selected"
        }
    }
    @IBAction func getCurrentLocation(_ sender: Any) {
        
        activityIndicator.startAnimating()
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
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        // Geocode Location
           var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            var currentlocation=self.processResponse(withPlacemarks: placemarks, error: error)
            print("lcation \(currentlocation)")
            self.locationLable.isHidden=false
            self.locationLable.text=currentlocation
            self.activityIndicator.stopAnimating()
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
            let newsTitleLength=self.nwsTitle.text?.count
           // print("newsTitleLength\(newsTitleLength)")
            let mainbodyContent=self.mainBody.text
            var mainBodyArray=mainbodyContent?.components(separatedBy: " ")
            var mainArrayLength = mainBodyArray?.count as! Int
          //  print("mainArrayLength \(mainArrayLength)")
          if (self.nwsTitle.text?.isEmpty)! {
              
                //self.nwsTitle.placeholder.
                self.nwsTitle.attributedPlaceholder = NSAttributedString(string: "Please enter News Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                //self.nwsTitle.placeholder="Please enter News Title"
                result=false
                
            }
            else if ( newsTitleLength! > 65) {
                self.nwsTitle.text=""
                self.nwsTitle.attributedPlaceholder = NSAttributedString(string: "Title should be max 64 Characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
               
                result=false
            }
             else if(self.mainBody.text?.isEmpty)!{
                   self.mainBody.attributedText = NSAttributedString(string: "Please enter News Content", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                  result=false
            }
          else if( mainArrayLength  > 1501){
                self.mainBody.attributedText = NSAttributedString(string: "Content should be upto 1500 word max", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
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
            let newsTitleLength=self.nwsTitle.text?.count
            let mainBodyLength=self.mainBody.text?.count as! Int
            //print("newsTitleLength\(newsTitleLength)")
            print("mainBodyLength\(mainBodyLength)")
            if (self.nwsTitle.text?.isEmpty)! {
                
                //self.nwsTitle.placeholder.
                self.nwsTitle.attributedPlaceholder = NSAttributedString(string: "Please enter News Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                //self.nwsTitle.placeholder="Please enter News Title"
                result=false
                
            }
            else if ( newsTitleLength! > 65) {
                self.nwsTitle.text=""
                self.nwsTitle.attributedPlaceholder = NSAttributedString(string: "Title should be max 64 Characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                
                result=false
            }
            else if(self.mainBody.text?.isEmpty)!{
                self.mainBody.attributedText = NSAttributedString(string: "Please enter News Content", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                result=false
            }
            else if( mainBodyLength > 281){
              self.mainBody.text=""
                 self.mainBody.attributedText = NSAttributedString(string: "Content should be upto max 280 Characters ", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
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
            if (self.nwsTitle.text?.isEmpty)! {
                
                //self.nwsTitle.placeholder.
                self.nwsTitle.attributedPlaceholder = NSAttributedString(string: "Please enter News Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                //self.nwsTitle.placeholder="Please enter News Title"
                result=false
            }
            else{
                result=true
            }
            if(self.mainBody.text?.isEmpty)!{
                self.mainBody.attributedText = NSAttributedString(string: "Please enter News Content", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
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
        return result
    }
    
    @IBAction func releaseNews(_ sender: Any) {
        print("in release news function ")
        var validation=validate()
        print("validation \(validation)")
        if(validation){
            
             let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addPost")
             var request=URLRequest(url:url!)
             request.httpMethod="POST"
             
             //let postString="num1=1&num2=6"
             let userId=UserDefaults.standard.object(forKey: "userId")
             let newsTitle=self.nwsTitle.text as! String
             let newsBody=self.mainBody.text as! String
             print("userId \(newsTitle)")
            let json = ["userId":"1","title":"\(newsTitle)","des":"\(newsBody)","type":self.newsType,"media":"\(self.media)","latitude":"\(self.lat)","longitude":"\(self.long)"] as [String : Any]
             print("json \(json)")
             let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
             request.httpBody = jsonData
             
             request.addValue("application/json", forHTTPHeaderField: "Content-Type")
             let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                
             if (error != nil){
           
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
                        let newsView = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
                        self.present(newsView, animated: true, completion: nil)
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
    //function to get media related to news
    @IBAction func getMedia(_ sender: Any) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Media", message: "Choose any option to load Media", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
        }
        let cancelAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
               // var imagePicker = UIImagePickerController()
                //imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let cancelAction1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cancelAction1)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicked.image = image
        dismiss(animated:true, completion: nil)
    }
    
    
}
