//
//  RadioButtonsController.swift
//  TestApp
//
//  Created by Al Shamas Tufail on 24/03/2015.
//  Copyright (c) 2015 Al Shamas Tufail. All rights reserved.
//

import Foundation
import UIKit

/// RadioButtonControllerDelegate. Delegate optionally implements didSelectButton that receives selected button.
@objc protocol SSRadioButtonControllerDelegate {
    /**
        This function is called when a button is selected. If 'shouldLetDeSelect' is true, and a button is deselected, this function
    is called with a nil.
    
    */
    @objc func didSelectButton(selectedButton: SSRadioButton?)
}

class SSRadioButtonsController : NSObject
{
    fileprivate var buttonsArray = [SSRadioButton]()
    weak var delegate : SSRadioButtonControllerDelegate? = nil
    /**
        Set whether a selected radio button can be deselected or not. Default value is false.
    */
    var shouldLetDeSelect = false
    /**
        Variadic parameter init that accepts UIButtons.

        - parameter buttons: Buttons that should behave as Radio Buttons
    */
    init(buttons: SSRadioButton...) {
        super.init()
        for aButton in buttons {
            aButton.addTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
        }
        self.buttonsArray = buttons
    }
    /**
        Add a UIButton to Controller

        - parameter button: Add the button to controller.
    */
    func addButton(_ aButton: SSRadioButton) {
        buttonsArray.append(aButton)
        aButton.addTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
    }
    /** 
        Remove a UIButton from controller.

        - parameter button: Button to be removed from controller.
    */
    func removeButton(_ aButton: SSRadioButton) {
        var iteratingButton: SSRadioButton? = nil
        if(buttonsArray.contains(aButton))
        {
            iteratingButton = aButton
        }
        if(iteratingButton != nil) {
            buttonsArray.remove(at: buttonsArray.index(of: iteratingButton!)!)
            iteratingButton!.removeTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
            iteratingButton!.isSelected = false
        }
    }
    /**
        Set an array of UIButons to behave as controller.
        
        - parameter buttonArray: Array of buttons
    */
    func setButtonsArray(_ aButtonsArray: [SSRadioButton]) {
        for aButton in aButtonsArray {
            aButton.addTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
        }
        buttonsArray = aButtonsArray
    }

    @objc public func pressed(_ sender: SSRadioButton) {
        var currentSelectedButton: SSRadioButton? = nil
        if(sender.isSelected) {
            if shouldLetDeSelect {
               
                sender.tintsColor = UIColor.white
                currentSelectedButton = nil
            }
        } else {
            for aButton in buttonsArray {
                 aButton.tintsColor = UIColor.white
            }
            //sender.isSelected = true
            sender.tintsColor = UIColor.black
            currentSelectedButton = sender
        }
        delegate?.didSelectButton(selectedButton: currentSelectedButton)
    }
    /**
        Get the currently selected button.
    
        - returns: Currenlty selected button.
    */
    func selectedButton() -> SSRadioButton? {
        guard let index = buttonsArray.index(where: { button in button.tintsColor != .white }) else { return nil }
        
        return buttonsArray[index]
    }
}
