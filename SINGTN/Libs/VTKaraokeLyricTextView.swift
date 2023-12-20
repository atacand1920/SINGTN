//
//  VTKaraokeLyricTextView.swift
//  SINGTN
//
//  Created by macbook on 2018-08-14.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
protocol VTKaraokeLyricTextViewDelegate:class {
    func karaokeLyric(textView: VTKaraokeLyricTextView, didStartAnimation: CAAnimation)
    func karaokeLyric(textView: VTKaraokeLyricTextView, didStopAnimation: CAAnimation, finished: Bool)
}
final class VTKaraokeLyricTextView: UITextView,CAAnimationDelegate,UITextViewDelegate {


    var duration:CGFloat                = 0.25
    
    private var textLayer:CATextLayer   = CATextLayer()
    private let animationKey            = "runLyricSaif"
    
    var isAnimating:Bool {
        return textLayer.speed > 0
    }
    
    var fillTextColor:UIColor? {
        didSet {
            guard let fillTextColor = self.fillTextColor else { return }
            textLayer.foregroundColor = fillTextColor.cgColor
        }
    }
    var lyricSegment:Dictionary<CGFloat,String>? {
        didSet {
            //Array(lyricSegment.keys).sort(<)
            guard let lyricSegment = self.lyricSegment else { return }
            let sortedKeys = Array(lyricSegment.keys.sorted())
            
            var fullText = ""
            for k in sortedKeys {
                
                if let segmentStr = lyricSegment[k] {
                    fullText = fullText.appendingFormat(segmentStr)
                    
                }
                
            }
            
            self.text = fullText
        }
    }
    override var text: String? {
        didSet {
            self.updateLayer()
        }
    }
    
    override var font: UIFont! {
        didSet {
            self.updateLayer()
        }
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
         prepareForLyricTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareForLyricTextView()
    }
    func prepareForLyricTextView() {
        textLayer.removeFromSuperlayer()
        
        textLayer = CATextLayer()
        textLayer.frame = self.bounds
        
        //self.numberOfLines = 1
        self.clipsToBounds = true
        self.textAlignment = .left
        //self.baselineAdjustment = .alignBaselines
        
        textLayer.foregroundColor = fillTextColor?.cgColor ?? UIColor.blue.cgColor
        
        let textFont = self.font
        textLayer.font      = CGFont(textFont!.fontName as CFString)
        textLayer.fontSize  = (textFont?.pointSize)!
        textLayer.string    = self.text
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.masksToBounds = true
        
        textLayer.anchorPoint   = CGPoint(x: 0, y: 0.5)
        textLayer.frame         = self.bounds
        textLayer.isHidden        = true
        self.layer.addSublayer(textLayer)
    }
    // MARK: Animation
    func animationForTextLayer() -> CAKeyframeAnimation {
        textLayer.isHidden = false
        
        let textAnim = CAKeyframeAnimation(keyPath: "bounds.size.width")
        textAnim.duration   = CFTimeInterval(self.duration)
        textAnim.values     = valuesFromLyricSegment()
        textAnim.keyTimes   = keyTimesFromLyricSegment() as [NSNumber]
        textAnim.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)]
        textAnim.isRemovedOnCompletion   = true
        textAnim.delegate              = self
        
        return textAnim
    }
    // MARK: Help methods
    
    func updateLayer() {
        self.sizeToFit()
        self.setNeedsLayout()
        self.prepareForLyricTextView()
    }
    func valuesFromLyricSegment() -> Array<CGFloat> {
        let layerWidth = textLayer.bounds.size.width
        
        guard let lyricSegment = self.lyricSegment else {
            return [0.0,layerWidth]
        }
        
        var values:Array<CGFloat> = [0.0]
        let sortedKeys = Array(lyricSegment.keys.sorted())
        
        var val:CGFloat = 0
        for k in sortedKeys {
            let str = lyricSegment[k]!
            
            let strWidth = str.size(withAttributes:[NSAttributedString.Key.font : self.font]).width
            val += strWidth
            values.append(val)
        }
        
        return values
    }
    func keyTimesFromLyricSegment() -> Array<CGFloat> {
        
        guard let lyricSegment = self.lyricSegment else {
            return [0.0, 1.0]
        }
        
        let keyTimes:Array<CGFloat> = [0.0] + Array(lyricSegment.keys.sorted()) + [1.0]
        return keyTimes
    }
    func pauseLayer() {
        let pauseTime = textLayer.convertTime(CACurrentMediaTime(), from: nil)
        textLayer.speed = 0.0
        textLayer.timeOffset = pauseTime
    }
    func resumeLayer() {
        let pauseTime = textLayer.timeOffset
        textLayer.speed = 1.0;
        textLayer.timeOffset = 0.0;
        textLayer.beginTime = 0.0;
        textLayer.beginTime = textLayer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
    }
    // MARK: Main methods
    
    func startAnimation() {
        guard let _ = textLayer.animation(forKey: animationKey) else {
            
            let anim = self.animationForTextLayer()
            textLayer.add(anim, forKey: animationKey)
            
            return
        }
    }
    
    func pauseAnimation() {
        guard let _ = textLayer.animation(forKey: animationKey) else {
            return
        }
        
        self.pauseLayer()
    }
    
    func resumeAnimation() {
        guard let _ = textLayer.animation(forKey: animationKey) else {
            return
        }
        
        self.resumeLayer()
    }
    func reset() {
        textLayer.removeAnimation(forKey: animationKey)
        textLayer.isHidden = true
    }
    // MARK: Delegate

    func animationDidStart(_ anim: CAAnimation) {
        //self.delegate?.karaokeLyric(textView: self, didStartAnimation: anim)
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //self.delegate?.karaokeLyric(textView: self, didStopAnimation: anim, finished: flag)
    }
}
