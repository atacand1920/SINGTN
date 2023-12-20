//
//  InvitationChatController.swift
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
import MapleBacon
class InvitationChatController : UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    var notifications: JSON = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (notifications.arrayObject?.count)!
    }
    @IBOutlet weak var defaultLabel : UILabel!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomInvitationCell {
            if notifications[indexPath.row]["contenu"].description != "null" {
            cell.TextL.text = notifications[indexPath.row]["contenu"].stringValue
            }
            let url = URL(string: notifications[indexPath.row]["owner"]["image_src"].stringValue)
            cell.ImgProfile.setImage(with: url!, placeholder: nil, transformer: nil, progress: nil, completion: nil)
            
            let type = notifications[indexPath.row]["type"].stringValue
            if type == "like" || type == "comment" {
                cell.joinBTN.isHidden = true
                if type == "like" {
                    cell.typeIMG.image = UIImage(named: "like_red")
                }else{
                    cell.typeIMG.image = UIImage(named: "chat")
                }
            }else{
                cell.typeIMG.isHidden = true
               
                cell.joinBTN.song = notifications[indexPath.row]["song"]
                
            }
            
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    @IBOutlet weak var table : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    self.defaultLabel.text = "No new Notfications!"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getNotifications()
    }
    func getNotifications(){
        SwiftSpinner.show("Loading...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            
            let params : Parameters = [
                "id_user" : a["id"].stringValue
            ]
            
            
            Alamofire.request(ScriptBase.sharedInstance.getNotifications, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
                SwiftSpinner.hide()
                let q = JSON(response.data)
                
                if q["status"].stringValue == "true" {
                    
                    self.notifications = q["data"]
                    self.table.isHidden = false
                    self.table.reloadData()
                }else{
                    if q["message"].stringValue == "empty" {
                        self.notifications = []
                        self.table.isHidden = true
                        self.table.reloadData()
                    }
                }
            }
            
            
        }catch{
                SwiftSpinner.hide()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
class CustomSongButton : UIButton {
    var song:JSON!
}
