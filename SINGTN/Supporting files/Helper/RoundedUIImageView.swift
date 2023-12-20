//
//  RoundedUIImageView.swift
//  SpotifyTest
//
//  Created by Bouzid saif on 13/07/2017.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import Foundation
import  UIKit
@IBDesignable
class RoundedUIImageView: UIImageView {
    @IBInspectable var round: Bool = true {
        didSet { self.setNeedsLayout() }
    }
    
    @IBInspectable var width: CGFloat = 2.5 {
        didSet { self.setNeedsLayout() }
    }
    
    @IBInspectable var color: UIColor = UIColor(red: 208, green: 208, blue: 208, alpha: 1){
        didSet { self.setNeedsLayout() }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        
        if round {
            self.layer.cornerRadius = self.frame.width / 2
        } else {
            self.layer.cornerRadius = 0
        }
        
        self.layer.borderWidth = self.width
        self.layer.borderColor = self.color.cgColor
    }
}
