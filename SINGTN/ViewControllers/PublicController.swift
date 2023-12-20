//
//  Fil_Actualité.swift
//  SINGTN
//
//  Created by macbook on 2018-06-18.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
/**
 this controller is responsible of the public News view
 */
class PublicController : UIViewController, UITableViewDelegate,UITableViewDataSource {
    /**
     our tableView height depending of it's contents.
     */
    @IBOutlet weak var heightTable: NSLayoutConstraint!
    /**
     our friends publications JSON
     */
    var publications : JSON = []
    /**
     this is the same as publications but it contains the newer publications if they exists.
     */
    var publicationsTemp: JSON = []
    /**
     this the same as likes but it contains the newer likes of the newer publications if they exists.
     */
    var likesTemp: JSON = []
    /**
     our users likes on this publications
     */
    var likes : JSON = []
    /**
     this a structed var of our likes
     */
    var likesArray : [like] = []
    /**
     to know if it is the first load of our controller or not.
     */
    var FirstLoad = 0
    /**
     this button appears when there are new publications.
     */
      @IBOutlet weak var NewItemsBTN: UIButton!
    /**
     this control the refresh Action of our NewItesBTN.
     */
    @IBAction func RefreshAction(_ sender: UIButton) {
        
        self.publications = self.publicationsTemp
        self.likes = self.likesTemp
        if self.likes.arrayObject?.count != 0 {
            for i in 0...(((self.likes.arrayObject?.count)!) - 1) {
                self.likesArray.append(like(id: self.likes[i]["id"].intValue, pub_id: self.likes[i]["publication"]["id"].intValue))
                
            }
        }
        self.table.reloadData()
        if self.publications != [] {
            self.table.isHidden = false
        }
        self.table.scrollsToTop = true
        self.NewItemsBTN.isHidden = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (publications.arrayObject?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
          heightTable.constant = table.contentSize.height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if publications[indexPath.row]["type"] == "master" {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomWallCell {
                cell.CellType = "Friends"
                print("Row Reloaded")
                let imageV = cell.viewWithTag(1) as! UIImageView
                imageV.image = UIImage(named: "preview")
                if likesArray.contains(where: { (like) -> Bool in
                    if like.pub_id == publications[indexPath.row]["id"].intValue {
                        cell.id_like = like.id
                        
                        return true
                    }else{
                        return false
                    }
                }) {
                    
                    cell.HeartStroke.test = 1
                }else {
                    
                    
                    cell.HeartStroke.test = 0
                }
                cell.id_pub = publications[indexPath.row]["id"].intValue
                cell.index = indexPath.row
                if cell.HeartStroke.test != 0 {
                    cell.HeartStroke.image = UIImage(named: "like_red")
                } else {
                    cell.HeartStroke.image = UIImage(named: "like_white")
                }
                if publications[indexPath.row]["song"]["song"].description != "null" {
                    let backgoundimageURL = URL(string: publications[indexPath.row]["song"]["song"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    
                    cell.BackgroundImg.setImage(with: backgoundimageURL, placeholder: nil, transformer: nil, progress: nil, completion: { (image) in
                        image?.getColors(scaleDownSize: CGSize(width: cell.BackgroundImg.frame.width, height: cell.BackgroundImg.frame.height), completionHandler: { (colors) in
                            
                            DispatchQueue.main.async(execute: {
                                var res = 0
                                res = colors.backgroundColor.isLight()! ? res + 1 : res - 1
                                print(colors.backgroundColor.isLight()! ? "light" : "dark")
                                res = colors.detailColor.isLight()! ? res + 1 : res - 1
                                print(colors.detailColor.isLight()! ? "light" : "dark")
                                res = colors.primaryColor.isLight()! ? res + 1 : res - 1
                                print(colors.primaryColor.isLight()! ? "light" : "dark")
                                res = colors.secondaryColor.isLight()! ? res + 1 : res - 1
                                print(colors.secondaryColor.isLight()! ? "light" : "dark")
                                print("res: ",res)
                                if res >= 3 {
                                    cell.FirstSingerLBL.textColor = .black
                                    cell.SecondSingerLBL.textColor = .black
                                    
                                }else{
                                    cell.FirstSingerLBL.textColor = .white
                                    cell.SecondSingerLBL.textColor = .white
                                }
                            })
                        })
                    })
                }else{
                    let backgoundimageURL = URL(string: publications[indexPath.row]["song"]["parent"]["song"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    
                    cell.BackgroundImg.setImage(with: backgoundimageURL, placeholder: nil, transformer: nil, progress: nil, completion: { (image) in
                        image?.getColors(scaleDownSize: CGSize(width: cell.BackgroundImg.frame.width, height: cell.BackgroundImg.frame.height), completionHandler: { (colors) in
                            
                            DispatchQueue.main.async(execute: {
                                var res = 0
                                res = colors.backgroundColor.isLight()! ? res + 1 : res - 1
                                res = colors.detailColor.isLight()! ? res + 1 : res - 1
                                res = colors.primaryColor.isLight()! ? res + 1 : res - 1
                                res = colors.secondaryColor.isLight()! ? res + 1 : res - 1
                                if res >= 3 {
                                    cell.FirstSingerLBL.textColor = .black
                                    cell.SecondSingerLBL.textColor = .black
                                    
                                }else{
                                    cell.FirstSingerLBL.textColor = .white
                                    cell.SecondSingerLBL.textColor = .white
                                }
                            })
                        })
                    })
                }
                
                cell.FirstSingerImg.setImage(with: URL(string: publications[indexPath.row]["song"]["createur"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                cell.FirstSingerLBL.text = publications[indexPath.row]["song"]["createur"]["First_name"].stringValue.firstCapitalized + " " + publications[indexPath.row]["song"]["createur"]["Last_name"].stringValue.firstCapitalized
                if publications[indexPath.row]["song"]["participants"].arrayObject?.count == 0 {
                    cell.SecondSingerImg.isHidden = true
                    cell.SecondSingerLBL.isHidden = true
                    cell.and.isHidden = true
                    
                    
                    
                }else if publications[indexPath.row]["song"]["participants"].arrayObject?.count == 1 {
                    cell.SecondSingerImg.isHidden = false
                    cell.SecondSingerLBL.isHidden = false
                    cell.and.isHidden = false
                    let participants = publications[indexPath.row]["song"]["participants"]
                    
                    cell.SecondSingerImg.setImage(with: URL(string: participants[0]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                    cell.SecondSingerLBL.text  = participants[0]["First_name"].stringValue.firstCapitalized + " " + participants[0]["Last_name"].stringValue.firstCapitalized
                }else{
                    cell.SecondSingerImg.isHidden = false
                    cell.SecondSingerLBL.isHidden = false
                    cell.and.isHidden = false
                    let participants = publications[indexPath.row]["song"]["participants"]
                    cell.SecondSingerImg.image = LetterImageGenerator.imageWith(name: String(participants.arrayObject!.count))
                    cell.SecondSingerLBL.text = String(participants.arrayObject!.count) + " others"
                    
                    
                    
                }
                if publications[indexPath.row]["song"]["song"].description != "null" {
                    cell.song_title.text = publications[indexPath.row]["song"]["song"]["song_name"].stringValue
                }else{
                    cell.song_title.text = publications[indexPath.row]["song"]["parent"]["song"]["song_name"].stringValue
                }
                // cell.song_title.text = cell.song_title.text! + " by "
                //cell.song_title.text = cell.song_title.text! + publications[indexPath.row]["song"]["song"]["artist_name"].stringValue
                return cell
            }else {
                return UITableViewCell()
            }
        }else{
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cellShare", for: indexPath) as? CustomWallShareCellTableViewCell {
                
                cell.Share_Name.text = publications[indexPath.row]["publicationShare"]["user"]["First_name"].stringValue + " " + publications[indexPath.row]["publicationShare"]["user"]["Last_name"].stringValue + " shared the song of " +  "@"+publications[indexPath.row]["user"]["username"].stringValue
                
                let URLSharePicture = URL(string: publications[indexPath.row]["publicationShare"]["user"]["image_src"].stringValue)
                
                cell.Share_Picture.setImage(with: URLSharePicture, placeholder: nil, transformer: nil, progress: nil, completion: nil)
                if publications[indexPath.row]["song"]["song"].description != "null" {
                    let backgoundimageURL = URL(string: publications[indexPath.row]["song"]["song"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    cell.BackgroundImg.setImage(with: backgoundimageURL, placeholder: nil, transformer: nil, progress: nil, completion: { (image) in
                        image?.getColors(scaleDownSize: CGSize(width: cell.BackgroundImg.frame.width, height: cell.BackgroundImg.frame.height), completionHandler: { (colors) in
                            
                            DispatchQueue.main.async(execute: {
                                var res = 0
                                res = colors.backgroundColor.isLight()! ? res + 1 : res - 1
                                res = colors.detailColor.isLight()! ? res + 1 : res - 1
                                res = colors.primaryColor.isLight()! ? res + 1 : res - 1
                                res = colors.secondaryColor.isLight()! ? res + 1 : res - 1
                                if res >= 3 {
                                    cell.FirstSingerLBL.textColor = .black
                                    cell.SecondSingerLBL.textColor = .black
                                    
                                }else{
                                    cell.FirstSingerLBL.textColor = .white
                                    cell.SecondSingerLBL.textColor = .white
                                }
                            })
                        })
                    })
                }else{
                    let backgoundimageURL = URL(string: publications[indexPath.row]["song"]["parent"]["song"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    cell.BackgroundImg.setImage(with: backgoundimageURL, placeholder: nil, transformer: nil, progress: nil, completion: { (image) in
                        image?.getColors(scaleDownSize: CGSize(width: cell.BackgroundImg.frame.width, height: cell.BackgroundImg.frame.height), completionHandler: { (colors) in
                            
                            DispatchQueue.main.async(execute: {
                                var res = 0
                                res = colors.backgroundColor.isLight()! ? res + 1 : res - 1
                                res = colors.detailColor.isLight()! ? res + 1 : res - 1
                                res = colors.primaryColor.isLight()! ? res + 1 : res - 1
                                res = colors.secondaryColor.isLight()! ? res + 1 : res - 1
                                if res >= 3 {
                                    cell.FirstSingerLBL.textColor = .black
                                    cell.SecondSingerLBL.textColor = .black
                                    
                                }else{
                                    cell.FirstSingerLBL.textColor = .white
                                    cell.SecondSingerLBL.textColor = .white
                                }
                            })
                        })
                    })
                }
                
                
                cell.FirstSingerImg.setImage(with: URL(string: publications[indexPath.row]["song"]["createur"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                cell.FirstSingerLBL.text = publications[indexPath.row]["song"]["createur"]["First_name"].stringValue.firstCapitalized + " " + publications[indexPath.row]["song"]["createur"]["Last_name"].stringValue.firstCapitalized
                if publications[indexPath.row]["song"]["participants"].arrayObject?.count == 0 {
                    cell.SecondSingerImg.isHidden = true
                    cell.SecondSingerLBL.isHidden = true
                    cell.and.isHidden = true
                    cell.contentView.clipsToBounds = true
                    cell.ContainerShareable.clipsToBounds = true
                    cell.ContainerShareable.layer.cornerRadius = 10
                    cell.ContainerShareable.layer.masksToBounds = true
                    cell.Share_Picture.clipsToBounds = true
                    cell.Share_Picture.layer.cornerRadius = 10
                    cell.Share_Picture.layer.masksToBounds = true
                    //cell.layoutIfNeeded()
                }else if publications[indexPath.row]["song"]["participants"].arrayObject?.count == 1 {
                    cell.SecondSingerImg.isHidden = false
                    cell.SecondSingerLBL.isHidden = false
                    cell.and.isHidden = false
                    let participants = publications[indexPath.row]["song"]["participants"]
                    
                    cell.SecondSingerImg.setImage(with: URL(string: participants[0]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                    cell.SecondSingerLBL.text = participants[0]["First_name"].stringValue.firstCapitalized + " " + participants[0]["Last_name"].stringValue.firstCapitalized
                }else{
                    cell.SecondSingerImg.isHidden = false
                    cell.SecondSingerLBL.isHidden = false
                    cell.and.isHidden = false
                    let participants = publications[indexPath.row]["song"]["participants"]
                    cell.SecondSingerImg.image = LetterImageGenerator.imageWith(name: String(participants.arrayObject!.count))
                    cell.SecondSingerLBL.text = String(participants.arrayObject!.count) + " others"
                    
                    
                    
                }
                if publications[indexPath.row]["song"]["song"].description != "null" {
                    cell.song_title.text = publications[indexPath.row]["song"]["song"]["song_name"].stringValue
                }else{
                    cell.song_title.text = publications[indexPath.row]["song"]["parent"]["song"]["song_name"].stringValue
                }
                
                return cell
            }else {
                return UITableViewCell()
            }
            
            
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let q = self.storyboard?.instantiateViewController(withIdentifier: "PubDesc") as! PublicationDescription
        q.song = [self.publications[indexPath.row]["song"]]
        q.pub_id = self.publications[indexPath.row]["id"].stringValue
        q.isLike = likesArray.contains(where: { (like) -> Bool in
            if like.pub_id == publications[indexPath.row]["id"].intValue {
                q.id_like = like.id
                return true
            }else{
                return false
            }
        })
        if q.isLike == false {
            q.id_like = -1
            
        }
        
        
        self.navigationController?.pushViewController(q, animated: true)
    }
    
    /* @objc func imgTapped(sender: UITapGestureRecognizer) {
     // change data model blah-blah
     print("hey")
     guard let tappedView = sender.view else {
     return
     }
     print("ka")
     let touchPointInTableView = self.table.convert(tappedView.bounds.origin, from: tappedView)
     print(touchPointInTableView)
     guard let indexPath = self.table.indexPathForRow(at: touchPointInTableView) else {
     print("no index")
     return
     }
     
     print("Selected item at indexPath \(indexPath)")
     let cell = self.table.cellForRow(at: indexPath)
     print("cellTestBefore:",((cell?.viewWithTag(2) as! UIView ).viewWithTag(4) as! CustomImage).test)
     if ((cell?.viewWithTag(2) as! UIView ).viewWithTag(4) as! CustomImage).test == 0 {
     ((cell?.viewWithTag(2) as! UIView ).viewWithTag(4) as! CustomImage).test = 1
     } else {
     ((cell?.viewWithTag(2) as! UIView ).viewWithTag(4) as! CustomImage).test = 0
     }
     print("cellTestAfter:",((cell?.viewWithTag(2) as! UIView ).viewWithTag(4) as! CustomImage).test)
     self.table.beginUpdates()
     self.table.reloadRows(at: [indexPath], with: .none)
     self.table.endUpdates()
     
     
     
     } */
    /**
     our tableView
     */
    @IBOutlet weak var table : UITableView!
    
    let updateLike        = NSNotification.Name(rawValue:"updateLikePublic")
    let UpdateLikeFromCell        = NSNotification.Name(rawValue:"UpdateLikeFromCellPublic")
    let CommentPush        = NSNotification.Name(rawValue:"CommentPushPublic")
    let CommentOpen        = NSNotification.Name(rawValue:"CommentOpenPublic")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.NewItemsBTN.isHidden = true
        self.table.dataSource = self
        self.table.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateLike(notification:)), name: updateLike, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLikeCell(notification:)), name: UpdateLikeFromCell, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentPu(notification:)), name: CommentPush, object: nil)
        
    }
    
    /**
     this is triggered when the user press to "Comment" button
     */
    @objc func CommentPu(notification: NSNotification){
        let index = notification.object as! Int
        
        let indexPath = IndexPath(row: index, section: 0)
        self.table.delegate!.tableView!(table, didSelectRowAt: indexPath)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: self.CommentOpen, object: nil)
        }
        
    }
    /**
     this is triggered when the user press the "Like" button inside the publicationDescription
     */
    @objc func updateLikeCell(notification: NSNotification){
        
        
        let objectLiked = notification.object as! like
        
        print(objectLiked)
        print(likesArray)
        if likesArray.contains(where: { (like) -> Bool in
            if like.pub_id == objectLiked.pub_id{
                return true
            }else{
                return false
            }
        }) {
            likesArray.removeAll { (like) -> Bool in
                return like.pub_id == objectLiked.pub_id
            }
        }else{
            likesArray.append(objectLiked)
            
        }
        print(likesArray)
        
    }
    /**
     this is triggered when the user press the "Like" button
     */
    @objc func updateLike(notification: NSNotification){
        
        
        let objectLiked = notification.object as! like
        if likesArray.contains(where: { (like) -> Bool in
            if like.id == objectLiked.id{
                return true
            }else{
                return false
            }
        }) {
            likesArray.removeAll { (like) -> Bool in
                return like.id == objectLiked.id
            }
            self.table.reloadData()
        }else{
            likesArray.append(objectLiked)
            self.table.reloadData()
            
        }
        
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: updateLike, object: nil)
        NotificationCenter.default.removeObserver(self, name: UpdateLikeFromCell, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if FirstLoad == 0 {
            self.getPublications(fresh: true)
            FirstLoad = FirstLoad + 1
        }else{
            
            self.getPublications(fresh: false)
        }
    }
    /**
     this function get the likes of the user from database.
     
     - Parameters:
        - fresh: a boolean value to indicate if this function is triggered from the refresh button or not.
     */
    func getLikes(fresh : Bool){
        
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
            
            let params: Parameters = [
                "id_user" : a["id"].stringValue
            ]
            print(params)
            Alamofire.request(ScriptBase.sharedInstance.GetLikes , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    SwiftSpinner.hide()
                    //print(response.data)
                    let q = JSON(response.data)
                    print(q)
                    if q["status"].stringValue == "true" {
                        if q["message"].stringValue == "successful" {
                            if fresh {
                            self.likes = q["data"]
                            if self.likes.arrayObject?.count != 0 {
                                for i in 0...(((self.likes.arrayObject?.count)!) - 1) {
                                    self.likesArray.append(like(id: self.likes[i]["id"].intValue, pub_id: self.likes[i]["publication"]["id"].intValue))
                                    
                                }
                            }
                            self.table.reloadData()
                            }else{
                                self.likesTemp = q["data"]
                            }
                            // self.navigationController?.popToRootViewController(animated: true)
                        }else{
                            
                            print("unexpected error on publications")
                        }
                    }else{
                        SwiftSpinner.hide()
                    }
                    
                    self.table.reloadData()
            }
        }catch {
            SwiftSpinner.hide()
            print(error)
        }
    }
    /**
     this function get the publications of the friends of the user from database.
     
     - Parameters:
        - fresh: a boolean value to indicate if this function is triggered from the refresh button or not.
     */
    func getPublications(fresh:Bool){
        if fresh {
        SwiftSpinner.show("Loading...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
            
            let params: Parameters = [
                "audience" : "public" ,
                "id_user" : a["id"].stringValue
            ]
            print(params)
            Alamofire.request(ScriptBase.sharedInstance.get_publication , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    //  SwiftSpinner.hide()
                    //print(response.data)
                    let q = JSON(response.data)
                    print(q)
                    if q["status"].stringValue == "true" {
                        if q["message"].stringValue == "successful" {
                            self.publications = q["data"]
                            self.getLikes(fresh: fresh)
                            // self.table.reloadData()
                            // self.navigationController?.popToRootViewController(animated: true)
                        }else{
                            
                            print("unexpected error on publications")
                        }
                    }else{
                        SwiftSpinner.hide()
                    }
                    
                    
            }
        }catch {
            SwiftSpinner.hide()
            print(error)
        }
        
        }else{
            let ab = UserDefaults.standard.value(forKey: "User") as! String
            let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
            do {
                let a = try JSON(data: dataFromString!)
                print(a)
                
                let params: Parameters = [
                    "audience" : "public" ,
                    "id_user" : a["id"].stringValue
                ]
                print(params)
                Alamofire.request(ScriptBase.sharedInstance.get_publication , method: .post, parameters: params, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        //  SwiftSpinner.hide()
                        //print(response.data)
                        let q = JSON(response.data)
                        print(q)
                        if q["status"].stringValue == "true" {
                            if q["message"].stringValue == "successful" {
                                if self.publications.arrayObject?.count != q["data"].arrayObject?.count {
                                    self.NewItemsBTN.isHidden  = false
                                    SwiftSpinner.show("Refreshing..")
                                self.publicationsTemp = q["data"]
                                self.getLikes(fresh: fresh)
                                }
                                // self.table.reloadData()
                                // self.navigationController?.popToRootViewController(animated: true)
                            }else{
                                
                                print("unexpected error on publications")
                            }
                        }else{
                            SwiftSpinner.hide()
                        }
                        
                        
                }
            }catch {
                SwiftSpinner.hide()
                print(error)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
