//
//  VTKaraokeLyricsController.swift
//  SINGTN
//
//  Created by macbook on 2018-08-15.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
@objc protocol VTKaraokeLyricsDataSource:class {
    func timesForLyricPlayerView(playerView: VTKaraokeLyricsController) -> Array<CGFloat>
    func lyricPlayerView(playerView: VTKaraokeLyricsController, atIndex:NSInteger) -> VTKaraokeLyricLabel
    
    @objc optional func lengthOfLyricPlayerView(playerView: VTKaraokeLyricsController) -> CFTimeInterval
    
    func lyricPlayerView(playerView: VTKaraokeLyricsController, allowLyricAnimationAtIndex: NSInteger) -> Bool
}
@objc protocol VTKaraokeLyricsDelegate:class {
    @objc optional func lyricPlayerViewDidStart(playerView: VTKaraokeLyricsController)
    @objc optional func lyricPlayerViewDidStop(playerView: VTKaraokeLyricsController)
}


class VTKaraokeLyricsController : NSObject,UIPickerViewDelegate, UIPickerViewDataSource {
    private var timingForLyric:Array<CGFloat>       = [CGFloat]()
    private var indexTiming:NSInteger               = 0
    private var timeIntervalRemain:CFTimeInterval   = 0
     private var length:CFTimeInterval           = 0
     private var timer:Timer?
    private var isPlaying = false
    weak var dataSource:VTKaraokeLyricsDataSource?
    weak var delegate:VTKaraokeLyricsDelegate?
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let CustomView =  pickerView.view(forRow: row, forComponent: 0) as! CustomPickerRowView
        if row != 0 {
            if self.lyricsKeys.count != 0 {
        switch self.lyricsKeys[row - 1] {
        case "Partner":
            CustomView.label.textColor = ScriptBase.sharedInstance.DUOC_or_DUOJ == "DUOC" ? UIColor.blue : UIColor.white
        case "Together":
            CustomView.label.textColor = UIColor(red: 209/255, green: 84/255, blue: 25/255, alpha: 1)
        default:
            CustomView.label.textColor = ScriptBase.sharedInstance.DUOC_or_DUOJ == "DUOC" ? UIColor.white : UIColor.blue
        }
            }else{
                CustomView.label.textColor = UIColor.white
            }
        }else{
            CustomView.label.textColor = ScriptBase.sharedInstance.DUOC_or_DUOJ == "DUOC" ? UIColor.white : UIColor.blue
        }
        pickerView.selectRow(row, inComponent: 0, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return text.count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.width
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return text[row].title
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let rowData = text[row]
        let customView = CustomPickerRowView(frame: CGRect.zero, rowData: rowData)
        print("viewforRow")
        if row != 0 {
            print("count:",self.lyricsKeys.count)
            if self.lyricsKeys.count != 0 {
                print("color: ",ScriptBase.sharedInstance.DUOC_or_DUOJ)
                switch self.lyricsKeys[row - 1] {
                case "Partner":
                    customView.label.textColor = ScriptBase.sharedInstance.DUOC_or_DUOJ == "DUOC" ? UIColor.blue : UIColor.black
                case "Together":
                    customView.label.textColor = UIColor(red: 209/255, green: 84/255, blue: 25/255, alpha: 1)
                default:
                    customView.label.textColor = ScriptBase.sharedInstance.DUOC_or_DUOJ == "DUOC" ? UIColor.black : UIColor.blue
                }
            }
        }else{
            customView.label.textColor = UIColor.black
        }
        return customView
    }
    var text : [RowData] = []
    var picker : UIPickerView!
    var lyricsKeys:[String]!
    var timing:Array<CGFloat>!
    var lyric:VTKaraokeLyric!
    init(picker:UIPickerView,timingKeys:Array<CGFloat>,lyrics:VTKaraokeLyric,LyricsKeys:[String]) {
      
        self.picker = picker
       self.timing = timingKeys
        self.lyric = lyrics
        self.lyricsKeys = LyricsKeys
        self.text.append(RowData(title: ""))
    }
    func InitController(){
        picker.delegate = self
        picker.dataSource = self
        for a in timing {
            text.append(RowData(title: (lyric?.content![a])!))
        }
       
        
        picker.reloadAllComponents()
        timingForLyric = self.timing
        
        self.startLyrics()
    }
    func prepareToPlay() {
        //self.setup()
        
        
        
        if let dataSource = self.dataSource {
            timingForLyric = dataSource.timesForLyricPlayerView(playerView: self)
            length = dataSource.lengthOfLyricPlayerView?(playerView: self) ?? 0
        }
        
        //nextLabelHaveToUpdate = .Top
        
       // self.showNextLabel()
    }
    private func startLyrics(){
       
       // self.picker.selectRow(0, inComponent: 0, animated: true)
        self.picker.delegate?.pickerView!(picker, didSelectRow: 0, inComponent: 0)
        
    }
    func start(){
        print("Starting Lyrics Plays")
        if self.isLastLyric() {
           // self.prepareToPlay()
            print("It's the last lyrics")
        }else{
            print("No hello no")
            if indexTiming == 0 {
                
                let timing = TimeInterval(timingForLyric[indexTiming] - 3)
                
               
                timer = Timer.scheduledTimer(timeInterval: timing, target: self, selector: #selector(handleAnimationAndShowLabel(timer:)), userInfo: nil, repeats: false)
               
                isPlaying = true
            } else {
               // self.resume()
            }
            
        }
        
    }
    func stop() {
        if isPlaying {
        timer?.invalidate()
            isPlaying = false
        }
    }
    func pause(){
        if let timer = self.timer {
            timeIntervalRemain = timer.fireDate.timeIntervalSinceNow
            timer.invalidate()
            isPlaying = false
        }
    }
    func resume() {
        
        if !isPlaying {
            //lyricBottom.resumeAnimation()
           // lyricTop.resumeAnimation()
            
            timer = Timer.scheduledTimer(timeInterval: timeIntervalRemain, target: self, selector: #selector(handleAnimationAndShowLabel(timer:)), userInfo: nil, repeats: false)
            
            isPlaying = true
        }
        
    }
    @objc func handleAnimationAndShowLabel(timer: Timer) {
         self.picker.delegate?.pickerView!(picker, didSelectRow: self.picker.selectedRow(inComponent: 0) + 1, inComponent: 0)
        //self.picker.selectRow(self.picker.selectedRow(inComponent: 0) + 1, inComponent: 0, animated: true)
        if isLastLyric() == false {
           
            let timing = TimeInterval(self.calculateDurationForLyric())
          
            self.timer = Timer.scheduledTimer(timeInterval: timing, target: self, selector: #selector(handleAnimationAndShowLabel(timer:)), userInfo: nil, repeats: false)
            indexTiming += 1
            //self.showNextLabel()
        } else {
            isPlaying = false
            //self.delegate?.lyricPlayerViewDidStop?(playerView: self)
        }
    }
    func calculateDurationForLyric() -> CGFloat {
        var duration:CGFloat = 0.0
        
        if !isLastLyric() {
            let timing = timingForLyric[indexTiming]
            let nextTiming = timingForLyric[indexTiming+1]
            duration = nextTiming - timing
        }
        
        return duration
    }
    func isLastLyric() -> Bool {
        return indexTiming >= (timingForLyric.count - 1)
    }
    
}
