//
//  InscriptionVC.swift
//  SINGTN
//
//  Created by macbook on 2018-05-16.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
/**
 this class is responsible of the first step of registring.
 */
class InscriptionVC1 : UIViewController {
    @IBOutlet weak var email : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       //self.navigationController?.isNavigationBarHidden = false
    }
    /**
     this function verify the availability of the input e-mail.
     */
    @IBAction func verifyAction (_ sender : UIButton) {
        if email.text != "" {
            let header : HTTPHeaders = ["Content-Type" : "application/json"]
            let params : Parameters = ["email" : email.text!]
            Alamofire.request(ScriptBase.sharedInstance.verifyemail , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header).responseJSON { response in
                if response.error == nil {
                     let b = JSON(response.data!)
                      if b["status"].stringValue == "true" {
                        if b["message"].stringValue == "go on" {
                            /// go next
                           let controller = self.storyboard?.instantiateViewController(withIdentifier: "insc2") as! InscriptionVC2
                            controller.email = self.email.text!
                            self.navigationController?.pushViewController(controller, animated: true)
                        }else{
                            // alert already exist
                            let alert = UIAlertController(title: "Register", message: b["message"].stringValue, preferredStyle: .alert)
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : { (_) -> Void in
                                self.email.text = ""
                            }))
                            
                            // show the alert
                            DispatchQueue.main.async(execute: {
                                self.present(alert, animated: true, completion: nil)
                            })
                        }
                    }
        }
            }
        }
    }
    /**
     the event action of back
     */
    @IBAction func roolBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    
}
