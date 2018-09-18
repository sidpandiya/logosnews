//
//  ReportInAppropriateViewController.swift
//  logos2
//
//  Created by Mansi on 31/07/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

class ReportInAppropriateViewController: UIViewController {

    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var feedbacktext: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func reportInappropriate(_ sender: Any) {
        if (self.feedbacktext.text?.isEmpty)!{
            self.showToaster(msg: "Please enter the value", type: 0)
        }
        else{
            let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/addFeedback")
            
            var request=URLRequest(url:url!)
            request.httpMethod="POST"
            let userId = UserDefaults.standard.object(forKey: "userId") as! String
            let data = [ "type":2,"userId":"\(userId)","desc":"\(self.feedbacktext.text!)" ] as[String : Any]
            print("json \(data)")
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                
                if (error != nil){
                    //self.userDetailsLoading.stopAnimating()
                    //self.userDetailsLoading.isHidden=true
                }
                
                let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                print("reposnString \(responseSting)")
                
                
                var error=NSError?.self
                
                do {
                    
                    if data != nil{
                        var jsonobj=JSON(data!)
                        let code=jsonobj["code"].int
                        print("code \(code)")
                        
                        if code==1{
                            DispatchQueue.main.async{
                                self.showToaster(msg: "Thank you!", type: 1)
                             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)){
                                      self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                        else{
                            DispatchQueue.main.async{
                                
                                self.showToaster(msg: "Error while Reporting as anappropriate ...", type: 0)
                            }
                            
                        }
                    }
                    else{
                        DispatchQueue.main.async{
                            
                            //self.showToaster(msg: "Error while adding language...", type: 0)
                        }
                    }
                    
                } catch let error as NSError {
                    
                    print("Failed to load: \(error.localizedDescription)")
                }
                
                
            }
            task.resume()
        }
        
    }
    //function to show toaster
    func showToaster(msg:String,type:Int){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
}
