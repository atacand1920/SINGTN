//
//  LoginController.swift
//  SINGTN
//
//  Created by macbook on 2018-06-28.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import OneSignal
import SwiftyJSON
import SwiftSpinner
import FBSDKLoginKit
import GoogleSignIn
class LoginController : UIViewController, OSSubscriptionObserver,GIDSignInDelegate,GIDSignInUIDelegate {
   
    
    @IBOutlet weak var SignUP: UIButton!
    @IBOutlet weak var username : UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var facebookLog : UIImageView!
    @IBOutlet weak var googleLog : UIImageView!
      var dict : [String : AnyObject]!
    override func viewDidLoad() {
        super.viewDidLoad()
        let yourAttributes : [NSAttributedString.Key  : Any] = [
            kCTFontAttributeName as NSAttributedString.Key : UIFont.systemFont(ofSize: 15),
            kCTForegroundColorAttributeName as NSAttributedString.Key  : UIColor.white,
            kCTUnderlineStyleAttributeName as NSAttributedString.Key  : NSUnderlineStyle.single.rawValue]
        let attributedString = NSMutableAttributedString(string: "Signup here!", attributes: yourAttributes)
        SignUP.setAttributedTitle(attributedString, for: .normal)
        if isKeyPresentInUserDefaults(key: "User") {
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "tabar"))!, animated: true)
        }
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(self.facebookLogin(_:)))
        tapgesture.numberOfTapsRequired = 1
        facebookLog.isUserInteractionEnabled = true
        facebookLog.addGestureRecognizer(tapgesture)
         let tapgestureG = UITapGestureRecognizer(target: self, action: #selector(self.googleLogin(_:)))
        tapgestureG.numberOfTapsRequired = 1
        googleLog.isUserInteractionEnabled = true
        googleLog.addGestureRecognizer(tapgestureG)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "752124266013-dgffgh7s101rbp5b6qdjk830q6h7eu80.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        
    }
    @objc func googleLogin(_ sender: UIImageView) {
        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user != nil {
        
            let params: Parameters = [
                "googleID": user.userID,
                "Last_name" : user.profile.familyName ,
                "First_name" : user.profile.givenName ,
                "email" : user.profile.email ,
                "image_src" : user.profile.imageURL(withDimension: 400).absoluteString,
                "username" : user.userID + "_" + user.profile.familyName,
                "password" : String(arc4random())
            ]
            let header: HTTPHeaders = [
                "Content-Type" : "application/json"
            ]
            print(params)
            Alamofire.request(ScriptBase.sharedInstance.googleLogReg, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
                SwiftSpinner.hide()
                let b = JSON(response.data)
                
                if b["status"].stringValue == "true" {
                    UserDefaults.standard.setValue(b["data"].rawString(), forKey: "User")
                    UserDefaults.standard.synchronize()
                    if b["data"]["pushEnabled"].description == "null" {
                        self.ConnectTopush();
                    }else{
                        if b["data"]["pushEnabled"].stringValue == "1"{
                            self.ConnectTopush()
                        }else{
                            OneSignal.setSubscription(false)
                        }
                    }
                    self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "tabar"))!, animated: true)
                }else{
                    let alert = UIAlertController(title: "Sign In", message: b["message"].stringValue, preferredStyle: .alert)
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : nil))
                    
                    // show the alert
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }else{
                SwiftSpinner.hide()
        }
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
       
        SwiftSpinner.show("Retrieving...")
    }
    @objc func facebookLogin(_ sender: UIImageView) {
         let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
       
        if FBSDKAccessToken.current() == nil {
            fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self){
                (result,error) in
                if error == nil {
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil {
                        if fbloginresult.grantedPermissions.contains("email") {
                            self.getFBUserData()
                        }
                    }
                }
            }
        }else{
            self.getFBUserData()
        }
    }
    func getFBUserData(){
        SwiftSpinner.show("Sync...")
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email " ])?.start(completionHandler: { (connection, result, error) -> Void in
                if error == nil {
                    let q = JSON(result as Any)
                    print(q)
                    let params: Parameters = [
                        "facebookId": q["id"].stringValue,
                        "Last_name" : q["last_name"].stringValue ,
                        "First_name" : q["first_name"].stringValue ,
                        "email" : q["email"].stringValue ,
                        "image_src" : q["picture"]["data"]["url"].stringValue,
                        "username" : q["name"].stringValue,
                        "password" : String(arc4random())
                    ]
                    let header: HTTPHeaders = [
                        "Content-Type" : "application/json"
                    ]
                    print(params)
                    Alamofire.request(ScriptBase.sharedInstance.facebookLogReg, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
                        SwiftSpinner.hide()
                        let b = JSON(response.data)
                        
                        if b["status"].stringValue == "true" {
                            UserDefaults.standard.setValue(b["data"].rawString(), forKey: "User")
                            UserDefaults.standard.synchronize()
                            if b["data"]["pushEnabled"].description == "null" {
                                self.ConnectTopush();
                            }else{
                                if b["data"]["pushEnabled"].stringValue == "1"{
                                    self.ConnectTopush()
                                }else{
                                    OneSignal.setSubscription(false)
                                }
                            }
                            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "tabar"))!, animated: true)
                        }else{
                            let alert = UIAlertController(title: "Sign In", message: b["message"].stringValue, preferredStyle: .alert)
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : nil))
                            
                            // show the alert
                            DispatchQueue.main.async(execute: {
                                self.present(alert, animated: true, completion: nil)
                            })
                        }
                    }
                }
            })
            
        }
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    @IBAction func SignIn(_ button: UIButton) {
        if username.text != "" && password.text != "" {
            SwiftSpinner.show("Connecting...")
            let header : HTTPHeaders = ["Content-Type" : "application/json"]
            let params : Parameters = ["username" : username.text! , "password" : password.text!]
           Alamofire.request(ScriptBase.sharedInstance.login , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header).responseJSON { response in
            SwiftSpinner.hide()
            if response.error == nil {
            let b = JSON(response.data!)
            
            print(b)
            if b["status"].stringValue == "true" {
                 UserDefaults.standard.setValue(b["data"].rawString(), forKey: "User")
                UserDefaults.standard.synchronize()
                if b["data"]["pushEnabled"].description == "null" {
                self.ConnectTopush();
                }else{
                    if b["data"]["pushEnabled"].stringValue == "1"{
                        self.ConnectTopush()
                    }else{
                        OneSignal.setSubscription(false)
                    }
                }
                self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "tabar"))!, animated: true)
            }else{
                let alert = UIAlertController(title: "Sign In", message: b["message"].stringValue, preferredStyle: .alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : nil))
                
                // show the alert
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
            }else{
                
                let alert = UIAlertController(title: "Sign In", message: "An unkown error occured", preferredStyle: .alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : nil))
                
                // show the alert
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
            
            }
            SwiftSpinner.hide()
                    
            }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
    if !stateChanges.from.subscribed && stateChanges.to.subscribed {
    print("Subscribed for OneSignal push notifications!")
    // get player ID
    print("userId:" ,  stateChanges.to.userId)
    if stateChanges.to.userId != nil {
    let ab = UserDefaults.standard.value(forKey: "User") as! String
    let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
    do {
            let a = try JSON(data: dataFromString!)
    let params : Parameters = [
    "user_id" : a["id"].stringValue ,
    "ios" : stateChanges.to.userId
    ]
    let header: HTTPHeaders = [
    "Content-Type" : "application/json"

    ]
    Alamofire.request(ScriptBase.sharedInstance.setIosPlayerId , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header)
    .responseJSON { response in
    //      LoaderAlert.shared.dismiss()
    
    let b = JSON(response.data!)
    print(b)
        UserDefaults.standard.setValue(b["data"].rawString(), forKey: "User")
        UserDefaults.standard.synchronize()
    
    }
    //  else {
    //      _ = SweetAlert().showAlert("Conexion", subTitle: "Veuillez vous connecter", style: AlertStyle.error)
    //}
    }catch{
        
        }
    }
        
    }
   
    
    }
    func ConnectTopush(){
        
        OneSignal.add(self as OSSubscriptionObserver)
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.setSubscription(false)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            OneSignal.setSubscription(true)
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            print("userID = \(userID)")
            let pushToken = status.subscriptionStatus.pushToken
            print("pushToken = \(pushToken)")
        })
        
    }
}
