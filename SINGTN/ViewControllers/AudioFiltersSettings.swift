//
//  AudioFiltersSettings.swift
//  SINGTN
//
//  Created by macbook on 2018-11-06.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class AudioFiltersSettings: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var table : UITableView!
    var objects:[Effect] = []
    var effects : [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.delegate = self
        self.table.dataSource = self
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getFilters()
    }
    func getFilters(){
        effects = []
        objects = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EffectsAudio")
        do {
            effects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        objects.append(Effect(name: "None (System)",image: UIImage(), delay: 0.0, delayMixer: 0.50, reverb: 0.60, reverbMixer: 0.50))
        objects.append(Effect(name: "Small Boost (System)", image: UIImage(named: "all filter"),delay: 0.71, delayMixer: 0.91, reverb: 0.60, reverbMixer: 0.50))
        objects.append(Effect(name: "Small Room (System)", image: UIImage(named: "all filter"),delay: 0.68, delayMixer: 0.50, reverb: 0.89, reverbMixer: 0.50))
        objects.append(Effect(name: "Big Room (System)", image: UIImage(named: "all filter"),delay: 0.85, delayMixer: 0.84, reverb: 0.86, reverbMixer: 0.60))
        if effects.count != 0 {
            for obj in effects {
                objects.append(Effect(name: obj.value(forKey: "name") as? String, image: UIImage(), delay: obj.value(forKey: "delay") as? Double, delayMixer: obj.value(forKey: "delayMixer") as? Double, reverb: obj.value(forKey: "reverb") as? Double, reverbMixer: obj.value(forKey: "reverbMixer") as? Double))
            }
        }
        self.table.reloadData()
        
    }
    
    
    @IBAction func AddNewFiltersAction(_ sender: UIBarButtonItem) {
        let q = self.storyboard?.instantiateViewController(withIdentifier: "AddNewFilters") as! AddNewFilters
        q.effects = self.objects
        q.navigation = self.navigationController!
        self.navigationController?.pushViewController(q, animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        label.text = self.objects[indexPath.row].name
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0, 1, 2, 3:
             cell.enable(on: false)
        default:
            cell.enable(on: true)
        }
        return cell
    }
   
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let suppAction = UIContextualAction(style: .destructive, title: "delete") { (action, view, success) in
            print("deleted")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.effects[indexPath.row - 4])
            appDelegate.saveContext()
            self.effects.remove(at: indexPath.row - 4)
            success(true)
        }
        return UISwipeActionsConfiguration(actions: [suppAction])
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        case 0 , 1, 2, 3:
            return false
        default:
            return true
        }
    }
    
}
extension UITableViewCell {
    func enable(on: Bool) {
        self.isUserInteractionEnabled = on
        for view in contentView.subviews {
            self.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}
