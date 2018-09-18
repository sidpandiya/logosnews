//
//  NewsFeedTableViewController.swift
//
//
//  Created by కార్తీక్ సూర్య on 5/7/18.
//

import UIKit
import os.log
import GoogleMaps
import Toast_Swift
import SwiftyJSON
import FirebaseDatabase
import SwiftMoment
class Post {
    static var newPost = false
}
class NewsFeedTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,GMSMapViewDelegate,CLLocationManagerDelegate, UISearchBarDelegate {
    //class NewsFeedTableViewController: UITableViewController {
   var ref: DatabaseReference!
    @IBOutlet weak var newsTableView: UITableView!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var allButt: UIButton!
    
    @IBOutlet weak var postsButt: UIButton!
    @IBOutlet weak var mediaButt: UIButton!
    @IBOutlet weak var artButt: UIButton!
   
    @IBOutlet weak var searchShadow: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var cityTitleText: UILabel!
    @IBOutlet weak var allLine: UIView!
    
    @IBOutlet weak var mediaLine: UIView!
    @IBOutlet weak var artLine: UIView!
    
    @IBOutlet weak var postsLine: UIView!
    let activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    let selectedColor = hexStringToUIColor(hex: "#5AC8FA")
    
    var loadingCompleted = false;
    var isFirstLoad = true;
    var userId = String()

    // variables
    var userCurrentLatitude : Any = 0.0
    var userCurrentLongitude : Any = 0.0
    var loadingData = false
    
    let defaultImageUrl : String = "https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/default_news_image.png?alt=media&token=293cd97b-77a4-4c4d-91df-f1c03fc1cc0e"
    
    
//    let news = ["Syria gas attack","Prez. Moon in talks","US-Russia clash in Syria","SpaceX does it again!","Avengers a smash","Back panther eats CDs","India nukes itself","India not nuked","Is India nuked?","India is fake news", "Cow survives India attack"]

    var newsFinalData=[newzListData]()
    
    // database variable
 
    
    // for pull to refresh
    private let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        let dayYear = Date()
        let dayYearFormatted = dayYear.toString(dateFormat: "dd yyyy")
        let f = DateFormatter()
        let weekDay = f.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
        let month = f.monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
        let fullDate = "\(weekDay), \(month) \(dayYearFormatted)"
        date.text = fullDate.uppercased()
        // for pull to refresh
    
        if #available(iOS 10.0, *) {
            newsTableView.refreshControl = refreshController
        } else {
            newsTableView.addSubview(refreshController)
        }
        refreshController.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
        
        ref = Database.database().reference()
        // Starts monitoring location
        
        
        //        var locationManager = CLLocationManager()
        //        locationManager.delegate = self
        //        locationManager.requestWhenInUseAuthorization()
        //        locationManager.startUpdatingLocation()
        //        locationManager.startMonitoringSignificantLocationChanges()
        
        //loadNews()
        
        
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.separatorStyle =
            UITableViewCellSeparatorStyle.none
        self.fetchNewsNew(start: "0", offset: 8)
//        cityTitleText.adjustsFontSizeToFitWidth = true
//        cityTitleText.numberOfLines = 1
//        cityTitleText.minimumScaleFactor = 0.01
        
        /* let borderColor = hexStringToUIColor(hex: "#80CBC4")
         self.header.layer.borderWidth = 1.0
         self.header.layer.borderColor = borderColor.cgColor
         header.addshadow(top: false, left: true, bottom: true, right: true)
         */
        /*  allButt.tintColor = selectedColor
         allLine.isHidden = false
         
         artButt.tintColor = UIColor.gray
         mediaButt.tintColor = UIColor.gray
         postsButt.tintColor = UIColor.gray
         artLine.isHidden = true
         mediaLine.isHidden = true
         postsLine.isHidden = true
         */
//        for subView in searchBar.subviews {
//
//            for subViewOne in subView.subviews {
//
//                if let textField = subViewOne as? UITextField {
//                    let searchColor = hexStringToUIColor(hex: "#F0F1F3")
//                    subViewOne.backgroundColor = searchColor
//
//                    //use the code below if you want to change the color of placeholder
//                    let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
//
//
//                    let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
//                    textFieldInsideUISearchBar?.textColor = UIColor.gray
//                    textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(13)
//                    //   textFieldInsideUISearchBarLabel?.
//                }
//            }
//        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //fetch all news lazy loadin function
//        let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getAllPosts2"
//        let data = ["type":0,"start":"0","offset":8] as [String : Any]
//        print("calling fetch News with data \(data)")
//        self.fetchNews(url: url, data: data)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if Post.newPost {
        if #available(iOS 10.0, *) {
            newsTableView.refreshControl = refreshController
        } else {
            newsTableView.addSubview(refreshController)
        }
        refreshController.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        ref = Database.database().reference()
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.separatorStyle =
        UITableViewCellSeparatorStyle.none
        self.newsFinalData.removeAll()
        self.fetchNewsNew(start: "0", offset: 8)
       
        newsTableView.reloadData()
        Post.newPost = false 
        }
    }
    override func viewDidLayoutSubviews() {
        
//        searchBar.delegate = self
//        searchBar.placeholder = "Search people, stories..."
//        searchBar.layer.cornerRadius = 8
//        searchBar.backgroundImage = UIImage()
//        
//        searchBar.setPositionAdjustment(UIOffset(horizontal: 0, vertical: 1), for: .search)
//        searchBar.layoutSubviews()
//        searchBar.layoutIfNeeded()
//    
//        searchBar.addshadow(top: false, left:true, bottom: true, right: true)
        newsTableView.rowHeight = (0.8 * newsTableView.frame.height) / 3.1
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // for pull to refresh
    private func updateView() {
        let hasDays = newsFinalData.count > 0
        newsTableView.isHidden = !hasDays
        
        
        if hasDays {
            newsTableView.reloadData()
        }
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        self.newsFinalData.removeAll()
        self.newsTableView.reloadData()
      
          self.fetchNewsNew(start: "0", offset: 4)
        self.activityIndicator.isHidden=true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("got news size \(newsFinalData.count)")
        return newsFinalData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("calling tableView **************")
        let cellIdentifier = "NewsListViewCell"
        guard let cell = newsTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NewsListViewCell else {
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
        
        cell.articleLabel.text = newsFinalData[indexPath.row].newsTitle
        let scaledImage = scaleUIImageToSize(image: newsFinalData[indexPath.row].newsImage
, size: cell.articleImage.frame.size)
        cell.articleImage.image = scaledImage
        cell.articleCategory.text = newsFinalData[indexPath.row].userEndorsment

        let firstNameOnly = newsFinalData[indexPath.row].userName.components(separatedBy: " ")
       cell.posterName.text = firstNameOnly[0]
        let seeUserProf = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
        seeUserProf.id = newsFinalData[indexPath.row].AuthorId
        cell.posterName.addGestureRecognizer(seeUserProf)
        let seeUserProf2 = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
        seeUserProf2.id = newsFinalData[indexPath.row].AuthorId
        cell.profilePic.addGestureRecognizer(seeUserProf2)
        cell.profilePic.layer.borderWidth = 0.5
        cell.profilePic.layer.masksToBounds = false
        cell.profilePic.layer.borderColor = bordColor.cgColor
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height/2
        cell.profilePic.clipsToBounds = true
        cell.profilePic.image=newsFinalData[indexPath.row].userProfileImage
        cell.time.text = "\(newsFinalData[indexPath.row].time)"
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
        
        let biasLevel = newsFinalData[indexPath.row].minBiasedValue
        print("biasLevel \(biasLevel)")
        if biasLevel < 0.0 {
            print("in minus")
            cell.rCountSlider.value = 0
            cell.lrCountSlider.value = Float(biasLevel)
            cell.lrCountSlider.setThumbImage(scaledThumb, for: .normal)
            cell.rCountSlider.setThumbImage(UIImage(), for: .normal)
            
        }
        else if biasLevel == 0.0 {
            print("if zero")
            cell.rCountSlider.value = 0
            cell.lrCountSlider.value = 0
            cell.lrCountSlider.setThumbImage(UIImage(), for: .normal)
            cell.rCountSlider.setThumbImage(UIImage(), for: .normal)
        }
        else if biasLevel > 0.0 {
            print("in plus ")
            cell.rCountSlider.value = Float(biasLevel)
            cell.lrCountSlider.value = 0
            cell.rCountSlider.setThumbImage(scaledThumb, for: .normal)
            cell.lrCountSlider.setThumbImage(UIImage(), for: .normal)
        }
        
        
        cell.lrCountSlider.isUserInteractionEnabled=false
        cell.rCountSlider.isUserInteractionEnabled = false
        
        print("agree \(newsFinalData[indexPath.row].agreeCount) neutral \(newsFinalData[indexPath.row].nutralCount) disAgrecount \(newsFinalData[indexPath.row].disAgreeCount)")
        let agreeCount :Int = newsFinalData[indexPath.row].agreeCount
        let neutralCount :Int = newsFinalData[indexPath.row].nutralCount
        let disAgreeCount :Int = newsFinalData[indexPath.row].disAgreeCount
        cell.newsAgreeCountText.text = "\(agreeCount) Agree"
        cell.newsNeutralCountText.text = "\(neutralCount) Neutral"
        cell.newsDisAgreeCountText.text = "\(disAgreeCount) Disagree"


        return (cell)
    }
    
    // lazy loading function
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        print("loadingData is : \(loadingCompleted) indexPath is : \(indexPath.row) and newsFinal count : \(newsFinalData.count)")
        if(indexPath.row == newsFinalData.count-1 && loadingCompleted && !isFirstLoad){
            print("call refresh")
            self.refreshData(id: self.newsFinalData[indexPath.row].id)
        }
//        if !loadingData && indexPath.row == newsFinalData.count-1{
//            loadingData=true;
//            self.refreshData(id: self.newsFinalData[indexPath.row].id)
//        }

    }
    func refreshData(id:String){
        DispatchQueue.main.async {
            self.fetchNewsNew(start: "\(id)", offset: 4)
           // self.loadingCompleted=false

        }
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddItem":
            print("testing")
            break;
        case "showDetails":

           // os_log("show news details",log:OSLog.default,type:.debug)

            guard let articleController = segue.destination as? ArticleViewController else{
                fatalError("unexpected destination :\(segue.destination)")
            }
            
            guard let selectedNewsCell = sender as? NewsListViewCell else{
                fatalError("unexpected sender \(String(describing: sender))")
            }
            guard let indexPath=self.newsTableView.indexPath(for: selectedNewsCell) else{
                fatalError("Selected Cell is not being displayed by table")
            }
            let selectedNews = newsFinalData[indexPath.row]
            articleController.news=selectedNews
            self.updateNewsView(id:selectedNews.id);
        case "AuthorDetails":
            //   os_log("show news details",log:OSLog.default,type:.debug)
            guard let articleController = segue.destination as? AuthorDetailsViewController else{
                fatalError("unexpected destination :\(segue.destination)")
            }
            articleController.userId=self.userId
        default:
            print("defualt case")
            fatalError("unexpected segue indentiifer \(String(describing: segue.identifier))")
            //default case
        }
    }
    
    func loadNews(){
        print("in load news function")
       // self.getLocality(newsType: 0)
    }
    
    //update news views
    //@Author Mansi 30.07.2018
    func updateNewsView(id:String){
        print("id \(id)")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/UpdateNewsViews")
        
        var request=URLRequest(url:url!)
        request.httpMethod="POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String
        let data = ["userId":"\(userId)", "newsId":"\(id)"] as[String : Any]
        print("json \(data)")
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("error while updating news views");
            }
            var error=NSError?.self
            do {
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(String(describing: code))")
                    if code==1{
                        DispatchQueue.main.async{
                            print("news views updated");
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            print("error while updating news views");
                        }
                    }
                }
                else{
                    DispatchQueue.main.async{
                        print("error while updating news views");
                    }
                }
            }
        }
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userCurrntLocations:CLLocation = locations[0] as CLLocation
        print("****** got current location for \(userCurrntLocations.coordinate.latitude) and \(userCurrntLocations.coordinate.longitude)")
        self.userCurrentLatitude = userCurrntLocations.coordinate.latitude
        self.userCurrentLongitude = userCurrntLocations.coordinate.longitude
        let geoCoder = CLGeocoder()
        //        geoCoder.reverseGeocodeLocation(userCurrntLocations) { (placemarks, error) in
        //            // Process Response
        //            var currentlocation=self.processResponse(withPlacemarks: placemarks, error: error)
        //
        //
        //        }
    }
    
    func locationManager2(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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

//            if (placemarks?.first?.locality != nil){
//                /*
//                 @Author subodh3344 5.4.18
//                 showmarker function to append marker on map
//                 params :
//                 latitude ,longitude,title ,mapview(maps instance),image(UIImage),tag:Id of city
//                 */
//
//                self.getNewsByLocation(latitude:userCurrntLocations.coordinate.latitude as! CLLocationDegrees,longitude : userCurrntLocations.coordinate.longitude as! CLLocationDegrees,type:0,cityName :placemarks?.first?.locality,countryName:placemarks?.first?.country)
//            }
//            else{
//                /*
//                 @Author subodh3344 5.4.18
//                 showmarker function to append marker on map
//                 params :
//                 latitude ,longitude,title ,mapview(maps instance),image(UIImage),tag:Id of city
//                 */
//
//                self.getNewsByLocation(latitude:userCurrntLocations.coordinate.latitude as! CLLocationDegrees,longitude : userCurrntLocations.coordinate.longitude as! CLLocationDegrees,type:0,cityName :nil,countryName:placemarks?.first?.country)
//            }

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
    
    // this function is to get current location and fetch news using current lcation
    
    func getLocality(newsType:Int){
        let userLocalData = UserDefaults.standard
        let currLat = userLocalData.value(forKey: "currentLatitude")
        let currLong = userLocalData.value(forKey: "currentLongitude")
        print (currLat, currLong)
        //  print("current location is \(String(describing: currLat)) and \(currLong)")
        let userLocation:CLLocation  = CLLocation(latitude : currLat as! CLLocationDegrees,longitude : currLong as! CLLocationDegrees)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            // Process Response
            var currentlocation=self.processResponse(withPlacemarks: placemarks, error: error)
            print("lcation \(currentlocation)")
            
            // to append city name on list
            //self.cityTitleText.text = currentlocation
            
            
            if (placemarks?.first?.locality != nil){
                self.getNewsByLocation(latitude:currLat,longitude : currLong,type:newsType,cityName :placemarks?.first?.locality,countryName:placemarks?.first?.country)
            }
            else{
                self.getNewsByLocation(latitude:currLat as! String,longitude : currLong as! String,type:newsType,cityName :nil,countryName:placemarks?.first?.country)
            }
            
        }
        
        
    }
    
    func getNewsByLocation(latitude:Any,longitude:Any,type:Int,cityName:String?,countryName:String?){
        print("in getNewsByLocation \(cityName) , country name \(countryName)")
        
        // if we get city name nil from google plces
        if(cityName == nil){
            // fetch news using latitude and longitude
            print("Fetching citywise news")
            let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getAllPosts"
            let data = ["type":type,"Lat":latitude,"Long":longitude,"countryName":countryName] as [String : Any]
            print("calling fetch News with data \(data)")
          //  self.fetchNews(url: url, data: data)
        }
        else{
            // fetch news using city name
            print("fetching locartion wise news")
            let url = "https://us-central1-logos-app-915d7.cloudfunctions.net/getCityNews"
            let data = ["cityName":cityName,"type":type,"countryName":countryName] as [String : Any]
            print("calling fetchNews with data \(data)")
          //  self.fetchNews(url: url, data: data)
        }
        
        
        
    }
    func fetchNewsNew(start:String,offset:Int){
        let frLocale = Locale(identifier: "fr_FR").alternateQuotationEndDelimiter
        let screenSize = UIScreen.main.bounds.width
        self.ref = Database.database().reference()
        print("in fetchNewsNew function with id \(start)")
        if start == "0"{
            print("in first load")
            self.showLoading()
            var postRef = self.ref.child("posts")
            
            //postRef = self.ref.child("posts").queryLimited(toFirst: UInt(offset))
            //            self.ref.child("posts").queryOrdered(byChild: "createdOn").observeSingleEvent(of: .value, with: { (snapshot) in
            self.ref.child("posts").queryLimited(toLast: UInt(offset)).observeSingleEvent(of: .value, with: { (snapshot) in
              
                var counter=snapshot.childrenCount
                for posts in snapshot.children.reversed(){
                    let snap = posts as! DataSnapshot
                    let postDict = snap.value as! [String:Any]
                    let title = postDict["title"] as! String
                    //                    print("title \(title)")
                    let newsId = snap.key as! NSString
                    var newsLat = postDict["latitude"] as! String
                    var newsLong = postDict["longitude"] as! String
                    var authorId = postDict["userId"] as! String
                    var newsTitle : String = ""
                    var cretaedOn = moment(postDict["createdOn"] as! String)?.fromNow()
                    //moment(postDict["createdOn"] as! String,"YYYY-MM-DD HH:mm Z")?.fromNow()
                    //print("cretaedOn \(cretaedOn)")
                    //let newsViews  = Float(postDict["views"] as! String as! CGFloat)
                    if (postDict["title"] as! String == nil || postDict["title"] as! String == ""){newsTitle = "NA"} else {newsTitle = postDict["title"] as! String}
                    let NewsMedia = postDict["media"]  as! String
                    let imageUrl : String
                    if(postDict["media"]  != nil){
                        imageUrl = postDict["media"]  as! String
                    }
                    else{
                        imageUrl = self.defaultImageUrl
                    }
                    //                print("image Url is \(imageUrl)")
                    let newsImageUrl:URL = URL(string:imageUrl)!
                    
                    let newsImageData:NSData = (NSData(contentsOf: newsImageUrl))!
                    let newsImage = UIImage(data: newsImageData as Data)
                    //show userDetails
                    self.ref.child("user").child(authorId as String).observeSingleEvent(of: .value, with: { (userSnapshot) in
                        let userValue = userSnapshot.value as? NSDictionary
                        let userName = userValue?["name"] as! String
                        var userImgUrl :String=""
                        if(userValue?["photo"] != nil){
                            userImgUrl = userValue?["photo"] as! String
                        }
                        else{
                            userImgUrl = self.defaultImageUrl
                        }
                        //              print("user image url \(userImgUrl)")
                        let userImageUrl : URL = URL(string:userImgUrl)!
                        let userImageData : NSData = NSData(contentsOf:userImageUrl)!
                        let userImage = UIImage(data:userImageData as Data)
                        
                        //show post react Count
                        self.ref.child("postreacts").queryOrdered(byChild: "postId").queryEqual(toValue: snap.key).observeSingleEvent(of: .value, with: { (reactSnapshot) in
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
                            self.ref.child("newslrcount").queryOrdered(byChild: "newsId").queryEqual(toValue: snap.key).observeSingleEvent(of: .value, with: { (lrCountSnapshot) in
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
                                guard let news2=newzListData(
                                    userName:userValue?["name"] as! String,
                                    userEndorsment:userValue?["highEndorsmentName"] as! String ,
                                    userProfileImage:userImage!,
                                    newsImage:newsImage!,
                                    newsTitle:newsTitle as! String,
                                    agreeCount:Int(agreeCount),
                                    disAgreeCount:Int(disagreeCount),
                                    nutralCount:Int(neutralCount),
                                    minBiasedValue:avg,
                                    id:snap.key as! String,
                                    time : "1d",//cretaedOn as! String,
                                    AuthorId : authorId as! String
                                    )
                                    
                                    else{
                                        
                                        fatalError("Error")
                                }
                                //              print("news 2 is \(news2)")
                                
                                self.newsFinalData.append(news2)
                                if(counter == self.newsFinalData.count){
                                    DispatchQueue.main.async () {
                                       // self.newsFinalData.sorted(by: {$0.time > $1.time})
                                        self.newsTableView.reloadData()
                                        self.newsTableView.layoutIfNeeded()
                                        // for pull to refresh
                                        self.updateView()
                                        self.refreshController.endRefreshing()
                                        
                                        self.hideLoading()
                                        self.loadingCompleted = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.isFirstLoad = false
                                        }
                                    }
                                }
                                
                            }){
                                (error)in
                                print("error in loading news LR Count details \(error.localizedDescription)")
                            }
                            
                            
                        }){
                            (error)in
                            print("error in loading news react details \(error.localizedDescription)")
                        }
                    }){
                        (error)in
                        print("error in loading post details \(error.localizedDescription)")
                    }
                }
            })
        }
        else{
            print("in lazy loading \(start)")
          var postRef = self.ref.child("posts")
            self.ref.child("posts").queryEnding(atValue: nil, childKey: start).queryLimited(toLast: UInt(6)).observeSingleEvent(of: .value, with: { (snapshot) in
                
                var counter=snapshot.childrenCount
                if snapshot.exists(){
                    var newsnapshot = snapshot.children.dropLast()
                    for posts in newsnapshot.reversed(){
                        let snap = posts as! DataSnapshot
                        let postDict = snap.value as! [String:Any]
                        let title = postDict["title"] as! String
                        //                    print("title \(title)")
                        let newsId = snap.key as! NSString
                        var newsLat = postDict["latitude"] as! String
                        var newsLong = postDict["longitude"] as! String
                        var authorId = postDict["userId"] as! String
                        var newsTitle : String = ""
                        var cretaedOn = moment(postDict["createdOn"] as! String)?.fromNow()
                        //moment(postDict["createdOn"] as! String,"YYYY-MM-DD HH:mm Z")?.fromNow()
                        //print("cretaedOn \(cretaedOn)")
                        //let newsViews  = Float(postDict["views"] as! String as! CGFloat)
                        if (postDict["title"] as! String == nil || postDict["title"] as! String == ""){newsTitle = "NA"} else {newsTitle = postDict["title"] as! String}
                        let NewsMedia = postDict["media"]  as! String
                        let imageUrl : String
                        if(postDict["media"]  != nil){
                            imageUrl = postDict["media"]  as! String
                        }
                        else{
                            imageUrl = self.defaultImageUrl
                        }
                        //                print("image Url is \(imageUrl)")
                        let newsImageUrl:URL = URL(string:imageUrl)!
                        
                        let newsImageData:NSData = (NSData(contentsOf: newsImageUrl))!
                        let newsImage = UIImage(data: newsImageData as Data)
                        //show userDetails
                        self.ref.child("user").child(authorId as String).observeSingleEvent(of: .value, with: { (userSnapshot) in
                            let userValue = userSnapshot.value as? NSDictionary
                            let userName = userValue?["name"] as! String
                            var userImgUrl :String=""
                            if(userValue?["photo"] != nil){
                                userImgUrl = userValue?["photo"] as! String
                            }
                            else{
                                userImgUrl = self.defaultImageUrl
                            }
                            //              print("user image url \(userImgUrl)")
                            let userImageUrl : URL = URL(string:userImgUrl)!
                            let userImageData : NSData = NSData(contentsOf:userImageUrl)!
                            let userImage = UIImage(data:userImageData as Data)
                            
                            //show post react Count
                            self.ref.child("postreacts").queryOrdered(byChild: "postId").queryEqual(toValue: snap.key).observeSingleEvent(of: .value, with: { (reactSnapshot) in
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
                                self.ref.child("newslrcount").queryOrdered(byChild: "newsId").queryEqual(toValue: snap.key).observeSingleEvent(of: .value, with: { (lrCountSnapshot) in
                                    var avg : Float = 0
                                    var total : Int = 0
                                    var lrCount : Float = 0
                                    for lrValue in lrCountSnapshot.children {
                                        let lrSnap = lrValue as! DataSnapshot
                                        let lrDict = lrSnap.value as! [String:Any]
                                        //                                    print("lr count \(Float(lrDict["lRcount"] as! String)!)")
                                        lrCount = lrCount + Float(lrDict["lRcount"] as! String)!
                                        total = total + 1
                                    }
                                    if lrCount != 0 {
                                        avg=(lrCount / Float(total) )*100
                                    }
                                    guard let news2=newzListData(
                                        userName:userValue?["name"] as! String,
                                        userEndorsment:userValue?["highEndorsmentName"] as! String ,
                                        userProfileImage:userImage!,
                                        newsImage:newsImage!,
                                        newsTitle:newsTitle as! String,
                                        agreeCount:Int(agreeCount),
                                        disAgreeCount:Int(disagreeCount),
                                        nutralCount:Int(neutralCount),
                                        minBiasedValue:avg,
                                        id:snap.key as! String,
                                        time : "1d",//cretaedOn as! String,
                                        AuthorId : authorId as! String
                                        )
                                        
                                        else{
                                            
                                            fatalError("Error")
                                    }
                                    //              print("news 2 is \(news2)")
                                    
                                    self.newsFinalData.append(news2)
                                    self.newsTableView.reloadData()
                                    if(counter == self.newsFinalData.count){
                                        DispatchQueue.main.async () {
                                            self.newsFinalData.sorted(by: {$0.time > $1.time})
                                            
                                            self.newsTableView.layoutIfNeeded()
                                            // for pull to refresh
                                            self.updateView()
                                            self.refreshController.endRefreshing()
                                            
                                            self.hideLoading()
                                            self.loadingCompleted = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                self.isFirstLoad = false
                                            }
                                        }
                                    }
                                    
                                }){
                                    (error)in
                                    print("error in loading news LR Count details \(error.localizedDescription)")
                                }
                                
                                
                            }){
                                (error)in
                                print("error in loading news react details \(error.localizedDescription)")
                            }
                        }){
                            (error)in
                            print("error in loading post details \(error.localizedDescription)")
                        }
                    }
                }else{
                    print("No data ")
                }
            })
        }
        
        
    }
    
    func fetchNews(url : String , data : Any){
      
        self.showLoading()
        print("in fetch news ")
        // get screen size
        let screenSize = UIScreen.main.bounds.width
        //print("screen size is\(screenSize)")
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
                print("error in fetchNews \(error)")
                DispatchQueue.main.async () {
                    self.hideLoading()
                }
            }
            do{
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code") as! Int
                        //print("in do \(code)")
                        // returned success code
                        if(code == 1){
                            var counter = 0
                            DispatchQueue.main.async {
                                if let newsDataArray = jsonObj!.value(forKey: "data") as? NSArray {
                                    for news in newsDataArray{
                                        if let newsDataDict = news as? NSDictionary {
                                            counter+=1
                                            // SIDDHARTH: Changed userData and newsData from NSObject to NSDictionary
                                            let userData = newsDataDict.value(forKey:"user") as! NSDictionary
                                            var newsData = newsDataDict.value(forKey:"news") as! NSDictionary
                                            //let newsId = newsDataDict.value(forKey:"newsId") as! NSString
                                            let newsLRCount = newsDataDict.value(forKey:"newsLRCount") as! Float
                                            let newsAgreeCount = newsDataDict.value(forKey:"agreeCount") as! NSNumber
                                            let newsDisAgreeCount = newsDataDict.value(forKey: "disagreeCount") as! NSNumber
                                            let newsNeutralCount = newsDataDict.value(forKey:"neutralCount") as! NSNumber
                                            var newsLat = newsData.value(forKey: "latitude") as! NSString
                                            var newsLong = newsData.value(forKey: "longitude") as! NSString
                                            var authorId = newsData.value(forKey: "userId") as! NSString
                                            var newsTitle : String = ""
                                            let newsViews  = Float(newsData.value(forKey: "views") as! CGFloat)
                                            if (newsData.value(forKey: "title") as! String == nil || newsData.value(forKey: "title") as! String == ""){newsTitle = "NA"} else {newsTitle = newsData.value(forKey: "title") as! String}
                                            let NewsMedia = newsData.value(forKey: "media") as! String
                                            let countryNewsViewCount = Float(newsDataDict.value(forKey: "countryNewsViewCount") as! CGFloat)
                                            
                                            // pish into newsList Array
                                            
                          //                  print("got news \(newsData)")
                                            
                                            let imageUrl : String
                                            if(newsData.value(forKey: "media") != nil){
                                                imageUrl = newsData.value(forKey: "media") as! String
                                            }
                                            else{
                                                imageUrl = self.defaultImageUrl
                                            }
                            //                print("image Url is \(imageUrl)")
                                            let newsImageUrl:URL = URL(string:imageUrl)!

                                            let newsImageData:NSData = (NSData(contentsOf: newsImageUrl))!
                                            let newsImage = UIImage(data: newsImageData as Data)
                                            
                                            var userImgUrl :String
                                            if(userData.value(forKey: "photo") != nil){
                                                userImgUrl = userData.value(forKey: "photo") as! String
                                            }
                                            else{
                                                userImgUrl = self.defaultImageUrl
                                            }
                              //              print("user image url \(userImgUrl)")
                                            let userImageUrl : URL = URL(string:userImgUrl)!
                                            let userImageData : NSData = NSData(contentsOf:userImageUrl)!
                                            let userImage = UIImage(data:userImageData as Data)

                                           
                                //            print("end is \(userData.value(forKey: "highEndorsmentName") as!String)")

                                            
                                            guard let news2=newzListData(
                                                userName:userData.value(forKey:"name") as! String,
                                                userEndorsment:userData.value(forKey: "highEndorsmentName") as!String,
                                                userProfileImage:userImage!,
                                                newsImage:newsImage!,
                                                newsTitle:newsData.value(forKey: "title") as! String,
                                                agreeCount:Int(newsAgreeCount),
                                                disAgreeCount:Int(newsDisAgreeCount),
                                                nutralCount:Int(newsNeutralCount),
                                                minBiasedValue:newsLRCount,
                                                id:newsDataDict.value(forKey: "newsId") as! String,
                                                time : newsDataDict.value(forKey: "timeAgo") as! String,
                                                AuthorId : newsData.value(forKey: "userId") as! String
                                            )
                                            
                                                else{

                                                    fatalError("Error")
                                                }
                                  //              print("news 2 is \(news2)")

                                            self.newsFinalData.append(news2)
                                            // self.newsData.append(news2)
                                            if(counter == newsDataArray.count){
                                                DispatchQueue.main.async () {
                                                    self.newsTableView.reloadData()
                                                    self.newsTableView.layoutIfNeeded()
                                                    // for pull to refresh
                                                    self.updateView()
                                                    self.refreshController.endRefreshing()
                                                    
                                                    self.hideLoading()
                                                    self.loadingCompleted = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        self.isFirstLoad = false
                                                    }
                                                }
                                            }
                                    //        print("news data is \(self.newsFinalData)")
                                            
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            if(code == 2){
                                DispatchQueue.main.async () {
                                    self.showToaster(msg:"\(jsonObj!.value(forKey: "msg") as! String)",type: 0)
                                    self.newsTableView.reloadData()
                                    self.hideLoading()
                                }
                                
                            }
                        }
                    }
                }
                
            }catch let error as NSError{
                print("Error in get posts url \(error.localizedDescription)")
                DispatchQueue.main.async () {
                    self.hideLoading()
                }
            }
        }
        //getPostsTask.resume()
    }
    
    /*  @IBAction func onSegmentChange(_ sender: Any) {
     switch self.segmentTitles.selectedSegmentIndex {
     case 0:
     //list of all news
     self.newsFinalData.removeAll()
     self.getLocality(newsType: 0)
     break
     case 1:
     // list of articles
     self.newsFinalData.removeAll()
     self.getLocality(newsType: 1)
     break
     case 2:
     //list of media
     self.newsFinalData.removeAll()
     self.getLocality(newsType: 2)
     break
     case 3:
     //list of post
     self.newsFinalData.removeAll()
     self.getLocality(newsType: 3)
     default:
     print("nothing ")
     }
     }
     */
    
    
    @IBAction func allPressed(_ sender: Any) {
        
        allButt.tintColor = selectedColor
        artButt.tintColor = UIColor.gray
        mediaButt.tintColor = UIColor.gray
        postsButt.tintColor = UIColor.gray
        artLine.isHidden = true
        mediaLine.isHidden = true
        postsLine.isHidden = true
        allLine.isHidden = false
        self.newsFinalData.removeAll()
        //self.getLocality(newsType: 0)

    //    let topIndex = IndexPath(row: 0, section: 0)
     //   newsTableView.scrollToRow(at: topIndex, at: .top, animated: true)
    }
    
    @IBAction func artPressed(_ sender: Any) {
        artButt.tintColor = selectedColor
        mediaButt.tintColor = UIColor.gray
        postsButt.tintColor = UIColor.gray
        allButt.tintColor = UIColor.gray
        artLine.isHidden = false
        mediaLine.isHidden = true
        postsLine.isHidden = true
        allLine.isHidden = true
        self.newsFinalData.removeAll()

       // self.getLocality(newsType: 1)
    //    let topIndex = IndexPath(row: 0, section: 0)
     //   newsTableView.scrollToRow(at: topIndex, at: .top, animated: true)

    }
    @IBAction func mediaPressed(_ sender: Any) {
        mediaButt.tintColor = selectedColor
        postsButt.tintColor = UIColor.gray
        allButt.tintColor = UIColor.gray
        artButt.tintColor = UIColor.gray
        artLine.isHidden = true
        mediaLine.isHidden = false
        postsLine.isHidden = true
        allLine.isHidden = true
        self.newsFinalData.removeAll()
        //self.getLocality(newsType: 2)
   //     let topIndex = IndexPath(row: 0, section: 0)
    //    newsTableView.scrollToRow(at: topIndex, at: .top, animated: true)

    }
    
    @IBAction func postsPressed(_ sender: Any) {
        postsButt.tintColor = selectedColor
        artButt.tintColor = UIColor.gray
        mediaButt.tintColor = UIColor.gray
        allButt.tintColor = UIColor.gray
        artLine.isHidden = true
        mediaLine.isHidden = true
        postsLine.isHidden = false
        allLine.isHidden = true
        self.newsFinalData.removeAll()

       // self.getLocality(newsType: 3)
       // let topIndex = IndexPath(row: 0, section: 0)

        //newsTableView.scrollToRow(at: topIndex, at: .top, animated: true)
    }
    func showLoading(){
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func hideLoading(){
        self.activityIndicator.stopAnimating()
    }
    
    // toast function
    
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    func showToasterSearch(msg:String,type:Int){
        var style=ToastStyle()
        if type==0{
            style.backgroundColor=UIColor.red
        }
        else{
            style.backgroundColor=UIColor.blue
        }
        style.messageColor=UIColor.white
        style.messageFont=UIFont.systemFont(ofSize: 20)
        
        view.makeToast(msg, duration: 3.0, position: .center, style: style)
        
    }
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
        activityIndicator.startAnimating()
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
                                            var authorId = newsData.value(forKey:"userId") as! NSString
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
                                self.showToasterSearch(msg : "No Data Available",type :0)
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
    
    func getUserLocation(){
        var locationManager = CLLocationManager()
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
        // guard let customMarkerView = marker.iconViewƒ as? CustomMarkerView else { return }
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
                time : newsDataDict.value(forKey: "timeAgo") as! String,
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
    
    @objc func goTOAuthorDetails(_sender:labelGesture1){
        var id=_sender.id
        self.userId=id
        print("THIS IS ID", id)
        performSegue(withIdentifier: "AuthorDetails", sender: self)
        // fromViewController.performSegueWithIdentifier("segue_id", sender: fromViewController)
    }
   /* @objc func goToArticle(_sender:labelGesture1){
        var id=_sender.id
        performSegue(withIdentifier: "showDetails", sender: self)
        // fromViewController.performSegueWithIdentifier("segue_id", sender: fromViewController)
    }*/
    
}


extension UIView {
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 4.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.7
        self.layer.shadowColor = UIColor.lightGray.cgColor
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
}
class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.35,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseInOut,
                                   animations: {
                                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                                   completion: { finished in
                                    src.present(dst, animated: false, completion: nil)
        }
        )
    }
}
class SegueFromRight: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        var padding = CGFloat(20)
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            padding = (window?.safeAreaInsets.top)!
            if padding == CGFloat(0.0) {
                padding = CGFloat(20)
            }
            
        }

        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: padding)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: padding)
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
