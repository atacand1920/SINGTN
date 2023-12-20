//
//  ProfilVisiteur.swift
//  SINGTN
//
//  Created by macbook on 2018-11-10.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import LNPopupController
import SwiftSpinner
class ProfilVisiteur : UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    
    
    @IBOutlet weak var heightTableSettings: NSLayoutConstraint!
    @IBOutlet weak var profile_img: RoundedUIImageView!
    var songs : JSON = []
    var user_id : String  = ""
    var isFriends = false
    @IBOutlet weak var profile_desc: UILabel!
    @IBOutlet weak var abonnement: UILabel!
    @IBOutlet weak var abonne: UILabel!
    @IBOutlet weak var profile_name: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emptyMessageLBL : UILabel!
    @IBOutlet weak var followBTN : UIButton!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return (songs.arrayObject?.count)!
        
    }
    
 
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let ImageV = cell.viewWithTag(1) as! UIImageView
            let Name = cell.viewWithTag(2) as! UILabel
            let src = cell.viewWithTag(3) as! UILabel
            if self.songs[indexPath.row]["song"].description != "null" {
                ImageV.setImage(with: URL(string: (self.songs[indexPath.row]["song"]["image_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                Name.text = self.songs[indexPath.row]["song"]["song_name"].stringValue
                src.text = self.songs[indexPath.row]["song"]["song_src"].stringValue
            }else{
                ImageV.setImage(with: URL(string: (self.songs[indexPath.row]["parent"]["song"]["image_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                Name.text = self.songs[indexPath.row]["parent"]["song"]["song_name"].stringValue
                src.text = self.songs[indexPath.row]["parent"]["song"]["song_src"].stringValue
            }
            src.isHidden = true
            let Particiapants = cell.viewWithTag(4) as! UILabel
            Particiapants.text = self.songs[indexPath.row]["createur"]["username"].stringValue
            if self.songs[indexPath.row]["participants"].arrayObject?.count != 0 {
                let count = (self.songs[indexPath.row]["participants"].arrayObject?.count)! - 1
                if self.songs[indexPath.row]["participants"].arrayObject?.count == 1 {
                    Particiapants.text = Particiapants.text! + " + " + self.songs[indexPath.row]["participants"][0]["username"].stringValue
                }else{
                    
                    Particiapants.text = Particiapants.text! + " and " + String(count) + " others"
                }
            }
            //if self.songs[indexPath.row][""]
            let date = cell.viewWithTag(5) as! UILabel
            date.text = self.songs[indexPath.row]["date"].stringValue
            
            
            
            return cell
        
    }
    
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        self.abonne.text = "0 abonné(s)"
        self.abonnement.text = "0 abonnement(s)"
        self.table.delegate = self
        self.table.dataSource = self
        self.table.bounces = false
        self.followBTN.setTitle(isFriends ? "S'abonner" : "Se désabonner", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.closePlayer), name: Notification.Name.init("ClosePlayer"), object: nil)
    }
    @objc func closePlayer(){
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //(UIApplication.shared.delegate as! AppDelegate).FloatingController.song = [self.songs[indexPath.row]]
            //(UIApplication.shared.delegate as! AppDelegate).FloatingController.show()
            let viewC = FloatingPlayerController.shared
            viewC.IndexSong = indexPath.row
            viewC.song = self.songs
            
            tabBarController?.popupBar.popupItem?.progress = Float(0.0)
            tabBarController?.presentPopupBar(withContentViewController: viewC, animated: true, completion: nil)
            viewC.initVLCPlayer(index: indexPath.row)
            tabBarController?.popupBar.progressViewStyle = .top
            tabBarController?.popupInteractionStyle = .drag
            tabBarController?.popupBar.backgroundStyle = .light
            
            //self.navigationController?.pushViewController(viewC, animated: true)
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserProfile()
        getFollowers()
       
        self.navigationController?.navigationBar.isHidden = false
    }
    func setupHeaderView() {
        self.header.translatesAutoresizingMaskIntoConstraints = false
        self.table.translatesAutoresizingMaskIntoConstraints = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func animateHeader() {
        self.headerHeightConstraint.constant = 254
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    //  abonnezés followers
    //following abonement
    func getFollowers(){
       
            let params: Parameters = [
                "id_user" : user_id
            ]
            Alamofire.request(ScriptBase.sharedInstance.get_followers , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    let q = JSON(response.data)
                    if q["status"].stringValue == "true" {
                        
                        self.abonne.text = q["data"]["followers"].stringValue + " abonné(s)"
                        self.abonne.underline()
                        let gesture  = UITapGestureRecognizer(target: self, action: #selector(self.showFollowers(_:)))
                        gesture.numberOfTapsRequired = 1
                        self.abonne.isUserInteractionEnabled = true
                        self.abonne.addGestureRecognizer(gesture)
                        self.abonnement.text = q["data"]["following"].stringValue + " abonnement(s)"
                        self.abonnement.underline()
                        let gesture2  = UITapGestureRecognizer(target: self, action: #selector(self.showFollowing(_:)))
                        self.abonnement.isUserInteractionEnabled = true
                        self.abonnement.addGestureRecognizer(gesture2)
                    }else{
                        print("unexpected error on followers")
                    }
                    
            }
            
        
    }
    @objc func showFollowing(_ sender: UILabel ) {
        let q = self.storyboard?.instantiateViewController(withIdentifier: "Follow_FollowingController") as! Follow_FollowingController
        q.typeCall = "Following"
        self.navigationController?.pushViewController(q, animated: true)
    }
    @objc func showFollowers(_ sender: UILabel){
        let q = self.storyboard?.instantiateViewController(withIdentifier: "Follow_FollowingController") as! Follow_FollowingController
        q.typeCall = "Followers"
        self.navigationController?.pushViewController(q, animated: true)
        
    }
    func getUserProfile(){
        
        
        let params: Parameters = [
            "user_id" : user_id
        ]
        Alamofire.request(ScriptBase.sharedInstance.getUserInfo , method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                let q = JSON(response.data)
                
                if q["status"].stringValue == "true" {
                    self.songs = q["data"]["histo"]
                    if self.songs.arrayObject?.count == 0 {
                        self.table.isHidden = true
                    }else{
                        self.table.reloadData()
                    }
                    print(q)
                    if q["data"]["user"]["description"].description != "null" {
                        self.profile_desc.text = q["data"]["user"]["description"].stringValue
                    }
                    self.profile_name.text = q["data"]["user"]["First_name"].stringValue + " " + q["data"]["user"]["Last_name"].stringValue
                    
                }else{
                    print("no Hitory")
                }
                
        }
        
        
    }
    
    @IBAction func Follow_unfollowAction(_ sender: UIButton) {
        if sender.title(for: .normal) == "S'abonner" {
            self.follow_unfollow(type: "follow")
            sender.setTitle("Se désabonner", for: .normal)
        }else{
              self.follow_unfollow(type: "unfollow")
             sender.setTitle("S'abonner", for: .normal)
        }
    }
    func follow_unfollow(type : String) {
        SwiftSpinner.show("Please wait...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            let params : Parameters = [
                "user_id" : a["id"].stringValue,
                "following" : self.user_id
            ]
            let header: HTTPHeaders = [
                "Content-Type" : "application/json"
                
            ]
            Alamofire.request( type == "follow" ? ScriptBase.sharedInstance.follow : ScriptBase.sharedInstance.unfollow , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header)
                .responseJSON { response in
                    //      LoaderAlert.shared.dismiss()
                    SwiftSpinner.hide()
                    let b = JSON(response.data!)
                    if b["status"].stringValue == "true" {
                        // we perfectly done the job
                        if type == "follow" {
                            //self.AlreadyFriends.append(object.id)
                            
                        }else{
                          /*  var index = 0
                            for q in self.AlreadyFriends {
                                if q == object.id {
                                    self.AlreadyFriends.remove(at: index)
                                }
                                index += 1
                            } */
                            
                        }
                    }
            }
            
        }catch let error as NSError {
            print(error.userInfo)
        }
    }
}

extension ProfilVisiteur:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll:",scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0 {
            animateHeader()
            //headerView.incrementColorAlpha(offset: self.headerHeightConstraint.constant)
            //headerView.incrementArticleAlpha(offset: self.headerHeightConstraint.constant)
        } else if scrollView.contentOffset.y > 0 && self.headerHeightConstraint.constant >= 10 {
            self.headerHeightConstraint.constant -= scrollView.contentOffset.y/100
            //headerView.decrementColorAlpha(offset: scrollView.contentOffset.y)
            //headerView.decrementArticleAlpha(offset: self.headerHeightConstraint.constant)
            
            if self.headerHeightConstraint.constant < 10 {
                self.headerHeightConstraint.constant = 0
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.headerHeightConstraint.constant > 254 {
            animateHeader()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.headerHeightConstraint.constant > 254 {
            animateHeader()
        }
    }
}

