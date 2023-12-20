//
//  DuoGroupController.swift
//  SINGTN
//
//  Created by macbook on 2018-10-13.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftSpinner
class DuoGroupController : UIViewController,UITableViewDelegate,UITableViewDataSource {
    var documentFolderPath : URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    var audioPart : URL {
        return documentFolderPath.appendingPathComponent("audioPart.m4a")
    }
    @IBOutlet weak var tableview : UITableView!
    @IBOutlet weak var defaultMessage : UILabel!
    var isDuo = true
    var song : JSON = []
    var idSongToFetch = ""
    var index : Int = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.song.arrayObject?.count)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        self.prepareData()
        print("Lang: ",ScriptBase.sharedInstance.getLanguage())
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let image = cell.viewWithTag(1) as! UIImageView
        let title = cell.viewWithTag(2) as! UILabel
        let artist = cell.viewWithTag(3) as! UILabel
        image.setImage(with: URL(string: song[indexPath.row]["createur"]["image_src"].stringValue), placeholder:#imageLiteral(resourceName: "User") , transformer: nil, progress: nil, completion: nil)
        
        title.text = song[indexPath.row]["song"]["song_name"].stringValue.firstCapitalized
        artist.text = song[indexPath.row]["song"]["artist_name"].stringValue.firstCapitalized
        let button = cell.viewWithTag(4) as! UIButton
        button.isUserInteractionEnabled = false
        let message = cell.viewWithTag(5) as! UILabel
        
        let Full_name = song[indexPath.row]["createur"]["First_name"].stringValue.firstCapitalized   + " " + song[indexPath.row]["createur"]["Last_name"].stringValue.firstCapitalized
        print("ss",message.text)
        message.text = Full_name + self.getMessage()
        
        let date = cell.viewWithTag(6) as! UILabel
        date.text = song[indexPath.row]["date"].string
        return cell
    }
    func getMessage() -> String {
        return ScriptBase.sharedInstance.getLanguage() == "fr" ? " a chanté  une partie de la chanson :" : " has sang a part of the song :"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let q = self.storyboard?.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        q.song = self.song
        q.index = indexPath.row
        q.isSolo = false
        if isDuo {
        q.isDuoCreate = "DUOJ"
            ScriptBase.sharedInstance.DUOC_or_DUOJ == "DUOJ"
        }else{
            q.isDuoCreate = "GROUPJ"
        }
        self.navigationController?.pushViewController(q, animated: true)
      /*  let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
        q.Songs = self.song
        q.index = self.index
        q.navigation = self.navigationController
        q.isVideo = true
        q.isSolo = false
        q.SongToPlay = self.audioPart
        self.navigationController?.pushViewController(q, animated: true) */
    }
    func prepareData(){
        
        var params : Parameters = [:]
        let header : HTTPHeaders = ["Content-Type" : "application/json"]
        if isDuo {
            params = [
                "type" : "DUOC",
                "song" : self.idSongToFetch
            
            ]
            
        }else{
            params = [
                "type" : "GROUPC",
                 "song" : self.idSongToFetch
            
            ]
        }
        
        Alamofire.request(ScriptBase.sharedInstance.getDuoGroupSongs, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            if response.error == nil {
                let b = JSON(response.data as Any)
                print(b)
                if b["status"].stringValue == "true" {
                self.song = b["data"]
            self.tableview.reloadData()
                }else{
                    self.tableview.isHidden = true
                    
                }
            }else{
                let alert = UIAlertController(title: "DUO Repository", message: "an Unknow error has occured", preferredStyle: .alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : nil))
                
                // show the alert
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
extension StringProtocol {
    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
}
