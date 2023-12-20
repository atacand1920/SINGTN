//
//  RepertoireController.swift
//  SINGTN
//
//  Created by macbook on 2018-06-25.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MapleBacon
struct DefaultSongs {
    var id : String!
    var song_src : String!
    var song_name : String!
    var lyric_src : String!
    var image_src : String!
    var artist_name :  String!
}
class RepertoireController : UIViewController,UITableViewDelegate,UITableViewDataSource {
    var songs_singtn : JSON = []
    var indexTitlesArray : [String] = []
    var songsDictionnary =  [String : [DefaultSongs]]()
    
    @IBOutlet weak var table: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let songKey = indexTitlesArray[section]
        if let songValue = songsDictionnary[songKey] {
            return songValue.count
        }
        return 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.getSongs()
        self.tabBarController?.tabBar.isHidden = false
          self.navigationController?.navigationBar.isHidden = false
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexTitlesArray.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexTitlesArray
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let image = cell.viewWithTag(1) as! UIImageView
        let title = cell.viewWithTag(2) as! UILabel
        let artist = cell.viewWithTag(3) as! UILabel
        guard let songKey = indexTitlesArray[indexPath.section] as? String else{
            self.table.reloadData()
            return UITableViewCell()
        }
        let songValues = songsDictionnary[songKey]!
       
        image.setImage(with: URL(string:  songValues[indexPath.row].image_src), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        
        title.text =  songValues[indexPath.row].song_name
        artist.text = songValues[indexPath.row].artist_name
        let button = cell.viewWithTag(4) as! UIButton
        button.isUserInteractionEnabled = false
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let q = self.storyboard?.instantiateViewController(withIdentifier: "ChoisirTypeDeChantViewController") as! ChoisirTypeDeChantViewController
       var index = 0
        let songValue = songsDictionnary[indexTitlesArray[indexPath.section]]![indexPath.row]
        for i in 0...((self.songs_singtn.arrayObject?.count)! - 1) {
            
            if self.songs_singtn[i]["song_src"].stringValue ==  songValue.song_src {
               q.index = index
            }
            index = index + 1
        }
        q.song = self.songs_singtn
       
      self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(q, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }

    func getSongs(){
        self.indexTitlesArray = [String]()
        self.songsDictionnary =  [String : [DefaultSongs]]()
    let header : HTTPHeaders = ["Content-Type" : "application/json"]
        Alamofire.request(ScriptBase.sharedInstance.songs, method: .get, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            if response.error == nil {
                let b = JSON(response.data)
                print(b)
                if b["status"].stringValue == "true" {
                    self.songs_singtn = b["data"]
                    if self.songs_singtn.arrayObject?.count != 0 {
                        for i in 0...((self.songs_singtn.arrayObject?.count)! - 1) {
                            if var songValues = self.songsDictionnary[self.songs_singtn[i]["song_name"].stringValue.prefix(1).uppercased()] {
                                 songValues.append(DefaultSongs(id: self.songs_singtn[i]["id"].stringValue, song_src: self.songs_singtn[i]["song_src"].stringValue, song_name: self.songs_singtn[i]["song_name"].stringValue, lyric_src: self.songs_singtn[i]["lyric_name"].stringValue, image_src: self.songs_singtn[i]["image_src"].stringValue, artist_name: self.songs_singtn[i]["artist_name"].stringValue))
                                self.songsDictionnary[self.songs_singtn[i]["song_name"].stringValue.prefix(1).uppercased()] = songValues
                            }else{
                               self.songsDictionnary[self.songs_singtn[i]["song_name"].stringValue.prefix(1).uppercased()] = [DefaultSongs(id: self.songs_singtn[i]["id"].stringValue, song_src: self.songs_singtn[i]["song_src"].stringValue, song_name: self.songs_singtn[i]["song_name"].stringValue, lyric_src: self.songs_singtn[i]["lyric_name"].stringValue, image_src: self.songs_singtn[i]["image_src"].stringValue, artist_name: self.songs_singtn[i]["artist_name"].stringValue)]
                                
                            }
                           
                            
                            
                            
                            
                        }
                    }
                    self.indexTitlesArray = [String] (self.songsDictionnary.keys)
                    self.indexTitlesArray = self.indexTitlesArray.sorted(by: { $0 < $1
                    })
                    self.table.reloadData()
                }
                
                
            }else{
                let alert = UIAlertController(title: "Repository", message: "no songs are available", preferredStyle: .alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : nil))
                
                // show the alert
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  self.indexTitlesArray.count != 0 ? self.indexTitlesArray[section] : ""
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
