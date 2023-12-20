//
//  FindFriendsController.swift
//  SINGTN
//
//  Created by macbook on 2018-11-08.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import MapleBacon
import Alamofire
import SwiftyJSON
import SwiftSpinner
struct Users {
    var id : String!
    var username : String!
    var First_name : String!
    var Last_name : String!
    var descriptions : String!
    var image_src : String!
}
class FindFriendsController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    var AllUsers: [Users] = []
    var AlreadyFriends : [String] = []
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if searchBar.text != "" {
            self.filterResults(text: searchBar.text!)
        }else{
             searchResults = self.AllUsers
            self.table.reloadData()
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            self.filterResults(text: searchBar.text!)
        }else{
            searchResults = self.AllUsers
            self.table.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        searchResults = self.AllUsers
        self.searchB.text = ""
        self.table.reloadData()
       self.view.endEditing(true)
    }
    func filterResults(text: String) {
        searchResults = AllUsers.filter({ (user) -> Bool in
            return ( user.username.lowercased().contains(text.lowercased()) || user.First_name.lowercased().contains(text.lowercased()) || user.Last_name.lowercased().contains(text.lowercased()))
        })
        self.table.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageV = cell.viewWithTag(1) as! UIImageView
        imageV.setImage(with: URL(string: searchResults[indexPath.row].image_src), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        let labelV = cell.viewWithTag(2) as! UILabel
        labelV.text = searchResults[indexPath.row].username
        let labelDesc = cell.viewWithTag(3) as! UILabel
        labelDesc.text = searchResults[indexPath.row].descriptions
        let button = cell.viewWithTag(4) as! CustomButton
        button.addTarget(self, action: #selector(self.follow(_:)), for: .touchUpInside)
        button.user = searchResults[indexPath.row]
        if AlreadyFriends.contains(searchResults[indexPath.row].id) {
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
    @IBOutlet weak var table : UITableView!
    @IBOutlet weak var searchB : UISearchBar!
    var searchResults : [Users] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.delegate = self
        self.table.dataSource = self
        self.searchB.delegate = self
        self.searchB.placeholder = "Looking for new friends?"
        self.searchB.showsCancelButton = true
        self.searchB.showsSearchResultsButton = true
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          getUsers()
    }
    func getUsers(){
        AllUsers = []
        AlreadyFriends = []
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
            Alamofire.request(ScriptBase.sharedInstance.getAllUsers , method: .post, parameters: params, encoding: JSONEncoding.default,headers : header)
                .responseJSON { response in
                    //      LoaderAlert.shared.dismiss()
                    SwiftSpinner.hide()
                    let b = JSON(response.data!)
                    let users = b["data"]["users"]
                    let friends = b["data"]["friends"]
                    if users.arrayObject?.count != 0 {
                        
                    for i in 0...((users.arrayObject?.count)! - 1) {
                        self.AllUsers.append(Users(id: users[i]["id"].stringValue, username: users[i]["username"].stringValue, First_name: users[i]["First_name"].stringValue, Last_name: users[i]["Last_name"].stringValue, descriptions: users[i]["description"].stringValue, image_src: users[i]["image_src"].stringValue))
                    }
                        
                    }
                    if friends.arrayObject?.count != 0 {
                        for i in 0...((friends.arrayObject?.count)! - 1) {
                            self.AlreadyFriends.append(friends[i]["following"]["id"].stringValue)
                        }
                    }
                    self.searchResults = self.AllUsers
                    self.table.reloadData()
                    
            }
            //  else {
            //      _ = SweetAlert().showAlert("Conexion", subTitle: "Veuillez vous connecter", style: AlertStyle.error)
            //}
        }catch{
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        let button = cell?.viewWithTag(4) as! CustomButton
        let q = self.storyboard?.instantiateViewController(withIdentifier: "ProfilVisiteur") as! ProfilVisiteur
        q.user_id = button.user.id
        q.isFriends = button.image(for: .normal) == #imageLiteral(resourceName: "follow.png") ? true : false
        self.navigationController?.pushViewController(q, animated: true)
        
       
        
    }
    
}
class CustomButton : UIButton {
    var user : Users!
}
