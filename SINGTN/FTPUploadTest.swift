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
class LyricWorkground : UIViewController , SSRadioButtonControllerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lyric.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let lbl = cell.viewWithTag(1) as! UILabel
        //lbl.text = ItemsTable[indexPath.row]
        lbl.text = self.lyric[CGFloat(indexPath.row)]
        return cell
    }
    
    func didSelectButton(selectedButton: SSRadioButton?) {
        print(selectedButton?.tag as Any)
    }
    let ItemsTable : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r"]
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var Me: SSRadioButton!
    @IBOutlet weak var Partner: SSRadioButton!
    @IBOutlet weak var Together: SSRadioButton!
    @IBOutlet weak var CheatView : UIView!
    var lyricsToParse : String = ""
    var lastSelectedCell = IndexPath()
    var song : JSON = []
    var index : Int = 0
    private var lyric : Dictionary<CGFloat, String> = [:]
     var radioButtonController: SSRadioButtonsController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
        self.CheatView.isHidden = true
        SwiftSpinner.show("Loading...")
        if let url = URL(string: (self.song[index]["lyric_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
            do {
                let contents = try String(contentsOf: url)
                lyricsToParse = contents
                let lyricParser = VTBasicKaraokeLyricParser()
                self.lyric = lyricParser.lyricFromLRCString(lrcStr: lyricsToParse).content!
                SwiftSpinner.hide()
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
        print(selectedOptions)
        switch selectedOptions {
        case Me:
            cell?.backgroundColor = Me.circleColor
        case Partner :
            cell?.backgroundColor = Partner.circleColor
        case Together :
            cell?.backgroundColor = Together.circleColor
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
    /*func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    } */
    
}
