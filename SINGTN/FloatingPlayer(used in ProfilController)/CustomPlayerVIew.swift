//
//  CustomPlayerVIew.swift
//  SINGTN
//
//  Created by macbook on 2018-09-27.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import UIKit
protocol CustomPlayerVIewDelegate {
    
    func OnchangePlayerButton(_ sender: UIButton)
     func onValueChanged(progress: Float, remaining: VLCTime, actual: VLCTime)
}

@IBDesignable
 class CustomPlayerVIew: UIView {
 var delegate: CustomPlayerVIewDelegate?
     @objc var view: UIView!
   @IBOutlet private var player_container : UIView!
    @IBOutlet private var player_slider : UIView! 
   @IBOutlet private  var playBTN : UIButton!
    @IBOutlet private var AdView : UIView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     
    */
    
    // MARK: Constants
    
    private let maximumUnitCount = 2
    private let sliderMinimumValue: Float = 0
    private let sliderMaximumValue: Float = 1.0
    var duration: TimeInterval = TimeInterval() {
        didSet {
            //updateProgress(self.progress,Remaining: )
        }
    }
    var remainingTime : VLCTime {
        
        get {
            return _remainingTime
        }
    }
    var progress: Float {
        
        get {
            return _progress
        }
    }
    private var _remainingTime : VLCTime = VLCTime(int: 0)
    private var _actualTime : VLCTime = VLCTime(int: 0)
    private var _progress: Float = 0
    private var isDragging = false
    @IBOutlet private weak var pastLabel: UILabel!
    @IBOutlet private weak var remainLabel: UILabel!
    @IBOutlet private weak var sliderView: UISlider!
    @IBAction private func sliderValueDidChanged(_ sender: Any) {
        updateProgressNew(sliderView.value,remaining: self._remainingTime,actualTime:self._actualTime )
    }
    
    // MARK:
    private func updateProgress(_ progress: Float, Remaining : VLCTime) {
        var actualValue = progress >= sliderMinimumValue ? progress: sliderMinimumValue
        actualValue = progress <= sliderMaximumValue ? actualValue: sliderMaximumValue
        
        self._progress = actualValue
        
        self.sliderView.value = actualValue
        
        let pastInterval = Float(duration) * actualValue
        let remainInterval = Float(duration) - pastInterval
        
        self.pastLabel.text = intervalToString(TimeInterval(pastInterval))
        self.remainLabel.text = intervalToString(TimeInterval(remainInterval))
        
    }
    public func updateProgressNew(_ progress: Float,remaining: VLCTime,actualTime: VLCTime) {
        var actualValue = progress >= sliderMinimumValue ? progress: sliderMinimumValue
        actualValue = progress <= sliderMaximumValue ? actualValue: sliderMaximumValue
        
        self._progress = actualValue
        self._remainingTime = remaining
        self.sliderView.value = actualValue
        
        let pastInterval = Float(duration) * actualValue
        let remainInterval = Float(remaining.intValue)
        //print("pastInterval:",pastInterval)
        //print("remainInterval: ",remainInterval)
        //self.pastLabel.text = intervalToString(TimeInterval(pastInterval))
        //self.remainLabel.text = intervalToString(TimeInterval(remainInterval))
        self.remainLabel.text = remaining.stringValue
        self.pastLabel.text = actualTime.stringValue
    }
    
    private func intervalToString (_ interval: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.maximumUnitCount = maximumUnitCount
        return formatter.string(from: interval)
    }
    @objc private func dragDidBegin() {
        isDragging = true
    }
    
    @objc private func dragDidEnd() {
        self.isDragging = false
        self.notifyDelegate()
    }
    
    private func notifyDelegate() {
        let timePast = self.duration * Double(sliderView.value)
        self.delegate?.onValueChanged(progress: sliderView.value, remaining: _remainingTime, actual : _actualTime)
    }
     @IBAction func play_pause_BTN(_ sender: UIButton) {
    delegate?.OnchangePlayerButton(sender)
    
    }
    func changeButtonImage(image:UIImage){
        playBTN.setImage(image, for: .normal)
    }
    var SliderView : UIView = UIView(){
        didSet {
            //SliderView.frame = CGRect(x: self.player_slider.frame.origin.x, y: self.player_slider.frame.origin.y, width: self.player_slider.frame.width, height: self.player_slider.frame.height)
           //self.player_slider.addSubview(SliderView)
            //self.player_container.bringSubviewToFront(player_slider)
           // self.bringSubviewToFront(player_container)
            //self.player_slider.backgroundColor = UIColor.
        }
    }
    var AdMobView : UIView = UIView() {
        
        didSet {
         
            self.AdView.addSubview(AdMobView)
            
        }
        
    }
    override  init(frame : CGRect) {
      
        
        super.init(frame: frame)
        self.createUI(frame:frame)
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.createUI()
    }
    private func createUI(frame:CGRect) {
        self.layoutIfNeeded()
        view = loadViewFromNib()
        view.frame = CGRect(x: 0, y: 0, width: frame.width, height: 224)
        //view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        //coverImageView.backgroundColor = UIColor.clear
        self.frame = CGRect(x: 0, y: 0, width: frame.width, height: 224)
        view.backgroundColor = UIColor.white
        //self.makeItRounded(view: view, newSize: view.bounds.width)
        self.backgroundColor = UIColor.blue
        
        addSubview(view)
        self.sliderView.addTarget(self, action: #selector (dragDidBegin), for: .touchDragInside)
        self.sliderView.addTarget(self, action: #selector (dragDidEnd), for: .touchUpInside)
        self.sliderView.setThumbImage(UIImage(named: "slider_thumb", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
    }
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomPlayerView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
