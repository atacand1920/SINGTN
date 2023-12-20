//
//  LSBBAR.swift
//  SINGTN
//
//  Created by macbook on 2018-08-14.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
@IBDesignable class LSBBAR : UISlider {
    let TOLLightLaterSize : CGSize = CGSize(width: 10.0, height: 12.0)
    let TOLTargetLightPadding : CGFloat = -3.0

    @IBInspectable var  leftChannelLevel : CGFloat = 0.5
    @IBInspectable var  rightChannelLevel : CGFloat = 0.5
    @IBInspectable var  inactiveColor : UIColor = UIColor(red: 0.19, green: 0.19, blue: 0.19, alpha: 0.8)
    @IBInspectable var  activeColor : UIColor = UIColor(red: 0.376, green: 0.4, blue: 0.416, alpha: 1)
    @IBInspectable var glowColors : NSArray = []
    var leftChannelLightLayers : NSMutableArray = []
    var rightChannelLightLayers : NSMutableArray = []
    override func awakeFromNib() {
        self.setup()
        super.awakeFromNib()
    }
    override init(frame: CGRect) {
       
        super.init(frame: frame)
         self.setup()
    }
    func setup() {
        var emptyImage : UIImage? = nil
        self.setMinimumTrackImage(emptyImage, for: .normal)
        self.setMaximumTrackImage(emptyImage, for: .normal)
        self.leftChannelLightLayers = NSMutableArray()
        self.rightChannelLightLayers = NSMutableArray()
        self.glowColors = [UIColor(red: 0, green: 0.90, blue: 0.29, alpha: 1),UIColor(red: 1, green: 0.82, blue: 0.27, alpha: 1),UIColor(red: 1, green: 0.38, blue: 0.14, alpha: 1),UIColor(red: 1, green: 0, blue: 0.08, alpha: 1)]
        self.leftChannelLevel = 0.5
        self.rightChannelLevel = 0.5
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let numberOfLights : CGFloat =  CGFloat(floorf(Float((self.bounds.width - TOLTargetLightPadding)/(TOLLightLaterSize.width + TOLTargetLightPadding))))
        let totalWidth = self.bounds.width
        let lightWidth = TOLLightLaterSize.width
        let actualPadding = roundf((Float(totalWidth - numberOfLights*lightWidth))/Float((numberOfLights + 1)))
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
