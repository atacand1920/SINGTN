//
//  ProfilController.swift
//  SINGTN
//
//  Created by macbook on 2018-06-25.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import LNPopupController
/**
 this class is responsible of our Profil View.
 */
class ProfilController : UIViewController ,UITableViewDataSource,UITableViewDelegate{
    /**
     this function get the publications of the friends of the user from database.
     
     - Parameters:
     - fresh: a boolean value to indicate if this function is triggered from the refresh button or not.
     */
    
    /**
     the height of the settings table view.
     */
    @IBOutlet weak var heightTableSettings: NSLayoutConstraint!
    /**
    the settings table view.
     */
    @IBOutlet weak var tableSettings: UITableView!
    /**
     the rounded user picture view.
     */
    @IBOutlet weak var profile_img: RoundedUIImageView!
    /**
     contains all the informations of the user history songs.
     */
    var songs : JSON = []
    /**
     the user description
     */
    @IBOutlet weak var profile_desc: UILabel!
    /**
    the user following
     */
    @IBOutlet weak var abonnement: UILabel!
    /**
     the user followers
     */
    @IBOutlet weak var abonne: UILabel!
    /**
    the user First name & last name.
     */
    @IBOutlet weak var profile_name: UILabel!
    /**
    the history song tableview Header height.
     */
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var descSceneGesture: UITapGestureRecognizer!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table {
        return (songs.arrayObject?.count)!
        }else{
            return 2
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == tableSettings{
            if indexPath.row == 1{
                self.heightTableSettings.constant = tableView.contentSize.height
            }
        }
    }
    /**
     the rounded Settings icon action
     */
    @IBAction func SignoutAction(_ sender: UIBarButtonItem) {
        //self.navigationController?.popToRootViewController(animated: true)
       // let q = self.storyboard?.instantiateViewController(withIdentifier: "firstNav") as! UINavigationController
        if self.tableSettings.isHidden == true {
            self.tableSettings.isHidden = false
            UIView.animate(withDuration: 0.5/*Animation Duration second*/, animations: {
                self.tableSettings.alpha = 1
            }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.5/*Animation Duration second*/, animations: {
                self.tableSettings.alpha = 0
            }, completion:  {
                (value: Bool) in
                self.tableSettings.isHidden = true
            })
        }
        
        
        UIView.animate(withDuration: 0.5, animations: {
           
            
            let view = sender.value(forKeyPath: "view") as? UIView
            
            if  view?.transform == .identity {
                 view?.transform = CGAffineTransform(rotationAngle: CGFloat(.pi * 0.5))
            } else {
               view?.transform = .identity
            }
        })
       
    }
    
    /**
    the sign out action
     */
    func signOut(){
        let domain = Bundle.main.bundleIdentifier!
        FloatingPlayerController.shared.CloseAction(self)
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        let root =  self.storyboard?.instantiateViewController(withIdentifier: "login")
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.window?.layer.add(transition, forKey: kCATransition)
        //q.popToRootViewController(animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(root!, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == table {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let ImageV = cell.viewWithTag(1) as! UIImageView
        let Name = cell.viewWithTag(2) as! UILabel
        let src = cell.viewWithTag(3) as! UILabel
            if self.songs[indexPath.row]["song"].description != "null" {
        ImageV.setImage(with: URL(string: (self.songs[indexPath.row]["song"]["image_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        Name.text = self.songs[indexPath.row]["song"]["song_name"].stringValue
        src.text = self.songs[indexPath.row]["song"]["song_src"].stringValue
            }else{
                ImageV.setImage(with: URL(string: (self.songs[indexPath.row]["parent"]["song"]["image_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                Name.text = self.songs[indexPath.row]["parent"]["song"]["song_name"].stringValue
                src.text = self.songs[indexPath.row]["parent"]["song"]["song_src"].stringValue
            }
        src.isHidden = true
        let Particiapants = cell.viewWithTag(4) as! UILabel
        Particiapants.text = self.songs[indexPath.row]["createur"]["username"].stringValue
        if self.songs[indexPath.row]["participants"].arrayObject?.count != 0 {
            let count = (self.songs[indexPath.row]["participants"].arrayObject?.count)! - 1
            if self.songs[indexPath.row]["participants"].arrayObject?.count == 1 {
                Particiapants.text = Particiapants.text! + " + " + self.songs[indexPath.row]["participants"][0]["username"].stringValue
            }else{
          
                Particiapants.text = Particiapants.text! + " and " + String(count) + " others"
            }
        }
        //if self.songs[indexPath.row][""]
        let date = cell.viewWithTag(5) as! UILabel
        date.text = self.songs[indexPath.row]["date"].stringValue
        
        
        
        return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSettings", for: indexPath)
            let title = cell.viewWithTag(1) as! UILabel
            
            switch indexPath.row {
            case 0:
                title.text = "Settings"
            case 1:
                title.text = "Sign Out"
            default:
                break
            }
            return cell
        }
    }
    
    /**
     the table view header of the history songs.
     */
    @IBOutlet weak var header: UIView!
    /**
     the history songs table view.
     */
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        self.tableSettings.alpha = 0
        self.tableSettings.delegate = self
        self.tableSettings.dataSource = self
        self.tableSettings.reloadData()
        self.abonne.text = "0 abonné(s)"
        self.abonnement.text = "0 abonnement(s)"
        
        self.profile_desc.isUserInteractionEnabled = true
        self.table.bounces = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.closePlayer), name: Notification.Name.init("ClosePlayer"), object: nil)
    }
    /**
     this is triggered by a swipe action on the bottom bar player view.
     */
    @objc func closePlayer(){
        tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableSettings {
            
            switch indexPath.row {
            case 0 :
                print("settings")
                
                
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
                //let navigation = UINavigationController(rootViewController: q)
               // let vc : UITableViewController = SettingsController()
                let navigationcontroller : UINavigationController = UINavigationController(rootViewController: vc)
                navigationcontroller.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                
                self.present(navigationcontroller, animated: true, completion: nil)
            
                self.SignoutAction(self.navigationItem.rightBarButtonItem!)
                
            case 1:
                self.signOut()
            default:
                break
            }
        }else{
            //(UIApplication.shared.delegate as! AppDelegate).FloatingController.song = [self.songs[indexPath.row]]
            //(UIApplication.shared.delegate as! AppDelegate).FloatingController.show()
            let viewC = FloatingPlayerController.shared
            viewC.IndexSong = indexPath.row
            viewC.song = self.songs
           
              tabBarController?.popupBar.popupItem?.progress = Float(0.0)
             tabBarController?.presentPopupBar(withContentViewController: viewC, animated: true, completion: nil)
             viewC.initVLCPlayer(index: indexPath.row)
             tabBarController?.popupBar.progressViewStyle = .top
             tabBarController?.popupInteractionStyle = .drag
             tabBarController?.popupBar.backgroundStyle = .light
            
            //self.navigationController?.pushViewController(viewC, animated: true)
           
        }
    }
    /**
     this set the user description.
     */
    func setDescription(){
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
            self.profile_name.text = a["First_name"].stringValue + " " + a["Last_name"].stringValue
            if a["description"].description == "null" {
                self.profile_desc.text = "écris quelques lignes personnels qui vous décrit..."
            }else{
                self.profile_desc.text = a["description"].stringValue
            }
            self.profile_img.setImage(with: URL(string: a["image_src"].stringValue), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        }catch {
            print(error)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSongHistorique()
        getFollowers()
        setDescription()
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    func setupHeaderView() {
       self.header.translatesAutoresizingMaskIntoConstraints = false
        self.table.translatesAutoresizingMaskIntoConstraints = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /**
     this is an animation when scrolling the table view of the history songs.
     */
    func animateHeader() {
        self.headerHeightConstraint.constant = 254
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    //  abonnezés followers
    //following abonement
    
    /**
     get the followers from database.
     */
    func getFollowers(){
        if let ab = UserDefaults.standard.value(forKey: "User") as? String {
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            let params: Parameters = [
                "id_user" : a["id"].stringValue
            ]
            Alamofire.request(ScriptBase.sharedInstance.get_followers , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    let q = JSON(response.data)
                    if q["status"].stringValue == "true" {
                       
                       self.abonne.text = q["data"]["followers"].stringValue + " abonné(s)"
                        self.abonne.underline()
                        let gesture  = UITapGestureRecognizer(target: self, action: #selector(self.showFollowers(_:)))
                        gesture.numberOfTapsRequired = 1
                        self.abonne.isUserInteractionEnabled = true
                        self.abonne.addGestureRecognizer(gesture)
                        self.abonnement.text = q["data"]["following"].stringValue + " abonnement(s)"
                       
                        self.abonnement.underline()
                         let gesture2  = UITapGestureRecognizer(target: self, action: #selector(self.showFollowing(_:)))
                         self.abonnement.isUserInteractionEnabled = true
                        self.abonnement.addGestureRecognizer(gesture2)
                    }else{
                        print("unexpected error on followers")
                    }
                    
            }
            
        }catch{
            
        }
        }
    }
    /**
     this is triggered when the user press on the Following numbers.
     */
    @objc func showFollowing(_ sender: UILabel ) {
        let q = self.storyboard?.instantiateViewController(withIdentifier: "Follow_FollowingController") as! Follow_FollowingController
        q.typeCall = "Following"
        self.navigationController?.pushViewController(q, animated: true)
    }
    /**
     this is triggered when the user press on the Followers numbers.
     */
    @objc func showFollowers(_ sender: UILabel){
        let q = self.storyboard?.instantiateViewController(withIdentifier: "Follow_FollowingController") as! Follow_FollowingController
        q.typeCall = "Followers"
        self.navigationController?.pushViewController(q, animated: true)
       
    }
    /**
     get the songs history of the actual user from database.
     */
    func getSongHistorique(){
        if UserDefaults.standard.value(forKeyPath: "User") != nil {
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
             let params: Parameters = [
                "id_user" : a["id"].stringValue
            ]
            Alamofire.request(ScriptBase.sharedInstance.history_song , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
             let q = JSON(response.data)
                    print("histo: ",q)
                    if q["status"].stringValue == "true" {
                    self.songs = q["data"]
                        
                    self.table.reloadData()
                    }else{
                        print("no Hitory")
                    }
            
            }
            
        }catch{
            
        }
        }else{
            self.songs = []
            self.table.reloadData()
        }
    }
    /**
     this function present the edit profile view.
     */
    @IBAction func goToEditProfile(_ sender: UIButton){
        let q = self.storyboard?.instantiateViewController(withIdentifier: "ProfilTouch") as! DescriptionProfilTouch
        let navigationcontroller : UINavigationController = UINavigationController(rootViewController: q)
        navigationcontroller.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        self.present(navigationcontroller, animated: true, completion: nil)
       
    }
    @IBAction func DescriptionSceneAction(_ sender: UITapGestureRecognizer) {
        
        
     
        
    }
    
}

extension ProfilController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll:",scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0 {
            animateHeader()
            //headerView.incrementColorAlpha(offset: self.headerHeightConstraint.constant)
            //headerView.incrementArticleAlpha(offset: self.headerHeightConstraint.constant)
        } else if scrollView.contentOffset.y > 0 && self.headerHeightConstraint.constant >= 10 {
            self.headerHeightConstraint.constant -= scrollView.contentOffset.y/100
            //headerView.decrementColorAlpha(offset: scrollView.contentOffset.y)
            //headerView.decrementArticleAlpha(offset: self.headerHeightConstraint.constant)
            
            if self.headerHeightConstraint.constant < 10 {
                self.headerHeightConstraint.constant = 0
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.headerHeightConstraint.constant > 254 {
            animateHeader()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.headerHeightConstraint.constant > 254 {
            animateHeader()
        }
    }
}
extension UILabel {
    func underline(){
        guard let text = self.text else {
            return
        }
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
        self.attributedText = attributedText
    }
}
