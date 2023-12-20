//
//  FTPUploadTest.swift
//  SINGTN
//
//  Created by macbook on 2018-10-11.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import SwiftSpinner
struct CustomLyric {
    var lyric : String!
    var owner : String!
}
/**
 this is class control the Lyric treatments form users when creating a new DUO song
 */
class LyricWorkground : UIViewController , SSRadioButtonControllerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate,UITableViewDataSource{
    // MARK: delegate
    func didSelectButton(selectedButton: SSRadioButton?) {
        // don't need it
    }
    
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.LyricsParsed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let lbl = cell.viewWithTag(1) as! UILabel
        lbl.text = self.LyricsParsed[indexPath.row].lyric
        switch self.LyricsParsed[indexPath.row].owner {
        case "Me":
            cell.backgroundColor = UIColor.white
        case "Partner" :
            cell.backgroundColor = UIColor(red: 7 / 255, green: 160/255, blue: 209/255, alpha: 1)
        case "Together" :
            cell.backgroundColor = UIColor(red: 209/255, green: 84/255, blue: 25/255, alpha: 1)
        default:
            break
        }
        return cell
    }

    /**
     our tableView
     */
    @IBOutlet weak var tableView : UITableView!
    /**
     this mean that the the selected lyric belongs to the actual user
     */
    @IBOutlet weak var Me: SSRadioButton!
    /**
     this mean that the selected lyric belongs to the joining user
     */
    @IBOutlet weak var Partner: SSRadioButton!
    /**
     this mean that the selected lyric belongs to all the users
     */
    @IBOutlet weak var Together: SSRadioButton!
    /**
     containing the result of the parsed lyrics
     */
    var LyricsParsed : [CustomLyric] = []
    /**
     contains the timeFrames of each lyric
     */
   private var timingKeys:Array<CGFloat> = [CGFloat]()
    /**
     the lyric to work on it
     */
    var lyricsToParse : String = ""
    /**
     the json containing all the informations of all songs
     */
    var song : JSON = []
    /**
     the index of the selected song
     */
    var index : Int = 0
    /**
     a helper to use for getting timing keys
     */
    private var lyric : VTKaraokeLyric!
    /**
     our radios buttons controller
     */
     var radioButtonController: SSRadioButtonsController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let done = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.FinishAction(_:)))
        self.navigationItem.rightBarButtonItem = done
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.CancelAction(_:)))
         self.navigationItem.leftBarButtonItem = cancel
     radioButtonController = SSRadioButtonsController(buttons: Me,Partner,Together)
        radioButtonController?.pressed(Me)
        radioButtonController?.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.triggerSwipeSeclection(_:)))
        swipe.direction = [.up, .down]
        swipe.delegate = self
        swipe.numberOfTouchesRequired = 1
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.triggerSelection(_:)))
        pan.delegate = self
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        self.tableView.addGestureRecognizer(pan)
        self.tableView.addGestureRecognizer(swipe)
        self.tableView.isScrollEnabled = false
        self.tableView.canCancelContentTouches = true
        self.tableView.allowsMultipleSelection = true
        SwiftSpinner.show("Loading...")
        if let url = URL(string: (self.song[index]["lyric_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
            do {
                let contents = try String(contentsOf: url)
                lyricsToParse = contents
                let lyricParser = VTBasicKaraokeLyricParser()
                self.lyric = lyricParser.lyricFromLRCString(lrcStr: lyricsToParse)
                SwiftSpinner.hide()
                if let lyric = self.lyric , self.lyric?.content != nil {
                    
                    timingKeys = Array(lyric.content!.keys.sorted())
                    
                    for i in 0...((lyric.content?.count)! - 1) {
                        let tKey = timingKeys[i]
                        self.LyricsParsed.append(CustomLyric(lyric: lyric.content![tKey], owner: "Me"))
                    }
                }
                self.tableView.reloadData()
                
            } catch {
                // contents could not be loaded
                print(error.localizedDescription)
            }
            
        } else {
            // the URL was bad!
            print("URL BAD")
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print("DidSelect")
        let selectedOptions = radioButtonController?.selectedButton()
        switch selectedOptions {
        case Me:
            if cell?.backgroundColor != Me.circleColor {
                self.LyricsParsed[indexPath.row].owner = "Me"
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        case Partner :
            
            if cell?.backgroundColor != Partner.circleColor {
                self.LyricsParsed[indexPath.row].owner = "Partner"
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        case Together :
            
            if cell?.backgroundColor != Together.circleColor {
                self.LyricsParsed[indexPath.row].owner = "Together"
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        default:
            break
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
         print("DeSelect")
        cell?.backgroundColor = .white
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Began")
        //xprint(touches)
        self.tableView.isScrollEnabled = true
        
    }
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
          print("Moved")
         //print(touches)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          print("Ended")
         //print(touches)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
          print("Cancelled")
        self.tableView.isScrollEnabled = false
         //print(touches)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func triggerSelection(_ sender : UIPanGestureRecognizer) {
        print("Started Selection :")
        self.tableView.isScrollEnabled = false
        let point = sender.location(in: self.tableView)
        
        guard let index = tableView.indexPathForRow(at: point) else {
            return
        }
        guard let cell = tableView.cellForRow(at: index) else {
            return
        }
        if cell.isSelected {
            //tableView.deselectRow(at: index, animated: true)
            
        }else{
            //tableView.selectRow(at: index, animated: true, scrollPosition: .none)
            tableView.delegate?.tableView!(self.tableView, didSelectRowAt: index)
            
        }
        
    }
       @objc  func triggerSwipeSeclection(_ sender : UISwipeGestureRecognizer) {
         print("Moved Selection")
        self.tableView.isScrollEnabled = true
    }
   
    
    /**
     save the lyric processing
     :param: sender the button that sends the event
     */
    @objc func FinishAction(_ sender: UIBarButtonItem) {
        
        var lyricKeys :[String]  = []
        for i in 0...(self.LyricsParsed.count - 1) {
            lyricKeys.append(self.LyricsParsed[i].owner)
        }
        
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CustomLyrics"), object: lyricKeys)
        }
    }
    /**
     cancel the processing
     :param: sender the button that sends the event
     */
    @objc func CancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
