//
//  ChoisirTypeDeChantViewController.swift
//  SINGTN
//
//  Created by macbook on 2018-07-31.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
struct CategorySong {
    var title: String!
    var active : Bool!
}
class ChoisirTypeDeChantViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var table : UITableView!
    var song: JSON = []
    var Category : [CategorySong] = []
    var index = 0
    var CustomLyrics: [String] = []
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.count
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let title = cell.viewWithTag(1) as! UILabel
        switch indexPath.row {
        case 0:
            title.text = self.Category[indexPath.row].title
            
            cell.backgroundColor = UIColor(red: 254/255, green: 224/255, blue: 107/255, alpha: 1)
        case 1:
            title.text = self.Category[indexPath.row].title
            
            
             cell.backgroundColor = UIColor(red: 122/255, green: 174/255, blue: 233/255, alpha: 1)
        default:
            title.text = self.Category[indexPath.row].title
             cell.backgroundColor = UIColor(red: 184/255, green: 141/255, blue: 214/255, alpha: 1)
        }
        return cell
    }
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:

            let q = self.storyboard?.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
            q.song = self.song
            q.index = self.index
            q.isSolo = true
        
            self.navigationController?.pushViewController(q, animated: true)
            
        case 1:
            let alert = UIAlertController(title: "DUO MODE", message: "Create a new one or join a partner?", preferredStyle: .alert)
            // add an action (button)
          
            alert.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default,handler : { (alert) in
               
                let q = self.storyboard?.instantiateViewController(withIdentifier: "LyricWorkground") as! LyricWorkground
                
                q.song = self.song
                q.index = self.index
                
                let navigationcontroller : UINavigationController = UINavigationController(rootViewController: q)
                navigationcontroller.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                
               // self.present(navigationcontroller, animated: true, completion: nil)
                self.present(navigationcontroller, animated: true, completion: {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.CustomLyricsCallBack(_:)), name: NSNotification.Name(rawValue: "CustomLyrics"), object: nil)
                })
            
                
               // self.navigationController?.present(q, animated: true, completion: nil)
                //self.navigationController?.pushViewController(q, animated: true)
                
                print("Still need Karaoke Conf")
            }))
            alert.addAction(UIAlertAction(title: "Join", style: UIAlertAction.Style.default,handler : { (alert) in
                if self.Category[indexPath.row].active {
                    // Another View selection controller
                    let q = self.storyboard?.instantiateViewController(withIdentifier: "DuoGroupController") as! DuoGroupController
                    q.isDuo = true
                    q.idSongToFetch = self.song[self.index]["id"].stringValue
                    self.navigationController?.pushViewController(q, animated: true)
                }else{
                    let alert2 = UIAlertController(title: "DUO MODE", message: "No one singed this song in the Duo mode, be the first", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "understood", style: .default, handler: nil))
                    DispatchQueue.main.async(execute: {
                        self.present(alert2, animated: true, completion: nil)
                    })
                }
                
            }))
            
            // show the alert
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
          
        default:
            let alert = UIAlertController(title: "GROUP MODE", message: "Create a new one or join  partners?", preferredStyle: .alert)
            // add an action (button)
            
            alert.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default,handler : { (alert) in
               /* let q = self.storyboard?.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
                q.song = self.song
                q.index = self.index
                
                self.navigationController?.pushViewController(q, animated: true) */
                 print("Still need Karaoke Conf")
                
            }))
            alert.addAction(UIAlertAction(title: "Join", style: UIAlertAction.Style.default,handler : { (alert) in
                if self.Category[indexPath.row].active {
                    // Another View selection controller
                    let q = self.storyboard?.instantiateViewController(withIdentifier: "DuoGroupController") as! DuoGroupController
                q.isDuo = false
                    q.idSongToFetch = self.song[self.index]["id"].stringValue
                    self.navigationController?.pushViewController(q, animated: true)
                }else{
                    let alert2 = UIAlertController(title: "DUO MODE", message: "No one has make a group mode for this song, be the first", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "understood", style: .default, handler: nil))
                    DispatchQueue.main.async(execute: {
                        self.present(alert2, animated: true, completion: nil)
                    })
                }
                
            }))
            
            // show the alert
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
        }
        
    }
    @objc func CustomLyricsCallBack(_ notification : NSNotification) {
        
        guard let  data = notification.object as? [String] else {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CustomLyrics"), object: nil)
            return
        }
        
        
        self.CustomLyrics = data
        
      /*  let q = self.storyboard?.instantiateViewController(withIdentifier: "SaveAndShareController") as! SaveAndShareController
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        q.Songs = self.song
        q.index = self.index
        q.SongToSave = documentDirectory.appendingPathComponent("mixed.amr")
        q.CustomLyrics = self.CustomLyrics
          q.typeOfMedia = "Audio" */
       
       
        let q = self.storyboard?.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        q.song = self.song
        q.index = self.index
         q.isSolo = true
        q.isDuoCreate = "DUOC"
        ScriptBase.sharedInstance.DUOC_or_DUOJ = "DUOC"
        q.CustomLyrics = self.CustomLyrics
        
        self.navigationController?.pushViewController(q, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.table.frame.height / 3
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.TestAvailableCategories()
    }
    
    func TestAvailableCategories(){
        SwiftSpinner.show("Loading...")
        let header : HTTPHeaders = ["Content-Type" : "application/json"]
        let params : Parameters = [
            "id_song" : self.song[self.index]["id"].stringValue
        ]
        Alamofire.request(ScriptBase.sharedInstance.getCategorySong, method: .post, parameters: params ,  encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            if response.error == nil {
                SwiftSpinner.hide()
                let b = JSON(response.data)
                print(b)
                if b["status"].stringValue == "true" {
                  
        self.Category.append(CategorySong(title: "SOLO", active: b["data"]["SOLO"].intValue == 1))
             self.Category.append(CategorySong(title: "DUO", active: b["data"]["DUO"].intValue == 1))
                self.Category.append(CategorySong(title: "GROUP", active: b["data"]["GROUP"].intValue == 1))
                    
                    self.table.reloadData()
                }
                
                
            }else{
                SwiftSpinner.hide()
                let alert = UIAlertController(title: "Repository", message: "An Unkown error has occured", preferredStyle: .alert)
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
