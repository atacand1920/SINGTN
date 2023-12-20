//
//  FloatingPlayerController.swift
//  SINGTN
//
//  Created by macbook on 2018-09-27.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import GoogleMobileAds
/**
 this controller is responsible of the history songs
 */
class FloatingPlayerController : UIViewController,VLCMediaPlayerDelegate, GADBannerViewDelegate, GADInterstitialDelegate,PlayerSliderProtocol {
    /**
     this is a static var to use once
     */
    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FloatingPlayerController") as! FloatingPlayerController
    /**
     a loading spin
     */
     private let loadingSpinner = UIActivityIndicatorView()
    /**
     this is our player controller, it can play a video or an audio file
     */
     var Vlc_player : VLCMediaPlayer!
    /**
     this contains all the informations of our songs
     */
    var song : JSON = []
    /**
     the title of our song
     */
    @IBOutlet weak var titleSong  : UILabel!
    /**
     the artist of our song
     */
     @IBOutlet weak var ArtistLBL  : UILabel!
    /**
     the cover picture of our song
     */
    @IBOutlet weak var SongPicture : UIImageView!
    /**
     a nice blur effect below the cover picture
     */
    @IBOutlet weak var blurEffect : UIVisualEffectView!
    /**
     it contains our player view
     */
    @IBOutlet weak var song_player_container: UIView!
   
    /**
     a slider for controlling the song
     */
    @IBOutlet weak var player_slider: PlayerSlider!
    /**
     this our Play/pause button
     */
    @IBOutlet weak var playBTN: UIButton!
    /**
     this is an Ads for moneting our app, it appears when the song is audio only
     */
     @IBOutlet weak var AdView : UIView!
    /**
     the close view button
     */
    @IBOutlet weak var closeViewB: UIButton!
    
    /**
     the Action event of closing our view
     */
    @IBAction func CloseAction(_ sender: Any) {
        if Vlc_player != nil {
        if Vlc_player.isPlaying {
            Vlc_player.stop()
        }
        }
        NotificationCenter.default.post(name: Notification.Name.init("ClosePlayer"), object: nil)
        //self.closePopup(animated: true, completion: nil)
        //self.dismissPopupBar(animated: true, completion: nil)
        //self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    /**
     the Action event for play/pause our song
     */
    @IBAction func play_pause_BTN(_ sender: UIButton) {
        
        if Vlc_player.isPlaying {
            Vlc_player.pause()
            self.playBTN.setImage(UIImage(named: "Controls_Play"), for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"play")
        }else{
            Vlc_player.play()
            self.playBTN.setImage(UIImage(named: "Controls_Pause"), for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"nowPlaying_pause")
        }
        
        
    }
    /**
     the Ads view
     */
    lazy var adBannerView: GADBannerView = {
        
        let adBannerView = GADBannerView(adSize: GADAdSizeFullWidthPortraitWithHeight(179))
        print(adBannerView.frame.size)
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    /**
     This is a full-screen advertisement shown at natural transition points
     */
      var interstitial: GADInterstitial?
    /**
    this leads to know when the user is seeking the song
     */
      var beeingSeek = false
    
    
    func onValueChanged(progress: Float, remaining: VLCTime, actual : VLCTime) {
        beeingSeek = true
        /*  if self.streamer != nil {
         let time = self.streamer.duration * TimeInterval(progress)
         self.streamer.currentTime = time
         } */
        
        //let frame = Int64(Float(player.audioFile.totalFrames) * progress)
        //self.player.seek(toFrame: frame)
        if self.Vlc_player.isSeekable { 
        self.Vlc_player.position = progress
        self.popupItem.progress =  progress
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let pause = UIBarButtonItem(image: UIImage(named: "nowPlaying_pause"), style: .plain, target: self, action: #selector(self.play_bar))
        let preview = UIBarButtonItem(image: UIImage(named: "nowPlaying_prev"), style: .plain, target: self, action: #selector(self.preview_bar))
         let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(self.next_bar))
        self.popupItem.leftBarButtonItems = [ preview, pause ]
        self.popupItem.rightBarButtonItems = [ next ]
    }
    /**
     this controll our bottom bar player play/pause button
     */
    @objc func play_bar(){
        if Vlc_player.isPlaying {
            Vlc_player.pause()
            self.playBTN.setImage(UIImage(named: "Controls_Play"), for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"play")
        }else{
            Vlc_player.play()
            self.playBTN.setImage(UIImage(named: "Controls_Pause"), for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"nowPlaying_pause")
        }
        
    }
    /**
     this controll our bottom bar player preview button
     */
    @objc func preview_bar(){
        if IndexSong == 0 {
            self.initVLCPlayer(index: IndexSong)
        }else{
            IndexSong = IndexSong - 1
            self.initVLCPlayer(index: IndexSong)
        }
    }
    /**
     this controll our bottom bar player next button
     */
    @objc func next_bar(){
        if IndexSong == ((self.song.arrayObject?.count)! - 1 )  {
            IndexSong = 0
            self.initVLCPlayer(index: IndexSong)
        }else{
            IndexSong = IndexSong + 1
            self.initVLCPlayer(index: IndexSong)
        }
    }
    /**
     the index of our song in JSON
     */
    var IndexSong : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.pleaseWait()
        print("FloatVIewDIDLoad")
      
       
        //PlayerContainer.addSubview(song_player_container)
       
  self.popupItem.progress = 0.0
        self.AdView.addSubview(adBannerView)
        
       
        let request = GADRequest()
        request.testDevices = ["7bb2f7d55292eceb33a6cd659256bb7e"]
        adBannerView.load(request)
       
         interstitial = createAndLoadInterstitial()
       
      self.player_slider.delegate = self
    }
    /**
     this is an observator of our slider
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "time" {
            self.popupItem.progress = self.Vlc_player.position
            self.player_slider.updateProgressNew(self.Vlc_player.position, remaining: self.Vlc_player.remainingTime, actualTime: self.Vlc_player.time)
            //self.wave_formVis.updateWaveWithBuffer(self.Vlc_player.media., withBufferSize: 20, withNumberOfChannels: self.Vlc_player.numberOfBands)
            
            //print("Info:",self.Vlc_player.media.tracksInformation)
            
            
            
            
        }else if keyPath == "remainingTime"{
            self.popupItem.progress = self.Vlc_player.position
            self.player_slider.updateProgressNew(self.Vlc_player.position, remaining: self.Vlc_player.remainingTime, actualTime: self.Vlc_player.time)
            
            
            
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    // MARK: - GADBannerViewDelegate methods
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            bannerView.transform = CGAffineTransform.identity
        }
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
        
    }
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/2934735716")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        request.testDevices = ["7bb2f7d55292eceb33a6cd659256bb7e"]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    // MARK: - GADInterstitialDelegate methods
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    /**
     this function set our cover picture & call updateForColors to set the title and artist name colors.
     
     - Parameters:
        - index: the index of our song from JSON.
     */
    private func configureWaveForm(index:Int){
        var StringURL = ""
        if song[index]["song"].description != "null" {
         StringURL = song[index]["song"]["image_src"].stringValue
        }else{
            StringURL = song[index]["parent"]["song"]["image_src"].stringValue
        }
        
        print ("hey :",StringURL)
        let URL_picture = URL(string: StringURL)
        SongPicture.setImage(with: URL_picture, placeholder: nil, transformer: nil, progress: nil) { (image) in
             self.popupItem.image = image
           
            image?.getColors(scaleDownSize: CGSize(width: self.SongPicture.frame.width, height: self.SongPicture.frame.height), completionHandler: { (colors) in
                
                DispatchQueue.main.async(execute: {
                    self.updateForColors(colors)
                })
            })
        }
    }
    /**
     this function set e title and artist name colors depending of the colors creating the cover picture.
     
     - Parameters:
        - colors: the colors of our cover picture.
     */
    fileprivate func updateForColors(_ colors: UIImageColors?) {
        
        
       
        
        if let color = colors?.primaryColor {
            titleSong.textColor = color
            titleSong.text = song[0]["song"].description != "null" ? song[0]["song"]["song_name"].stringValue : song[0]["parent"]["song"]["song_name"].stringValue
        }
        
        if let color = colors?.secondaryColor {
             ArtistLBL.textColor = color
            ArtistLBL.text =  song[0]["song"].description != "null" ? song[0]["song"]["artist_name"].stringValue : song[0]["parent"]["song"]["artist_name"].stringValue
        }
        
        // songNameLabel.changeAnimated(metadata.title ?? unknown, color: songNameColor)
        // songAlbumLabel.changeAnimated(metadata.albumName ?? unknown, color: songAlbumColor)
        //wave_formVis.setColors(left: leftChannelColor, right: rightChannelColor)
    }
    /**
     this function initialize of VLC player and also our view & the bottom bar view.
     
     - Parameters:
        - index: the index of our song from JSON.
     */
    func initVLCPlayer(index : Int){
        
        if Vlc_player == nil {
            let SongURL = URL(string: song[index]["song_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! )
            titleSong.text = song[index]["song"].description != "null" ? song[index]["song"]["song_name"].stringValue :  song[index]["parent"]["song"]["song_name"].stringValue
            ArtistLBL.text = song[index]["song"].description != "null" ? song[index]["song"]["artist_name"].stringValue :  song[index]["parent"]["song"]["artist_name"].stringValue
            self.popupItem.title = song[index]["song"].description != "null" ? song[index]["song"]["song_name"].stringValue : song[index]["parent"]["song"]["song_name"].stringValue
            self.popupItem.subtitle = song[index]["song"].description != "null" ? song[index]["song"]["artist_name"].stringValue :  song[index]["parent"]["song"]["artist_name"].stringValue
            configureWaveForm(index: index)
            Vlc_player =  VLCMediaPlayer()
            Vlc_player.delegate = self
            Vlc_player.libraryInstance.debugLogging = true
            Vlc_player.addObserver(self, forKeyPath: "time", options: [], context: nil)
            Vlc_player.addObserver(self, forKeyPath: "remainingTime", options: [], context: nil)
            let media = VLCMedia(url: SongURL!)
            Vlc_player.media  = media
            if song[index]["type"].stringValue == "Video" {
                self.adBannerView.isHidden = true
                Vlc_player.drawable = self.AdView
            }else{
                self.adBannerView.isHidden = false
                Vlc_player.drawable = nil
            }
            Vlc_player.play()
        }else{
            let SongURL = URL(string: song[index]["song_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! )
            titleSong.text = song[index]["song"].description != "null" ? song[index]["song"]["song_name"].stringValue : song[index]["parent"]["song"]["song_name"].stringValue
                ArtistLBL.text = song[index]["song"].description != "null" ? song[index]["song"]["artist_name"].stringValue : song[index]["parent"]["song"]["artist_name"].stringValue
                self.popupItem.title = song[index]["song"].description != "null" ? song[index]["song"]["song_name"].stringValue : song[index]["parent"]["song"]["song_name"].stringValue
                self.popupItem.subtitle = song[index]["song"].description != "null" ? song[index]["song"]["artist_name"].stringValue : song[index]["parent"]["song"]["artist_name"].stringValue
             configureWaveForm(index: index)
            let media = VLCMedia(url: SongURL!)
            if Vlc_player.isPlaying {
                Vlc_player.stop()
            }
            if song[index]["type"].stringValue == "Video" {
                self.adBannerView.isHidden = true
                Vlc_player.drawable = self.AdView
            }else{
                self.adBannerView.isHidden = false
                Vlc_player.drawable = nil
            }
            Vlc_player.media  = media
            Vlc_player.play()
        }
        
        
        
    }
    //*************Delegate VLC ********************
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        // print("mediaPlayerStateChanged: ",aNotification)
        
        let object = aNotification?.object as! VLCMediaPlayer
        let currentstate : VLCMediaPlayerState = object.state
        if currentstate == VLCMediaPlayerState.buffering{
            
            
            
        }else if currentstate == VLCMediaPlayerState.error {
            self.Vlc_player.stop()
            self.playBTN.setImage(UIImage(named: "Controls_Play")!, for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"play")
            self.noticeError("Error While trying to play",autoClear: true)
        }else if currentstate == VLCMediaPlayerState.ended {
            self.Vlc_player.stop()
            self.Vlc_player.position = 0
            
            self.player_slider.updateProgressNew(self.Vlc_player.position, remaining: self.Vlc_player.media.length, actualTime: self.Vlc_player.time)
           self.playBTN.setImage(UIImage(named: "Controls_Play")!, for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"play")
        }else if currentstate == VLCMediaPlayerState.stopped {
             self.playBTN.setImage(UIImage(named: "Controls_Play")!, for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"play")
        }
        
        if object.isPlaying {
          
             self.playBTN.setImage(UIImage(named: "Controls_Pause")!, for: .normal)
            self.popupItem.leftBarButtonItems![1].image = UIImage(named:"nowPlaying_pause")
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
    
    private func configureSliderView(){
       // player_slider.delegate = self
        // player_slider.progress = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
