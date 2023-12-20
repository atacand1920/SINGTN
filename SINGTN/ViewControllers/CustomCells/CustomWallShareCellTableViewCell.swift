//
//  CustomWallShareCellTableViewCell.swift
//  SINGTN
//
//  Created by macbook on 2018-09-18.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import UIKit

class CustomWallShareCellTableViewCell: UITableViewCell {
   
   

    
    
    @IBOutlet weak var FirstSingerImg: UIImageView!
    @IBOutlet weak var FirstSingerLBL: UILabel!
    @IBOutlet weak var SecondSingerImg: UIImageView!
    @IBOutlet weak var BackgroundImg: UIImageView!
    
    @IBOutlet weak var SecondSingerLBL: UILabel!
    @IBOutlet weak var and: UILabel!
    
  
    
    @IBOutlet weak var song_title: UILabel!
    
    @IBOutlet weak var ContainerShareable : UIView!
    @IBOutlet weak var Share_Name : UILabel!
    @IBOutlet weak var Share_Picture : UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        FirstSingerLBL.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
        SecondSingerLBL.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
