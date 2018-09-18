//
//  NewsViewController.swift
//  logos2
//
//  Created by subodh-mac on 23/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import Firebase
class NewsViewController: UIViewController {

    @IBOutlet weak var showMapButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var getLRCount: UISlider!
    @IBOutlet weak var disagreeButton: UIButton!
    @IBOutlet weak var neutrallButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var showLRCount: UISlider!
    @IBOutlet weak var noOfDisagree: UILabel!
    @IBOutlet weak var noOfAgree: UILabel!
    // @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var noOfViews: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userEnorsement: UILabel!
    @IBOutlet weak var userProfile: UIImageView!
    //@IBOutlet weak var uploadPhoto: UIButton!
    var newsData = (gotNewsId:"1",gotNewsTitle:"test")
    let storage = Storage.storage()
    var id=0
    override func viewDidLoad() {
        print("id  in newsViewController is\(newsData.gotNewsId)")
        agreeButton.backgroundColor=UIColor.blue
        disagreeButton.backgroundColor=UIColor.white
        neutrallButton.backgroundColor=UIColor.white
       loadData()
         //let getMainViewX = mainView.frame.origin.x
      
       
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   /*// @IBAction func addPhoto(_ sender: Any) {
        var imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // var imagePicker = UIImagePickerController()
            //imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    /*1.Choose image from image librabry
      2. Upload it on firebase Storage
      3.Show image preview in image controller
     **need to test on real devices
     @author Mansi
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("in on click function")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
         print("data \(image)")
        let storageRef = storage.reference()
        var data=Data()
        data=UIImagePNGRepresentation(image)!
       
        var imageRef=storageRef.child("images/star")
        _=imageRef.putData(data, metadata: nil, completion: {(metadata,error)in
            guard let metadata=metadata else{
                print("error : \(error)")
                return
            }
            let dowloadURL=metadata.downloadURL()
            self.imagePreview.image=UIImage(named:(dowloadURL?.absoluteString)!)
            print("downloadURL \(dowloadURL)")
            
            let url2 = URL(string: (dowloadURL?.absoluteString)!)  //postPhoto URL
            let data = NSData(contentsOf: url2! ) // this URL convert into Data
            if data != nil {  //Some time Data value will be nil so we need to validate such things
                self.imagePreview.image = UIImage(data: data as! Data)
            }
            
            
            
        })
    }*/
   
  
    func loadData(){
        
        let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/getNewsById?key=\(newsData.gotNewsId)")
        var request=URLRequest(url:url!)
        request.httpMethod="GET"
        
        let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
            if (error != nil){
                print("error \(error)")
                DispatchQueue.main.async () {
                   // self.loading.stopAnimating()
                }
                
            }
            
            //   var error=NSError?.self
            do {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    if(jsonObj != nil){
                        let code=jsonObj!.value(forKey: "code")
                        print("code of newsData \(code)")
                        // print(jsonObj!.value(forKey: "data")!)
                        //  self.newsData.removeAll();
                        if let newsData = jsonObj!.value(forKey: "data") as? NSDictionary {
                            let newsLRCount = newsData.value(forKey: "newsLRCount") as? NSNumber
                          
                            let newsAgreeCount = newsData.value(forKey: "agreeCount") as? NSNumber
                           //   self.noOfAgree.text=newsAgreeCount
                            let newsDisagreeCount =  newsData.value(forKey: "disagreeCount") as? NSNumber
                            let newsNutralCount = newsData.value(forKey: "nuetralCount") as? NSNumber
                           
                            let newsDict = newsData.value(forKey:"newsDetails") as? NSDictionary
                            
                        }
                    }
                    else{
                   //     self.loading.stopAnimating()
                        print("empty json ")
                    }
                    
                }
                
                
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            
        }
        task.resume()
        
        
        
        
        
        
        ////add labels Dynamically
         let getMainViewX=self.mainView.frame.origin.x
        var messages=[1,2,3,4,5]
        for msg in messages
        {
            //let label = UILabel(frame: CGRectMake(getMainViewX, getMainViewY, 200, 21))
            let label = UILabel(frame:CGRect(x:getMainViewX,y:CGFloat(msg)*21,width:200,height:21))
            // (frame: CGRect(getMainViewX, CGFloat(msg) * 21, 200, 21))
            //label.center = CGPointMake(160, 284)
            label.textAlignment = NSTextAlignment.center
            label.text = "I'am a test label"
            label.isUserInteractionEnabled=true
        
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
            label.addGestureRecognizer(tap)
            //label.Target(self, action: #selector(hitForLike(_:)), for: UIControlEvents.touchUpInside)
            self.mainView.addSubview(label)
            //getMainViewX+=20
            
           /* let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector(("handleTap")))
            label.addGestureRecognizer(gestureRecognizer)*/
            
        }
        
    
    }
    @objc func showDatePicker(){
        print("testing")
    }
}
