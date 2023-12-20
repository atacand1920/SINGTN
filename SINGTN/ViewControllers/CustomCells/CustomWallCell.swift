//
//  CustomWallCell.swift
//  SINGTN
//
//  Created by macbook on 2018-06-21.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
class CustomWallCell : UITableViewCell {
    @IBOutlet weak var imageV : UIView!
    @IBOutlet weak var HeartStroke : CustomImage!
     @IBOutlet weak var Comment : UIView!
    @IBOutlet weak var Share : UIView!
    
    @IBOutlet weak var FirstSingerImg: UIImageView!
    @IBOutlet weak var FirstSingerLBL: UILabel!
    @IBOutlet weak var SecondSingerImg: UIImageView!
    @IBOutlet weak var BackgroundImg: UIImageView!
  
    @IBOutlet weak var SecondSingerLBL: UILabel!
    @IBOutlet weak var and: UILabel!
    var index = 0
    var id_like : Int = -1
    var id_pub : Int = -1
    var Dwait = true
    var CellType = ""
    let CommentPush        = NSNotification.Name(rawValue:"CommentPush")
     let CommentPushPublic        = NSNotification.Name(rawValue:"CommentPushPublic")
    @IBOutlet weak var song_title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageV.isUserInteractionEnabled = true
        imageV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:))))
        
        Comment.isUserInteractionEnabled = true
        Comment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CommentTapped(sender:))))
        
        Share.isUserInteractionEnabled = true
        Share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShareTapped(sender:))))
        
        FirstSingerLBL.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
         SecondSingerLBL.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        FirstSingerImg.image = UIImage(named: "profilSaif")
        SecondSingerImg.image = UIImage(named: "profilSaif")
    }
    
     @objc func ShareTapped(sender: UITapGestureRecognizer) {
        SwiftSpinner.show("Sharing...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            
  
              let params : Parameters = [
                    "id_user" : a["id"].stringValue,
                    "id_publication" : self.id_pub
                ]
            
            
            Alamofire.request( ScriptBase.sharedInstance.SharePublication , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    SwiftSpinner.hide()
                    //print(response.data)
                    
                    let q = JSON(response.data)
                   
                    if q["status"].stringValue == "true" {
                        SwiftNotice.noticeOnStatusBar("The publication has been shared with your friends", autoClear: true, autoClearTime: 3)
                       
                        
                    }
                    //print(q)
                    
                    
                    
            }
            
            
            
        }catch{
            Dwait = true
        }
    }
    @objc func CommentTapped(sender: UITapGestureRecognizer) {
   // print("will work soon")
        if CellType == "Friends" {
        NotificationCenter.default.post(name: CommentPush, object: index)
        }else{
            NotificationCenter.default.post(name: CommentPushPublic, object: index)
        }
    }
    @objc func imgTapped(sender: UITapGestureRecognizer) {
        // change data model blah-blah
       
        if self.HeartStroke.test == 0 {
            
            if Dwait {
            self.HeartStroke.test = 1
            
            HeartStroke.image = UIImage(named: "like_red")
            
            Add_Remove_Like(AR: true, pub_id: id_pub, id_like: id_like)
      
            }
            
        } else {
            if Dwait {
            self.HeartStroke.test = 0
             HeartStroke.image = UIImage(named: "like_white")
             Add_Remove_Like(AR: false, pub_id: id_pub, id_like: id_like)
            }
        }
      
       
        
        
        
    }
    func Add_Remove_Like(AR:Bool,pub_id : Int, id_like : Int){
        
        Dwait = false
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            
            var params : Parameters = [:]
            if AR {
                params = [
                    "id_user" : a["id"].stringValue,
                    "id_publication" : pub_id
                ]
                print(params)
            }else{
                params = [
                    "id_like" : id_like
                ]
                    print(params)
            }
            
            Alamofire.request( (AR) ? ScriptBase.sharedInstance.AddLikeToPublication : ScriptBase.sharedInstance.RemoveLikeFromPublication , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    //print(response.data)
                    
                    let q = JSON(response.data)
                    
                    if q["status"].stringValue == "true" {
                        if AR {
                            //self.likesArray.append(like(id: q["data"]["id"].intValue, pub_id: pub_id))
                             self.id_like = q["data"]["id"].intValue
                            if self.CellType == "friends" {
                            NotificationCenter.default.post(name: NSNotification.Name("UpdateLikeFromCell"), object: like(id: self.id_like  ,pub_id: self.id_pub))
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name("UpdateLikeFromCellPublic"), object: like(id: self.id_like  ,pub_id: self.id_pub))
                            }
                           
                            self.Dwait = true
                        }else{
                            /*self.likesArray.remove(at: self.likesArray.firstIndex(where: { (like) -> Bool in
                                return like.id == id_like
                                
                                
                                
                            })!) */
                             self.id_like = -1
                            
                            if self.CellType == "friends" {
                                NotificationCenter.default.post(name: NSNotification.Name("UpdateLikeFromCell"), object: like(id: self.id_like  ,pub_id: self.id_pub))
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name("UpdateLikeFromCellPublic"), object: like(id: self.id_like  ,pub_id: self.id_pub))
                            }
                           
                            self.Dwait = true
                        }
                    }
                    //print(q)
                    
                    
                    
            }
            
            
            
        }catch{
            Dwait = true
        }
        
    }
    
   
}
