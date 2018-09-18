//
//  ArticleViewController.swift
//  logos2
//
//  Created by ???????? ????? on 5/8/18.
//  Copyright  2018 subodh. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import JJFloatingActionButton
import os.log
import Firebase
import FirebaseDatabase



class newsContentDetails{
    var id:String,
    color:Int,
    percentage:Float,
    text : String

    init(id:String, text: String, color: Int, percentage: Float) {
        self.id=id
        self.text = text
        self.color=color
        self.percentage=percentage
    }
}
class Opinions {
    var noOfAgrees : Int,
    noOfDisagrees : Int,
    noOfNeutrals : Int
    init(noOfAgrees:Int, noOfDisagrees: Int, noOfNeutrals: Int) {
        self.noOfAgrees = noOfAgrees
        self.noOfDisagrees = noOfDisagrees
        self.noOfNeutrals = noOfNeutrals
    }
}



class ArticleViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate {

    var buttonJson = [UIControl:String]()
    var buttonReportJson = [UIControl:String]()
    var agreeCommentBtnJson = [UIControl:String]()
    var disAgreeCommentBtnJson = [UIControl:String]()
    var neutralCommentBtnJson = [UIControl:String]()
//this is for the annotations popup, could be a xib eventually
    
    @IBOutlet weak var opinionStats: UIView!
    
    @IBOutlet weak var opinionStatsCancel: UIButton!
    @IBOutlet weak var opinionStatsMap: mapButton!
    
    @IBOutlet weak var opinionStatsNeutral: UILabel!
        @IBOutlet weak var opinionStatsDisagree: UILabel!
        @IBOutlet weak var opinionStatsAgree: UILabel!
    @IBOutlet weak var mapviewImage: UIImageView!
    @IBOutlet weak var reportImage: UIImageView!
    @IBOutlet weak var viewsImage: UIImageView!
    fileprivate let actionButton = JJFloatingActionButton()
    fileprivate let actionButton1 = JJFloatingActionButton()
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var authorEndorsment: UILabel!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsContentBox: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var newsImage: UIImageView!

    @IBOutlet weak var noOfNeutral: UILabel!

    @IBOutlet weak var locationAndDate: UILabel!
    @IBOutlet weak var worldview: UIButton!
    @IBOutlet weak var noOfAgree: UILabel!
    @IBOutlet weak var noOfDisagree: UILabel!

    @IBOutlet weak var commentsTable: UITableView!

    @IBOutlet weak var commentsHeight: NSLayoutConstraint!
    @IBOutlet weak var noOfViews: UILabel!

    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var newsContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var articleBackground: UIImageView!
    @IBOutlet weak var articleFiller: UIView!
    @IBOutlet weak var reportArticle: UIButton!
    @IBOutlet weak var userInputSlider: UISlider!
    @IBOutlet weak var newsContainerHeight: NSLayoutConstraint!
    var news : newzListData?
    var id = String()
    var shapeLayer = CAShapeLayer()
    var shapeLayer1 = CAShapeLayer()
    var newsArray=[newsContentDetails]()
    var userId = String()
    var commentArray=[commentData]()
    var replyArrayCount = 0
    // var commentTableViews=UITableView(frame: CGRect(x: 0, y: 0, width:80, height: 80.0))
    let cellIdentifier="CommentsTableViewCell"
    let replyCellIdentifier = "ReplyTableViewCell"
    let agreeColor = hexStringToUIColor(hex: "009688")
    let neutralColor = hexStringToUIColor(hex:"#5AC8FA" )
    let disagreeColor = hexStringToUIColor(hex:"#C6453B" )
    // to check if A button is already clicked @Author subodh3344
    var showHighlited = false
    var showHighlited2 = false
   var wantedLabel = UILabel()
    // database variable
    var ref:DatabaseReference!
    override func viewDidLoad() {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        if let news = news {
            authorName.text=news.userName
            authorEndorsment.text=news.userEndorsment
            authorImage.image=news.userProfileImage
            newsTitle.text=news.newsTitle
            id=news.id
            let image = news.newsImage
            let ratio = (image.size.width) / (image.size.height)
            var newHeight =  (0.9 * view.frame.width)/ratio
            newsImage.frame.size = CGSize(width: (0.9 * view.frame.width), height: newHeight)
            let scaledImageNews = scaleUIImageToSize(image: image, size: newsImage.frame.size)
            newsImage.image = scaledImageNews
        }

        newsTitle.textColor = UIColor.black
        //this prevents the bias bar from showing up first in initial load
        newsContainerHeight.constant = 250
        userInputSlider.minimumValue = -100
        userInputSlider.maximumValue = 100
        userInputSlider.setMinimumTrackImage(UIImage(named: "biasBar2"), for: UIControlState.normal)
        userInputSlider.setMaximumTrackImage(UIImage(named: "biasBar2"), for: UIControlState.normal)
        userInputSlider.isContinuous = false
        userInputSlider.addTarget(self, action: #selector(self.sliderValueDidChange), for: .valueChanged)
        commentsTable.delegate = self
        commentsTable.dataSource = self
        commentsTable.separatorStyle =
        UITableViewCellSeparatorStyle.none

        //loadNews()

        // new load news function using inApp firebase DB
        loadNewsNew()

        // loadCommentsNew(newsId: self.id);

        commentsTable.rowHeight = UITableViewAutomaticDimension
        commentsTable.estimatedRowHeight = 150

        let scaledEye = scaleUIImageToSize(image: UIImage(named: "views2")!, size: viewsImage.frame.size)
        viewsImage.image = scaledEye
        let scaledMap = scaleUIImageToSize(image: UIImage(named: "mapview2")!, size: viewsImage.frame.size)
        mapviewImage.image = scaledMap
        let scaledFlag = scaleUIImageToSize(image: UIImage(named: "report2")!, size: viewsImage.frame.size)
        reportImage.image = scaledFlag

       // titleContainer.backgroundColor = UIColor(patternImage: UIImage(named:"articleback")!)
      //  infoContainer.backgroundColor = UIColor(patternImage: UIImage(named:"articleback")!)
      //  articleFiller.backgroundColor = UIColor(patternImage: UIImage(named:"articleback")!)
        let scaledBack = scaleUIImageToSize(image: UIImage(named:"backArrow2")!, size: backButton.frame.size)
        backButton.setImage(scaledBack, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideHighlighted(notification:)),
                                               name: NSNotification.Name(rawValue: "hideHighlight"), object: nil)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        authorImage.layer.masksToBounds = false
        authorImage.layer.cornerRadius = authorImage.frame.height/2
        authorImage.clipsToBounds = true
   //     self.newsContainer.backgroundColor = UIColor(patternImage: UIImage(named:"articleback")!)


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func goBack(_ sender: Any) {

        dismissDetail()
    }




    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // funciton to load news using firease functions drectly
    func loadNewsNew(){
        self.ref = Database.database().reference()
        print("in loadNewsnew function with id \(self.id)")
        self.ref.child("posts").child(self.id).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get values
            print("News data : \(snapshot.value as Any)")
            //var newsTitle = snapshot.value!["title"]

            let value = snapshot.value as? NSDictionary
            let newsTitle = value?["title"] as! String
            let newsMedia  = value?["media"] as! String
            let newsViews = value?["views"] as! Int
            let newsCity = value?["city"] as! String
            let newsCountry = value?["country"] as! String
            let userId = value?["userId"] as! String
            // to append newsMedia
            let imageUrl:URL = URL(string: newsMedia)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            let image = UIImage(data: imageData as Data)
            //append news Views
            self.noOfViews.text = "\(newsViews) Views"
            // to append location of news
            let newsDate = value?["createdOn"] as? String
            let clippedDate = newsDate?.prefix(10)
            let year = clippedDate?.prefix(4)
            let startMonth = clippedDate?.index((clippedDate?.startIndex)!, offsetBy: 5)
            let endMonth = clippedDate?.index((clippedDate?.endIndex)!, offsetBy: -3)
            let monthRange = startMonth!..<endMonth!
            let subMonth = clippedDate![monthRange] // month
            let month = String(subMonth)
            let day = clippedDate?.suffix(2)
            self.locationAndDate.text = "\(newsCity as! String), \(newsCountry as! String), \(month)/\(day!)/\(year!)"


            // function to fetch news content of selected news
            self.loadContent(newsId:self.id)


            print("title is \(newsTitle)")

            //show userDetails
            self.ref.child("user").child(userId).observeSingleEvent(of: .value, with: { (userSnapshot) in
                let userValue = userSnapshot.value as? NSDictionary
                let userName = userValue?["name"] as! String

                let tap = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
                print("user is \(userId)");
                tap.id = userId

                let tap2 = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
                print("user is \(userId)");
                tap2.id = userId
                self.authorName.addGestureRecognizer(tap)
                self.authorImage.addGestureRecognizer(tap2)
            }){
                (error)in
                print("error in loading user details \(error.localizedDescription)")
            }
            //show post react Count
            self.ref.child("postreacts").queryOrdered(byChild: "postId").queryEqual(toValue: self.id).observeSingleEvent(of: .value, with: { (reactSnapshot) in
                var agreeCount = 0
                var disagreeCount = 0
                var neutralCount = 0
                for reactValue in reactSnapshot.children {
                    let snap = reactValue as! DataSnapshot
                    let reactDict = snap.value as! [String:Any]

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
                self.noOfAgree.textColor = self.agreeColor
                self.noOfDisagree.textColor = self.disagreeColor
                self.noOfNeutral.textColor = self.neutralColor
                self.noOfAgree.text="●  \(agreeCount as! Int) Agree"
                self.noOfDisagree.text="●  \(disagreeCount as! Int) Disagree"
                self.noOfNeutral.text = "●  \(neutralCount as! Int) Neutral"
                let agreeOnNews = labelGesture(target: self, action: #selector(self.addAgreeopinion(_sender:)))
                agreeOnNews.id = "addAgreeOpinion"
                self.noOfAgree.addGestureRecognizer(agreeOnNews)
                let disagreeOnNews = labelGesture(target: self, action: #selector(self.adddisagreeopinion(_sender:)))
                disagreeOnNews.id = "addDisagreeOpinion"
                self.noOfDisagree.addGestureRecognizer(disagreeOnNews)
                let neutralOnNews = labelGesture(target: self, action: #selector(self.addneutralopinion(_sender:)))
                neutralOnNews.id = "addNeutralOpinion"
                self.noOfNeutral.addGestureRecognizer(neutralOnNews)
                var value = self.userInputSlider.value
                self.userInputSlider.value = roundf(self.userInputSlider.value / 5.0 ) * 5.0
                var slider = UISlider()
                self.reportArticle.addTarget(self, action: #selector(self.markNewReported), for: .touchUpInside)
                self.reportArticle.titleLabel?.adjustsFontSizeToFitWidth = true
                self.reportArticle.titleLabel?.numberOfLines = 1
                self.reportArticle.titleLabel?.minimumScaleFactor = 0.01
                self.worldview.addTarget(self, action: #selector(self.showNewsMap), for: .touchUpInside)
                self.worldview.titleLabel?.adjustsFontSizeToFitWidth = true
                self.worldview.titleLabel?.numberOfLines = 1
                self.worldview.titleLabel?.minimumScaleFactor = 0.01
                //self.loadCommentsNew(newsId:self.id)
                self.loadComments(id: self.id)
            }){
                (error)in
                print("error in loading user details \(error.localizedDescription)")
            }

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // function to load news content
    // function to load news content
    func loadContent(newsId:String){
        print("calling get news content with news id \(newsId)")
        self.ref = Database.database().reference()
        self.ref.child("postcontent").queryOrdered(byChild: "postId").queryEqual(toValue: newsId).observeSingleEvent(of: .value, with: { (newsContentSnap) in
            var fullText = ""
            var startX = self.newsContentBox.frame.origin.x
            var startY = self.newsContentBox.frame.origin.y
            var addOnX=startX
            var totalHeight = CGFloat(10.0)
            let lastIndex = newsContentSnap.childrenCount - 1
            var currentInd = 0
            for content in newsContentSnap.children{
                let snap = content as! DataSnapshot
                let contentDict = snap.value as! [String:Any]
                let postId = contentDict["postId"] as! String
                let PostContentId = snap.key as!String
                print("data is \(postId)")
                var newsData = contentDict["content"] as? String

                let newsContent=UILabel.init()
                newsContent.frame = CGRect(x: CGFloat(startX - ( 0.05 * self.contentView.frame.width) )  ,
                                           y: CGFloat(startY), width: self.newsContentBox.frame.width,
                                           height: 0.0)

                var newsSent=contentDict["content"] as? String
                if currentInd != lastIndex {
                    newsSent?.append(".")
                }
                if newsSent?.first == " " {
                    newsSent = String ((newsSent?.dropFirst(1))!)
                }
                // this removes the spacing from being highlighted by giving the spacing its own label
                if  newsSent?.first == "\n" {
                        var spacing = "\n"
                        newsSent = String((newsSent?.dropFirst(1))!)
                    if newsSent?.first == "\n" {
                        newsSent = String((newsSent?.dropFirst(1))!)
                        spacing = "\n\n"
                    }
                    
                    let newsContent2=UILabel.init()
                    newsContent2.frame = CGRect(x: CGFloat(startX - ( 0.05 * self.contentView.frame.width) )  , y: CGFloat(startY), width: self.newsContentBox.frame.width,
                                               height: 0.0)

                    let attributedString = NSMutableAttributedString(string:spacing)
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 1 // Whatever line spacing you want in points
                    attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                    let font = UIFont(name: "EBGaramond-Regular", size: 10.0)
                    attributedString.addAttribute(NSAttributedStringKey.font, value:font, range:NSMakeRange(0, attributedString.length))
                    newsContent2.attributedText = attributedString
                    newsContent2.numberOfLines = 0
                    newsContent2.sizeToFit()
                    newsContent2.backgroundColor = UIColor.yellow
                    self.newsContentBox.addSubview(newsContent2)
                    newsContent2.isUserInteractionEnabled = false
                    startY = startY + newsContent2.frame.size.height
                    totalHeight = totalHeight + newsContent2.frame.size.height
                    fullText.append(newsContent2.text!)
                }
                currentInd = currentInd + 1
                let attributedString = NSMutableAttributedString(string:newsSent!)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
                attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                let font = UIFont(name: "EBGaramond-Regular", size: 17.0)
                attributedString.addAttribute(NSAttributedStringKey.font, value:font, range:NSMakeRange(0, attributedString.length))
                newsContent.attributedText = attributedString
                newsContent.textAlignment = .left
                newsContent.textColor = UIColor.black
                newsContent.numberOfLines = 0
                newsContent.sizeToFit()
                self.newsContentBox.addSubview(newsContent)
                newsContent.isUserInteractionEnabled = true
                self.ref.child("postcontentReactCoutDetails").queryOrdered(byChild: "postContentId").queryEqual(toValue: PostContentId).observeSingleEvent(of: .value, with: { (postContentSnap) in
                    print("details of content \(postContentSnap)")
                    if postContentSnap.exists() {
                        for contentDetails in postContentSnap.children{
                            let snap = contentDetails as! DataSnapshot
                            let contentDetailsDict = snap.value as! [String:Any]
                            print("contentDetailsDict \(contentDetailsDict["postContentId"] as! String)")
                            let agreeCount = contentDetailsDict["agreeCount"] as! Int
                            let disagreeCount = contentDetailsDict["disagreeCount"] as! Int
                            let neutralCount = contentDetailsDict["neutralCount"] as! Int
                            let total = contentDetailsDict["total"] as! Int
                            let agreeper = (agreeCount / total)*100;
                            let disagreeper = (disagreeCount / total)*100;
                            let neutralper = (neutralCount / total)*100;
                            let allPercentage = [agreeper,neutralper,disagreeper]
                            let highPercentage = allPercentage.max()
                            var color = 0
                            if highPercentage == agreeper{
                                color = 1
                            }
                            else if highPercentage == disagreeper{
                                color = 2
                            }
                            else if highPercentage == neutralper{
                                color = 0
                            }
                            else{
                                color = 0
                            }
                            print("highPercentage \(highPercentage)")
                            let addOpinion = longTapGesture(target: self, action: #selector(self.showStatementOpenions(_sender:)))
                            addOpinion.id = PostContentId
                            addOpinion.color = color as! Int
                            let percentage:Float = Float(highPercentage as! Int)
                            addOpinion.percent = percentage
                            newsContent.addGestureRecognizer(addOpinion)
                            let checkOpinion = labelGesture(target: self, action: #selector(self.showStatementMapOption(_sender:)))
                            checkOpinion.id = PostContentId
                            checkOpinion.color = color
                            checkOpinion.percent = percentage
                            newsContent.addGestureRecognizer(checkOpinion)
                            print("color \(color )")
                            print("heighPercentage \(percentage)")
                            let newsD=newsContentDetails(id:PostContentId ,text:newsContent.text!,color:color ,percentage:percentage)
                            self.newsArray.append(newsD)

                        }//end For
                    }
                    else{
                        let addOpinion = longTapGesture(target: self, action: #selector(self.showStatementOpenions(_sender:)))
                        addOpinion.id = PostContentId
                        addOpinion.color = 0
                        let percentage:Float = Float(0)
                        addOpinion.percent = percentage
                        newsContent.addGestureRecognizer(addOpinion)
                        let checkOpinion = labelGesture(target: self, action: #selector(self.showStatementMapOption(_sender:)))
                        checkOpinion.id = PostContentId
                        checkOpinion.color = 0
                        checkOpinion.percent = 0
                        newsContent.addGestureRecognizer(checkOpinion)
                        let newsD=newsContentDetails(id:PostContentId ,text:newsContent.text!,color:0 ,percentage:0)
                        self.newsArray.append(newsD)
                    }

                })
                startY = startY + newsContent.frame.size.height + 6
                totalHeight = totalHeight + newsContent.frame.size.height + 6
                //   xOrigin=CGFloat(xOrigin)+newsContent.frame.size.height+10
                //   Yorigin=CGFloat(Yorigin)+newsContent.frame.size.height
                fullText.append(newsContent.text!)
            }
            let attributedString = NSMutableAttributedString(string:fullText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.newsContentBox.attributedText = attributedString
            self.newsContainerHeight.constant = totalHeight
        })
    }

    // fetch news comments using firebase db
 /*   func loadCommentsNew(newsId : String){
        self.commentArray.removeAll()
        self.commentsTable.reloadData()
        print("in load comment  got news Id is \(newsId)")
        let serialQueue = DispatchQueue(label: "getCommentsQueue")

        var commentCount = 0
        self.ref = Database.database().reference()
        self.ref.child("postcomments").queryOrdered(byChild: "postId").queryEqual(toValue: newsId).observeSingleEvent(of: .value, with: { (newsCommentsSnap) in
            print("got news comments size: \(newsCommentsSnap.childrenCount)")
            if(newsCommentsSnap.childrenCount != 0){

                for comment in newsCommentsSnap.children{
                    commentCount = commentCount + 1
                    serialQueue.sync {
                        //print("comment  is \(comment)")
                        let snap = comment as! DataSnapshot
                        let commentDict = snap.value as! [String:Any]
                        let commentId = snap.key
                        // comment data
                        let postId = commentDict["postId"] as! String
                        let noOfNeutrals = commentDict["noOfNeutral"] as! Int
                        let noOfAgree = commentDict["noOfAgree"] as! Int
                        let noOfDisagree = commentDict["noOfDisAgree"] as! Int
                        let commentedUserId = commentDict["userId"] as! String
                        let commentOpenion = commentDict["openion"] as! Int
                        let createdOn = commentDict["createdOn"] as! String
                        let comment = commentDict["comments"] as! String
                        let noOfReplies = commentDict["noOfReplies"] as! Int
                        let isCommeedEdited = commentDict["isEdited"] as! Bool
                        let getCommentsUserQueue = DispatchQueue(label: "getCommentsUserQueue")
                        getCommentsUserQueue.sync {
                            //  fetch user of comment
                            self.ref.child("user").child(commentedUserId).observeSingleEvent(of: .value, with: { (commentedUserSnap) in
                                // Get values
                                // print("user data : \(commentedUserSnap.value as Any)")
                                let userValues = commentedUserSnap.value as? NSDictionary

                                // got user data
                                let userName = userValues?["name"] as! String
                                let highEnd = userValues?["highEndorsmentName"] as! String
                                // to check if user got profile image
                                let userImage : UIImage
                                if (userValues?["photo"] != nil){
                                    let userImageUrl:URL = URL(string:userValues?["photo"] as! String)!
                                    let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                                    userImage = UIImage(data:userImageData as Data)!
                                }
                                else {
                                    // TODO : Add default image of newzSlate here @Author subodh3344
                                    let userImageUrl:URL = URL(string:"https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff")!
                                    let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                                    userImage = UIImage(data:userImageData as Data)!
                                }

                                var isEditable = false
                                let loggedInUserData = UserDefaults.standard
                                let loggedInUserId = loggedInUserData.string(forKey: "userId") as! String
                                if(loggedInUserId == commentedUserId){
                                    isEditable = true
                                }

                                // push comments in aaray
                                guard let comment = commentData(
                                    commentId : commentId ,
                                    authorId  :  commentedUserId ,
                                    authorName : userName,
                                    authorImage  : userImage,
                                    authorEndorsment : highEnd,
                                    comment : comment,
                                    noOfReply : noOfReplies,
                                    opinion : commentOpenion,
                                    isReply : false,
                                    isEdited : isCommeedEdited,
                                    noOfAgrees: noOfAgree,
                                    noOfDisagrees: noOfDisagree,
                                    noOfNeutrals: noOfNeutrals,
                                    actualID: commentId,
                                    isEditable : isEditable,
                                    timeAgo : commentsData.value(forKey: "timeago") as! String

                                    )
                                    else{
                                        fatalError("Error in comments")
                                }

                                print("adding in comments in array :: \(comment)");
                                self.commentArray.append(comment)
                                //print("finallyyyy 22 :\(self.commentArray)")
                                let getRepliesQueue = DispatchQueue(label: "getRepliesQueue")
                                getRepliesQueue.sync {
                                    // fetch replies for comment
                                    self.ref.child("commentsonpostcomments").queryOrdered(byChild: "commentId").queryEqual(toValue: commentId).observeSingleEvent(of: .value, with: { (commentRepliesSnap) in

                                        print("got news replies count : \(commentRepliesSnap.childrenCount)")

                                        if(commentRepliesSnap.childrenCount != 0){
                                            var replyCount = 0
                                            for reply in commentRepliesSnap.children{
                                                replyCount = replyCount + 1
                                                let replySnap = reply as! DataSnapshot
                                                let replyDict = replySnap.value as! [String:Any]
                                                let replyId = replySnap.key
                                                let replyUserId = replyDict["userId"] as! String
                                                let reply = replyDict["comments"] as! String
                                                let replyIsEdited = replyDict["isEdited"] as! Bool
                                                // print("Reply dict is \(replyDict)")
                                                let getRepliesUserQueue = DispatchQueue(label: "getRepliesUserQueue")
                                                getRepliesUserQueue.sync {
                                                    // to load replied user's data
                                                    self.ref.child("user").child(replyUserId).observeSingleEvent(of: .value, with: { (repliedUserSnap) in
                                                        // Get values
                                                        // print("replied user data : \(repliedUserSnap.value as Any)")
                                                        let repliedUserValues = repliedUserSnap.value as? NSDictionary

                                                        // got user data
                                                        let repliedUserName = repliedUserValues?["name"] as! String
                                                        let repliedUserHighEnd = repliedUserValues?["highEndorsmentName"] as! String
                                                        // to check if user got profile image
                                                        let repliedUserImage : UIImage
                                                        if (repliedUserValues?["photo"] != nil){
                                                            let userImageUrl:URL = URL(string:repliedUserValues?["photo"] as! String)!
                                                            let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                                                            repliedUserImage = UIImage(data:userImageData as Data)!
                                                        }
                                                        else {

                                                            let userImageUrl:URL = URL(string:"https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff")!
                                                            let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                                                            repliedUserImage = UIImage(data:userImageData as Data)!
                                                        }

                                                        var isEditable = false
                                                        let loggedInUserData = UserDefaults.standard
                                                        let loggedInUserId = loggedInUserData.string(forKey: "userId") as! String
                                                        if(loggedInUserId == replyUserId){
                                                            isEditable = true
                                                        }

                                                        guard let commentAsReply = commentData(
                                                            commentId : replyId,
                                                            authorId : replyUserId,
                                                            authorName : repliedUserName,
                                                            authorImage  : repliedUserImage,
                                                            authorEndorsment :repliedUserHighEnd,
                                                            comment : reply,
                                                            noOfReply : 0,
                                                            opinion : 0,
                                                            isReply : true,
                                                            isEdited : replyIsEdited,
                                                            noOfAgrees: 0,
                                                            noOfDisagrees: 0,
                                                            noOfNeutrals: 0,
                                                            actualID: "",  isEditable : isEditable,
                                                            timeAgo : commentsData.value(forKey: "timeago") as! String

                                                            )
                                                            else{
                                                                fatalError("Error in creating commentsAsReply")
                                                        }
                                                        print("adding reply in comment ::\(commentAsReply)");
                                                        self.commentArray.append(commentAsReply)
                                                        print("finallyyyy 33: \(self.commentArray)")
                                                        print("comment snap \(commentDict)")
                                                        print("finallyyyy \(self.commentArray)")
                                                        self.commentsTable.reloadData()
                                                        self.commentsHeight.constant = 300
                                                        self.commentsTable.layoutIfNeeded()
                                                        self.commentsHeight.constant = self.commentsTable.contentSize.height
                                                    }){(error) in
                                                        print("Error while fetching reply user \(error.localizedDescription)")
                                                    }
                                                }// getRepliesUserQueue ends
                                                print("replycount \(replyCount) == commentreplies \(commentRepliesSnap.childrenCount)")
                                                if(replyCount == commentRepliesSnap.childrenCount){
                                                    // reply end
                                                    print("commentCount \(commentCount) == newsCommentSnapcount \(newsCommentsSnap.childrenCount)")
                                                    if(commentCount == newsCommentsSnap.childrenCount){
                                                        // load complete
                                                        self.commentsTable.reloadData()
                                                        self.commentsHeight.constant = 300
                                                        self.commentsTable.layoutIfNeeded()
                                                        self.commentsHeight.constant = self.commentsTable.contentSize.height
                                                        print ("RELOADED with Data of comments and replies 2", self.commentsTable.contentSize.height)

                                                    }// if commentCount == newsCommentsSnap.childrenCount ends
                                                }// if replyCount == commentRepliesSnap.childrenCount ends

                                            }// replies for end
                                        }// check repliescount ends
                                            // replies are not present
                                        else{
                                            print("No replies available")
                                            print("comm count : \(commentCount) == news commcount : \(newsCommentsSnap.childrenCount)")
                                            if(commentCount == newsCommentsSnap.childrenCount){
                                                // load complete
                                                self.commentsTable.reloadData()
                                                self.commentsHeight.constant = 300
                                                self.commentsTable.layoutIfNeeded()
                                                self.commentsHeight.constant = self.commentsTable.contentSize.height
                                                print ("RELOADED with Data of comments and replies 2", self.commentsTable.contentSize.height)

                                            }// if commentCount == newsCommentsSnap.childrenCount ends
                                        }// check replies else ends


                                    }){(error) in
                                        print("Error in fetch comment replies \(error.localizedDescription)")
                                    }
                                }// getRepliesQueue ends

                            }){(error) in
                                print("Error while fetching user for comment \(error.localizedDescription)")
                            }
                        }// getCommentsUserQueue ends
                    }//serialQueue ends
                }// comment for end

            }// comment size if ends
            else{
                print("no comments available")
            }// comment size else ends

        }){(error) in
            print("Error in fetch news comments \(error.localizedDescription)")
        }
    }
    */

    func loadNews(){
        print("in loadnews")
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getNewsById?key=\(self.id)")
        print("Url is \(url)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("error \(error?.localizedDescription)")
                DispatchQueue.main.async () {
                    // self.loading.stopAnimating()
                }
            }
            do {
                if data != nil{
                    var jsonobj=JSON(data!)
                    let code=jsonobj["code"].int
                    print("code \(code)")
                    if code==0{
                        DispatchQueue.main.async{
                            var data=jsonobj["data"]
                            var newsDetails=data["newsDetails"]

                            //show news content

                            var fullText = ""
                            let newsContent=data["newsContent"].arrayValue
                            for news in newsContent
                            {
                                var newsData=news["content"]
                                var contentString = newsData["content"].string

                                fullText.append(contentString!)

                                fullText.append(".")
                                print("color \(news["color"].int)")
                                print("heighPercentage \(news["heighPercentage"])")
                                var heighPer:Float = news["heighPercentage"].floatValue
                                var newsD=newsContentDetails(id:news["id"].string!,text:contentString!,color:news["color"].int!,percentage:heighPer)
                                self.newsArray.append(newsD)
                            }

                            let attributedString = NSMutableAttributedString(string:fullText)
                            let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.lineSpacing = 9 // Whatever line spacing you want in points
                            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))


                            self.newsContentBox.attributedText = attributedString
                            self.newsContentBox.textColor = UIColor.black

                            //    let addOpinion = longTapGesture(target: self, action: #selector(self.handleTapOnLabel(_:)))
                            //    self.newsContentBox.addGestureRecognizer(addOpinion)

                            //this is the ugly way of annotating
                            var startX = self.newsContentBox.frame.origin.x
                            var startY = self.newsContentBox.frame.origin.y
                            var addOnX=startX
                            var totalHeight = CGFloat(10.0)
                            for news in newsContent
                            {
                                var newsData=news["content"]
                                let newsContent=UILabel.init()
                                newsContent.frame = CGRect(x: CGFloat(startX - (0.1 * self.contentView.frame.width) )  , y: CGFloat(startY), width: self.newsContentBox.frame.width, height: 0.0)

                                var newsSent = newsData["content"].string
                                newsSent?.append(".")
                                let attributedString = NSMutableAttributedString(string:newsSent!)
                                let paragraphStyle = NSMutableParagraphStyle()
                                paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
                                attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                                let font = UIFont(name: "Times New Roman", size: 19.0)
                                attributedString.addAttribute(NSAttributedStringKey.font, value:font, range:NSMakeRange(0, attributedString.length))
                                newsContent.attributedText = attributedString
                                newsContent.textAlignment = .left
                                newsContent.textColor = UIColor.black
                                newsContent.numberOfLines = 0
                                newsContent.sizeToFit()


                                self.newsContentBox.addSubview(newsContent)
                                newsContent.isUserInteractionEnabled = true
                                let addOpinion = longTapGesture(target: self, action: #selector(self.showStatementOpenions(_sender:)))
                                addOpinion.id = news["id"].string!
                                addOpinion.color = news["color"].int!
                                addOpinion.percent = news["heighPercentage"].floatValue
                                newsContent.addGestureRecognizer(addOpinion)
                                let checkOpinion = labelGesture(target: self, action: #selector(self.showStatementMapOption(_sender:)))
                                checkOpinion.id = news["id"].string!
                                checkOpinion.color = news["color"].int!
                                checkOpinion.percent = news["heighPercentage"].floatValue
                                newsContent.addGestureRecognizer(checkOpinion)
                                print("color \(news["color"].int)")
                                print("heighPercentage \(news["heighPercentage"])")
                                var heighPer:Float = news["heighPercentage"].floatValue
                                var newsD=newsContentDetails(id:news["id"].string!,text:newsContent.text!,color:news["color"].int!,percentage:heighPer)
                                self.newsArray.append(newsD)
                                startY = startY + newsContent.frame.size.height + 6
                                totalHeight = totalHeight + newsContent.frame.size.height + 6
                                //   xOrigin=CGFloat(xOrigin)+newsContent.frame.size.height+10
                                //   Yorigin=CGFloat(Yorigin)+newsContent.frame.size.height
                                fullText.append(newsContent.text!)
                            }


                            let attributedString1 = NSMutableAttributedString(string:fullText)
                            let paragraphStyle1 = NSMutableParagraphStyle()
                            paragraphStyle.lineSpacing = 8 // Whatever line spacing you want in points
                            attributedString1.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle1, range:NSMakeRange(0, attributedString1.length))
                            self.newsContentBox.attributedText = attributedString1
                            self.newsContainerHeight.constant = totalHeight

                            //show news media if any
                            /*   var imageView = UIImageView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width , height:0))

                             if (url?.isEmpty)!{
                             imageView = UIImageView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width , height:0))
                             }
                             else{*/

                            var user=data["userDetails"]

                            let tap = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
                            print("user is \(data["userId"].string!)");
                            tap.id = data["userId"].string!

                            let tap2 = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
                            print("user is \(data["userId"].string!)");
                            tap2.id = data["userId"].string!
                            self.authorName.addGestureRecognizer(tap)
                            self.authorImage.addGestureRecognizer(tap2)
                            let url = newsDetails["media"].string
                            let imageUrl:URL = URL(string: url!)!
                            // Start background thread so that image loading does not make app unresponsive
                            //  print("xOrigin \(Yorigin)")
                            // var startImageX=CGFloat(xOrigin)
                            let imageData:NSData = NSData(contentsOf: imageUrl)!


                            let image = UIImage(data: imageData as Data)
                            let scaledImageNews = scaleUIImageToSize(image: image!, size: self.newsImage.frame.size)
                            self.newsImage.image = scaledImageNews

                            //  self.newsImage.image = #imageLiteral(resourceName: "flag")



                            //This is for annotating and viewing annotations
                            /*    self.actionButton.buttonColor = UIColor.yellow


                             // see user's openions for statements button 'A'
                             self.actionButton.addItem(title: "Edit", image:UIImage(named:"A")) { item in
                             print("on click of A")
                             self.showHighlited2 = !self.showHighlited2
                             for newslable in self.newsArray{
                             print("in news lable array \(newslable.id) and color \(newslable.color)")
                             if self.showHighlited2{
                             newslable.lable.isHighlighted=true
                             }
                             else{
                             newslable.lable.isHighlighted=false
                             }
                             //neutral Color
                             if(newslable.color == 0){
                             DispatchQueue.main.async{
                             newslable.lable.highlightedTextColor=UIColor.blue
                             }
                             }
                             //agree
                             else if (newslable.color == 1){
                             DispatchQueue.main.async{
                             newslable.lable.highlightedTextColor=UIColor.green
                             }
                             }
                             //disagree
                             else if (newslable.color == 2){
                             DispatchQueue.main.async{
                             newslable.lable.highlightedTextColor=UIColor.red
                             }
                             }
                             // newslable.lable.backgroundColor=UIColor.clear
                             //   newslable.lable.highlightedTextColor=UIColor.clear
                             newslable.lable.isUserInteractionEnabled=true

                             let tap = labelGesture(target: self, action: #selector(self.showStatementMapOption))
                             tap.id = newslable.id
                             tap.color = newslable.color
                             tap.percent = newslable.percentage
                             newslable.lable.addGestureRecognizer(tap)
                             }// end for
                             }

                             self.actionButton.display(inViewController: self)

                             //right side action butttob
                             self.configureActionButton()
                             self.view.addSubview(self.actionButton1)
                             self.actionButton1.translatesAutoresizingMaskIntoConstraints = false
                             if #available(iOS 11.0, *) {
                             self.actionButton1.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
                             self.actionButton1.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
                             } else {
                             self.actionButton1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
                             self.actionButton1.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16).isActive = true
                             }

                             // give openion button click function 'pencil'
                             self.actionButton1.addItem(title: "Edit", image:UIImage(named:"edit")) { item in
                             print("on click red button")
                             for newslable in self.newsArray
                             {
                             print("in news lable array \(newslable.id)")
                             print("in if ")

                             newslable.lable.backgroundColor=UIColor.clear
                             newslable.lable.highlightedTextColor=UIColor.clear
                             newslable.lable.isUserInteractionEnabled=true

                             let tap = labelGesture(target: self, action: #selector(self.showStatementOpenions))
                             tap.id = newslable.id
                             tap.color = newslable.color
                             tap.percent = newslable.percentage
                             newslable.lable.addGestureRecognizer(tap)
                             }
                             }

                             //line below the content
                             print("imageView.frame.height+imageView.frame.origin.x \(imageView.frame.height+imageView.frame.origin.x)")

                             let path1 = UIBezierPath()
                             path1.move(to: CGPoint(x:self.contentView.frame.origin.x+10, y:UIScreen.main.bounds.width-20.0))
                             path1.addLine(to: CGPoint(x:self.contentView.frame.origin.x+10, y: UIScreen.main.bounds.size.width - 20.0))

                             self.shapeLayer1.path = path1.cgPath
                             self.shapeLayer1.strokeColor = UIColor.red.cgColor
                             self.shapeLayer1.lineWidth = 2

                             self.contentView.layer.addSublayer(self.shapeLayer1)*/
                            var city = newsDetails["city"].string
                            var country = newsDetails["country"].string
                            var date = newsDetails["createdOn"].string
                            var clippedDate = date?.prefix(10)
                            var year = clippedDate?.prefix(4)
                            let startMonth = clippedDate?.index((clippedDate?.startIndex)!, offsetBy: 5)
                            let endMonth = clippedDate?.index((clippedDate?.endIndex)!, offsetBy: -3)
                            let monthRange = startMonth!..<endMonth!
                            let subMonth = clippedDate![monthRange]  // month
                            let month = String(subMonth)
                            let day = clippedDate?.suffix(2)
                            self.locationAndDate.text = "\(city as! String), \(country as! String), \(month)/\(day!)/\(year!)"
                            //No of views UIlable
                            var views = newsDetails["views"].int
                            self.noOfViews.text = "\(views as! Int) Views"
                            //    self.noOfViews.text = "14k Views"

                            //No of agree UILable
                            var agreeCount=data["agreeCount"].int
                            self.noOfAgree.text="●  \(agreeCount as! Int) Agree"

                            //  self.noOfAgree.text = "14 Agree"
                            //No of Disagree UILable
                            var disagreeCount=data["disagreeCount"].int
                            self.noOfDisagree.text="●  \(disagreeCount as! Int) Disagree"
                            //   self.noOfDisagree.text = "15 Disagree"

                            var neutralCount = data["neutralCount"].int
                            self.noOfNeutral.text = "●  \(neutralCount as! Int) Neutral"
                            // Show L-R values on news
                            /* let slider1 = UISlider(frame:CGRect(x: CGFloat(self.contentView.frame.origin.x+20), y: CGFloat(Yorigin + self.newsImage.frame.height+self.newsImage.frame.origin.x), width: UIScreen.main.bounds.size.width - 50, height: 80.0))
                             slider1.minimumValue = -100
                             slider1.maximumValue = 100
                             slider1.isContinuous = false
                             slider1.tintColor = UIColor.red
                             slider1.isUserInteractionEnabled=false
                             slider1.minimumValueImage=UIImage(named:"L")
                             slider1.maximumValueImage=UIImage(named:"R") */
                            //  let value1=data["newsLRCount"].floatValue
                            //slider1.value = value1 as! Float
                            //self.contentView.addSubview(slider1)

                            //Agree button

                            /*     let agreeButton = UIButton(frame: CGRect(x: CGFloat(self.contentView.frame.origin.x+10), y: CGFloat(self.newsImage.frame.height+self.newsImage.frame.origin.x+self.self.noOfViews.frame.height+Yorigin), width: UIScreen.main.bounds.size.width / 3, height: 80.0))
                             agreeButton.backgroundColor = UIColor.white
                             agreeButton.layer.shadowColor=UIColor.black.cgColor
                             agreeButton.layer.shadowRadius=5
                             agreeButton.layer.shadowOpacity=1.0
                             agreeButton.layer.shadowOffset=CGSize(width: 5, height: 5)
                             agreeButton.setTitleColor(UIColor.green, for: .normal)
                             agreeButton.setTitle("Agree", for: .normal)
                             agreeButton.addTarget(self, action: #selector(self.addAgreeopinion), for: .touchUpInside)*/
                            let agreeOnNews = labelGesture(target: self, action: #selector(self.addAgreeopinion(_sender:)))
                            agreeOnNews.id = "addAgreeOpinion"
                            self.noOfAgree.addGestureRecognizer(agreeOnNews)
                            //   self.contentView.addSubview(agreeButton)


                            //disagreeButton
                            /*      let disagreeButton = UIButton(frame: CGRect(x: CGFloat(agreeButton.frame.width+agreeButton.frame.origin.x+10), y: CGFloat(self.newsImage.frame.height+self.newsImage.frame.origin.x+self.noOfViews.frame.height+Yorigin), width: UIScreen.main.bounds.size.width / 3, height: 80.0))
                             disagreeButton.backgroundColor = UIColor.white
                             disagreeButton.layer.shadowColor=UIColor.black.cgColor
                             disagreeButton.layer.shadowRadius=5
                             disagreeButton.layer.shadowOpacity=1.0
                             disagreeButton.layer.shadowOffset=CGSize(width: 5, height: 5)
                             disagreeButton.setTitleColor(UIColor.red, for: .normal)
                             disagreeButton.setTitle("Disagree", for: .normal)
                             disagreeButton.addTarget(self, action: #selector(self.adddisagreeopinion), for: .touchUpInside)
                             //   self.contentView.addSubview(disagreeButton)
                             */
                            let disagreeOnNews = labelGesture(target: self, action: #selector(self.adddisagreeopinion(_sender:)))
                            disagreeOnNews.id = "addDisagreeOpinion"
                            self.noOfDisagree.addGestureRecognizer(disagreeOnNews)
                            //neutral Button

                            /*      let neutralButton = UIButton(frame: CGRect(x: CGFloat(disagreeButton.frame.width + disagreeButton.frame.origin.x+10), y: CGFloat(self.newsImage.frame.height+self.newsImage.frame.origin.x+self.noOfViews.frame.height+Yorigin), width: UIScreen.main.bounds.size.width / 3, height: 80.0))
                             neutralButton.backgroundColor = UIColor.white
                             neutralButton.layer.shadowColor=UIColor.black.cgColor
                             neutralButton.layer.shadowRadius=5
                             neutralButton.layer.shadowOpacity=1.0
                             neutralButton.layer.shadowOffset=CGSize(width: 5, height: 5)
                             neutralButton.setTitleColor(UIColor.blue, for: .normal)
                             neutralButton.setTitle("Neutral", for: .normal)
                             neutralButton.addTarget(self, action: #selector(self.addneutralopinion), for: .touchUpInside)
                             //    self.contentView.addSubview(neutralButton)
                             */
                            //L_R baised slider get user input
                            let neutralOnNews = labelGesture(target: self, action: #selector(self.addneutralopinion(_sender:)))
                            neutralOnNews.id = "addNeutralOpinion"
                            self.noOfNeutral.addGestureRecognizer(neutralOnNews)



                            var value = self.userInputSlider.value
                            self.userInputSlider.value = roundf(self.userInputSlider.value / 5.0 ) * 5.0



                            //   self.contentView.addSubview(slider)

                            var slider = UISlider()
                            //add Flagged button
                            // var maxY = self.newsImage.frame.height+self.newsImage.frame.origin.x+noOfViews.frame.height
                            //let flagButton = UIButton(frame: CGRect(x: CGFloat(self.contentView.frame.origin.x+50), y: CGFloat(maxY + Yorigin + slider1.frame.height + slider.frame.height), width:80, height: 80.0))

                            // flagButton.setImage(UIImage(named:"flag"), for: .normal)
                            //flagButton.setTitleColor(UIColor.blue, for: .normal)
                            self.reportArticle.addTarget(self, action: #selector(self.markNewReported), for: .touchUpInside)
                            self.reportArticle.titleLabel?.adjustsFontSizeToFitWidth = true
                            self.reportArticle.titleLabel?.numberOfLines = 1
                            self.reportArticle.titleLabel?.minimumScaleFactor = 0.01
                            // self.contentView.addSubview(flagButton)

                            //Map Button
                            // var mapY = self.newsImage.frame.height+self.newsImage.frame.origin.x+noOfViews.frame.height+Yorigin
                            //let mapButton = UIButton(frame: CGRect(x: CGFloat(self.contentView.frame.width - 150), y: CGFloat(mapY + slider1.frame.height+slider.frame.height), width:80, height: 80.0))

                            //  mapButton.setImage(UIImage(named:"glob"), for: .normal)
                            //mapButton.setTitleColor(UIColor.blue, for: .normal)
                            self.worldview.addTarget(self, action: #selector(self.showNewsMap), for: .touchUpInside)
                            self.worldview.titleLabel?.adjustsFontSizeToFitWidth = true
                            self.worldview.titleLabel?.numberOfLines = 1
                            self.worldview.titleLabel?.minimumScaleFactor = 0.01
                            //   self.contentView.addSubview(mapButton)

                            self.loadComments(id:self.id)
                            //add commets tabe
                            /*     var commentY = self.newsImage.frame.height+self.newsImage.frame.origin.x+self.noOfViews.frame.height+Yorigin
                             self.commentTableViews=UITableView(frame: CGRect(x: CGFloat(self.contentView.frame.origin.x + 20), y: CGFloat(commentY + slider1.frame.height+slider.frame.height + self.reportArticle.frame.height), width:self.contentView.frame.width-50, height: self.contentView.frame.height))

                             self.commentTableViews.register(CommentsTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
                             self.commentTableViews.dataSource=self
                             self.commentTableViews.delegate=self
                             self.commentTableViews.rowHeight=UITableViewAutomaticDimension
                             self.commentTableViews.estimatedRowHeight=500
                             */
                            //  self.contentView.addSubview(self.commentTableViews)

                            /*

                             // see user's openions for statements button 'A'
                             self.actionButton.addItem(title: "Edit", image:UIImage(named:"A")) { item in
                             print("on click of A")
                             self.showHighlited2 = !self.showHighlited2
                             for newslable in self.newsArray{
                             print("in news lable array \(newslable.id) and color \(newslable.color)")
                             if self.showHighlited2{
                             newslable.lable.isHighlighted=true
                             }
                             else{
                             newslable.lable.isHighlighted=false
                             }
                             //neutral Color
                             if(newslable.color == 0){
                             DispatchQueue.main.async{
                             newslable.lable.highlightedTextColor=UIColor.blue
                             }
                             }
                             //agree
                             else if (newslable.color == 1){
                             DispatchQueue.main.async{
                             newslable.lable.highlightedTextColor=UIColor.green
                             }
                             }
                             //disagree
                             else if (newslable.color == 2){
                             DispatchQueue.main.async{
                             newslable.lable.highlightedTextColor=UIColor.red
                             }
                             }
                             // newslable.lable.backgroundColor=UIColor.clear
                             //   newslable.lable.highlightedTextColor=UIColor.clear
                             newslable.lable.isUserInteractionEnabled=true

                             let tap = labelGesture(target: self, action: #selector(self.showStatementMapOption))
                             tap.id = newslable.id
                             tap.color = newslable.color
                             tap.percent = newslable.percentage
                             newslable.lable.addGestureRecognizer(tap)
                             }// end for
                             }

                             self.actionButton.display(inViewController: self)

                             //right side action butttob
                             self.configureActionButton()
                             self.view.addSubview(self.actionButton1)
                             self.actionButton1.translatesAutoresizingMaskIntoConstraints = false
                             if #available(iOS 11.0, *) {
                             self.actionButton1.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
                             self.actionButton1.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
                             } else {
                             self.actionButton1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
                             self.actionButton1.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -16).isActive = true
                             }

                             // give openion button click function 'pencil'
                             self.actionButton1.addItem(title: "Edit", image:UIImage(named:"edit")) { item in
                             print("on click red button")
                             for newslable in self.newsArray
                             {
                             print("in news lable array \(newslable.id)")
                             print("in if ")

                             newslable.lable.backgroundColor=UIColor.clear
                             newslable.lable.highlightedTextColor=UIColor.clear
                             newslable.lable.isUserInteractionEnabled=true

                             let tap = labelGesture(target: self, action: #selector(self.showStatementOpenions))
                             tap.id = newslable.id
                             tap.color = newslable.color
                             tap.percent = newslable.percentage
                             newslable.lable.addGestureRecognizer(tap)
                             }
                             }
                             */
                        }



                    }
                    else{
                        DispatchQueue.main.async {
                            self.showToaster(msg: "Error while fetching news", type: 0)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Error while fetching news", type: 0)
                    }
                }

            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.view.makeToast("Error while Fetching news...")
                }
            }
        }
        task.resume()
    }


    // called if user clicked on 'A' button

    @objc func showStatementMapOption(_sender:labelGesture){
        var id=_sender.id
        var title=""
        var title1=""
        let newsSent = getLabelsInView(view: self.newsContentBox)
        var newsText = ""
        var color = _sender.color
      
        for news in self.newsArray {
            if _sender.id == news.id {
                newsText = news.text
                break
            }
            
        }
        for labels in newsSent {
            if labels.text == newsText {
                wantedLabel = labels
                break
            }
            
        }
        let agreeColor2 = hexStringToUIColor(hex: "#CCEFD2")
        wantedLabel.backgroundColor = agreeColor2
        wantedLabel.layer.masksToBounds = false
        wantedLabel.clipsToBounds = true
       /*
        self.opinionStats.layer.masksToBounds = false
        self.opinionStats.layer.cornerRadius = 7
        self.opinionStats.layer.borderWidth = 0.2
        self.opinionStats.layer.borderColor = UIColor.lightGray.cgColor
        self.opinionStats.addshadow(top: false, left: true, bottom: true, right: true)
        self.opinionStats.layer.shadowRadius = 10
        self.opinionStats.layer.shadowOpacity = 0.3
        self.opinionStatsAgree.text = ""
        self.opinionStatsDisagree.text = ""
        self.opinionStatsNeutral.text = ""
        self.opinionStatsMap.isHidden = true
      
        self.loadStatementOpinions(statementID: id) { (opinion) -> (Void) in
            self.opinionStats.isHidden = false
            let agree = opinion.noOfAgrees
            let disagree = opinion.noOfDisagrees
            let neutral = opinion.noOfNeutrals
            
            self.opinionStatsAgree.text = "●  \(agree)"
            self.opinionStatsDisagree.text = "●  \(disagree)"
            self.opinionStatsNeutral.text = "●  \(neutral)"
            self.opinionStatsMap.isHidden = false
            self.opinionStatsMap.statementID = id
        
        }
        */
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "articleAlert") as? OpinionAlertController
        myAlert?.id = id
        myAlert?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert!, animated: true, completion: nil)
        if color == 0{
            title="Neutral"
            title1="neutral"
     /*       let neutralColor = hexStringToUIColor(hex: "#BBDEFB")
            wantedLabel.backgroundColor = neutralColor
            wantedLabel.clipsToBounds = true
            wantedLabel.layer.masksToBounds = false */
        }
        else if color == 1 {
            title="Agree"
            title1="agreed"
        /*    let agreeColor = hexStringToUIColor(hex: "#CCEFD2")
            wantedLabel.backgroundColor = agreeColor
            wantedLabel.layer.masksToBounds = false
            wantedLabel.clipsToBounds = true */
        }
        else if color == 2 {
            title="Disagree"
            title1="disagreed"
        /*    let disColor = hexStringToUIColor(hex: "#FFCDD2")
            wantedLabel.backgroundColor = disColor
            wantedLabel.layer.masksToBounds = false
            wantedLabel.clipsToBounds = true */
        }
       
    }



    // called if pencilicon is clicked and clicked on perticulat statement

    @objc func showStatementOpenions(_sender:longTapGesture1){
        let newsSent = getLabelsInView(view: self.newsContentBox)
        var newsText = ""
        var wantedLabel = UILabel()
        for news in self.newsArray {
            if _sender.id == news.id {
                newsText = news.text
                break
            }

        }
        for labels in newsSent {
            if labels.text == newsText {
                labels.layer.masksToBounds = false
                let agreeColor2 = hexStringToUIColor(hex: "#CCEFD2")
                labels.backgroundColor = agreeColor2
                wantedLabel = labels
                break
            }

        }
        var id=_sender.id
        print("testing \(id)")
        let alertController = UIAlertController(title: title, message: "Add your opinion", preferredStyle: .alert)

        // Create the actions
        let disagreeAction = UIAlertAction(title: "Disagree", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            NSLog("DisAgree Pressed")
            wantedLabel.backgroundColor = UIColor.clear
            self.addUserOpinion(id: _sender.id, opinion: 2)

        }
        let nuetralAction = UIAlertAction(title: "Neutral", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("Neutral Pressed")
            wantedLabel.backgroundColor = UIColor.clear
            self.addUserOpinion(id: _sender.id, opinion: 0)
        }
        let agreeAction = UIAlertAction(title: "Agree", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.addUserOpinion(id: _sender.id, opinion: 1)
            wantedLabel.backgroundColor = UIColor.clear
            NSLog("Agree Pressed")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            wantedLabel.backgroundColor = UIColor.clear
            NSLog("Cancel Pressed")
        }



        /* let cancleAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel) {
         UIAlertAction in

         NSLog("Cancel Pressed")
         }*/

        agreeAction.setValue(agreeColor, forKey: "titleTextColor")
        disagreeAction.setValue(disagreeColor, forKey: "titleTextColor")
        nuetralAction.setValue(neutralColor, forKey: "titleTextColor")


        alertController.addAction(agreeAction)
        alertController.addAction(nuetralAction)
        alertController.addAction(disagreeAction)
        alertController.addAction(cancelAction)
        // alertController.addAction(cancleAction)


        let popover = alertController.popoverPresentationController
        popover?.sourceView = view
        popover?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)

        present(alertController, animated: true)
    }

    fileprivate func configureActionButton() {
        actionButton1.overlayView.backgroundColor = UIColor(hue: 0.31, saturation: 0.37, brightness: 0.10, alpha: 0.30)
        actionButton1.buttonImage = UIImage(named:"edit")
        actionButton1.buttonColor = .red
        actionButton1.buttonImageColor = .white
        actionButton1.itemAnimationConfiguration = .slideIn(withInterItemSpacing: 14)
        actionButton1.layer.shadowColor = UIColor.black.cgColor
        actionButton1.layer.shadowOffset = CGSize(width: 0, height: 1)
        actionButton1.layer.shadowOpacity = Float(0.4)
        actionButton1.layer.shadowRadius = CGFloat(2)

        actionButton1.itemSizeRatio = CGFloat(0.75)

    }
    //add user opinio on statment
    func addUserOpinion(id:String,opinion:Int){
        print("id \(id) opinion\(opinion)")

        let addOpnionUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addOpnionOnStatement")
        var addOpinionRequest = URLRequest(url:addOpnionUrl!)
        addOpinionRequest.httpMethod = "POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        let addOpinionJson = [ "openion":"\(opinion)","userId":"\(userId)","postContentId":"\(id)"] as[String : Any]
        print("json \(addOpinionJson)")
        let jsonData = try? JSONSerialization.data(withJSONObject: addOpinionJson, options: .prettyPrinted)
        addOpinionRequest.httpBody = jsonData
        addOpinionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let addOpinionTask=URLSession.shared.dataTask(with: addOpinionRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error adding user opinion ")
                DispatchQueue.main.async{
                    self.showToaster(msg: "Error adding user opinion ", type: 0)
                }

            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Thank you! ", type: 1)
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }

                        //self.loadComments(id: self.id)
                        self.reloadFunction()

                    }
                }
            }catch let error as NSError {
                print("Failed to  add user opinion Function : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to  add user opinion - try again", type: 1)
                }
            }
        }
        print("calling reload 1")
      //  self.reloadFunction()
        addOpinionTask.resume()
    }


    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)

    }
    @objc func addAgreeopinion(_sender:labelGesture1){
        print("addAgreeopinion")

        self.addUserOpinionOnNews(opinion: 1)
    }
    @objc func adddisagreeopinion(_sender:labelGesture1){
        print("adddisagreeopinion")
        self.addUserOpinionOnNews(opinion: 2)
    }
    @objc func addneutralopinion(_sender:labelGesture1){
        print("addneutralopinion")
        self.addUserOpinionOnNews(opinion: 0)
    }

    // add user opinion on perticular news
    func addUserOpinionOnNews(opinion:Int){
        print("opinion\(opinion)")

        let addOpnionUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addOpnionOnNews")
        var addOpinionRequest = URLRequest(url:addOpnionUrl!)
        addOpinionRequest.httpMethod = "POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        let addOpinionJson = [ "openion":"\(opinion)","userId":"\(userId)","postId":"\(id)"] as[String : Any]
        print("json of add openion : \(addOpinionJson)")
        let jsonData = try? JSONSerialization.data(withJSONObject: addOpinionJson, options: .prettyPrinted)
        addOpinionRequest.httpBody = jsonData
        addOpinionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let addOpinionTask=URLSession.shared.dataTask(with: addOpinionRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error adding user opinion ")
                self.showToaster(msg: "Error adding user opinion ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                    DispatchQueue.main.async {
                        print("in here")
                        //  self.showToaster(msg: "Thank You .. ", type: 1)
                        let alertController = UIAlertController(title: "Add Comment", message: "Do you want to add a comment on this article?", preferredStyle: .alert)


                        let nuetralAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {
                            UIAlertAction in
                            NSLog("Cancel Pressed")
                            self.showToaster(msg: "Your opinion has been added.", type: 1)
                            //super.viewDidLoad()
                           // self.reloadFunction()
                            self.commentArray.removeAll()
                            self.buttonJson.removeAll()
                            self.buttonReportJson.removeAll()
                            self.agreeCommentBtnJson.removeAll()
                            self.disAgreeCommentBtnJson.removeAll()
                            self.neutralCommentBtnJson.removeAll()
                            DispatchQueue.main.async {
                                self.commentsTable.reloadData()
                            }

                            //self.loadComments(id: self.id)
                            self.reloadFunction()

                        }
                        let agreeAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            self.getComments(opinion:opinion);
                            NSLog("Save Pressed")

                        }

                        // Add the actions
                        alertController.addAction(agreeAction)
                        alertController.addAction(nuetralAction)

                        let popover = alertController.popoverPresentationController
                        popover?.sourceView = self.view
                        popover?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)

                        self.present(alertController, animated: true)
                        self.showToaster(msg: "Your opinion has been added.", type: 1)
                    }
                }
            }catch let error as NSError {
                print("Failed to  add user opinion Function : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to  add user opinion Function ..Try Again", type: 1)
                }
            }
        }
       // self.reloadFunction()
        addOpinionTask.resume()
    }

    func getComments(opinion:Int){
        let alertController = UIAlertController(title: "Add Comment", message: "Please enter your comment:", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            if fNameField.text != ""{
                print(fNameField.text)
                self.addNewsComments(opinion: opinion, comment: fNameField.text!)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter your comment", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert -> Void in
        })
        )
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }

    func addNewsComments(opinion:Int,comment:String){
        let addLRUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addNewsComments")
        var addLRRequest = URLRequest(url:addLRUrl!)
        addLRRequest.httpMethod = "POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        let addLRJson = [ "comments":"\(comment)","userId":"\(userId)","postId":"\(id)","openion":"\(opinion)"] as[String : Any]
        print("json \(addLRJson)")
        let jsonData = try? JSONSerialization.data(withJSONObject: addLRJson, options: .prettyPrinted)
        addLRRequest.httpBody = jsonData
        addLRRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let addLRTask=URLSession.shared.dataTask(with: addLRRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error adding user opinion ")
                self.showToaster(msg: "Error adding user opinion ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                   // DispatchQueue.main.async {
                       // self.showToaster(msg: "Thank You .. ", type: 1)
                        print("added comment")
                        print("calling reload 2")
                        //self.reloadFunction()
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }

                        //self.loadComments(id: self.id)
                        self.reloadFunction()
                   // }
                }
            }catch let error as NSError {
                print("Failed to  add user opinion Function : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to  add user opinion Function ..Try Again", type: 1)
                }
            }
        }

        addLRTask.resume()
    }

    // function to reloa data after changes in news
    func reloadFunction(){
        print("calling reloadFunction")
        var count = 0
        DispatchQueue.main.async {
            //self.viewDidLoad()
            self.loadNewsNew()
        }
    }


    // show alert on slider changed
    @objc func sliderValueDidChange(sender:UISlider!)
    {
        print("number:\(sender.value)")
        let alertController = UIAlertController(title: "", message: "Do you want to save \(sender.value)?", preferredStyle: .alert)


        let nuetralAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")

        }
        let agreeAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.addUserLROnNews(lRcount: sender.value)
            NSLog("Save Pressed")
        }

        // Add the actions
        alertController.addAction(agreeAction)
        alertController.addAction(nuetralAction)

        let popover = alertController.popoverPresentationController
        popover?.sourceView = view
        popover?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)

        present(alertController, animated: true)
    }

    // add user L-R on perticular news
    func addUserLROnNews(lRcount:Float){
        print("opinion\(lRcount)")

        let addLRUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addLRCountOnNews")
        var addLRRequest = URLRequest(url:addLRUrl!)
        addLRRequest.httpMethod = "POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        let addLRJson = [ "lRcount":"\(lRcount)","userId":"\(userId)","postId":"\(id)"] as[String : Any]
        print("json \(addLRJson)")
        let jsonData = try? JSONSerialization.data(withJSONObject: addLRJson, options: .prettyPrinted)
        addLRRequest.httpBody = jsonData
        addLRRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let addLRTask=URLSession.shared.dataTask(with: addLRRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error adding user opinion ")
                self.showToaster(msg: "Error adding user opinion ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Thank you!", type: 1)
                          print("calling reload 3")
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }

                        //self.loadComments(id: self.id)
                        self.reloadFunction()
                    }
                }
            }catch let error as NSError {
                print("Failed to  add user opinion Function : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to  add user opinion Function ..Try Again", type: 1)
                }
            }
        }
        addLRTask.resume()
    }


    @objc func markNewReported(sender:UIButton){
        let alertController = UIAlertController(title: "Report", message: "Please enter a reason to report:", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField


            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.reportNews(reason: fNameField.text!)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter a reason to report", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert -> Void in
        })
        )
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)


    }


    //function to report news
    func reportNews(reason:String){
        let reportNewsrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/reportNews")
        var addLRRequest = URLRequest(url:reportNewsrl!)
        addLRRequest.httpMethod = "POST"
        let userId = UserDefaults.standard.object(forKey: "userId") as! String

        let addLRJson = [ "note":"\(reason)","userId":"\(userId)","postId":"\(id)"] as[String : Any]
        print("json \(addLRJson)")
        let jsonData = try? JSONSerialization.data(withJSONObject: addLRJson, options: .prettyPrinted)
        addLRRequest.httpBody = jsonData
        addLRRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let addLRTask=URLSession.shared.dataTask(with: addLRRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error adding user opinion ")
                self.showToaster(msg: "Error adding user opinion ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Thank you!", type: 1)
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }

                        //self.loadComments(id: self.id)
                        self.reloadFunction()

                    }
                }
            }catch let error as NSError {
                print("Failed to  add user opinion Function : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to  add user opinion Function ..Try Again", type: 1)
                }
            }
        }
          print("calling reload 4")
       // self.reloadFunction()
        addLRTask.resume()
    }

    //function to show map of news
    @objc func showNewsMap(sender:UIButton){
        var newDataForView=mapOpions(newsId:self.id,mapType:0)
        //let vc = UIStoryboard.init(name:"Main",bundle:Bundle.main).instantiateViewController(withIdentifier: "OpinionMapViewController") as! OpinionMapViewController
        // vc.news = newDataForView
        // let backItem = UIBarButtonItem()
        // backItem.title = ""
        // navigationItem.backBarButtonItem = backItem
        // self.navigationController?.pushViewController(vc, animated: true)
        let mainTabController = storyboard?.instantiateViewController(withIdentifier:"OpinionMapViewController") as! OpinionMapViewController
        mainTabController.news = newDataForView
        present(mainTabController, animated: true, completion: nil)
    }
    @objc func goTOAuthorDetails(_sender:labelGesture1){
        var id=_sender.id
        print("id \(id)")
        self.userId=id
        performSegue(withIdentifier: "AuthorDetails", sender: self)
        // fromViewController.performSegueWithIdentifier("segue_id", sender: fromViewController)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        print("segue.identifier \(segue.identifier)")
        switch (segue.identifier ?? "") {
        case "AuthorDetails":
            //   os_log("show news details",log:OSLog.default,type:.debug)
            guard let articleController = segue.destination as? AuthorDetailsViewController else{
                fatalError("unexpected destination :\(segue.destination)")
            }
            articleController.userId=self.userId
        default:
            print("defualt case")
            fatalError("unexpected segue indentiifer \(segue.identifier)")
            //default case
        }
    }

    ///coments table views
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (commentArray.count)


    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 13
        }
        else {
            return 28
        }
    }

  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentData = commentArray[indexPath.row]
//        let userData = UserDefaults.standard
//        let userId = userData.string(forKey: "userId") as! String
        let firstNameOnly = commentData.authorName.components(separatedBy: " ")
        switch (commentData.isReply){
        case true:
            guard let cellAsReply = tableView.dequeueReusableCell(withIdentifier: "ReplyTableViewCell", for: indexPath) as? ReplyTableViewCell
                else{
                    fatalError("Error in creating commentcell")
            }
            cellAsReply.layoutSubviews()
            cellAsReply.setNeedsLayout()
            cellAsReply.layoutIfNeeded()
            cellAsReply.edit.id=commentData.commentId
            cellAsReply.edit.comment=commentData.comment
            cellAsReply.edit.opinion=commentData.opinion
            cellAsReply.edit.addTarget(self, action: #selector(self.editReply), for: .touchUpInside)
            cellAsReply.edit.isHidden = !commentData.isEditable

            cellAsReply.commentContainer.layer.cornerRadius = 10
            cellAsReply.selectionStyle = UITableViewCellSelectionStyle.none
            cellAsReply.commentName.sizeToFit()
            cellAsReply.commentName.text = firstNameOnly[0]
            cellAsReply.commentProfileImage.image = commentData.authorImage
            cellAsReply.commentProfileImage.layer.borderWidth = 0.5
            cellAsReply.commentProfileImage.layer.borderColor = UIColor.lightGray.cgColor
            cellAsReply.commentProfileImage.layer.masksToBounds = false
            cellAsReply.commentProfileImage.layer.cornerRadius = cellAsReply.commentProfileImage.frame.width/2
            cellAsReply.commentProfileImage.clipsToBounds = true
            cellAsReply.comment.text = commentData.comment

            let tap = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
            tap.id = commentData.authorId
            cellAsReply.commentName.addGestureRecognizer(tap)
            let tap2 = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
            tap2.id = commentData.authorId
            cellAsReply.commentProfileImage.addGestureRecognizer(tap2)
            cellAsReply.agreesOnComment.titleLabel?.textColor = agreeColor
            cellAsReply.disagreesOnComment.titleLabel?.textColor = disagreeColor
            cellAsReply.neutralsOnComment.titleLabel?.textColor = neutralColor
            self.agreeCommentBtnJson[cellAsReply.agreesOnComment] = commentData.commentId
            cellAsReply.agreesOnComment.addTarget(self, action: #selector(self.agreeCommentFunction), for: .touchUpInside)
            self.disAgreeCommentBtnJson[cellAsReply.disagreesOnComment] = commentData.commentId
            cellAsReply.disagreesOnComment.addTarget(self, action: #selector(self.disAgreeCommentFunction), for: .touchUpInside)
            self.neutralCommentBtnJson[cellAsReply.neutralsOnComment] = commentData.commentId
            cellAsReply.neutralsOnComment.addTarget(self, action: #selector(self.neutralCommentFunction), for: .touchUpInside)
            self.buttonJson[cellAsReply.replyToComment] = commentData.actualID
            cellAsReply.agreesOnComment.setTitle("● \(commentData.noOfAgrees)" , for: .normal)
            cellAsReply.disagreesOnComment.setTitle("● \(commentData.noOfDisagrees)" , for: .normal)
            cellAsReply.neutralsOnComment.setTitle("● \(commentData.noOfNeutrals)" , for: .normal)
          //  cellAsReply.replyToComment.isHidden = true
            cellAsReply.time.text = commentData.timeAgo
            cellAsReply.isEdited.isHidden = true
            cellAsReply.opinionColor.isHidden = true
            cellAsReply.noOfReplies.isHidden = true
            cellAsReply.replyToComment.addTarget(self, action: #selector(self.comments), for: .touchUpInside)
          /*  if commentData.opinion == 1{
                cellAsReply.opinionColor.backgroundColor = agreeColor
            }
            else if commentData.opinion == 2{
                cellAsReply.opinionColor.backgroundColor = disagreeColor
            }
            else{
                cellAsReply.opinionColor.backgroundColor = neutralColor
            } */
            //to show comment is edited or not
            cellAsReply.commentEndorsement.text = commentData.authorEndorsment
            return cellAsReply
        case false:
            guard let cell = commentsTable.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath) as? CommentsTableViewCell
                else{
                    fatalError("Error in creating commentcell")
            }
        cell.edit.isHidden = !commentData.isEditable
        //to edit comment
        cell.edit.id=commentData.commentId
        cell.edit.comment=commentData.comment
        cell.edit.opinion=commentData.opinion
        cell.edit.addTarget(self, action: #selector(self.editComment), for: .touchUpInside)

       // cell.isEdited.isHidden = !commentData.isEdited

        cell.commentContainer.layer.cornerRadius = 10
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.commentName.text = firstNameOnly[0]
        cell.commentProfileImage.image = commentData.authorImage
        cell.commentProfileImage.layer.borderWidth = 0.5
        cell.commentProfileImage.layer.borderColor = UIColor.lightGray.cgColor
        cell.commentProfileImage.layer.masksToBounds = false
        cell.commentProfileImage.layer.cornerRadius = cell.commentProfileImage.frame.width/2
        cell.commentProfileImage.clipsToBounds = true
            cell.layoutSubviews()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()

        cell.comment.text = commentData.comment
        let tap = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
        tap.id = commentData.authorId
        cell.commentName.addGestureRecognizer(tap)
        let tap2 = labelGesture(target: self, action: #selector(self.goTOAuthorDetails(_sender:)))
        tap2.id = commentData.authorId
        cell.commentProfileImage.addGestureRecognizer(tap2)
        cell.agreesOnComment.titleLabel?.textColor = agreeColor
        cell.disagreesOnComment.titleLabel?.textColor = disagreeColor
        cell.neutralsOnComment.titleLabel?.textColor = neutralColor
        self.agreeCommentBtnJson[cell.agreesOnComment] = commentData.commentId
        cell.agreesOnComment.addTarget(self, action: #selector(self.agreeCommentFunction), for: .touchUpInside)
        self.disAgreeCommentBtnJson[cell.disagreesOnComment] = commentData.commentId
        cell.disagreesOnComment.addTarget(self, action: #selector(self.disAgreeCommentFunction), for: .touchUpInside)
        self.neutralCommentBtnJson[cell.neutralsOnComment] = commentData.commentId
        cell.neutralsOnComment.addTarget(self, action: #selector(self.neutralCommentFunction), for: .touchUpInside)
        self.buttonJson[cell.replyToComment] = commentData.commentId
        cell.replyToComment.addTarget(self, action: #selector(self.comments), for: .touchUpInside)
        DispatchQueue.main.async {
            cell.noOfReplies.text="\(commentData.noOfReply) Replies"
            cell.agreesOnComment.setTitle("● \(commentData.noOfAgrees)" , for: .normal)
            cell.disagreesOnComment.setTitle("● \(commentData.noOfDisagrees)" , for: .normal)
            cell.neutralsOnComment.setTitle("● \(commentData.noOfNeutrals)" , for: .normal)
        }

        if commentData.opinion == 1{
            cell.opinionColor.backgroundColor = agreeColor
        }
        else if commentData.opinion == 2{
            cell.opinionColor.backgroundColor = disagreeColor
        }
        else{
            cell.opinionColor.backgroundColor = neutralColor
        }
        cell.time.text = commentData.timeAgo

          /*  if commentData.isEdited{
                cell.isEdited.isHidden=false
            }
            else{
                cell.isEdited.isHidden=true
            } */
        cell.commentEndorsement.text = commentData.authorEndorsment
        return cell
            
        }
    }


    @objc func editReply(_sender:editCommentButton){
        let alertController = UIAlertController(title: "Update", message: "Update your reply here", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Update", style: .default, handler: {
            alert -> Void in

            let fNameField = alertController.textFields![0] as UITextField


            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.updateReply(id:_sender.id,reply:fNameField.text!,opinion: _sender.opinion)

            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter reply details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))

        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Edit Reply"
            textField.textAlignment = .center
            textField.text!=_sender.comment
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert -> Void in
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }

    func updateReply(id:String,reply:String,opinion:Int){
        let reportUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateReply")
        var reportRequest = URLRequest(url:reportUrl!)
        reportRequest.httpMethod = "POST"
        reportRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let userData = UserDefaults.standard
        let userId = userData.string(forKey: "userId") as! String
        let reportData = ["reply":"\(reply)","replyId":"\(id)","userId":userId] as[String : Any]

        print("replyData json \(reportData)")
        let jsonData = try? JSONSerialization.data(withJSONObject: reportData, options: .prettyPrinted)
        reportRequest.httpBody = jsonData
        let reportTask = URLSession.shared.dataTask(with: reportRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error in updating comment")
                self.showToaster(msg: "Error updating comment ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]

                let code = json["code"] as? Int

                if code == 1{
                    let msg = json["msg"] as? String
                    DispatchQueue.main.async () {
                        self.showToaster(msg: msg!, type: 1)
                        print("calling loadComments after edit comments/replies")
                        //self.loadComments(id: self.id)
                        //self.reloadFunction()
                        DispatchQueue.main.async () {
                            print("reloading after edit reply")
                            self.commentArray.removeAll()
                            self.buttonJson.removeAll()
                            self.buttonReportJson.removeAll()
                            self.agreeCommentBtnJson.removeAll()
                            self.disAgreeCommentBtnJson.removeAll()
                            self.neutralCommentBtnJson.removeAll()
                            DispatchQueue.main.async {
                                self.commentsTable.reloadData()
                            }
                            self.reloadFunction()
                        }// end dispatchQ
                    }// end dispatchQ
                }
            }catch let error as NSError {
                print("Failed to  update comment : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to update comment ..Try Again", type: 1)
                }
            }
        }
        reportTask.resume()
    }
    @objc func editComment(_sender:editCommentButton){
        print("in edit comment function \(_sender.id)")
        let alertController = UIAlertController(title: "Update", message: "Update your comment here", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Neutral", style: .default, handler: {
            alert -> Void in

            let fNameField = alertController.textFields![0] as UITextField


            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.updateComment(id:_sender.id,comment: fNameField.text!,opinion:0)

            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter comments details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Agree", style: .destructive, handler: {
            alert -> Void in

            let fNameField = alertController.textFields![0] as UITextField


            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.updateComment(id:_sender.id,comment: fNameField.text!,opinion:1)

            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter comments details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Disagree", style: .default, handler: {
            alert -> Void in

            let fNameField = alertController.textFields![0] as UITextField


            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.updateComment(id:_sender.id,comment: fNameField.text!,opinion: 2)

            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter comments details", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Edit comment"
            textField.textAlignment = .center
            textField.text!=_sender.comment
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert -> Void in
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }
    func updateComment(id:String,comment:String,opinion:Int){
        let reportUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/updateComment")
        var reportRequest = URLRequest(url:reportUrl!)
        reportRequest.httpMethod = "POST"
        reportRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let reportData = ["comments":"\(comment)","commentId":"\(id)","opinion":opinion] as[String : Any]

        print("replyData json \(reportData)")
        let jsonData = try? JSONSerialization.data(withJSONObject: reportData, options: .prettyPrinted)
        reportRequest.httpBody = jsonData
        let reportTask = URLSession.shared.dataTask(with: reportRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error in updating comment")
                self.showToaster(msg: "Error updating comment ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]

                let code = json["code"] as? Int

                if code == 1{
                    let msg = json["msg"] as? String
                    DispatchQueue.main.async () {
                        self.showToaster(msg: msg!, type: 1)
                        print("calling loadComments after comment update")
                        //  self.loadComments(id: self.id)
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }

                        //self.loadComments(id: self.id)
                        self.reloadFunction()
                        //self.reloadFunction()
                    }// end dispatchQ
                }
            }catch let error as NSError {
                print("Failed to  update comment : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to update comment ..Try Again", type: 1)
                }
            }
        }
        reportTask.resume()
    }
    // function to load comments and replies cells
    /*  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     //        self.buttonJson.removeAll()
     //        self.buttonReportJson.removeAll()
     //        self.agreeCommentBtnJson.removeAll()
     //        self.disAgreeCommentBtnJson.removeAll()
     //        self.neutralCommentBtnJson.removeAll()


     // print("in tablview Functions")
     let cell = UITableViewCell.self

     let commentData = commentArray[indexPath.row]
     //print("comment data in table is \(commentData)")
     //print("is reply \(commentData.isReply)")

     // return reply cell
     if(commentData.isReply){
     guard let replyCell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? CommentsTableViewCell
     else{
     fatalError("Error in creating replycell")
     }

     replyCell.authorEndorsment.text = commentData.authorEndorsment
     replyCell.authorName.text = commentData.authorName
     replyCell.authorProfileImage.image = commentData.authorImage
     replyCell.comment.text = commentData.comment
     replyCell.sizeToFit()
     return replyCell
     }
     // return comment cell
     else{
     guard let commentCell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? CommentsTableViewCell
     else{
     fatalError("Error in creating commentcell")
     }

     commentCell.authorEndorsment.text = commentData.authorEndorsment
     commentCell.authorName.text = commentData.authorName
     commentCell.authorProfileImage.image = commentData.authorImage
     commentCell.comment.text = commentData.comment
     if commentData.opinion == 1{
     commentCell.backgroundColor = UIColor.green
     }
     else if commentData.opinion == 2{
     commentCell.backgroundColor = UIColor.red
     }
     else{
     commentCell.backgroundColor = UIColor.blue
     }



     // buttons for opinion on comments
     //Agree Btn
     let agreeCommentBtn = UIButton(frame: CGRect(x: CGFloat(commentCell.frame.origin.x+20), y: CGFloat(commentCell.frame.origin.y+2), width: commentCell.frame.size.width / 4, height: 20.0))
     // agreeCommentBtn.center = CGPoint(x:5,y:13)
     agreeCommentBtn.setTitle("Agree", for: .normal)
     agreeCommentBtn.setTitleColor(UIColor.white, for: .normal)
     self.agreeCommentBtnJson[agreeCommentBtn] = commentData.commentId
     agreeCommentBtn.addTarget(self, action: #selector(self.agreeCommentFunction), for: .touchUpInside)
     agreeCommentBtn.sizeToFit()
     commentCell.addSubview(agreeCommentBtn)


     // buttons for opinion on comments
     //DisAgree Btn
     let disAgreeCommentBtn = UIButton(frame: CGRect(x: CGFloat(commentCell.frame.origin.x+10+agreeCommentBtn.frame.size.width+agreeCommentBtn.frame.origin.x+10), y: CGFloat(commentCell.frame.origin.y+2), width: commentCell.frame.size.width / 4, height: 20.0))
     //disAgreeCommentBtn.center = CGPoint(x:10,y:13)
     disAgreeCommentBtn.setTitle("DisAgree", for: .normal)
     disAgreeCommentBtn.setTitleColor(UIColor.white, for: .normal)
     self.disAgreeCommentBtnJson[disAgreeCommentBtn] = commentData.commentId
     disAgreeCommentBtn.addTarget(self, action: #selector(self.disAgreeCommentFunction), for: .touchUpInside)
     disAgreeCommentBtn.sizeToFit()
     commentCell.addSubview(disAgreeCommentBtn)

     // buttons for opinion on comments
     //neutral Btn
     let neutralCommentBtn = UIButton(frame: CGRect(x: CGFloat(commentCell.frame.origin.x+10+agreeCommentBtn.frame.size.width+agreeCommentBtn.frame.origin.x+10+disAgreeCommentBtn.frame.size.width+disAgreeCommentBtn.frame.origin.x+10), y: CGFloat(commentCell.frame.origin.y+2), width: commentCell.frame.size.width / 4, height: 20.0))
     //disAgreeCommentBtn.center = CGPoint(x:15,y:13)
     neutralCommentBtn.setTitle("Neutral", for: .normal)
     agreeCommentBtn.setTitleColor(UIColor.white, for: .normal)
     self.neutralCommentBtnJson[neutralCommentBtn] = commentData.commentId
     neutralCommentBtn.addTarget(self, action: #selector(self.neutralCommentFunction), for: .touchUpInside)
     neutralCommentBtn.sizeToFit()
     commentCell.addSubview(neutralCommentBtn)

     // to add report button
     let reportBtn = UIButton(frame: CGRect(x: CGFloat(commentCell.frame.origin.x+10+agreeCommentBtn.frame.size.width+agreeCommentBtn.frame.origin.x+10+disAgreeCommentBtn.frame.size.width+disAgreeCommentBtn.frame.origin.x+10+neutralCommentBtn.frame.size.width+neutralCommentBtn.frame.origin.x+10), y: CGFloat(commentCell.frame.origin.y+2), width: commentCell.frame.size.width / 4, height: 20.0))
     reportBtn.center = CGPoint(x:20,y:12)
     reportBtn.setImage(UIImage(named:"flag"), for: .highlighted)
     self.buttonReportJson[reportBtn] = commentData.commentId
     reportBtn.addTarget(self, action: #selector(self.reportComments), for: .touchUpInside)
     reportBtn.sizeToFit()
     commentCell.addSubview(reportBtn)

     // add reply button
     let replyBtn = UIButton(frame: CGRect(x: CGFloat(commentCell.frame.origin.x+10+reportBtn.frame.size.width+neutralCommentBtn.frame.origin.x+10), y: CGFloat(commentCell.frame.origin.y+2), width: commentCell.frame.size.width / 4, height: 20.0))
     replyBtn.setTitle("Reply", for: .normal)
     replyBtn.center = CGPoint(x:25,y:13)
     replyBtn.setTitleColor(UIColor.white, for: .normal)
     self.buttonJson[replyBtn] = commentData.commentId
     replyBtn.addTarget(self, action: #selector(self.comments), for: .touchUpInside)
     commentCell.sizeToFit()
     commentCell.addSubview(replyBtn)

     return commentCell
     }

     }
     */
    // function to add agree opinion to comment
    @objc func agreeCommentFunction(_sender: UIButton){
        let commentId = self.agreeCommentBtnJson[_sender] as! String
        //print("got comment id is \(commentId)")
        let agreeCmntAlertController = UIAlertController(title: "", message: "Do you want to agree with this comment?", preferredStyle: .alert)


        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")

        }
        let saveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            UIAlertAction in
            // add comment agree fubction here
            let userData = UserDefaults.standard
            let userId = userData.string(forKey: "userId") as! String
            let commentOpinionUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addCommentOpinion")
            var request = URLRequest(url:commentOpinionUrl!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let requestData = ["userId":"\(userId)","commentId":"\(commentId)","opinion":1] as[String : Any]
            // print("op data \(requestData)")
            //print("replyData json \(replyData)")
            let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                if (error != nil){
                    print("Error in adding opinion for comment")
                    self.showToaster(msg: "Error adding opinion ", type: 0)
                }
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    //  print("Opinion for comment opt is:  \(json)")
                    let code = json["code"] as? Int

                    if code == 1{
                        let msg = json["msg"] as? String
                        DispatchQueue.main.async () {
                            self.showToaster(msg: msg!, type: 1)
                        }// end dispatchQ



                            print("reloading after edit reply")
                            self.commentArray.removeAll()
                            self.buttonJson.removeAll()
                            self.buttonReportJson.removeAll()
                            self.agreeCommentBtnJson.removeAll()
                            self.disAgreeCommentBtnJson.removeAll()
                            self.neutralCommentBtnJson.removeAll()
                            DispatchQueue.main.async {
                                self.commentsTable.reloadData()
                            }
                            self.reloadFunction()


                    }
                }catch let error as NSError {
                    print("Failed to add opnion comment : \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Failed to add opinion comment ..Try Again", type: 1)
                    }
                }
            }
            task.resume()
        }
        agreeCmntAlertController.addAction(saveAction)
        agreeCmntAlertController.addAction(cancelAction)


        self.present(agreeCmntAlertController, animated: true, completion: nil)
    }


    // function to add disAgree opinion to comment
    @objc func disAgreeCommentFunction(_sender: UIButton){
        let commentId = self.disAgreeCommentBtnJson[_sender] as! String
        //print("got comment id is \(commentId)")
        let disAgreeController = UIAlertController(title: "", message: "Do you want to disagree with this comment?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")

        }
        let saveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            UIAlertAction in
            // add comment agree fubction here
            let userData = UserDefaults.standard
            let userId = userData.string(forKey: "userId") as! String
            let commentOpinionUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addCommentOpinion")
            var request = URLRequest(url:commentOpinionUrl!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let requestData = ["userId":"\(userId)","commentId":"\(commentId)","opinion":2] as[String : Any]
            // print("op data \(requestData)")
            //print("replyData json \(replyData)")
            let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                if (error != nil){
                    print("Error in adding opinion for comment")
                    self.showToaster(msg: "Error adding opinion ", type: 0)
                }
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    // print("Opinion for comment opt is:  \(json)")
                    let code = json["code"] as? Int

                    if code == 1{
                        let msg = json["msg"] as? String
                        DispatchQueue.main.async () {
                            self.showToaster(msg: msg!, type: 1)
                        }// end dispatchQ
                        print("reloading after disagree on comment")
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }
                        self.reloadFunction()
                    }
                }catch let error as NSError {
                    print("Failed to add opnion comment : \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Failed to add opinion comment ..Try Again", type: 1)
                    }
                }
            }
            task.resume()
        }

        disAgreeController.addAction(saveAction)
        disAgreeController.addAction(cancelAction)


        self.present(disAgreeController, animated: true, completion: nil)
    }



    // function to add neutral opinion to comment
    @objc func neutralCommentFunction(_sender: UIButton){
        let commentId = self.neutralCommentBtnJson[_sender] as! String
        // print("got comment id is \(commentId)")
        let newtralCommentController = UIAlertController(title: "", message: "Do you want to reaact neutral to this comment?", preferredStyle: .alert)


        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")

        }
        let saveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            UIAlertAction in
            // add comment agree fubction here
            let userData = UserDefaults.standard
            let userId = userData.string(forKey: "userId") as! String
            let commentOpinionUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addCommentOpinion")
            var request = URLRequest(url:commentOpinionUrl!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let requestData = ["userId":"\(userId)","commentId":"\(commentId)","opinion":0] as[String : Any]
            //  print("op data \(requestData)")
            //print("replyData json \(replyData)")
            let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                if (error != nil){
                    print("Error in adding opinion for comment")
                    self.showToaster(msg: "Error adding opinion ", type: 0)
                }
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    // print("Opinion for comment opt is:  \(json)")
                    let code = json["code"] as? Int

                    if code == 1{
                        let msg = json["msg"] as? String
                        DispatchQueue.main.async () {
                            self.showToaster(msg: msg!, type: 1)
                        }// end dispatchQ
                        print("reloading after edit reply")
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }
                        self.reloadFunction()
                    }
                }catch let error as NSError {
                    print("Failed to add opnion comment : \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showToaster(msg: "Failed to add opinion comment ..Try Again", type: 1)
                    }
                }
            }
            task.resume()
        }
        newtralCommentController.addAction(saveAction)
        newtralCommentController.addAction(cancelAction)


        self.present(newtralCommentController, animated: true, completion: nil)
    }


    @objc func reportComments(_sender: UIButton){
        let commentId = buttonReportJson[_sender] as! String
        let alertController = UIAlertController(title: "Report Comment", message: "Do you want to report this comment?", preferredStyle: .alert)


        let nuetralAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")

        }
        let agreeAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.getReason(commentId:commentId)
            NSLog("Save Pressed")

        }

        // Add the actions
        alertController.addAction(agreeAction)
        alertController.addAction(nuetralAction)

        let popover = alertController.popoverPresentationController
        popover?.sourceView = view
        popover?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)

        present(alertController, animated: true)

    }


    // function to get reason from user for report comment
    func getReason(commentId : String){
        let alertController = UIAlertController(title: "Report", message: "Please enter a reason to report this article:", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Report", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            if fNameField.text != ""{
                //self.newUser = User(fn: fNameField.text!, ln: lNameField.text!)
                //TODO: Save user data in persistent storage - a tutorial for another time
                print(fNameField.text)
                self.reportComment(reason: fNameField.text!,commentId:commentId)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter a reason to report", preferredStyle: .alert)
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


    // API call to report comment
    func reportComment(reason:String,commentId : String)  {
        print("reason \(reason) and comment id is \(commentId)")
        let userData = UserDefaults.standard
        let userId = userData.string(forKey: "userId")
        let reportUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/reportComment")
        var reportRequest = URLRequest(url:reportUrl!)
        reportRequest.httpMethod = "POST"
        reportRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let reportData = ["note":"\(reason)","reportedByUserId":"\(userId)","commentId":"\(commentId)"] as[String : Any]

        //print("replyData json \(replyData)")
        let jsonData = try? JSONSerialization.data(withJSONObject: reportData, options: .prettyPrinted)
        reportRequest.httpBody = jsonData
        let reportTask = URLSession.shared.dataTask(with: reportRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error in reporting comment")
                self.showToaster(msg: "Error adding reply ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt report comments: 1 \(json)")
                let code = json["code"] as? Int

                if code == 1{
                    let msg = json["msg"] as? String
                    DispatchQueue.main.async () {
                        self.showToaster(msg: msg!, type: 1)
                    }// end dispatchQ
                    print("reloading after edit reply")
                    self.commentArray.removeAll()
                    self.buttonJson.removeAll()
                    self.buttonReportJson.removeAll()
                    self.agreeCommentBtnJson.removeAll()
                    self.disAgreeCommentBtnJson.removeAll()
                    self.neutralCommentBtnJson.removeAll()
                    DispatchQueue.main.async {
                        self.commentsTable.reloadData()
                    }
                    self.reloadFunction()
                }
            }catch let error as NSError {
                print("Failed to  report comment : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to report comment ..Try Again", type: 1)
                }
            }
        }
        reportTask.resume()

    }




    @objc func comments(_sender: UIButton){
        let commentId = buttonJson[_sender] as! String
        print("comment id is \(commentId)")
        let alertController = UIAlertController(title: "Add a reply", message: "Please enter your reply:", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            let fNameField = alertController.textFields![0] as UITextField
            if fNameField.text != ""{
                print(fNameField.text)
                self.addComments(comment: fNameField.text!,commentId: commentId)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter your reply", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))

        let cancleAction = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in

            NSLog("Cancel Pressed")
        }

        alertController.addAction(cancleAction)

        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Reason"
            textField.textAlignment = .center
        })
        self.present(alertController, animated: true, completion: nil)
    }



    // add replies to comments
    func addComments(comment:String,commentId : String){
        //print("comment \(comment) and id is \(commentId)")
        let userData = UserDefaults.standard
        let userId = userData.string(forKey: "userId") as! String
        let replyUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addReplyOnComment")
        var replyRequest = URLRequest(url:replyUrl!)
        replyRequest.httpMethod = "POST"
        replyRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let replyData = ["comments":"\(comment)","userId":"\(userId)","commentId":"\(commentId)"] as[String : Any]

        print("replyData json \(replyData)")
        let jsonData = try? JSONSerialization.data(withJSONObject: replyData, options: .prettyPrinted)
        replyRequest.httpBody = jsonData
        let addReplyTask = URLSession.shared.dataTask(with: replyRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error adding reply ")
                self.showToaster(msg: "Error adding reply ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                print("opt add points : 1 \(json)")
                let code = json["code"] as? Int

                if code == 1{
                    let msg = json["msg"] as? String
                    DispatchQueue.main.async () {
                        self.showToaster(msg: msg!, type: 1)
                        print("reloading after add reply")
                        self.commentArray.removeAll()
                        self.buttonJson.removeAll()
                        self.buttonReportJson.removeAll()
                        self.agreeCommentBtnJson.removeAll()
                        self.disAgreeCommentBtnJson.removeAll()
                        self.neutralCommentBtnJson.removeAll()
                        DispatchQueue.main.async {
                            self.commentsTable.reloadData()
                        }
                        self.reloadFunction()
                    }// end dispatchQ
                }
            }catch let error as NSError {
                print("Failed to  add reply to comment : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to  add Reply to comment ..Try Again", type: 1)
                }
            }
        }
        addReplyTask.resume()
    }



    func loadComments(id:String){
        self.commentArray.removeAll()
        print("calling load comments old way")
        let dispatchGroup = DispatchGroup()

        let commentUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getAllCommentsByNewsId?key=\(id)")
        var commentRequest = URLRequest(url:commentUrl!)
        commentRequest.httpMethod = "POST"

        commentRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let commentTask=URLSession.shared.dataTask(with: commentRequest){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("Error in getting Comments ")
                self.showToaster(msg: "Error in loading comments ", type: 0)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                //         print("opt add points : 1 \(json)")
                let code = json["code"] as? Int
                if code == 1{
                    DispatchQueue.main.async () {
                        if let gotCommentsArray = json["data"] as? NSArray {
                            //  print("got comments count \(gotCommentsArray.count)")

                            var replyProcess = false
                            var commentsCount = 0
                            for comments in gotCommentsArray {
                                commentsCount = commentsCount + 1
                                dispatchGroup.enter()

                                if let commentsData = comments as? NSDictionary{

                                    // code to add comments in aaray

                                    let commentsUserDataObject = commentsData.value(forKey: "user") as! NSObject
                                    let commentsDataObject = commentsData.value(forKey: "comment") as! NSObject
                                    var commentIsEdited = false
                                    if(commentsDataObject.value(forKey: "isEdited") as! Int == 1){
                                        commentIsEdited = true
                                    }
                                    let userImage : UIImage
                                    if (commentsUserDataObject.value(forKey: "photo") != nil){
                                        let userImageUrl:URL = URL(string:commentsUserDataObject.value(forKey: "photo") as! String)!
                                        let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                                        userImage = UIImage(data:userImageData as Data)!
                                    }
                                    else {
                                        // TODO : Add default image of newzSlate here @Author subodh3344
                                        let userImageUrl:URL = URL(string:"https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff")!
                                        let userImageData:NSData = NSData(contentsOf : userImageUrl)!
                                        userImage = UIImage(data:userImageData as Data)!
                                    }
                                    // code to get replies of comments
                                    DispatchQueue.main.async {
                                        let commentId = commentsData.value(forKey: "commentId") as! String
                                        let getReplyUrl = URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getRepliesOfComments?key=\(commentId)")
                                        print("fetchng replies using url ::: \(getReplyUrl)")
                                        var replyRequest = URLRequest(url:getReplyUrl!)
                                        replyRequest.httpMethod = "POST"
                                        replyRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                        let getReplyTask = URLSession.shared.dataTask(with: replyRequest){
                                            (replyData:Data?,replyResponse:URLResponse?,replyError:Error?) in
                                            if(replyError != nil){
                                                print("Error in getting Replies for comment \(commentId)")
                                                self.showToaster(msg: "Error In getting Replies ", type: 0)
                                            }
                                            do{
                                                let replyJson = try JSONSerialization.jsonObject(with: replyData!, options: []) as! [String:AnyObject]
                                                let replyCode = replyJson["code"] as? Int
                                                // code to add replies in array
                                                var isEditable = false
                                                let loggedInUserData = UserDefaults.standard
                                                let loggedInUserId = loggedInUserData.string(forKey: "userId") as! String
                                                if(loggedInUserId == commentsData.value(forKey: "userId") as! String){
                                                    isEditable = true
                                                }


                                                if replyCode == 1 {
                                                    DispatchQueue.main.async () {


                                                        // push comments in array
                                                        print("comment data \(commentsDataObject.value(forKey: "comments") as! String) and isedited is \(commentsDataObject.value(forKey: "isEdited") != nil)) and noOfDisagree is  \(commentsDataObject.value(forKey: "noOfDisAgree"))")
                                                        guard let comment = commentData(
                                                            commentId : commentsData.value(forKey: "commentId") as! String,
                                                            authorId : commentsData.value(forKey: "userId") as! String,
                                                            authorName : commentsUserDataObject.value(forKey: "name") as! String,
                                                            authorImage  : userImage,
                                                            authorEndorsment : commentsUserDataObject.value(forKey : "highEndorsmentName") as! String,
                                                            comment : commentsDataObject.value(forKey: "comments") as! String,
                                                            noOfReply : commentsDataObject.value(forKey: "noOfReplies") as! Int,
                                                            opinion : commentsDataObject.value(forKey: "openion") as! Int,
                                                            isReply : false,
                                                            isEdited : commentIsEdited,
                                                            noOfAgrees: commentsDataObject.value(forKey: "noOfAgree") as! Int,
                                                            noOfDisagrees: commentsDataObject.value(forKey: "noOfDisAgree") as! Int,
                                                            noOfNeutrals: commentsDataObject.value(forKey: "noOfNeutral") as! Int,
                                                            actualID: commentsData.value(forKey: "commentId") as! String,
                                                            isEditable : isEditable,
                                                            timeAgo : commentsData.value(forKey: "timeago") as! String

                                                            )
                                                            else{
                                                                fatalError("Error in comments")
                                                        }
                                                        print("adding in comments in array with reply \(comment)");
                                                        self.commentArray.append(comment)
                                                       // var opinions = Opinions(noOfAgrees:0, noOfDisagrees:0, noOfNeutrals:0)

                                                        if let gotReplyArray = replyJson["data"] as? NSArray{
                                                            //print("got replies array count \(gotReplyArray.count)")
                                                            var replyCounter = 0
                                                            var a = 0
                                                            var b = 0
                                                            var c = 0
                                                            self.replyArrayCount = gotReplyArray.count
                                                            var replyCount = 0
                                                            for gotReplyData in gotReplyArray{

                                                                if let actualReply = gotReplyData as? NSDictionary{
                                                                    let repliedUserData = actualReply.value(forKey: "user") as! NSObject
                                                                    let repliesData = actualReply.value(forKey: "reply") as! NSObject
                                                                    let replyId = actualReply.value(forKey: "replyId") as! String
                                                                            replyCounter+=1
                                                                            replyCount = replyCount + 1
                                                                            let replyUserId = actualReply.value(forKey: "userId") as! String
                                                                            let repliedUserImage : UIImage
                                                                            if (repliedUserData.value(forKey: "photo") != nil){
                                                                                let repliedUserImageUrl:URL = URL(string:repliedUserData.value(forKey: "photo") as! String)!
                                                                                let repliedUserImageData:NSData = NSData(contentsOf : repliedUserImageUrl)!
                                                                                repliedUserImage = UIImage(data:repliedUserImageData as Data)!
                                                                            }

                                                                            else{
                                                                                // TODO : Add default image of newzSlate here @Author subodh3344
                                                                                let repliedUserImageUrl:URL = URL(string:"https://firebasestorage.googleapis.com/v0/b/logos-app-915d7.appspot.com/o/images%2Fuser1.jpeg?alt=media&token=3dab8582-ccf9-43cd-8de9-ba9a88b2a7ff")!
                                                                                let repliedUserImageData:NSData = NSData(contentsOf : repliedUserImageUrl)!
                                                                                repliedUserImage = UIImage(data:repliedUserImageData as Data)!
                                                                            }
                                                                            var isEditable2 = false
                                                                            let loggedInUserData2 = UserDefaults.standard
                                                                            let loggedInUserId2 = loggedInUserData.string(forKey: "userId") as! String
                                                                            if(loggedInUserId2 == replyUserId){
                                                                                isEditable2 = true
                                                                            }


                                                                            guard let commentAsReply = commentData(
                                                                                commentId : replyId,
                                                                                authorId : replyUserId,
                                                                                authorName : repliedUserData.value(forKey: "name") as! String,
                                                                                authorImage  : repliedUserImage,
                                                                                authorEndorsment :repliedUserData.value(forKey: "highEndorsmentName") as! String,
                                                                                comment : repliesData.value(forKey: "comments") as! String,
                                                                                noOfReply : commentsDataObject.value(forKey: "noOfReplies") as! Int,
                                                                                opinion : 0,
                                                                                isReply : true,
                                                                                isEdited : (commentsDataObject.value(forKey: "isEdited") != nil),
                                                                                noOfAgrees: a,
                                                                                noOfDisagrees: b,
                                                                                noOfNeutrals: c,
                                                                                actualID: repliesData.value(forKey:"commentId") as! String,
                                                                                isEditable: isEditable2,
                                                                                timeAgo : actualReply.value(forKey: "timeago") as! String


                                                                                )
                                                                                else{
                                                                                    fatalError("Error in creating commentsAsReply")
                                                                            }
                                                                            print("adding reply in comment \(commentAsReply)");
                                                                            self.commentArray.append(commentAsReply)
                                                                          let commentIndex = self.commentArray.count - 1
                                                                                                            self.loadReplyOpinions(replyID: replyId) { (opinion) -> (Void) in
                                                                                                                             self.commentArray[commentIndex].noOfAgrees =  (opinion?.noOfAgrees)!
                                                                                                commentAsReply.noOfDisagrees = (opinion?.noOfDisagrees)!
                                                                                                                        commentAsReply.noOfNeutrals = (opinion?.noOfNeutrals)!
                                                                                                        self.commentsTable.reloadData()
                                                                                                                
                                                                                                                                        }
                                                                            if(replyCount == gotReplyArray.count){
                                                                                if(commentsCount == gotCommentsArray.count){
                                                                                    DispatchQueue.main.async {
                                                                                        self.commentsTable.reloadData()
                                                                     self.commentsHeight.constant = CGFloat(self.commentArray.count * 80)
                                                                                        self.commentsTable.layoutIfNeeded()
                                                                                        self.commentsHeight.constant = self.commentsTable.contentSize.height
                                                                                        print ("RELOADED without replies", self.commentsTable.contentSize.height)
                                                                                    }
                                                                                }
                                                                            }

                                   // this would be closing brace of the loadreplyopinions call
                                                                }

                                                            }
                                                        }
                                                    }
                                                }
                                                    // reply code is 0 i.e no reply found
                                                else{

                                                    var isEditable = false
                                                    let loggedInUserData = UserDefaults.standard
                                                    let loggedInUserId = loggedInUserData.string(forKey: "userId") as! String
                                                    if(loggedInUserId == commentsData.value(forKey: "userId") as! String){
                                                        isEditable = true
                                                    }
                                                    // push comments in aaray
                                                    guard let comment = commentData(
                                                        commentId : commentsData.value(forKey: "commentId") as! String,
                                                        authorId : commentsData.value(forKey: "userId") as! String,
                                                        authorName : commentsUserDataObject.value(forKey: "name") as! String,
                                                        authorImage  : userImage,
                                                        authorEndorsment : commentsUserDataObject.value(forKey : "highEndorsmentName") as! String,
                                                        comment : commentsDataObject.value(forKey: "comments") as! String,
                                                        noOfReply : commentsDataObject.value(forKey: "noOfReplies") as! Int,
                                                        opinion : commentsDataObject.value(forKey: "openion") as! Int,
                                                        isReply : false,
                                                        isEdited : commentIsEdited,
                                                        noOfAgrees: commentsDataObject.value(forKey: "noOfAgree") as! Int,
                                                        noOfDisagrees: commentsDataObject.value(forKey: "noOfDisAgree") as! Int,
                                                        noOfNeutrals: commentsDataObject.value(forKey: "noOfNeutral") as! Int,
                                                        actualID: commentId,
                                                        isEditable : isEditable,
                                                        timeAgo : commentsData.value(forKey: "timeago") as! String

                                                        )
                                                        else{
                                                            fatalError("Error in comments")
                                                    }
                                                    print("adding comment in without withour reply \(comment)");
                                                    self.commentArray.append(comment)
                                                    if(commentsCount == gotCommentsArray.count){
                                                        DispatchQueue.main.async {
                                                            self.commentsTable.reloadData()
                                                               self.commentsHeight.constant = CGFloat(self.commentArray.count * 80)
                                                            self.commentsTable.layoutIfNeeded()
                                                            self.commentsHeight.constant = self.commentsTable.contentSize.height
                                                            print ("RELOADED without replies", self.commentsTable.contentSize.height)
                                                        }
                                                    }


                                                }


                                            }// end do
                                            catch let replyErr as NSError{
                                                print("Failed to load replies : \(replyErr.localizedDescription)")
                                                DispatchQueue.main.async {
                                                    self.showToaster(msg: "Failed load replies..Try Again", type: 0)
                                                }
                                            }// ebd reply catch
                                        }
                                        getReplyTask.resume()
                                    }

                                }



                            }// end for
                        }//end if commentsDataArray

                    }// end dispatchQ

                }
            }catch let error as NSError {
                print("Failed load comments : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showToaster(msg: "Failed to load comments..Try Again", type: 0)
                }
            }

        }
        commentTask.resume()
    }


  @objc func showStatmentmap(id:String){
        print("in show map "+id);
        var newDataForView=mapOpions(newsId:id,mapType:1)

        //let vc = UIStoryboard.init(name:"Main",bundle:Bundle.main).instantiateViewController(withIdentifier: "OpinionMapViewController") as! OpinionMapViewController
        print("newDataForView \(newDataForView?.mapType)");
        ///vc.news = newDataForView
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        //self.navigationController?.popViewController(animated: true)
        // self.navigationController?.pushViewController(vc, animated: true)
        let mainTabController = storyboard?.instantiateViewController(withIdentifier:"OpinionMapViewController") as! OpinionMapViewController
        mainTabController.news = newDataForView
        present(mainTabController, animated: true, completion: nil)

    }
      typealias ReplyOpinionClosure = (Opinions?) -> Void
    func loadReplyOpinions(replyID : String ,completionHandler: @escaping ReplyOpinionClosure) {
        //var dict : [String:Int]?
        let replyOpinionQueue = DispatchQueue(label: "replyOpinion")
        var opinionCount = 0
        var noOfAgrees = 0
        var noOfDisagrees = 0
        var noOfNeutrals = 0
        var opinion = Opinions(noOfAgrees: 0, noOfDisagrees: 0, noOfNeutrals: 0)
        self.ref = Database.database().reference()
        //gets all of the opinions for a reply

        self.ref.child("commentopinion").queryOrdered(byChild: "commentId").queryEqual(toValue: replyID).observeSingleEvent(of: .value, with: { (newsCommentsSnap) in
            print ( "THIS NUM" , replyID, newsCommentsSnap.childrenCount)
            if(newsCommentsSnap.childrenCount != 0){
                for opinion in newsCommentsSnap.children{
                    opinionCount = opinionCount + 1

                        //print("comment  is \(comment)")
                        print ( "THIS NUM3" , replyID, newsCommentsSnap.childrenCount)
                        let snap = opinion as! DataSnapshot
                        let opinionDict = snap.value as! [String:Any]
                        let opinionId = snap.key
                        let replyOpinion = opinionDict["opinion"] as! Int
                        print(replyOpinion, replyID)
                        switch (replyOpinion) {
                        case 0 :
                            noOfNeutrals = noOfNeutrals + 1
                            print("neutraled", noOfNeutrals)
                        case 2 :
                            noOfDisagrees = noOfDisagrees + 1
                            print("neutraled2", noOfDisagrees)
                        default:
                            noOfAgrees = noOfAgrees + 1
                            print("neutraled3", noOfAgrees)
                    }
                }
                opinion.noOfDisagrees = noOfDisagrees
                           print("dis2", noOfDisagrees)
                opinion.noOfAgrees = noOfAgrees
                opinion.noOfNeutrals = noOfNeutrals

            }
            DispatchQueue.main.async() {
                 print("dis5", opinion.noOfDisagrees)
                completionHandler(opinion)
            }
        }) {
            (error) in
            print(error.localizedDescription) }
    }
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
    
    @IBAction func opinionStatsCancelled(_ sender: Any) {
        self.opinionStats.isHidden = true
        wantedLabel.backgroundColor = UIColor.clear
    }

    @IBAction func opinionStatsShowMap(_ sender: mapButton) {
        self.showStatmentmap(id:sender.statementID!)
        opinionStatsCancelled(self)
        

    }
    
    @objc func hideHighlighted(notification: NSNotification) {
        wantedLabel.backgroundColor = UIColor.clear
    }
    
    typealias StatementOpinionClosure = (Opinions) -> Void
    func loadStatementOpinions(statementID : String ,completionHandler: @escaping StatementOpinionClosure) {
        //var dict : [String:Int]?
        var opinionCount = 0
        var noOfAgrees = 0
        var noOfDisagrees = 0
        var noOfNeutrals = 0
        var opinion = Opinions(noOfAgrees: 0, noOfDisagrees: 0, noOfNeutrals: 0)
        self.ref = Database.database().reference()
        //gets all of the opinions for a reply
        self.ref.child("postcontentReactCoutDetails").queryOrdered(byChild: "postContentId").queryEqual(toValue: statementID).observeSingleEvent(of: .value, with: { (newsCommentsSnap) in
            if(newsCommentsSnap.childrenCount != 0){
                for opinion in newsCommentsSnap.children{
                    opinionCount = opinionCount + 1
                    //print("comment  is \(comment)")
                    let snap = opinion as! DataSnapshot
                    let opinionDict = snap.value as! [String:Any]
                    let opinionId = snap.key
                    noOfAgrees = opinionDict["agreeCount"] as! Int
                    noOfDisagrees = opinionDict["disagreeCount"] as! Int
                    noOfNeutrals = opinionDict["neutralCount"] as! Int

                }
                opinion.noOfDisagrees = noOfDisagrees
                opinion.noOfAgrees = noOfAgrees
                opinion.noOfNeutrals = noOfNeutrals
            }
            DispatchQueue.main.async() {
                completionHandler(opinion)
            }
        }) {
            (error) in
            print(error.localizedDescription) }
    }
    /*@objc func handleTapOnLabel(_ recognizer: longTapGesture1) {
     for news in newsArray {
     guard let text = self.newsContentBox.attributedText?.string else {
     return
     }
     let newsString = news.text
     if let range = text.range(of: NSLocalizedString(news.text, comment: news.text)),
     recognizer.didTapAttributedTextInLabel(label: self.newsContentBox, inRange: NSRange(range, in: text)) {
     print ( "THIS SI PRESS" , news.text , "WHY", range)

     }
     }
     } */

}
func scaleUIImageToSize( image: UIImage, size: CGSize) -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    image.draw(in: CGRect(origin: CGPoint.zero, size: size))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return scaledImage!
}

class labelGesture:UITapGestureRecognizer{
    var id = String()
    var color = Int()
    var percent =  Float()
}
class labelGesture1:UITapGestureRecognizer{
    var id = String()

}


class longTapGesture: UILongPressGestureRecognizer {
    var id = String()
    var color = Int()
    var percent =  Float()
}
class longTapGesture1:UILongPressGestureRecognizer{
    var id = String()

}
class mapOpions {
    var newsId = String()
    var mapType = Int()
    init?(newsId:String,mapType:Int){
        self.newsId = newsId
        self.mapType = mapType
    }
}
class editCommentButton:UIButton{
    var id = String ()
    var comment = String ()
    var opinion = Int()
}
func getLabelsInView(view: UILabel) -> [UILabel] {
    var results = [UILabel]()
    for subview in view.subviews as [UIView] {
        if let labelView = subview as? UILabel {
            results += [labelView]
        }
    }
    return results
}


class mapButton: UIButton {
    var statementID: String?
}

/*
 extension UILongPressGestureRecognizer {

 func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
 // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
 let layoutManager = NSLayoutManager()
 let textContainer = NSTextContainer(size: CGSize.zero)
 let textStorage = NSTextStorage(attributedString: label.attributedText!)

 // Configure layoutManager and textStorage
 layoutManager.addTextContainer(textContainer)
 textStorage.addLayoutManager(layoutManager)

 // Configure textContainer
 textContainer.lineFragmentPadding = 0.0
 textContainer.lineBreakMode = label.lineBreakMode
 textContainer.maximumNumberOfLines = label.numberOfLines
 let labelSize = label.bounds.size
 textContainer.size = labelSize

 // Find the tapped character location and compare it to the specified range
 let locationOfTouchInLabel = self.location(in: label)
 let textBoundingBox = layoutManager.usedRect(for: textContainer)
 let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
 (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
 let locationOfTouchInTextContainer = CGPointMake((locationOfTouchInLabel.x - textContainerOffset.x),
 0 );
 // Adjust for multiple lines of text
 let lineModifier = Int(ceil(locationOfTouchInLabel.y / label.font.lineHeight)) - 1
 let rightMostFirstLinePoint = CGPointMake(labelSize.width, 0)
 let charsPerLine = layoutManager.characterIndexForPoint(rightMostFirstLinePoint, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

 let indexOfCharacter = layoutManager.characterIndexForPoint(locationOfTouchInTextContainer, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
 let adjustedRange = indexOfCharacter + (lineModifier * charsPerLine)

 return NSLocationInRange(adjustedRange, targetRange)
 }

 }
 extension Range where Bound == String.Index {
 var nsRange:NSRange {
 return NSRange(location: self.lowerBound.encodedOffset,
 length: self.upperBound.encodedOffset -
 self.lowerBound.encodedOffset)
 }
 }
 */
