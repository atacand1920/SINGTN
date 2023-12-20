//
//  Follow_FollowingController.swift
//  SINGTN
//
//  Created by macbook on 2018-11-13.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import MapleBacon
import Alamofire
import SwiftyJSON
import SwiftSpinner
class Follow_FollowingController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var AllUsers: [Users] = []
    var AlreadyFriends : [String] = []
    var typeCall = ""
    @IBOutlet weak var table : UITableView!
    @IBOutlet weak var defaultLabel : UILabel!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageV = cell.viewWithTag(1) as! UIImageView
        imageV.setImage(with: URL(string: AllUsers[indexPath.row].image_src), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        let labelV = cell.viewWithTag(2) as! UILabel
        labelV.text = AllUsers[indexPath.row].username
        let labelDesc = cell.viewWithTag(3) as! UILabel
        labelDesc.text = AllUsers[indexPath.row].descriptions
        let button = cell.viewWithTag(4) as! CustomButton
        button.addTarget(self, action: #selector(self.follow(_:)), for: .touchUpInside)
        button.user = AllUsers[indexPath.row]
        if AlreadyFriends.contains(AllUsers[indexPath.row].id) {
            ///MARK: they are friends
            print("they are friends")
            button.setImage(#imageLiteral(resourceName: "following") , for: .normal)
        }else{
            ///MARK: they are not friends
            print("they are not friends")
            button.setImage(#imageLiteral(resourceName: "follow"), for: .normal)
        }
        
        return cell
    }
    @objc func follow(_ sender : CustomButton) {
        if sender.image(for: .normal) == #imageLiteral(resourceName: "follow.png") {
            // here follow and change
            self.follow_unfollow(object: sender.user, type: "follow")
            sender.setImage(#imageLiteral(resourceName: "following.png"), for: .normal)
            
        }else{
            // here to unfollow and change
            self.follow_unfollow(object: sender.user, type: "unfollow")
            sender.setImage(#imageLiteral(resourceName: "follow.png"), for: .normal)
        }
    }
    func follow_unfollow(object:Users, type : String) {
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            let params : Parameters = [
                "user_id" : a["id"].stringValue,
                "following" : object.id
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
                            self.AlreadyFriends.append(object.id)
                            
                        }else{
                            var index = 0
                            for q in self.AlreadyFriends {
                                if q == object.id {
                                    self.AlreadyFriends.remove(at: index)
                                }
                                index += 1
                            }
                            
                        }
                    }
            }
            
        }catch let error as NSError {
            print(error.userInfo)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.delegate = self
        self.table.dataSource = self
        if typeCall == "Following" {
            defaultLabel.text = "Start follow users!"
        }else{
            defaultLabel.text = "No one have followed you"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        getUsers()
    }
    func getUsers(){
        AllUsers = []
       
        SwiftSpinner.show("Please wait...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            let params : Parameters = [
                "user_id" : a["id"].stringValue
            ]
            let header: HTTPHeaders = [
                "Content-Type" : "application/json"
                
            ]
            Alamofire.request(typeCall == "Following" ? ScriptBase.sharedInstance.getAllFollowing : ScriptBase.sharedInstance.getAllFollowers , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header)
                .responseJSON { response in
                    //      LoaderAlert.shared.dismiss()
                    SwiftSpinner.hide()
                    let b = JSON(response.data!)
                    print(b)
                    let users = b["data"]
                    if b["status"].stringValue == "true" {
                    if users.arrayObject?.count != 0 {
                        if self.typeCall == "Following" {
                        for i in 0...((users.arrayObject?.count)! - 1) {
                            self.AllUsers.append(Users(id: users[i]["following"]["id"].stringValue, username: users[i]["following"]["username"].stringValue, First_name: users[i]["following"]["First_name"].stringValue, Last_name: users[i]["following"]["Last_name"].stringValue, descriptions: users[i]["following"]["description"].stringValue, image_src: users[i]["following"]["image_src"].stringValue))
                             self.AlreadyFriends.append(users[i]["following"]["id"].stringValue)
                        }
                        }else{
                            for i in 0...((users.arrayObject?.count)! - 1) {
                                self.AllUsers.append(Users(id: users[i]["follower"]["id"].stringValue, username: users[i]["follower"]["username"].stringValue, First_name: users[i]["follower"]["First_name"].stringValue, Last_name: users[i]["follower"]["Last_name"].stringValue, descriptions: users[i]["follower"]["description"].stringValue, image_src: users[i]["follower"]["image_src"].stringValue))
                                self.AlreadyFriends.append(users[i]["follower"]["id"].stringValue)
                            }
                        }
                    }else{
                        self.table.isHidden = true
                        }
                    
                 
                    self.table.reloadData()
                    }else{
                        if b["message"].exists() == false {
                        let rech = Reachability()
                        if rech.isReachable() {
                            self.defaultLabel.text = "Remote server Problem!"
                            self.table.isHidden = true
                        }else{
                            self.defaultLabel.text = "No Internet Connexion"
                             self.table.isHidden = true
                        }
                        }else{
                            self.table.isHidden = true
                        }
                    }
                    
            }
            //  else {
            //      _ = SweetAlert().showAlert("Conexion", subTitle: "Veuillez vous connecter", style: AlertStyle.error)
            //}
        }catch{
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        let button = cell?.viewWithTag(4) as! CustomButton
        let q = self.storyboard?.instantiateViewController(withIdentifier: "ProfilVisiteur") as! ProfilVisiteur
        q.user_id = button.user.id
        q.isFriends = button.image(for: .normal) == #imageLiteral(resourceName: "follow.png") ? true : false
        self.navigationController?.pushViewController(q, animated: true)
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
