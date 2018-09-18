//
//  NewsFeedTableViewController.swift
//  
//
//  Created by కార్తీక్ సూర్య on 5/7/18.
//

import UIKit

/*
enum NewsfeedViewModelItemType {
    case userPost
    case articlePost
    case mediaPost
}

protocol NewsfeedViewModelItem {
    var type: NewsfeedViewModelItemType { get }
    var sectionTitle: String { get }
}

extension NewsfeedViewModelItem {
    /*var rowCount: Int {
        return 1
    }*/
}

class NewsfeedViewModelNameItem: NewsfeedViewModelItem {
    var type: NewsfeedViewModelItemType {
        return .userPost
    }
    
    var sectionTitle: String {
        return "Main Info"
    }
}

class NewsfeedViewModelNameItem: NewsfeedViewModelItem {
    var type: NewsfeedViewModelItemType {
        return .articlePost
    }
    
    var sectionTitle: String {
        return "Main Info"
    }
}

class NewsfeedViewModelNameItem: NewsfeedViewModelItem {
    var type: NewsfeedViewModelItemType {
        return .mediaPost
    }
    
    var sectionTitle: String {
        return "Main Info"
    }
}
*/
class NewsFeedTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//class NewsFeedTableViewController: UITableViewController {
    //@IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var newsTableView: UITableView!
    
    @IBOutlet weak var newsTypeSegment: UISegmentedControl!
    let news = ["Syria gas attack","Prez. Moon in talks","US-Russia clash in Syria","SpaceX does it again!","Avengers a smash","Back panther eats CDs","India nukes itself","India not nuked","Is India nuked?", "Cow survives India attack"]
      var newsData=[newzListData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NewsListViewCell"
        guard let cell = newsTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NewsListViewCell else {
            fatalError("The deqeued cell is not a instance of NewsListViewCell")
        }
        let lightblue = UIColor(red: 90.0/255.0, green: 200.0/255.0, blue: 250.0/255.0, alpha: 1.0) //#5AC8FA
        let stdGray = UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 1.0) //#8e8e93
        let redCons = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 15.0/255.0, alpha: 1.0)  //#FF3B0F
        let bordColor = UIColor(red: 128.0/255.0, green: 203.0/255.0, blue: 196.0/255.0, alpha: 1.0) //#80cbc4
        
        cell.cellBound.layer.borderWidth = 1.5;
        cell.cellBound.layer.borderColor = bordColor.cgColor
        cell.cellBound.layer.cornerRadius = 7
        
        cell.shadowView.layer.cornerRadius = 7
        cell.shadowView.layer.shadowOpacity = 0.8
        cell.shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.shadowView.layer.shadowRadius = 4
        cell.shadowView.layer.shadowColor = bordColor.cgColor
 
        let news=newsData[indexPath.row]
        cell.articleLabel.text = news.newsTitle
          //  cell.articleImage.image=news.newsImage
        cell.articleImage.image = UIImage(named: "Desktop-Blur-Backgrounds-Download-620x388")
        cell.articleCategory.text = news.userEndorsment
        cell.posterName.text = news.userName
        cell.profilePic.image = UIImage(named: "user1")
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height / 2
        cell.newsId.text = news.id
        return (cell)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onSegmentChanged(_ sender: Any) {
        
        switch self.newsTypeSegment.selectedSegmentIndex {
            
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
    
    func loadNewsList(type:Int){
        print("in loadNewslist function")
        self.newsData.removeAll()
        let photo1=UIImage(named:"user1")
        let photo2=UIImage(named:"user2")
        let photo3=UIImage(named:"user3")
        
        guard let new1=newzListData(userName:"Mansi",userEndorsment:"Indian History",userProfileImage:photo1!,newsImage:photo1!,newsTitle:"Syria Gas Attack",agreeCount:(2 as? Int)!,disAgreeCount:(5 as? Int)!,nutralCount:(3 as? Int)!,minBiasedValue:(8 as? Int)!,id:"-LC8bIjDRki_lD-OXaep") else {
            fatalError("error")
        }
        guard let new2=newzListData(userName:"Mansi",userEndorsment:"Indian History",userProfileImage:photo1!,newsImage:photo1!,newsTitle:"Syria Gas Attack",agreeCount:(2 as? Int)!,disAgreeCount:(5 as? Int)!,nutralCount:(3 as? Int)!,minBiasedValue:(8 as? Int)!,id:"-LC8bIjDRki_lD-OXaep") else {
            fatalError("error")
        }
        guard let new3=newzListData(userName:"Mansi",userEndorsment:"Indian History",userProfileImage:photo1!,newsImage:photo1!,newsTitle:"Syria Gas Attack",agreeCount:(2 as? Int)!,disAgreeCount:(5 as? Int)!,nutralCount:(3 as? Int)!,minBiasedValue:(8 as? Int)!,id:"-LC8bIjDRki_lD-OXaep") else {
            fatalError("error")
        }
      newsData=[new1,new2,new3]
       // self.loading.isHidden=false
        //self.loading.startAnimating();
     /*   let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getAllPosts?type=\(type)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("error \(error)")
                DispatchQueue.main.async () {
              //      self.loading.stopAnimating()
                }
                
            }
            
            //   var error=NSError?.self
            do {
               
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
                                    
                                    
                                    var userPhoto1 = try UIImage(data: NSData(contentsOf: NSURL(string:userImageUrl as! String)! as URL) as Data)
                                    guard let new2=newzListData(userName:username as! String,userEndorsment:endorsmentname as! String,userProfileImage:userPhoto1!,newsImage:newsImage!,newsTitle:newsTitle as! String,agreeCount:(2 as? Int)!,disAgreeCount:(5 as? Int)!,nutralCount:(3 as? Int)!,minBiasedValue:(8 as? Int)!,id:newsId as! String) else {
                                        fatalError("error")
                                    }
                                    self.newsData.append(new2)
                                    DispatchQueue.main.async () {
                                        self.newsTableView
                                            .reloadData()
                                        //self.loading.stopAnimating()
                                       // self.loading.isHidden=true
                                    }
                                }
                            }
                        }
                    }
                    else{
                    //    self.loading.stopAnimating()
                        print("empty json ")
                    }
                    
                }
                
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()*/
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
        let indexPath = tableView.indexPathForSelectedRow
        //print("in didselected indexPath \(indexPath)")
        let currentCell=tableView.cellForRow(at: indexPath!) as! NewsListViewCell
        //print("in didselected indexPath \(indexPath)")
        let currentItem=currentCell.newsId.text
        print("news Id is  \(currentItem)")
        print("news Id is  \(currentCell.articleLabel.text)")
        let newsView = self.storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
       newsView.newsData = (gotNewsId:currentCell.newsId.text!,gotNewsTitle:currentCell.articleLabel.text!)
        self.present(newsView, animated: true, completion: nil)
    }
}
