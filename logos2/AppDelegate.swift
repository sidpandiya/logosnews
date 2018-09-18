//
//  AppDelegate.swift
//  logos2
//
//  Created by Mansi on 16/04/18.
//  Copyright © 2018 subodh. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import Fabric
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,CLLocationManagerDelegate{
    
    var window: UIWindow?
    var lat = Double()
    var long = Double()
    var locationManager:CLLocationManager!
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // FCM configuration
        // [START set_messaging_delegate]
        
        Messaging.messaging().delegate = self as! MessagingDelegate
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    
        GIDSignIn.sharedInstance().clientID=FirebaseApp.app()?.options.clientID
        GMSServices.provideAPIKey("AIzaSyBR1AiGZT4RyEkj9Cdb2zUWZK34aDqg4Sc")
        GMSPlacesClient.provideAPIKey("AIzaSyB4_TkPJgLeAtrJeQ3K9ZFDRNgaydrRUWA")
        
        // facebook login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
      ///  Fabric.sharedSDK().debug = true
        
        let userData = UserDefaults.standard
        
        if(userData.object(forKey: "isLoggedIn") != nil){
            var userIsLoggedIn = userData.object(forKey: "isLoggedIn") as! Bool
            print("userLoggedIn is **********\(userIsLoggedIn)")
            if (userIsLoggedIn) {
                // user is logged in
                // redirect user to main feed
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainTabController")
                window?.makeKeyAndVisible()
            }
            else{
                // got key but user is not logged in
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                window?.makeKeyAndVisible()
            }
        }
        else{
            //got nil so user is not logged in
            // add facebook button on view
            var user = Auth.auth().currentUser   // to check if user is logged in using social login
//            print("user after auth is **********\(user)")
//            print ("user id \(user?.email)")
//            print ("user name \(user?.displayName)")
//            
//            print ("user phone number \(user?.phoneNumber)")
//            print ("user photo \(user?.photoURL)")
//            print("user \(user?.description)")
//            print("user \(user?.uid)")
            
            if(user != nil){
                var email=user?.email as! String
                var userId=user?.uid as! String
                var userData2 = UserDefaults.standard
                if(userData2.object(forKey: "userId") != nil){
                    // user is logged in
                    print("sending to main tab")
                    userData.set(true, forKey: "isLoggedIn")
                    window = UIWindow(frame: UIScreen.main.bounds)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainTabController")
                    window?.makeKeyAndVisible()
                }
                else{
                    locationManager = CLLocationManager()
                    // got user id .. fetch user info from db
                    let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/CheckUserAlreadyPresent")
                    var request=URLRequest(url:url!)
                    request.httpMethod="POST"
                    let json = ["socialId":userId,"email":email] as [String : Any]
                    print("json \(json)")
                    let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    request.httpBody = jsonData
                    
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                        
                        if (error != nil){
                            print("error while get user appdelegate \(error)")
                        }
                        
                        let responseSting = NSString(data:data!,encoding:String.Encoding.utf8.rawValue)
                        //print("reposnString \(responseSting)")
                        
                        //parese json
                        var error=NSError?.self
                        // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                            print("sral 1 \(json)")
                            let code = json["code"] as? Int
                            
                            print("names \(code)")
                            if code == 1 {
                                DispatchQueue.main.async () {
                                    self.window = UIWindow(frame: UIScreen.main.bounds)
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                                    self.window?.makeKeyAndVisible()
                                    
                                }
                                
                            }
                            else if code == 2{
                                var  userId = json["userId"] as? String
                                var userData=json["userData"] as? NSDictionary
                                DispatchQueue.main.async () {
                                    //set user details in local storage
                                    let user = UserDefaults.standard
                                    user.set(userId, forKey: "userId")
                                    user.set(userData?.value(forKey: "name"), forKey: "userName")
                                    user.set(userData?.value(forKey: "email"), forKey: "userEmail")
                                    user.set(userData?.value(forKey: "latitude"), forKey: "userLatitude")
                                    user.set(userData?.value(forKey: "longitude"), forKey: "userLongitude")
                                    user.set(userData?.value(forKey: "contact"), forKey: "userContact")
                                    user.set(userData?.value(forKey: "isNormalUser"), forKey: "userType")
                                    user.set(userData?.value(forKey: "photo"), forKey: "userPhoto")
                                    user.set(self.lat, forKey: "currentLatitude")
                                    user.set(self.long, forKey: "currentLongitude")
                                    user.set(true, forKey: "isLoggedIn")
                                    
                                    // redirect to main tab
                                    
                                    
                                    
                                }
                                self.window = UIWindow(frame: UIScreen.main.bounds)
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainTabController")
                                self.window?.makeKeyAndVisible()
                            }
                            
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                        
                        
                    }
                    task.resume()
                }
                
            }
            else{
                print("got nil user data")
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                window?.makeKeyAndVisible()
            }
        }
        
        return true
    }
    
    // to load lat long
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        var latitude=userLocation.coordinate.latitude
        var longitude=userLocation.coordinate.longitude
        self.lat=userLocation.coordinate.latitude
        self.long=userLocation.coordinate.longitude
        
        }
    
    
    
    func application(_ application: UIApplication,open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let gsdk = GIDSignIn.sharedInstance().handle(url,sourceApplication: sourceApplication,annotation: annotation)
        let fbSdk = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return gsdk || fbSdk
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        let gSdk = GIDSignIn.sharedInstance().handle(url,sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        let fSdk = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return gSdk || fSdk
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    /*@author Mansi 27.04.2018
     Function to authentication using google
     */
    
  
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 3333: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 454 : \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
    
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)
        
        
        
        
        /* let tabBar:UITabBarController = self.window?.rootViewController as! UITabBarController
         let navInTab:UINavigationController = tabBar.viewControllers?[2] as! newNotificationController
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let destinationViewController = storyboard.instantiateViewController(withIdentifier: "newNotificationController") as? newNotificationController
         navInTab.pushViewController(destinationViewController!, animated: true)*/
        
        completionHandler()
    }
}
// [END ios_10_message_handling]
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        /*Add this token in localstorage*/
        var userData = UserDefaults.standard
        userData.set(fcmToken, forKey: "userAPNToken")
        //check fcm token
          var uData = UserDefaults.standard
        var APNToken = uData.object(forKey: "userAPNToken")
        print("APNToken is \(APNToken)")
        // check if user is logged in if yes then update APNToken in db
        if(userData.object(forKey: "isLoggedIn") != nil){
            var userLoggedIn = userData.object(forKey: "isLoggedIn") as! Bool
            if(userLoggedIn){
                if userData.object(forKey: "userId") != nil {
                    var userId = userData.object(forKey: "userId")
                    let url=URL(string:"https://us-central1-logos-app-915d7.cloudfunctions.net/setFirebaseToken")
                    var request=URLRequest(url:url!)
                    request.httpMethod="POST"
                    let json = ["userId":userId as! String,"token":fcmToken] as [String : Any]
                    print("json \(json)")
                    let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    request.httpBody = jsonData
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let task=URLSession.shared.dataTask(with: request){(data:Data?,response:URLResponse?,error:Error?) in
                        if (error != nil){
                            print("error APN key update \(error)")
                        }
                        var error=NSError?.self
                        // var json=try JSONSerialization.data(withJSONObject: data, options: [])as? [String:Any]
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                            print("sral 1 \(json)")
                            let code = json["code"] as? Int
                            let msg = json["msg"] as? String
                            print("Update APNYoken code \(code) : status \(msg)")
                            
                        } catch let error as NSError {
                            print("Failed to load update APNKey: \(error.localizedDescription)")
                        }
                    }
                    task.resume()
                }
                
                
            }
            else{
                print("user is not logged in in didreciveRegToken")
            }
        }
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}






