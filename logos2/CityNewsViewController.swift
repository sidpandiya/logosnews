//
//  CityNewsViewController.swift
//  logos2
//
//  Created by subodh-mac on 24/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//  use this controller to fetch all news list related to selected city
//  this controller will present when user clicks perticular city bubble


import UIKit

class CityNewsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
  
    
    // initialization of parameters
    var cityData = (cityLat:0.0,cityLong:0.0,cityId:1,cityName:"Pune")
    // input labels
    
    @IBOutlet weak var backButton: UIButton!
   
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var newsListTableView: UITableView!
    @IBOutlet weak var newSegment: UISegmentedControl!
    @IBOutlet weak var cityNewsTitle: UILabel!
    let cellIdentifier="Cell"
    var newsData=[newzListData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi m here got citydate \(cityData.cityName)")
        cityNewsTitle.text = cityData.cityName
        // Do any additional setup after loading the view.
        newsListTableView.delegate=self
        newsListTableView.dataSource=self
        loadNewsList(type: 0)
        // self.newsListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    func loadNewsList(type:Int){
     
    
        self.newsData.removeAll()
       self.loading.isHidden=false
        self.loading.startAnimating();
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getAllPosts?type=\(type)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
    
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("error \(error)")
                DispatchQueue.main.async () {
                       self.loading.stopAnimating()
                }
             
            }
         
         //   var error=NSError?.self
            do {
//                if data{
//
//                }
//                else{
//
//                }
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code")
                        print("code \(code)")
                        // print(jsonObj!.value(forKey: "data")!)
                        //  self.newsData.removeAll();
                        if let newsDataArray = jsonObj!.value(forKey: "data") as? NSArray {
                            for news in newsDataArray{
                                if let newsDataDict = news as? NSDictionary {
                                    let newsLRCount = newsDataDict.value(forKey: "newsLRCount") as? NSNumber
                                    let newsAgreeCount = newsDataDict.value(forKey: "agreeCount") as? NSNumber
                                    let newsDisagreeCount =  newsDataDict.value(forKey: "disagreeCount") as? NSNumber
                                    let newsNutralCount = newsDataDict.value(forKey: "nuetralCount") as? NSNumber
                                    let newsId = newsDataDict.value(forKey: "newsId")
                                    let newsDict = newsDataDict.value(forKey:"news") as? NSDictionary
                                    let newsTitle=newsDict?.value(forKey: "title")
                                    let noOfViews=newsDict?.value(forKey: "views")
                                    let url = newsDict?.value(forKey: "media")
                                    var newsImage = try UIImage(data: NSData(contentsOf: NSURL(string:url as! String)! as URL) as Data)
                                    let userDict=newsDataDict.value(forKey:"user") as? NSDictionary
                                    let username=userDict?.value(forKey: "name")
                                    let userImageUrl=userDict?.value(forKey: "photo")
                                    let userknowsAboutDic=newsDataDict.value(forKey: "userknowsabout")as? NSDictionary
                                    let endorsmentname=userknowsAboutDic?.value(forKey: "knowledge")
                                    let authorId = newsDataDict.value(forKey: "userId")
                                    
                                 
                                    var userPhoto1 = try UIImage(data: NSData(contentsOf: NSURL(string:userImageUrl as! String)! as URL) as Data)
                                    guard let new2=newzListData(
                                        userName:username as! String,
                                        userEndorsment:endorsmentname as! String,
                                        userProfileImage:userPhoto1!,
                                        newsImage:newsImage!,
                                        newsTitle:newsTitle as! String,
                                        agreeCount:(2 as? Int)!,
                                        disAgreeCount:(5 as? Int)!,
                                        nutralCount:(3 as? Int)!,
                                        minBiasedValue:(8 as? Float)!,
                                        id:newsId as! String,
                                        time : "2d",
                                        AuthorId: authorId as! String)
                                    else {
                                        fatalError("error")
                                    }
                                    self.newsData.append(new2)
                                    DispatchQueue.main.async () {
                                        self.newsListTableView.reloadData()
                                        self.loading.stopAnimating()
                                        self.loading.isHidden=true
                                    }
                                }
                            }
                        }
                    }
                    else{
                        self.loading.stopAnimating()
                        print("empty json ")
                    }
                    
                    }
                   
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
        
     
        
      
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
        let cell = newsListTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath) as! MapListTableViewCell
        
       let news=newsData[indexPath.row]
        print("id \(news.id)")
        cell.baiseedCount.value=Float(news.minBiasedValue)
        cell.disagreeCount.text="\(news.disAgreeCount)"
        
        cell.agreeCount.text="\(news.agreeCount)"
        cell.newsImage.image=news.newsImage
        cell.newsTitle.text=news.newsTitle
        cell.nutralCount.text="\(news.nutralCount)"
        cell.userName.text=news.userName
        cell.userEndorsment.text=news.userEndorsment
        cell.userImage.image=news.userProfileImage
        cell.id.text=news.id
        return (cell)
    }
    @IBAction func onChangeSegment(_ sender: Any) {
    
        switch newSegment.selectedSegmentIndex {
         
        case 0:
            //list of all news
           
            loadNewsList(type: 0)
            self.newsListTableView.reloadData()
            break
        case 1:
            // list of articles
            
            loadNewsList(type: 1)
            self.newsListTableView.reloadData()
            
            break
            
        case 2:
                //list of media
           
            loadNewsList(type: 3)
            self.newsListTableView.reloadData()
            break
        case 3:
                //list of post
            
            loadNewsList(type: 2)
            
                self.newsListTableView.reloadData()
            
            
        default:
            print("nothing ")
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
        let indexPath = tableView.indexPathForSelectedRow
        //print("in didselected indexPath \(indexPath)")
        let currentCell=tableView.cellForRow(at: indexPath!) as! MapListTableViewCell
        //print("in didselected indexPath \(indexPath)")
        let currentItem=currentCell.id
        print("news Id is  \(currentItem)")
        let newsView = self.storyboard?.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        newsView.newsData = (gotNewsId:currentCell.id.text!,gotNewsTitle:currentCell.newsTitle.text!)
        self.present(newsView, animated: true, completion: nil)
    }
}
