//
//  HeaderViewCont.swift
//  SINGTN
//
//  Created by macbook on 2018-06-25.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
class HeaderViewCont : UIView {
    
    @IBOutlet weak var backgroundImageFace : UIImageView!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var abonnee : UILabel!
    @IBOutlet weak var abonnement : UILabel!
    @IBOutlet weak var descriptionArea : UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    func setupView(){
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
