//
//  OpinionAlertController.swift
//  logos2
//
//  Created by SHIRLY Fang on 9/4/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import Firebase

class OpinionAlertController : UIViewController {
    let agreeColor = hexStringToUIColor(hex: "009688")
    let neutralColor = hexStringToUIColor(hex:"#5AC8FA" )
    let disagreeColor = hexStringToUIColor(hex:"#C6453B" )
    @IBOutlet weak var opinionStats: UIView!
    
    @IBOutlet weak var opinionStatsCancel: UIButton!
    @IBOutlet weak var opinionStatsMap: mapButton!
    
    @IBOutlet weak var opinionStatsNeutral: UILabel!
    @IBOutlet weak var opinionStatsDisagree: UILabel!
    @IBOutlet weak var opinionStatsAgree: UILabel!
    var id = String()
    var ref:DatabaseReference!
    override func viewDidLoad() {
        self.opinionStats.layer.masksToBounds = false
        self.opinionStats.layer.cornerRadius = 7
        self.opinionStats.layer.borderWidth = 0.2
        self.opinionStats.layer.borderColor = UIColor.lightGray.cgColor
        self.opinionStats.layer.shadowRadius = 10
        self.opinionStats.layer.shadowOpacity = 0.3
        self.opinionStatsAgree.textColor = agreeColor
        self.opinionStatsDisagree.textColor = disagreeColor
        self.opinionStatsNeutral.textColor = neutralColor
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
            self.opinionStatsMap.statementID = self.id
            
        }
    }
    override func viewDidLayoutSubviews() {
         self.opinionStats.addshadow(top: false, left: true, bottom: true, right: true)
    }
    @IBAction func opinionStatsCancelled(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideHighlight"), object: nil)
    }
    
    @IBAction func opinionStatsShowMap(_ sender: mapButton) {
        self.showStatmentmap(id:id)
        
        
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
    
    
}
