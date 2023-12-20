//
//  PublicationDescription.swift
//  SINGTN
//
//  Created by macbook on 2018-09-17.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import MapleBacon
import SwiftyJSON
import Alamofire
import AudioKit
struct Comment {
    var owner : String
    var image : String
    var comment : String
    var date : String
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
class PublicationDescription: UIViewController,UITableViewDelegate,UITableViewDataSource,VLCMediaPlayerDelegate {
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageV = cell.viewWithTag(1) as! RoundedUIImageView
        
    imageV.setImage(with: URL(string: comments[indexPath.row].image), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        let owner = cell.viewWithTag(2) as! UILabel
        owner.text = comments[indexPath.row].owner
        let comment = cell.viewWithTag(3) as! UILabel
        
        comment.text = comments[indexPath.row].comment
        print(comment.text)
        return cell
        
    }
    
    
    var comments: [Comment] = []
    var pub_id = "5"

    var isLike = false
    var id_like = -2
     var beeingSeek = false
    var song : [JSON] = []
    var LikeChanged = false
    var player : AudioPlayer!
    fileprivate var kBufferingRatioKVOKey = 1
    fileprivate var kDurationKVOKey = 1
    fileprivate var kStatusKVOKey = 1
     var rightChannelColor: UIColor = UIColor.green
     var leftChannelColor: UIColor = UIColor.blue
    @IBOutlet weak var song_player_container: UIView!
    
    @IBOutlet weak var like_container: UIView!
    
    
    @IBOutlet weak var share_container: UIView!
    
    @IBOutlet weak var comments_table: UITableView!
    
    @IBOutlet weak var player_container: UIView!
    
    @IBOutlet weak var player_slider: PlayerSlider!
    
    @IBOutlet weak var playBTN: UIButton!
    
    @IBOutlet weak var songPicture: UIImageView!
    @IBOutlet weak var wave_formVis: UIView!
    @IBOutlet weak var HeartStroke : CustomImage!
    @IBOutlet weak var MainView: UIView!
    
    
    @IBOutlet weak var visualEffects: UIVisualEffectView!
    @IBAction func play_pause_BTN(_ sender: UIButton) {
   
        if Vlc_player.isPlaying {
        Vlc_player.pause()
            self.playBTN.setImage(UIImage(named: "Controls_Play"), for: .normal)
        }else{
            Vlc_player.play()
            self.playBTN.setImage(UIImage(named: "Controls_Pause"), for: .normal)
        }
        
        
    }
    var Vlc_player : VLCMediaPlayer!
    @IBOutlet weak var textInputBar : ALTextInputBar!
     let keyboardObserver = ALKeyboardObservingView()
    let updateLike        = NSNotification.Name(rawValue:"updateLike")
    let CommentOp        = NSNotification.Name(rawValue:"CommentOpen")
    
    override var inputAccessoryView: UIView? {
        get {
            return keyboardObserver
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
    
        self.pleaseWait()
        getPublicationComment()
         IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(notification:)), name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(CommentOpen(notification:)), name: CommentOp, object: nil)
        self.comments_table.delegate = self
        self.comments_table.dataSource = self
        configureInputBar()
        //configureNavigationBar()
        configureSliderView()
        configureWaveForm()
       //initStreamingPlayer()
       self.hideKeyboardWhenTappedAround()
        initVLCPlayer()
        initLike()
    }
    @objc func CommentOpen(notification: NSNotification){
        self.textInputBar.textView.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            Vlc_player.stop()
            Vlc_player = nil
            Vlc_player =  VLCMediaPlayer()
            Vlc_player.delegate = self
            if LikeChanged {
                NotificationCenter.default.post(name: updateLike, object: like(id: self.id_like  ,pub_id: Int(self.pub_id)!))
            }
        }
    }
    func initLike(){
        like_container.isUserInteractionEnabled = true
        like_container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:))))
        if isLike {
            self.HeartStroke.image =  UIImage(named: "like_red")
        }else{
            self.HeartStroke.image = UIImage(named: "like_white")
        }
        
    }
    @objc func imgTapped(sender: UITapGestureRecognizer) {
        // change data model blah-blah
        
        if isLike == false {
            if self.id_like == -1 {
            self.isLike = true
            HeartStroke.image = UIImage(named: "like_red")
                if self.LikeChanged {
                    self.LikeChanged = false
                }else{
                    self.LikeChanged = true
                }
            Add_Remove_Like(AR: true)
            }
            
        } else {
            if self.id_like != -1 {
            self.isLike = false
                if self.LikeChanged {
                    self.LikeChanged = false
                }else{
                    self.LikeChanged = true
                }
              Add_Remove_Like(AR: false)
            HeartStroke.image = UIImage(named: "like_white")
            }
        }
        
        
        
        
        
    }
    func Add_Remove_Like(AR:Bool){
        
        
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            
            var params : Parameters = [:]
            if AR {
                 params = [
                    "id_user" : a["id"].stringValue,
                    "id_publication" : self.pub_id
                ]
                 print(params)
            }else{
                 params = [
                    "id_like" : self.id_like
                ]
                print(params)
            }
           
            Alamofire.request( (AR) ? ScriptBase.sharedInstance.AddLikeToPublication : ScriptBase.sharedInstance.RemoveLikeFromPublication , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    //print(response.data)
                    let q = JSON(response.data)
                    
                    if q["status"].stringValue == "true" {
                        if AR {
                            self.id_like = q["data"]["id"].intValue
                        }else{
                            self.id_like = -1
                        }
                    }
                    print(q)
                    
                    
                    
            }
            
            
            
        }catch{
            
        }
      
    }
    func initVLCPlayer(){
       
         let SongURL = URL(string: song[0]["song_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! )
        Vlc_player =  VLCMediaPlayer()
        Vlc_player.delegate = self
        Vlc_player.libraryInstance.debugLogging = true
        Vlc_player.addObserver(self, forKeyPath: "time", options: [], context: nil)
        Vlc_player.addObserver(self, forKeyPath: "remainingTime", options: [], context: nil)
        let media = VLCMedia(url: SongURL!)
        Vlc_player.media  = media
        if song[0]["type"].stringValue == "video" {
            self.visualEffects.isHidden = true
            Vlc_player.drawable = self.wave_formVis
        }
        
        
        Vlc_player.play()
      
       
        
    }
    //*************Delegate VLC ********************
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
       // print("mediaPlayerStateChanged: ",aNotification)
        
        let object = aNotification?.object as! VLCMediaPlayer
        let currentstate : VLCMediaPlayerState = object.state
        if currentstate == VLCMediaPlayerState.buffering{
           
            
            
        }else if currentstate == VLCMediaPlayerState.error {
            self.Vlc_player.stop()
            self.playBTN.setImage(UIImage(named: "Controls_Play"), for: .normal)
            self.noticeError("Error While trying to play",autoClear: true)
        }else if currentstate == VLCMediaPlayerState.ended {
                self.Vlc_player.stop()
            self.Vlc_player.position = 0
            
            self.player_slider.updateProgressNew(self.Vlc_player.position, remaining: self.Vlc_player.media.length, actualTime: self.Vlc_player.time)
            self.playBTN.setImage(UIImage(named: "Controls_Play"), for: .normal)
        }else if currentstate == VLCMediaPlayerState.stopped {
               self.playBTN.setImage(UIImage(named: "Controls_Play"), for: .normal)
        }
        
        if object.isPlaying {
            self.playBTN.setImage(UIImage(named: "Controls_Pause"), for: .normal)
            self.clearAllNotice()
            self.player_slider.duration = TimeInterval(exactly: object.media.length.intValue)!
        }
        
    }
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
          //print("mediaPlayerTimeChanged: ",aNotification)
        let object = aNotification?.object as! VLCMediaPlayer
   
        //self.player_slider.progress = Float((1 / object.media.length.intValue) * object.time.intValue)
        //self.player_slider.progress = object.media.
        //object.time.intValue
    }
    func mediaPlayerTitleChanged(_ aNotification: Notification!) {
         //print("mediaPlayerTitleChanged: ",aNotification)
    }
    func mediaPlayerSnapshot(_ aNotification: Notification!) {
         //print("mediaPlayerSnapshot: ",aNotification)
    }
    func mediaPlayerChapterChanged(_ aNotification: Notification!) {
         //print("mediaPlayerChapterChanged: ",aNotification)
    }
    
    
    private func initStreamingPlayer(){
        let SongURL = URL(string: song[0]["song_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! )
        self.player = AudioPlayer()
        self.player.delegate  = self
        self.player.play(item: AudioItem(mediumQualitySoundURL: SongURL)!)
        
       
 
    }
    //obsereValues
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "time" {
            
            self.player_slider.updateProgressNew(self.Vlc_player.position, remaining: self.Vlc_player.remainingTime, actualTime: self.Vlc_player.time)
            //self.wave_formVis.updateWaveWithBuffer(self.Vlc_player.media., withBufferSize: 20, withNumberOfChannels: self.Vlc_player.numberOfBands)
         
            //print("Info:",self.Vlc_player.media.tracksInformation)
          
          
            
        
     }else if keyPath == "remainingTime"{
            self.player_slider.updateProgressNew(self.Vlc_player.position, remaining: self.Vlc_player.remainingTime, actualTime: self.Vlc_player.time)
        
        
       
        }else {
             super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
     
     }
   
    // stolen from https://stackoverflow.com/a/40794726
    func hmsFrom(seconds: Int, completion: @escaping (_ minutes: Int, _ seconds: Int)->()) {
        completion((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    private func configureWaveForm(){
        print(song)
        
        let StringURL = song[0]["song"]["image_src"].stringValue
        print ("hey :",StringURL)
        let URL_picture = URL(string: StringURL)
        songPicture.setImage(with: URL_picture, placeholder: nil, transformer: nil, progress: nil) { (image) in
            image?.getColors(scaleDownSize: CGSize(width: self.songPicture.frame.width, height: self.songPicture.frame.height), completionHandler: { (colors) in
               
                DispatchQueue.main.async(execute: {
                    self.updateForColors(colors)
                })
            })
        }
    }
    fileprivate func updateForColors(_ colors: UIImageColors?) {
       
        
        if let color = colors?.primaryColor {
            rightChannelColor = color
        }
        
        if let color = colors?.secondaryColor {
            leftChannelColor = color
        }
        
        if let color = colors?.primaryColor {
           // songNameColor = color
        }
        
        if let color = colors?.primaryColor {
           // songAlbumColor = color
        }
        
       // songNameLabel.changeAnimated(metadata.title ?? unknown, color: songNameColor)
       // songAlbumLabel.changeAnimated(metadata.albumName ?? unknown, color: songAlbumColor)
        //wave_formVis.setColors(left: leftChannelColor, right: rightChannelColor)
    }
    private func configureNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        title = ""
    }
    private func configureSliderView(){
        player_slider.delegate = self
       // player_slider.progress = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
         //textInputBar.frame = CGRect(x: 0, y: self.comments_table.frame.maxY + textInputBar.defaultHeight, width: MainView.frame.size.width, height: textInputBar.defaultHeight)
        textInputBar.frame.size.width = view.bounds.width
        
    }
    func configureInputBar() {
        let rightButton = UIButton(frame: CGRect(x: 0, y: self.comments_table.frame.maxY, width: 44, height: 44))
        rightButton.addTarget(self, action: #selector(addComment), for: UIControl.Event.touchUpInside)
      
        rightButton.setImage(#imageLiteral(resourceName: "rightIcon"), for: .normal)
        
        keyboardObserver.isUserInteractionEnabled = false
        
        textInputBar.showTextViewBorder = true
        textInputBar.rightView = rightButton
        //textInputBar.horizontalSpacing = 0
        //textInputBar.horizontalPadding = 0
     
        //textInputBar.defaultHeight = 49.0
        //textInputBar.frame = CGRect(x: 0, y: self.comments_table.frame.maxY, width: view.frame.size.width, height: textInputBar.defaultHeight)
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textInputBar.keyboardObserver = keyboardObserver
        
        //self.MainView.addSubview(textInputBar)
        //self.MainView.bringSubviewToFront(textInputBar)
    }
    private func frameForTabAtIndex(index: Int) -> CGRect {
        var frames = view.subviews.flatMap { (view:UIView) -> CGRect? in
            if let view = view as? UIControl {
                return view.frame
            }
            return nil
        }
        frames.sort { $0.origin.x < $1.origin.x }
        if frames.count > index {
            return frames[index]
        }
        return frames.last ?? CGRect.zero
    }
    @objc func keyboardFrameChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    @objc func addComment(){
        
        let text = textInputBar.text
       
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            
            let newComment = Comment(owner: "@" + a["username"].stringValue, image: a["image_src"].stringValue, comment: text!,date : "maintenant")
            comments.insert(newComment, at: 0)
            addCommentToDataBase(text: text!)
             self.comments_table.reloadData()
        }catch{
            
        }
       
  self.textInputBar.text = ""
       view.endEditing(true)
        
    }
    func addCommentToDataBase(text:String){
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            let params: Parameters = [
                "id_user" : a["id"].stringValue,
                "id_publication" : self.pub_id,
                "comment" : text
            ]
            Alamofire.request(ScriptBase.sharedInstance.addComment , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                   
                    //print(response.data)
                    let q = JSON(response.data)
                    print(q)
                   
                    
                    
            }
            
            
            
        }catch{
            
        }
    }
    func getPublicationComment(){
        
        let params: Parameters = [
           
            "id_publication" : self.pub_id
           
        ]
        Alamofire.request(ScriptBase.sharedInstance.getComments , method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                //print(response.data)
                let q = JSON(response.data)
                    print(q)
                if q["status"].stringValue == "true" {
                    self.comments = []
                let CommentsJSON = q["data"]
                if CommentsJSON.arrayObject?.count != 0 {
                    for i in 0...((CommentsJSON.arrayObject?.count)! - 1) {
                        self.comments.append(Comment(owner: CommentsJSON[i]["owner"]["username"].stringValue, image: CommentsJSON[i]["owner"]["image_src"].stringValue, comment: CommentsJSON[i]["comment"].stringValue,date :  CommentsJSON[i]["date"].stringValue ))
                    }
                }
                    self.comments_table.reloadData()
            
                }
                
                
        }
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension PublicationDescription: PlayerSliderProtocol {
    func onValueChanged(progress: Float, remaining: VLCTime, actual : VLCTime) {
        beeingSeek = true
      
        
        //let frame = Int64(Float(player.audioFile.totalFrames) * progress)
        //self.player.seek(toFrame: frame)
        self.Vlc_player.position = progress
    }
}
extension PublicationDescription : AudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        print("willStartPlaying")
    }
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        print("didchangeStateFrom: ",from, " to ", state)
    }
}
