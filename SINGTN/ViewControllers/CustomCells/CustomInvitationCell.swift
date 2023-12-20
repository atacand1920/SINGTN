//
//  CustomInvitationCell.swift
//  SINGTN
//
//  Created by macbook on 2018-06-21.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
class CustomInvitationCell : UITableViewCell {
    @IBOutlet weak var joinBTN : CustomSongButton!
    @IBOutlet weak var ImgProfile : UIImageView!
    
    @IBOutlet weak var typeIMG: RoundedUIImageView!
    @IBOutlet weak var TextL : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func JoinAction(_ sender: CustomSongButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let q = storyboard.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        q.song = [sender.song]
        q.index = 0
        q.isSolo = false
        if sender.song["category"].stringValue == "DUOC" {
        q.isDuoCreate = "DUOJ"
        }else if sender.song["category"].stringValue == "GROUPC" {
            q.isDuoCreate = "GROUPJ"
        }
        print(q.song)
       self.viewContainingController()?.navigationController?.pushViewController(q, animated: true)
       // navigation.pushViewController(q, animated: true)
        
    }
}
