//
//  CityMapViewController.swift
//  logos2
//
//  Created by subodh-mac on 17/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import Toast_Swift

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}

// init cityData object @Author subodh3344
struct cityData {
    var cityLat : CLLocationDegrees
    var cityLong : CLLocationDegrees
    var cityId : Int
    var cityName : String
    var newsId : NSString
}


class CityMapViewController : UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate,UISearchBarDelegate{
    var activityInidicator:UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var navBar: UINavigationItem!
    
    // new
    let currentLocationMarker = GMSMarker()
    var locationManager = CLLocationManager()
    var chosenPlace: MyPlace?
    
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    
    
    // variables
    var userCurrentLatitude : Any = 0.0
    var userCurrentLongitude : Any = 0.0
    
    
    
    var Data = (cityLat:0.0,cityLong:0.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        /*TODO : Uncomment code */
        
        activityInidicator.center = self.view.center
        activityInidicator.hidesWhenStopped = true
        activityInidicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityInidicator)
        activityInidicator.startAnimating()
        
        // call function to get user's current location @Author subodh3344
        
       //self.getUserLocation()
        
        // add api key from google map sdk manager
     //   GMSServices.provideAPIKey("AIzaSyBR1AiGZT4RyEkj9Cdb2zUWZK34aDqg4Sc")
        
        /*
         @Author subodh3344 5.4.18
         pass user's current latitude and logitude to withLatitude and longitude
         */
       

//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startMonitoringSignificantLocationChanges()

        
        // search bar functionality
        search.alpha = 0.8
        search.backgroundImage = UIImage()
        search.barTintColor = UIColor.clear
        //search.isUserInteractionEnabled = true
        search.delegate = self
    //view.insertSubview(searchbar, aboveSubview: view)
      // view.bringSubview(toFront: searchbar)
        search.placeholder = "";
       // search.showsCancelButton = true
        navBar.titleView = search
        
       //searchbar.bringSubview(toFront: search)
       activityInidicator.stopAnimating()
    }
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            
        }
    }
    
    
    // search bar functions
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            print("searching for \(searchBar.text)")
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print("ended \(searchBar.text)")
//    }
    
    
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    
    // function call once user clicks enter/search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("clicked \(searchBar.text)")
        self.searchAuthorOrNews(text:searchBar.text as! String)
    }
    
    
    func searchAuthorOrNews(text:String){
        
       // print("in getNewsByLocation \(cityName) , country name \(countryName)")
        let camera = GMSCameraPosition.camera(withLatitude: self.userCurrentLatitude as! CLLocationDegrees, longitude:self.userCurrentLongitude as! CLLocationDegrees, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        view = mapView
        
        
        print("in search function got text : \(text)")
         activityInidicator.startAnimating()
        let searchText = text as! String
        let getAllPostsUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/searchNewsOrAuthor")
        var getAllPostsRequest = URLRequest(url:getAllPostsUrl!)
        getAllPostsRequest.httpMethod = "POST"
        let json = ["searchText":"\(searchText)"] as [String:Any]
        //print("json \(json)")
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        getAllPostsRequest.httpBody = jsonData
        getAllPostsRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getPostsTask=URLSession.shared.dataTask(with: getAllPostsRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if(error != nil){
                //print("Nil error getNewsbyLocation ")
                DispatchQueue.main.async () {
                    //self.loading.stopAnimating()
                }
            }
            do{
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code") as! Int
                        // returned success code
                        if(code == 1){
                            DispatchQueue.main.async {
                                if let newsDataArray = jsonObj!.value(forKey: "data") as? NSArray {
                                    for news in newsDataArray{
                                        if let newsDataDict = news as? NSDictionary {
                                            let userData = newsDataDict.value(forKey:"user") as! NSObject
                                            let newsData = newsDataDict.value(forKey:"news") as! NSObject
                                            let newsId = newsDataDict.value(forKey:"newsId") as! NSString
                                            let newsLRCount = newsDataDict.value(forKey:"newsLRCount") as! NSNumber
                                            let newsAgreeCount = newsDataDict.value(forKey:"agreeCount") as! NSNumber
                                            let newsNeutralCount = newsDataDict.value(forKey:"neutralCount") as! NSNumber
                                            var newsLat = newsData.value(forKey: "latitude") as! NSString
                                            var newsLong = newsData.value(forKey: "longitude") as! NSString
                                            var newsTitle : String = ""
                                            let newsViews  = Float(newsData.value(forKey: "views") as! CGFloat)
                                            if (newsData.value(forKey: "title") as! String == nil || newsData.value(forKey: "title") as! String == ""){newsTitle = "NA"} else {newsTitle = newsData.value(forKey: "title") as! String}
                                            let NewsMedia = newsData.value(forKey: "media") as! String
                                            let size = Float(50)
                                            print("size \(size)")
                                            self.showMarkers(lat: newsLat.doubleValue, long: newsLong.doubleValue, title: newsTitle, mapView:
                                                mapView,imageUrl:NewsMedia as! String,tag:1,size :size,newsId:newsId,newsData:newsDataDict)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.showToaster(msg : "No Data Available",type :0)
                            }
                        }
                    }
                }
                
            }catch let error as NSError{
                print("Error in get posts url \(error.localizedDescription)")
            }
        }
        getPostsTask.resume()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel clicked")
    }
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        //image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: newSize.width, height: newSize.height))  )
        //self.image.layer
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

//        override func didReceiveMemoryWarning() {
//            super.didReceiveMemoryWarning()
//            // Dispose of any resources that can be recreated.
//        }
//
//        show marker function we can add customized markers here @Author subodh3344
    func showMarkers(lat : CLLocationDegrees,long : CLLocationDegrees,title : String,mapView : GMSMapView,imageUrl:String,tag:Int,size:Float,newsId :NSString,newsData:NSDictionary){
        var imageHeight : Float = 0.0
        var imageWidth : Float = 0.0
        if(size<=50.0){
            imageHeight = 50.0
            imageWidth = 50.0
        }
        else{
            imageHeight = size * 2
            imageWidth = size * 2
        }
        print("lat\(lat) and long\(long) , size \(size) imageWidth n height is \(imageWidth)in show marker")
        // to fetch Image By URL
        let url = "https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff"
        let imageUrl:URL = URL(string: url)!
        // Start background thread so that image loading does not make app unresponsive
        
        let imageData:NSData = NSData(contentsOf: imageUrl)!
        let imageView = UIImageView(frame: CGRect(x:800, y:self.view.frame.origin.x+40, width:CGFloat(imageWidth), height:CGFloat(imageHeight)))
        imageView.center = self.view.center
        imageView.layer.cornerRadius = CGFloat(imageHeight/2)
        imageView.layer.masksToBounds = true
        let image = UIImage(data: imageData as Data)
        imageView.image = image
        let data = cityData(cityLat: lat, cityLong: long,cityId:tag,cityName:title,newsId : newsId) // initialize struct
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude : lat,longitude : long)
        marker.title = title;
        marker.iconView = imageView
        marker.userData = newsData
        marker.map = mapView
    }
    
    func mapView(_mapView: GMSMapView, markerInfoContents marker: GMSMarker){
        
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.darkGray, tag: customMarkerView.tag)
        marker.iconView = customMarker
        
        //        return restaurantPreviewView
    }
    
    func mapView(_mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("tapped")
        // guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        //let tag = customMarkerView.tag
        //restaurantTapped(tag)
    }
    
    func mapView(_mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.darkGray, tag: customMarkerView.tag)
        marker.iconView = customMarker
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        if let newsDataDict = marker.userData as? NSDictionary {
            // author information
            let userData = newsDataDict.value(forKey:"user") as! NSObject
            // news Information
            let newsData = newsDataDict.value(forKey:"news") as! NSObject
            let newsId = newsDataDict.value(forKey:"newsId") as! NSString
            let newsLRCount = newsDataDict.value(forKey:"newsLRCount") as! NSNumber
            let newsAgreeCount = newsDataDict.value(forKey:"agreeCount") as! NSNumber
            let newsNeutralCount = newsDataDict.value(forKey:"neutralCount") as! NSNumber
            let newsDisagreeCount = newsDataDict.value(forKey: "disagreeCount") as! NSNumber
           var newsLat = newsData.value(forKey: "latitude") as! NSString
            var newsLong = newsData.value(forKey: "longitude") as! NSString
            var newsTitle : String = ""
            let newsViews  = Float(newsData.value(forKey: "views") as! CGFloat)
            if (newsData.value(forKey: "title") as! String == nil || newsData.value(forKey: "title") as! String == ""){
                newsTitle = "NA"
                
            }
            else {
                newsTitle = newsData.value(forKey: "title") as! String
                
            }
            let NewsMedia = newsData.value(forKey: "media") as! String
            let countryNewsViewCount = Float(newsDataDict.value(forKey: "countryNewsViewCount") as! CGFloat)
            let userImage : UIImage
            let mediaImage : UIImage
            if(userData.value(forKey: "photo") != nil){
                let userImageUrl:URL = URL(string: userData.value(forKey: "photo") as! String)!
                let UserImageData:NSData = NSData(contentsOf: userImageUrl)!
                userImage = UIImage(data: UserImageData as Data)!
               
            }
            else{
                let userImageUrl:URL = URL(string: "https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff")!
                let UserImageData:NSData = NSData(contentsOf: userImageUrl)!
                 userImage = UIImage(data: UserImageData as Data)!
               }
            
            
            if (newsData.value(forKey: "media") != nil){
                let newsImageUrl:URL = URL(string:newsData.value(forKey: "media") as! String)!
                let mediaImageData:NSData = NSData(contentsOf : newsImageUrl)!
                 mediaImage = UIImage(data:mediaImageData as Data)!
               }
            else{
                // TODO : Add default image of newzSlate here @Author subodh3344
                let newsImageUrl:URL = URL(string:"https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff")!
                let mediaImageData:NSData = NSData(contentsOf : newsImageUrl)!
                mediaImage = UIImage(data:mediaImageData as Data)!
               }
           
            
            guard let newDataForView = newzListData(
                userName:userData.value(forKey: "name") as! String,
                userEndorsment:"0",
                userProfileImage:userImage,
                newsImage:mediaImage,
                newsTitle:newsTitle,
                agreeCount:Int(newsAgreeCount),
                disAgreeCount:Int(newsDisagreeCount), nutralCount:Int(newsNeutralCount),
                minBiasedValue:0,
                id:newsId as String,
                time: newsData.value(forKey: "timeAgo") as! String,
                AuthorId: newsData.value(forKey: "userId") as! String
                )else{
                fatalError("Error while creating newsDataForView")
            }
            
            
            print("newsDataForView \(newDataForView)")
            let vc = UIStoryboard.init(name:"Main",bundle:Bundle.main).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
            vc.news = newDataForView
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return true
    }

    
    
    // location manager function to get user's current location @Auhor subodh3344
    func getUserLocation(){
        var locationManager = CLLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userCurrntLocations:CLLocation = locations[0] as CLLocation
        print("****** got current location \(userCurrntLocations.coordinate.latitude) and \(userCurrntLocations.coordinate.longitude)")
        self.userCurrentLatitude = userCurrntLocations.coordinate.latitude
        self.userCurrentLongitude = userCurrntLocations.coordinate.longitude
        
        // to set current location in local storage
        UserDefaults.standard.set(userCurrntLocations.coordinate.latitude, forKey: "currentLatitude")
        UserDefaults.standard.set(userCurrntLocations.coordinate.longitude, forKey:"currentLongitude")
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userCurrntLocations) { (placemarks, error) in
            // Process Response
            var currentlocation=self.processResponse(withPlacemarks: placemarks, error: error)
            print("lcation \(currentlocation)")
            if (placemarks?.first?.locality != nil){
                /*
                 @Author subodh3344 5.4.18
                 showmarker function to append marker on map
                 params :
                 latitude ,longitude,title ,mapview(maps instance),image(UIImage),tag:Id of city
                 */
                
                self.getNewsByLocation(latitude:userCurrntLocations.coordinate.latitude as! CLLocationDegrees,longitude : userCurrntLocations.coordinate.longitude as! CLLocationDegrees,type:0,cityName :placemarks?.first?.locality,countryName:placemarks?.first?.country)
            }
            else{
                /*
                 @Author subodh3344 5.4.18
                 showmarker function to append marker on map
                 params :
                 latitude ,longitude,title ,mapview(maps instance),image(UIImage),tag:Id of city
                 */
                
                self.getNewsByLocation(latitude:userCurrntLocations.coordinate.latitude as! CLLocationDegrees,longitude : userCurrntLocations.coordinate.longitude as! CLLocationDegrees,type:0,cityName :nil,countryName:placemarks?.first?.country)
            }
            
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
    
    /*Get location wise news
     input :
     1 . user's current latitude
     2 . user's current longitude
     @Author subodh3344
     */
    
    func getNewsByLocation(latitude:CLLocationDegrees,longitude:CLLocationDegrees,type:Int,cityName:String?,countryName:String?){
        print("in getNewsByLocation \(cityName) , country name \(countryName)")
        let camera = GMSCameraPosition.camera(withLatitude: self.userCurrentLatitude as! CLLocationDegrees, longitude:self.userCurrentLongitude as! CLLocationDegrees, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        view = mapView
        // if we get city name nil from google plces
        if(cityName == nil){
            // fetch news using latitude and longitude
            print("Fetching citywise news")
            let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getAllPosts"
            let data = ["type":type,"Lat":latitude,"Long":longitude,"countryName":countryName] as [String : Any]
            self.fetchNews(url: url, data: data, mapView: mapView)
        }
        else{
            // fetch news using city name
            print("fetching locartion wise news")
            let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getCityNews"
            let data = ["cityName":cityName,"type":type,"countryName":countryName] as [String : Any]
             self.fetchNews(url: url, data: data, mapView: mapView)
        }
        
        
    
}

    func fetchNews(url : String , data : Any , mapView:GMSMapView){
        // get screen size
        let screenSize = UIScreen.main.bounds.width
        print("screen size is\(screenSize)")
        print("Url is \(url)")
        print("Data is \(data)")
        let getAllPostsUrl = URL(string:url)
        var getAllPostsRequest = URLRequest(url:getAllPostsUrl!)
        getAllPostsRequest.httpMethod = "POST"
        let json = data
        //print("json \(json)")
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        getAllPostsRequest.httpBody = jsonData
        getAllPostsRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getPostsTask=URLSession.shared.dataTask(with: getAllPostsRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if(error != nil){
                //print("Nil error getNewsbyLocation ")
                DispatchQueue.main.async () {
                    //self.loading.stopAnimating()
                }
            }
            do{
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code") as! Int
                        // returned success code
                        if(code == 1){
                            DispatchQueue.main.async {
                                if let newsDataArray = jsonObj!.value(forKey: "data") as? NSArray {
                                    for news in newsDataArray{
                                        if let newsDataDict = news as? NSDictionary {
                                            let userData = newsDataDict.value(forKey:"user") as! NSObject
                                            let newsData = newsDataDict.value(forKey:"news") as! NSObject
                                            let newsId = newsDataDict.value(forKey:"newsId") as! NSString
                                            let newsLRCount = newsDataDict.value(forKey:"newsLRCount") as! NSNumber
                                            let newsAgreeCount = newsDataDict.value(forKey:"agreeCount") as! NSNumber
                                            let newsNeutralCount = newsDataDict.value(forKey:"neutralCount") as! NSNumber
                                           var newsLat = newsData.value(forKey: "latitude") as! NSString
                                            var newsLong = newsData.value(forKey: "longitude") as! NSString
                                            var newsTitle : String = ""
                                            let newsViews  = Float(newsData.value(forKey: "views") as! CGFloat)
                                            if (newsData.value(forKey: "title") as! String == nil || newsData.value(forKey: "title") as! String == ""){newsTitle = "NA"} else {newsTitle = newsData.value(forKey: "title") as! String}
                                            let NewsMedia = newsData.value(forKey: "media") as! String
                                            let countryNewsViewCount = Float(newsDataDict.value(forKey: "countryNewsViewCount") as! CGFloat)
                                            
                                            // calculation for news bubble size
                                            let size = ((newsViews/countryNewsViewCount)*100).remainder(dividingBy: Float(screenSize))
                                            print("size \(size)")
                                            self.showMarkers(lat: newsLat.doubleValue, long: newsLong.doubleValue, title: newsTitle, mapView:
                                                mapView,imageUrl:NewsMedia as! String,tag:1,size :size,newsId:newsId,newsData:newsDataDict)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }catch let error as NSError{
                print("Error in get posts url \(error.localizedDescription)")
            }
        }
        getPostsTask.resume()
        
    }
}

