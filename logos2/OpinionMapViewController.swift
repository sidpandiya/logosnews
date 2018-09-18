//
//  OpinionMapViewController.swift
//  logos2
//
//  Created by subodh-mac on 18/06/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
var style = "[{\"elementType\": \"geometry\",\"stylers\": [{\"color\": \"#212121\" } ]},{\"elementType\": \"labels.icon\",\"stylers\": [ { \"visibility\": \"off\" }]},{\"elementType\": \"labels.text.fill\",\"stylers\": [ {\"color\": \"#757575\"} ]},{ \"elementType\": \"labels.text.stroke\",\"stylers\": [{\"color\": \"#212121\" }]},{\"featureType\": \"administrative\", \"elementType\": \"geometry\",\"stylers\": [{\"color\": \"#757575\"}]},{\"featureType\": \"administrative.country\",\"elementType\": \"labels.text.fill\",    \"stylers\": [{\"color\": \"#9e9e9e\" }  ]},{\"featureType\": \"administrative.locality\",\"elementType\": \"labels.text.fill\",    \"stylers\": [{\"color\": \"#bdbdbd\"}]},{\"featureType\": \"poi\",\"elementType\": \"labels.text.fill\",\"stylers\": [{\"color\":\"#757575\"}]},{\"featureType\": \"poi.park\",\"elementType\": \"geometry\",\"stylers\": [{\"color\": \"#181818\"    }]},{\"featureType\": \"poi.park\",\"elementType\": \"labels.text.fill\", \"stylers\": [ {\"color\": \"#616161\"}    ]},{ \"featureType\": \"poi.park\",\"elementType\": \"labels.text.stroke\",\"stylers\": [{ \"color\": \"#1b1b1b\"}]},{\"featureType\": \"road\",\"elementType\": \"geometry.fill\",\"stylers\": [{\"color\": \"#2c2c2c\"} ]},{\"featureType\": \"road\",\"elementType\": \"labels.text.fill\",\"stylers\": [ {        \"color\": \"#8a8a8a\"    }    ]},{ \"featureType\": \"road.arterial\",\"elementType\": \"geometry\",\"stylers\": [{\"color\": \"#373737\"} ]},{\"featureType\": \"road.arterial\",\"elementType\": \"labels\",\"stylers\": [{\"visibility\": \"off\"}]},{ \"featureType\": \"road.highway\",\"elementType\": \"geometry\",\"stylers\": [{\"color\": \"#3c3c3c\"}]},{ \"featureType\": \"road.highway\",\"elementType\": \"labels\",\"stylers\": [{\"visibility\": \"off\"}]},{\"featureType\": \"road.highway.controlled_access\", \"elementType\": \"geometry\",\"stylers\": [{\"color\": \"#4e4e4e\"}]},{\"featureType\": \"road.local\",\"stylers\": [{\"visibility\": \"off\"}]},{\"featureType\": \"road.local\",\"elementType\": \"labels.text.fill\",\"stylers\": [{\"color\": \"#616161\"}]},{\"featureType\": \"transit\",\"elementType\": \"labels.text.fill\",\"stylers\": [{\"color\": \"#757575\"}]},{ \"featureType\": \"water\",\"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#000000\" }]},{\"featureType\": \"water\",\"elementType\": \"labels.text.fill\",\"stylers\": [ {\"color\": \"#3d3d3d\"}]}]"
class OpinionMapViewController: UIViewController,GMSMapViewDelegate {
    var news:mapOpions?
    override func viewDidLoad() {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        print("news \(news?.mapType)")
        let userlat = UserDefaults.standard.object(forKey: "currentLatitude") as! NSNumber
        let userlong = UserDefaults.standard.object(forKey: "currentLongitude") as! NSNumber
        print("userlat \(userlat) userlong \(userlong)")
        //self.showMap(latitude: CLLocationDegrees(userlat), longitude: CLLocationDegrees(userlong))
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(userlat) as! CLLocationDegrees, longitude:CLLocationDegrees(userlong) as! CLLocationDegrees, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        
        
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        do {
            // Set the map style by passing the URL of the local file.
            print("in load style json")
            mapView.mapStyle = try GMSMapStyle(jsonString: style)
            
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        view = mapView
        if news?.mapType == 0{
            self.showNewsopiniosMap(newsId:(news?.newsId)!,mapView:mapView)
        }
        else {
            self.showStatmentopiniosMap(newsId:(news?.newsId)!,mapView:mapView)
        }
        var back=UIImage(named:"cross")
        self.navigationController?.navigationBar.backIndicatorImage=back
        
        self.navigationController?.navigationBar.tintColor=UIColor.white
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage=back
        super.viewDidLoad()
        
        let image = UIImage(named: "cancel1.png") as! UIImage
        
        let btn: UIButton = UIButton(type: UIButtonType.roundedRect)
        var padding = CGFloat(20)
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            padding = (window?.safeAreaInsets.top)!
            if padding == CGFloat(0.0) {
                padding = CGFloat(20)
            }
            
        }
        btn.frame = CGRect(x: 15, y: padding, width: 50, height: 30)
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor.white
        //btn.setTitle("MyButton", for: UIControlState.normal)
        //btn.backgroundColor = UIColor.white
        btn.addTarget(self, action: #selector(changeScreen), for: .touchUpInside);
        self.view.addSubview(btn)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func changeScreen(button: UIButton)
    {
        dismiss(animated: true, completion: nil)
        // performSegue(withIdentifier: "screen1ToScreen2", sender: button);
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func showNewsopiniosMap(newsId:String,mapView:GMSMapView){
        print("newsId \(newsId)")
        var url="https://us-central1-logos-app-915d7.cloudfunctions.net/getNewsOpinionByNewsId?key=\(newsId)"
        let getNewOpinionUrl = URL(string:url)
        var getNewOpinionRequest = URLRequest(url:getNewOpinionUrl!)
        getNewOpinionRequest.httpMethod = "POST"
        
        
        getNewOpinionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getNewOpinionTask=URLSession.shared.dataTask(with: getNewOpinionRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if(error != nil){
                //print("Nil error getNewsbyLocation ")
                DispatchQueue.main.async () {
                    //self.loading.stopAnimating()
                }
            }
            do{
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    print("data \(jsonObj)" );
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code") as! Int
                        // returned success code
                        if(code == 1){
                            DispatchQueue.main.async {
                                if let newsopinionArray = jsonObj!.value(forKey: "data") as? NSArray {
                                    for newsOpinion in newsopinionArray{
                                        
                                        if let newsOpinionDict = newsOpinion as? NSDictionary {
                                            
                                            let userlatitude = newsOpinionDict.value(forKey:"userlatitude") as! String
                                            let userlongitude = newsOpinionDict.value(forKey:"userlongitude")  as! String
                                            let opinio=Int(newsOpinionDict.value(forKey:"opinion")  as! String)
                                            self.showMarkers(lat: CLLocationDegrees(userlatitude)!, long: CLLocationDegrees(userlongitude)!, mapView: mapView,opinion: opinio! )
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            let alert = UIAlertController(title: "Alert", message: "No opinion Found on this News Feed", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
                
            }catch let error as NSError{
                print("Error in get posts  opinion url \(error.localizedDescription)")
            }
        }
        getNewOpinionTask.resume()
    }
    func showMarkers(lat : CLLocationDegrees,long : CLLocationDegrees,mapView : GMSMapView,opinion :Int){
        
        print("lat\(lat) and long\(long) ")
        
        // Start background thread so that image loading does not make app unresponsive
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude : lat,longitude : long)
        
        marker.map = mapView
        
        
        print("opinion \(Int (opinion))")
        
        let agreeColor = hexStringToUIColor(hex: "009688")
        let neutralColor = hexStringToUIColor(hex:"#5AC8FA" )
        let disagreeColor = hexStringToUIColor(hex:"#C6453B" )
        marker.iconView?.backgroundColor = UIColor.black
        if opinion == 0 {
            // marker.icon=GMSMarker.markerImage(with: UIColor.blue)
            marker.iconView=UIImageView(image:UIImage(named:"blue2")?.withRenderingMode(.alwaysTemplate))
            marker.iconView?.tintColor = neutralColor
        }else if opinion == 1{
            // marker.icon=GMSMarker.markerImage(with: UIColor.green)
            marker.iconView=UIImageView(image:UIImage(named:"green2")?.withRenderingMode(.alwaysTemplate))
            marker.iconView?.tintColor = agreeColor
        }
        else if opinion == 2{
            //marker.icon=GMSMarker.markerImage(with: UIColor.red)
            marker.iconView=UIImageView(image:UIImage(named:"red2")?.withRenderingMode(.alwaysTemplate))
            marker.iconView?.tintColor = disagreeColor
        }
        else{
            
        }
    }
    func showStatmentopiniosMap(newsId:String,mapView:GMSMapView){
        print("newsId \(newsId)")
        var url="https://us-central1-logos-app-915d7.cloudfunctions.net/getNewsStatementOpinionByNewsId?key=\(newsId)"
        let getNewOpinionUrl = URL(string:url)
        var getNewOpinionRequest = URLRequest(url:getNewOpinionUrl!)
        getNewOpinionRequest.httpMethod = "POST"
        
        
        getNewOpinionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let getNewOpinionTask=URLSession.shared.dataTask(with: getNewOpinionRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if(error != nil){
                //print("Nil error getNewsbyLocation ")
                DispatchQueue.main.async () {
                    //self.loading.stopAnimating()
                }
            }
            do{
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    print("data \(jsonObj)" );
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code") as! Int
                        // returned success code
                        if(code == 1){
                            DispatchQueue.main.async {
                                if let newsopinionArray = jsonObj!.value(forKey: "data") as? NSArray {
                                    for newsOpinion in newsopinionArray{
                                        
                                        if let newsOpinionDict = newsOpinion as? NSDictionary {
                                            
                                            let userlatitude = newsOpinionDict.value(forKey:"userlatitude") as! String
                                            let userlongitude = newsOpinionDict.value(forKey:"userlongitude")  as! String
                                            let opinio=Int(newsOpinionDict.value(forKey:"opinion")  as! String)
                                            self.showMarkers(lat: CLLocationDegrees(userlatitude)!, long: CLLocationDegrees(userlongitude)!, mapView: mapView,opinion: opinio!)
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            let alert = UIAlertController(title: "Alert", message: "No opinion Found on this Statement ", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
                
            }catch let error as NSError{
                print("Error in get posts  opinion url \(error.localizedDescription)")
            }
        }
        getNewOpinionTask.resume()
    }
    
}

