//
//  CustomPickerRowView.swift
//  CustomUIPickerCell
//
//  Created by Frederik Jacques on 05/07/15.
//  Copyright (c) 2015 Frederik Jacques. All rights reserved.
//

import UIKit
struct RowData {
    
   
    let title:String
    
}
class CustomPickerRowView: UIView {

    // MARK: - IBOutlets
    
    // MARK: - Properties
    let rowData:RowData
    
   
    var label:UILabel!
    
    var didSetupConstraints:Bool = false
    
    // MARK: - Initializers methods
    init(frame: CGRect, rowData:RowData) {
        
        self.rowData = rowData
        
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        
       
        createLabel()
        
        //label.autoCenterInSuperview()
        
       
        label.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -6)
        label.autoPinEdge(.leading, to: .leading, of: self, withOffset : 2)
    }

    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }

    
    private func createLabel(){
    
        label = UILabel.newAutoLayout()
       
        
        //label.addConstraint(constraint)
        
        
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Verdana", size: 19.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = rowData.title
        addSubview(label)
        
    }
    
    // MARK: - Public methods
    
    // MARK: - Getter & setter methods
    
    // MARK: - IBActions
    
    // MARK: - Target-Action methods
    
    // MARK: - Notification handler methods
    
    // MARK: - Datasource methods
    
    // MARK: - Delegate methods

}
