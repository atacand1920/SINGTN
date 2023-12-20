//
//  InscriptionVC2.swift
//  SINGTN
//
//  Created by macbook on 2018-07-23.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
/**
 this class is responsible of the final step of registring.
 */
class InscriptionVC2 : UIViewController {
    @IBOutlet weak var first_name : UITextField!
    @IBOutlet weak var last_name : UITextField!
    @IBOutlet weak var birthday : UITextField!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
     let datePicker = UIDatePicker()
    /**
     repeat password
     */
    @IBOutlet weak var Rpassword: UITextField!
    /**
     the e-mail from the preview controller "InscriptionVC1".
     */
    var email = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        showDatePicker()
      
        //self.birthday
    }
    /*
     * open a date picker and initialize
     */
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
    
            datePicker.locale = NSLocale(localeIdentifier: "en_EN") as Locale
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelDatePicker))
            toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
     
        if birthday.text != "" {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            datePicker.date = formatter.date(from: birthday.text!)!
            
        }
        birthday.inputAccessoryView = toolbar
        birthday.inputView = datePicker
    }
    /**
     this is the cancel button in datePicker.
     */
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    /**
     this is the done button in datePicker.
     */
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        birthday.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    /**
     this the event action for registring.
     */
    @IBAction func registerAction(_ sender : UIButton) {
        if first_name.text != "" && last_name.text != "" && birthday.text != "" && username.text != "" && password.text != "" && Rpassword.text != "" {
            
            if password.text == Rpassword.text {
            SwiftSpinner.show("Registring...")
            let header : HTTPHeaders = ["Content-Type" : "application/json"]
            let params : Parameters = ["email" : email, "first_name" : first_name.text! , "last_name" : last_name.text!
                , "birthday" : birthday.text! , "username" : username.text! , "password" : password.text!
            ]
                Alamofire.request(ScriptBase.sharedInstance.register , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header).responseJSON { response in
                if response.error == nil {
                    SwiftSpinner.hide()
                    let b = JSON(response.data!)
                    print(b)
                    if b["status"].stringValue == "true" {
                        let alert = UIAlertController(title: "Register", message: "Welcome to SINGTN dear " + self.first_name.text! + "." , preferredStyle: .alert)
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "Awesome", style: UIAlertAction.Style.default,handler : { (_) -> Void in
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        
                        // show the alert
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                    }else{
                        let alert = UIAlertController(title: "Register", message: b["message"].stringValue , preferredStyle: .alert)
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : { (_) -> Void in
                           
                        }))
                        
                        // show the alert
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                    
                    
                }else{
                    SwiftSpinner.hide()
                    let alert = UIAlertController(title: "Register", message: "\(String(describing: response.error))" , preferredStyle: .alert)
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : { (_) -> Void in
                       
                    }))
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            
            }
            }else{
                let alert = UIAlertController(title: "Register", message: "Passwords dosen't match." , preferredStyle: .alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : { (_) -> Void in
                    
                }))
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
