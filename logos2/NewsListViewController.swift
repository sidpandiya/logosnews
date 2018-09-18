//
//  NewsListViewController.swift
//  logos2
//
//  Created by subodh-mac on 17/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit


class NewsListViewController : UIViewController,UITableViewDataSource,UITableViewDelegate{
      
    @IBOutlet weak var segmentTitles: UISegmentedControl!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var newsTableView: UITableView!
    
  
       var newsData=[newzListData]()
    override func viewDidLoad() {
        
        // define deligates of table view to self @Author subodh3344
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        super.viewDidLoad()
         loadNewsList(type: 0)
        
    }
    
    // Ferch news list of selected city from firebase @Author subodh3344
  
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return newsData.count
    }
   
    // append values of news list in table from here @Author subodh3344
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print("adding data to cell")
        
        
        let cell = newsTableView.dequeueReusableCell(withIdentifier: "newsCell", for:indexPath) as! NewsTableViewCell
        
        let news=newsData[indexPath.row]
        cell.newsLRSlider.value=Float(news.minBiasedValue)
        cell.newsDisagreeCount.text="\(news.disAgreeCount)"
        
        cell.newsAgreeCount.text="\(news.agreeCount)"
        cell.newsImage.image=news.newsImage
        cell.newsTitle.text=news.newsTitle
        cell.newsNeutralCount.text="\(news.nutralCount)"
        cell.newsLabel.text=news.userName
        cell.newsAuthorKnowsAbout.text=news.userEndorsment
        cell.newsAuthorProfileImage.image=news.userProfileImage
        cell.newsId.text = "\(indexPath.row)"
        cell.newsId.isHidden = true
        print("got cell")


        return (cell)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
        let indexPath = tableView.indexPathForSelectedRow
        //print("in didselected indexPath \(indexPath)")
        let currentCell=tableView.cellForRow(at: indexPath!) as! NewsTableViewCell
        //print("in didselected indexPath \(indexPath)")
        let currentItem=currentCell.newsId
        print("news Id is  \(currentItem)")
        let newsView = self.storyboard?.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
       // newsView.newsData = (gotNewsId:currentItem,gotNewsTitle:currentCell.newsTitle)
        self.present(newsView, animated: true, completion: nil)
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
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    
                    // print(jsonObj!.value(forKey: "data")!)
                    //  self.newsData.removeAll();
                    if let newsDataArray = jsonObj!.value(forKey: "data") as? NSArray {
                        //     print("newsDataArray\(newsDataArray.count)")
                        for news in newsDataArray{
                            
                            
                            if let newsDataDict = news as? NSDictionary {
                                
                                
                                let newsLRCount = newsDataDict.value(forKey: "newsLRCount")
                                let newsAgreeCount = newsDataDict.value(forKey: "agreeCount")
                                let newsDisagreeCount =  newsDataDict.value(forKey: "disagreeCount")
                                let newsNutralCount = newsDataDict.value(forKey: "nuetralCount")
                                let newsId = newsDataDict.value(forKey: "newsId")
                                let newsTime = newsDataDict.value(forKey: "timeAgo")
                                let authorId = newsDataDict.value(forKey: "userId")
                                let newsDict = newsDataDict.value(forKey:"news") as? NSDictionary
                                let newsTitle=newsDict?.value(forKey: "title")
                                let noOfViews=newsDict?.value(forKey: "views")
                                let url = newsDict?.value(forKey: "media")
                                var newsImage = try UIImage(data: NSData(contentsOf: NSURL(string:url as! String)! as URL) as Data)
                                
                                
                                //  let newsImage = UIImage(data:data)
                                let userDict=newsDataDict.value(forKey:"user") as? NSDictionary
                                let username=userDict?.value(forKey: "Name")
                                let userImageUrl=userDict?.value(forKey: "photo")
                                
                                let userknowsAboutDic=newsDataDict.value(forKey: "userknowsabout")as? NSDictionary
                                let endorsmentname=userknowsAboutDic?.value(forKey: "knowledge")
                                var userPhoto1 = try UIImage(data: NSData(contentsOf: NSURL(string:userImageUrl as! String)! as URL) as Data)
                                guard let new2=newzListData(userName:username as! String,userEndorsment:endorsmentname as! String,userProfileImage:userPhoto1!,newsImage:newsImage!,newsTitle:newsTitle as! String,agreeCount:newsAgreeCount as! Int,disAgreeCount:newsDisagreeCount as! Int,nutralCount:newsNutralCount as! Int,minBiasedValue:newsLRCount as! Float,id:newsId as! String,time:newsTime as! String, AuthorId: authorId as! String) else {
                                    fatalError("error")
                                }
                                
                                self.newsData.append(new2)
                                
                                DispatchQueue.main.async () {
                                    print("reloading news List table view")
                                    self.newsTableView.reloadData()
                                    self.loading.stopAnimating()
                                    self.loading.isHidden=true
                                }
                                
                            }
                        }
                    }
                    
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
        
        
        
        
    }
    @IBAction func onSegmentChanged(_ sender: Any) {
        switch self.segmentTitles.selectedSegmentIndex {
        case 0:
            //list of all news
            loadNewsList(type: 0)
            self.newsTableView.reloadData()
            break
        case 1:
            // list of articles
            loadNewsList(type: 1)
            self.newsTableView.reloadData()
            break
        case 2:
            //list of media
            loadNewsList(type: 3)
            self.newsTableView.reloadData()
            break
        case 3:
            //list of post
            loadNewsList(type: 2)
            self.newsTableView.reloadData()
        default:
            print("nothing ")
        }
    }
    
    
}
