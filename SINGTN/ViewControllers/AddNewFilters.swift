//
//  AddNewFilters.swift
//  SINGTN
//
//  Created by macbook on 2018-11-06.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AudioKitUI
import CoreData
class AddNewFilters: UIViewController {
    var effects : [Effect] = []
    var navigation : UINavigationController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appdelegate.preapare_audioKit()
        do {
            try AudioKit.start()
        }catch let error as NSError {
            print("Could not start audioKit. \(error), reason \(error.userInfo)")
        }
        setupUI()
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        do {
            
            
            //AudioKit.disconnectAllInputs()
            try AudioKit.stop()
            
        }catch let error as NSError {
            print(error)
        }
    }
    @IBAction func saveData(_ button: UIButton) {
        var alert : UIAlertController! = UIAlertController(title: "New Filter", message: "", preferredStyle: .alert)
        alert.addTextField { (text) in
            text.placeholder = "Filter name"
            text.clearButtonMode = UITextField.ViewMode.whileEditing
            text.borderStyle = .roundedRect
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (al) in
            let textF = alert!.textFields?.first!
            var verif = true
            for f in self.effects {
                if f.name == textF?.text {
                    verif = false
                    break
                }
            }
            if verif {
                
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                let entity =
                    NSEntityDescription.entity(forEntityName: "EffectsAudio",
                                               in: managedContext)!
                let filters = NSManagedObject(entity: entity,
                                             insertInto: managedContext)
                
                filters.setValue(textF?.text, forKey: "name")
                filters.setValue(appDelegate.delay.feedback, forKey: "delay")
                filters.setValue(appDelegate.delayMixer.balance, forKey: "delayMixer")
                filters.setValue(appDelegate.reverb.feedback, forKey: "reverb")
                filters.setValue(appDelegate.reverbMixer.balance, forKey: "reverbMixer")
                do {
                    if AudioKit.engine.isRunning {
                        
                        AudioKit.disconnectAllInputs()
                        try AudioKit.stop()
                    }
                    try managedContext.save()
                    self.navigation?.popViewController(animated: true)
                }catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                
            }else{
                alert = UIAlertController(title: "New Filter", message: "this name already exist", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (al) in
                    self.saveData(UIButton())
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
        
    }
    func setupUI() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
 
        
        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Feedback",
            format: "%0.2f",
            value: appdelegate.delay.feedback, minimum: 0, maximum: 0.99,
            color: UIColor.green) { sliderValue in
                appdelegate.delay.feedback = sliderValue
        })
        
        stackView.addArrangedSubview(AKPropertySlider(
            property: "Delay Mix",
            format: "%0.2f",
            value: appdelegate.delayMixer.balance, minimum: 0, maximum: 1,
            color: UIColor.blue) { sliderValue in
                appdelegate.delayMixer.balance = sliderValue
        })
        
        stackView.addArrangedSubview(AKPropertySlider(
            property: "Reverb Feedback",
            format: "%0.2f",
            value: appdelegate.reverb.feedback, minimum: 0, maximum: 0.99,
            color: UIColor.red) { sliderValue in
                appdelegate.reverb.feedback = sliderValue
        })
        
        stackView.addArrangedSubview(AKPropertySlider(
            property: "Reverb Mix",
            format: "%0.2f",
            value: appdelegate.reverbMixer.balance, minimum: 0, maximum: 1,
            color: UIColor.yellow) { sliderValue in
                appdelegate.reverbMixer.balance = sliderValue
        })
        
        view.addSubview(stackView)
        
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true
        stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1).isActive = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
