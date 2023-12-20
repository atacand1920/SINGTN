//
//  PlayerSlider.swift
//  Player
//
//  Created by Pavel Yevtukhov on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit

protocol PlayerSliderProtocol: class {
    /**
     delegate of the slider
     :param: progress Float
     remaining VLCTime
     actual VLCTime
     */
    func onValueChanged(progress: Float, remaining: VLCTime, actual: VLCTime)
}

class PlayerSlider: ViewWithXib {

    // MARK: Constants
    
    private let maximumUnitCount = 2
    private let sliderMinimumValue: Float = 0
    private let sliderMaximumValue: Float = 1.0
    
    // MARK: Properties
    
    var delegate: PlayerSliderProtocol?
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
    
    // MARK: Outlets
    
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
    public func setProgress(_ prog : Float) {
        self._progress = prog
        
            self._actualTime = VLCTime(int: 0)
            self._remainingTime = VLCTime(int: 0)
        
        self.notifyDelegate()
        self.updateProgressNew(self._progress, remaining: self._remainingTime, actualTime: self._actualTime)
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
	
	override func initUI() {
		super.initUI()
		self.sliderView.addTarget(self, action: #selector (dragDidBegin), for: .touchDragInside)
		self.sliderView.addTarget(self, action: #selector (dragDidEnd), for: .touchUpInside)
		self.sliderView.setThumbImage(UIImage(named: "slider_thumb", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
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
	
}
