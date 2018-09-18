//
//  NotificationTableViewController.swift
//  logos2
//
//  Created by Mansi on 23/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
    
    var notification=[Notification]()
    let cellIdentifier="NotificationTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSample()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notification.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as?
            NotificationTableViewCell else{
                fatalError("error")
        }
        
        // Configure the cell...
        let noti=notification[indexPath.row]
        cell.authorName.text=noti.name
        cell.authorImage.image=noti.photo
        cell.authorEndorsment.text=noti.endorsment
        cell.details.text=noti.details
        cell.time.text=noti.time
        return cell
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
    
    /*Notification list
     need to fetch from datbase
     */
    func loadSample(){
        let photo1=UIImage(named:"user1")
        let photo2=UIImage(named:"user2")
        let photo3=UIImage(named:"user3")
        
        guard let noti1=Notification(name:"Mansi",details:"test", time:"35m", endorsment:"History", photo:photo1!)else{
            fatalError("error")
        }
        guard let noti2=Notification(name:"Preeti",details:"Posted Article", time:"35m", endorsment:"History", photo:photo2!)else{
            fatalError("error")
        }
        guard let noti3=Notification(name:"Pooja",details:"Posted Media", time:"35m", endorsment:"History", photo:photo3!)else{
            fatalError("error")
        }
        guard let noti4=Notification(name:"Priya",details:"Subscribed to You", time:"35m", endorsment:"History", photo:photo1!)else{
            fatalError("error")
        }
        guard let noti5=Notification(name:"Raj",details:"Posted Post", time:"35m", endorsment:"History", photo:photo2!)else{
            fatalError("error")
        }
        
        guard let noti6=Notification(name:"Jay",details:"Posted Comment", time:"35m", endorsment:"History", photo:photo3!)else{
            fatalError("error")
        }
        guard let noti7=Notification(name:"Pruthvi",details:"Posted Article", time:"35m", endorsment:"History", photo:photo1!)else{
            fatalError("error")
        }
        
        notification += [noti1,noti2,noti3,noti4,noti5,noti7]
    }
    /*Function to show pop up on click of notification */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        print("in didselected indexPath \(indexPath)")
        let currentCell=tableView.cellForRow(at: indexPath!)as! NotificationTableViewCell
        print("in didselected indexPath \(indexPath)")
    
        let authorName = currentCell.authorName?.text
        let details=currentCell.details?.text
        let msg=authorName! + " " + details!
        print("in didselected function \(msg)")
        let alertController = UIAlertController(title: "Notification", message: msg , preferredStyle: .alert)
         
         let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
         alertController.addAction(defaultAction)
         present(alertController, animated: true, completion: nil)
        
    }
    
}

