//
//  DescriptionProfilTouch.swift
//  SINGTN
//
//  Created by macbook on 2018-09-17.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import VideoToolbox
import DKImagePickerController
class DescriptionProfilTouch : UITableViewController,UITextViewDelegate {
  
    @IBOutlet weak var table : UITableView!
    @IBOutlet weak var FirstNameCell : UITableViewCell!
    @IBOutlet weak var LastNameCell : UITableViewCell!
    @IBOutlet weak var PictureCell : UITableViewCell!
    @IBOutlet weak var DescriptionCell : UITableViewCell!
    @IBOutlet weak var navigationItemCustom : UINavigationItem!
      var state = 0
    var tabbar : UITabBarController? = nil
    var pictureTemp = ""
    var id_user = ""
    @IBOutlet weak var popup: UIView!

    var oldText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        self.tableView.backgroundColor = UIColor(red:  243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.changeState))
        self.navigationItemCustom.rightBarButtonItem = done
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(NothingAction))
      self.navigationItemCustom.leftBarButtonItem = cancel
       
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
            let desc = DescriptionCell.viewWithTag(1) as! UITextView
            
            if a["description"].description == "null" {
                desc.text = "écris quelques lignes personnels qui vous décrit..."
                desc.textColor = UIColor.lightGray
            }else {
                desc.text = a["description"].stringValue
                desc.textColor = UIColor.black
            }
            desc.delegate = self
            self.id_user = a["id"].stringValue
            let FirstName = FirstNameCell.viewWithTag(1) as! UITextField
            FirstName.text = a["First_name"].stringValue
            let LastName = LastNameCell.viewWithTag(1) as! UITextField
            LastName.text = a["Last_name"].stringValue
            let pictureView = PictureCell.viewWithTag(1) as! UIImageView
            pictureView.setImage(with: URL(string: a["image_src"].stringValue), placeholder: nil, transformer: nil, progress: nil, completion: nil)
            pictureTemp = a["image_src"].stringValue
            let changePicture = PictureCell.viewWithTag(2) as! UIButton
            changePicture.addTarget(self, action: #selector(self.ChangePictureAction(_:)), for: .touchUpInside)
            
            
        }catch{
            
        }
       
        
        
        
    }
    @objc func ChangePictureAction(_ button: UIButton) {
        let pickerController = DKImagePickerController()
        pickerController.singleSelect = true
        pickerController.autoCloseOnSingleSelect = false
        pickerController.maxSelectableCount = 1
        pickerController.assetType = .allPhotos
        pickerController.allowMultipleTypes = false
        pickerController.allowsLandscape = false
        pickerController.showsCancelButton = true
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("DIDSELECTASSETS")
            print(assets.count)
            let imageview = (self.PictureCell.viewWithTag(1) as! UIImageView)
            
            let asset = assets.first
            asset?.fetchOriginalImage(completeBlock: { (image, info) in
                imageview.image = image
                self.uploadToServer()
            })
           

           
        }
        pickerController.didCancel = {
            print("DIDCANCEL")
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    func uploadToServer(){
        SwiftSpinner.show("Uploading Picture...")
        let boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW"
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        
        let filename = "Picture.jpg"
        
        let mimeType = "image/jpeg"
        
        let fieldName = "userfile"
        let uploadScriptUrl = URL(string:ScriptBase.sharedInstance.uploadViaPost)
        let fileData : Data? = (self.PictureCell.viewWithTag(1) as! UIImageView).image!.jpegData(compressionQuality: 1)
       
    
        let requestBodyData : NSMutableData = NSMutableData()
        requestBodyData.append(("--\(boundaryConstant)\r\n").data(using: String.Encoding.utf8)!)
        
        requestBodyData.append(( "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n").data(using: String.Encoding.utf8)!)
        requestBodyData.append(( "Content-Type: \(mimeType)\r\n\r\n").data(using: String.Encoding.utf8)!)
        //dataString += String(contentsOfFile: SongToSave.path, encoding: NSUTF8StringEncoding, error: &error)!
        requestBodyData.append(fileData!)
        // dataString += try! String(contentsOfFile: SongToSave.path, encoding: String.Encoding.utf8)
        requestBodyData.append(("\r\n").data(using: String.Encoding.utf8)!)
        requestBodyData.append(("--\(boundaryConstant)--\r\n").data(using: String.Encoding.utf8)!)
        var request = URLRequest(url: uploadScriptUrl!)
        
        
        request.httpMethod = "POST"
        request.httpBody = requestBodyData as Data
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
       
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            // You can print out response object
            print("******* response = \(String(describing: response))")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
             SwiftSpinner.hide()
            
               
            let a = JSON(data!)
            if a["url"].exists() {
                if a["error"].boolValue == false {
                self.pictureTemp = a["url"].stringValue
            print(self.pictureTemp)
                }
            }
                
            
        }
        
        task.resume()
    }
    @objc func NothingAction(){
     self.dismiss(animated: true, completion: nil)
    }
    @objc func DissmissAction(){
        print("yes")
        
      
            self.changeState()
        
        
        self.dismiss(animated: true, completion: nil)
    }
    @objc func changeState(){
        SwiftSpinner.show("Applying new changes...")
        
        
        let params : Parameters = [
            "id_user" : self.id_user,
            "First_name" : (FirstNameCell.viewWithTag(1) as! UITextField).text!,
            "Last_name" : (LastNameCell.viewWithTag(1) as! UITextField).text!,
            "image_src" : self.pictureTemp,
            "description" : (DescriptionCell.viewWithTag(1) as! UITextView).text
        ]
        
        Alamofire.request(ScriptBase.sharedInstance.changeInfoUser, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            let b = JSON(response.data)
            UserDefaults.standard.setValue(b["data"].rawString(), forKey: "User")
            UserDefaults.standard.synchronize()
            
            SwiftSpinner.hide()
            self.dismiss(animated: true, completion: nil)
            
            
            
        }
        
        
        
        
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "écris quelques lignes personnels qui vous décrit..." {
            textView.text = ""
            textView.textColor = UIColor.black
            
        }
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "écris quelques lignes personnels qui vous décrit..."
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func exitAction(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
  /*  func saveChanges(){
        SwiftSpinner.show("Applying changes...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
            let params: Parameters = [
                "id_user" : a["id"].stringValue,
                "description" : self.desc.text
            ]
            Alamofire.request(ScriptBase.sharedInstance.changedescriptionUser , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    SwiftSpinner.hide()
                    //print(response.data)
                    let q = JSON(response.data)
                    print(q)
                    if q["status"].stringValue == "true" {
                          UserDefaults.standard.setValue(q["data"].rawString(), forKey: "User")
                        UserDefaults.standard.synchronize()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    
            }
            
            
            
        }catch {
            print(error)
        }
    } */

}
