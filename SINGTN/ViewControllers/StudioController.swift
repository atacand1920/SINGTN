//
//  StudioController.swift
//  SINGTN
//
//  Created by macbook on 2018-08-17.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import MapleBacon
import SwiftSpinner
import AudioKit
import AudioKitUI
import CoreData
class StudioController : UIViewController,AVAudioPlayerDelegate,BWHorizontalTableViewDelegate,BWHorizontalTableViewDataSource,PlayerSliderProtocol,VLCMediaPlayerDelegate {
    
    
    
    @IBOutlet weak var volumeEffectsContainer: UIView!
    @IBOutlet weak var OptionsViewHeight: NSLayoutConstraint!
    var Stop_resume = 0
   
   
    @IBOutlet weak var artist_Label: UILabel!
    @IBOutlet weak var byMessage: UILabel!
    @IBOutlet weak var ImageSong : UIImageView!
    @IBOutlet weak var SongName : UILabel!
    @IBOutlet weak var player_slider: PlayerSlider!
    @IBOutlet weak var play_p : UIButton!
    
    @IBOutlet weak var CameraView : UIView!
      var Vlc_player_Song : VLCMediaPlayer!
    var Vlc_VideoPlayer : VLCMediaPlayer!
    @IBOutlet weak var EffectsButton: UIButton!
    @IBOutlet weak var VolumeButton: UIButton!
    @IBOutlet weak var tableview: BWHorizontalTableView!
    @IBOutlet weak var VolumeLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    var navigation : UINavigationController!
    var spinner = SwiftSpinner.sharedInstance
    var CustomLyrics : [String] = []
    var FirstTimeSync = true
    var EffectsObject : [Effect] = []
    var timer : Timer = Timer()
    var SongToPlay: URL!
    var Songs : JSON = []
    var index : Int = 0
    var i = 0
    var Song : String! = "http://adcarryteam.000webhostapp.com/images/5b7587e2c30ae.mp3"
    var meterrings : [Float] = []
    var FirstEntry : Bool = true
    var FirstDeselect : Bool = true
    var selectedIndexPath : IndexPath = IndexPath(row: 0, section: 0)
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!
    var offlineRender = OfflineRenderer()
    var isVideo : Bool = false
    var selectedFilter = 0
    var isSolo = true
    var isDuoCreate = ""
    var isSecondTime = false
    var AKplayerTime : Double!
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")
       
    }
    var documentFolderPath : URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
     
        return documentDirectory
    }
    var tempSong : URL {
        return documentFolderPath.appendingPathComponent("/song.mp3")
    }
    var recordVoiceURL : URL {
        return documentFolderPath.appendingPathComponent("recording.m4a")
    }
    var mixedAudioURL : URL {
        return documentFolderPath.appendingPathComponent("mixed.m4a")
    }
    var recordVideoURL : URL {
        return documentFolderPath.appendingPathComponent("videoRec.mp4")
    }
    var mixedVideoURL : URL {
        return documentFolderPath.appendingPathComponent("mixedVideo.mp4")
    }
    var SourceVideo : URL {
        return documentFolderPath.appendingPathComponent("song.mp4")
    }
    var audioPart : URL {
        return documentFolderPath.appendingPathComponent("audioPart.m4a")
    }
    var file : AKAudioFile!
    var player : AKPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.isNavigationBarHidden = true
       self.startStudio()
       self.getFilters()
        if isVideo == false {
            if Songs[index]["image_src"].exists() {
        ImageSong.setImage(with: URL(string: Songs[index]["image_src"].stringValue), placeholder: nil, transformer: nil, progress: nil, completion: nil)
        
        SongName.text = Songs[index]["song_name"].stringValue
            artist_Label.text = Songs[index]["artist_name"].stringValue
            }else{
                ImageSong.setImage(with: URL(string: Songs[index]["song"]["image_src"].stringValue), placeholder: nil, transformer: nil, progress: nil, completion: nil)
                
                SongName.text = Songs[index]["song"]["song_name"].stringValue
                artist_Label.text = Songs[index]["song"]["artist_name"].stringValue
            }
            byMessage.text = self.getMessage()
            
        }
     //   NotificationCenter.default.addObserver(self, selector: #selector(StudioController.didReceiveMeteringLevelUpdate),                                            name: .audioPlayerManagerMeteringLevelDidUpdateNotification, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(StudioController.didAudioPlayerStartPlays),name: .audioPlayerManagerDidStartPlaying, object: nil)
        
        
       // Session()
 
                
               
               
                
        
          
            //let url = Bundle.main.url(forResource: "avicii", withExtension: "mp3")
           // self.playerEngine = try AVAudioPlayer(contentsOf: tempSong)
            //self.playerEngineRecorder = try AVAudioPlayer(contentsOf: mixedAudioURL)
            
            
            
       // playerEngine.isMeteringEnabled = true
           // playerEngineRecorder.isMeteringEnabled = true
            
        //playerEngine.prepareToPlay()
            //playerEngineRecorder.prepareToPlay()
        //playerEngine.currentTime = 0
            //playerEngineRecorder.currentTime = 0
           // playerEngine.play()
            //self.meterrings = self.audioVis.scaleSoundDataToFitScreen()
        
        
        
      
       
            self.OptionsViewHeight.constant = 0
            self.view.layoutIfNeeded()
        player_slider.delegate = self
        
    }
    func startStudio(){
        do {
            if self.isSecondTime == false {
            file = try AKAudioFile(forReading: recordVoiceURL)
            player =  AKPlayer(audioFile: file)
            self.player.preroll()
            delay = AKVariableDelay(player)
            delay.rampTime = 0.5
            delayMixer = AKDryWetMixer(player, delay)
            
            reverb = AKCostelloReverb(delayMixer)
            reverbMixer = AKDryWetMixer(delayMixer, reverb)
            booster = AKBooster(reverbMixer)
            booster.gain = (UIApplication.shared.delegate as! AppDelegate).booster.gain
            self.volumeSlider.value = Float((UIApplication.shared.delegate as! AppDelegate).booster.gain)
            self.VolumeLabel.text = String(format: "%0.2f", self.volumeSlider.value * 100) + "%"
            
            AudioKit.output = booster
            try AudioKit.start()
            }
            Vlc_player_Song = VLCMediaPlayer()
            if isSolo {
                
                Vlc_player_Song.media = VLCMedia(url: tempSong)
                
            }else{
                if isDuoCreate != "DUOJVideo" {
                    Vlc_player_Song.media = VLCMedia(url: self.SongToPlay)
                }else{
                    Vlc_player_Song.media = VLCMedia(url: self.audioPart)
                }
            }
            Vlc_player_Song.addObserver(self, forKeyPath: "time", options: [], context: nil)
            Vlc_player_Song.addObserver(self, forKeyPath: "remainingTime", options: [], context: nil)
            if isVideo {
                Vlc_VideoPlayer = VLCMediaPlayer()
                Vlc_VideoPlayer.delegate = self
                // if self.isSolo == false {
                if isDuoCreate != "DUOJVideo" {
                    Vlc_VideoPlayer.media = VLCMedia(url: recordVideoURL)
                }else{
                    Vlc_VideoPlayer.media = VLCMedia(url: mixedVideoURL)
                }
                //  }else{
                //    Vlc_VideoPlayer.media = VLCMedia(url: self.SongToPlay)
                // }
                //Vlc_VideoPlayer.addObserver(self, forKeyPath: "time", options: [], context: nil)
                //Vlc_VideoPlayer.addObserver(self, forKeyPath: "remainingTime", options: [], context: nil)
                
                Vlc_VideoPlayer.drawable = self.CameraView
            }else{
                Vlc_player_Song.delegate = self
            }
            
            
            if isSecondTime {
                try  AudioKit.engine.start()
                self.startPlayers()
               
            }
            self.isSecondTime = true
        }catch{
            print (error)
        }
    }
    func getMessage() -> String {
        return ScriptBase.sharedInstance.getLanguage() == "fr" ? "par" : "by"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startPlayers()
        
    }
    func getFilters(){
        var effects : [NSManagedObject] = []
        EffectsObject = []
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
        EffectsObject.append(Effect(name: "None",image: UIImage(), delay: 0.0, delayMixer: 0.50, reverb: 0.60, reverbMixer: 0.50))
        EffectsObject.append(Effect(name: "Small Boost", image: UIImage(named: "all filter"),delay: 0.71, delayMixer: 0.91, reverb: 0.60, reverbMixer: 0.50))
        EffectsObject.append(Effect(name: "Small Room", image: UIImage(named: "all filter"),delay: 0.68, delayMixer: 0.50, reverb: 0.89, reverbMixer: 0.50))
        EffectsObject.append(Effect(name: "Big Room", image: UIImage(named: "all filter"),delay: 0.85, delayMixer: 0.84, reverb: 0.86, reverbMixer: 0.60))
        if effects.count != 0 {
            for obj in effects {
                EffectsObject.append(Effect(name: obj.value(forKey: "name") as? String, image: UIImage(), delay: obj.value(forKey: "delay") as? Double, delayMixer: obj.value(forKey: "delayMixer") as? Double, reverb: obj.value(forKey: "reverb") as? Double, reverbMixer: obj.value(forKey: "reverbMixer") as? Double))
            }
        }
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.reloadData()
        tableview.delegate?.horizontalTableView!(tableview, didSelectColumnAt: IndexPath(row: appDelegate.SelectedFilter, section: 0))
        
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
      let object = aNotification?.object as! VLCMediaPlayer
        
       // print("VLC: ",object.time)
        if self.FirstTimeSync && isVideo {
        let currentTime = object.time.value.doubleValue / 1000
        print("VLC: ", currentTime)
        print("AKPlayer: ",self.player.currentTime)
        self.player.setPosition(Double(currentTime))
        self.Vlc_player_Song.time = object.time
         self.FirstTimeSync = false
        }
        if self.FirstTimeSync && isVideo == false {
            let currentTime = object.time.value.doubleValue / 1000
            print("VLC: ", currentTime)
            print("AKPlayer: ",self.player.currentTime)
            self.player.setPosition(Double(currentTime))
            self.FirstTimeSync = false
        }
        
    }
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        let objet = aNotification?.object as! VLCMediaPlayer
        switch objet.state {
        case .ended:
            
            self.player.preroll(from: 0, to: self.player.duration)
            self.Vlc_player_Song.time = VLCTime(int: 0)
            if isVideo {
                self.Vlc_VideoPlayer.time = VLCTime(int: 0)
                
            }
            self.player_slider.setProgress(0)
            self.play_p.setImage(UIImage(named: "Controls_Play"), for: .normal)
            self.FirstTimeSync = true
            self.Stop_resume = 0
            
        default:
            break
        }
    }
    func startPlayers(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           
            if AudioKit.engine.isRunning {
                self.Vlc_player_Song.play()
                if self.isVideo {
                    self.Vlc_VideoPlayer.audio.isMuted = true
                    self.Vlc_VideoPlayer.play()
                    
                }
                
                self.player.isLooping = false
                self.player.play()
                 self.play_p.setImage(#imageLiteral(resourceName: "Controls_Pause"), for: .normal)
           /*    _ = AKPlaygroundLoop(every: 0.000000000001) {
                let min = Int(self.player.currentTime) / 60
                
                let sec = Int(self.player.currentTime) - ((Int(self.player.currentTime) / 60) * 60 )
                
                print("AKPlayer: ",NSString(format: "%i:%02i",min,sec ))
                
                } */
                //self.synchronizePlayer()
                
              
                
            }else{
                self.startPlayers()
            }
        }
       
        
    }
    func synchronizePlayer(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.Vlc_VideoPlayer.isPlaying && self.player.isPlaying {
                self.Vlc_VideoPlayer.equalizerEnabled = true
               
                self.Vlc_player_Song.rewind(atRate: 0)
                self.player_slider.updateProgressNew(self.Vlc_player_Song.position, remaining: self.Vlc_player_Song.remainingTime, actualTime: self.Vlc_player_Song.time)
               
                self.player.play(from: 0)
            }else{
                self.synchronizePlayer()
            }
        }
        
    }
    //obsereValues
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "time" {
          
            self.player_slider.updateProgressNew(self.Vlc_player_Song.position, remaining: self.Vlc_player_Song.remainingTime, actualTime: self.Vlc_player_Song.time)
            //self.wave_formVis.updateWaveWithBuffer(self.Vlc_player.media., withBufferSize: 20, withNumberOfChannels: self.Vlc_player.numberOfBands)
            
            //print("Info:",self.Vlc_player.media.tracksInformation)
            
            
            
            
        }else if keyPath == "remainingTime"{
         
            self.player_slider.updateProgressNew(self.Vlc_player_Song.position, remaining: self.Vlc_player_Song.remainingTime, actualTime: self.Vlc_player_Song.time)
            
            
            
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        
    }
    func onValueChanged(progress: Float, remaining: VLCTime, actual: VLCTime) {
        
        print("progress : ", progress)
        if isVideo {
            self.Vlc_VideoPlayer.position = progress
            self.Vlc_player_Song.position = progress
            if self.player != nil {
            self.player.setPosition(Double(progress))
            }
           self.FirstTimeSync = true
            // let currentTime = self.Vlc_VideoPlayer.time.value.doubleValue / 1000
          //  self.player.setPosition(Double(currentTime))
        //    self.Vlc_player_Song.time = self.Vlc_VideoPlayer.time
        
        }else{
              self.Vlc_player_Song.position = progress
            if self.player != nil {
            self.player.setPosition(Double(progress))
            }
            //let currentTime = self.Vlc_player_Song.time.value.doubleValue / 1000
             //self.player.setPosition(Double(currentTime))
            self.FirstTimeSync = true
        }
        //self.player.setPosition(Double(self.Vlc_player_Song!.time!.intValue))
    }
    func mixVoiceToBeat(type:String,RecorderFile:URL){
        if type == "Audio" || type == "DUOJOnlyAudio" || type == "DUOJOnlyAudioFromVideo" {
            DispatchQueue.main.async {
               SwiftSpinner.show("Creating the Audio...")
            }
        
        let composition : AVMutableComposition = AVMutableComposition()
        let compositionMusic = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionVoice =  composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            var musicAsset: AVAsset!
            if type == "DUOJOnlyAudioFromVideo" {
                musicAsset = AVAsset(url: self.audioPart)
            }else{
             musicAsset = AVAsset(url: tempSong)
            }
        let voiceAsset = AVAsset(url: RecorderFile)
        let musicAssetTrack = musicAsset.tracks(withMediaType: AVMediaType.audio).first
        let voiceAssetTrack = voiceAsset.tracks(withMediaType: AVMediaType.audio).first
        
        //now we will merge the voice and beat
        
        try! compositionMusic?.insertTimeRange(CMTimeRange(start: CMTime.zero , duration: musicAsset.duration), of: musicAssetTrack!, at: CMTime.zero)
        try! compositionVoice?.insertTimeRange(CMTimeRange(start: CMTime.zero , duration: voiceAsset.duration), of: voiceAssetTrack!, at: CMTime.zero)
       
        if FileManager.default.fileExists(atPath: mixedAudioURL.path) {
            try? FileManager.default.removeItem(atPath: mixedAudioURL.path)
        }
        
        let exporter : AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.determineCompatibleFileTypes { ( all: [AVFileType]
            ) in
            print("supported")
            print(all)
            exporter.outputURL = self.mixedAudioURL
            exporter.outputFileType = AVFileType.init(rawValue: "public.mpeg-4")
            exporter.shouldOptimizeForNetworkUse = true
            exporter.exportAsynchronously {
                DispatchQueue.main.async {
                    if exporter.status == .completed {
                        //export Complete
                        print("URLMIXED:",self.mixedAudioURL.path)
                         DispatchQueue.main.async {
                        SwiftSpinner.hide()
                        }
                        let q = self.storyboard?.instantiateViewController(withIdentifier: "SaveAndShareController") as! SaveAndShareController
                        q.Songs = self.Songs
                        q.index = self.index
                        q.SongToSave = self.mixedAudioURL
                        q.isDuoCreate = self.isDuoCreate
                        q.CustomLyrics = self.CustomLyrics
                        q.navigation = self.navigation
                        q.typeOfMedia = "Audio"
                        self.navigation.pushViewController(q, animated: true)
                        
                    }else{
                        //export failed
                        print(exporter.error.debugDescription)
                    }
                }
            }
        }
        }else if type == "SoloVideo" || type == "DuoCVideo"{
           /*  DispatchQueue.main.async {
            SwiftSpinner.show("Creating the Video...")
            } */
            let composition : AVMutableComposition = AVMutableComposition()
            let compositionVideo = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let compositionVoice =  composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            let compostionMusic = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            let videoAsset = AVAsset(url: recordVideoURL)
            let voiceAsset = AVAsset(url: RecorderFile)
            let MusicAsset = AVAsset(url: tempSong)
            let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first
            let voiceAssetTrack = voiceAsset.tracks(withMediaType: AVMediaType.audio).first
            let musicAssetTrack = MusicAsset.tracks(withMediaType: AVMediaType.audio).first
            try! compositionVideo?.insertTimeRange(CMTimeRange(start: CMTime.zero , duration: videoAsset.duration), of: videoAssetTrack!, at: CMTime.zero)
            try! compositionVoice?.insertTimeRange(CMTimeRange(start: CMTime.zero , duration: voiceAsset.duration), of: voiceAssetTrack!, at: CMTime.zero)
            try! compostionMusic?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: MusicAsset.duration), of: musicAssetTrack!, at: CMTime.zero)
            
            if FileManager.default.fileExists(atPath: mixedVideoURL.path) {
                try? FileManager.default.removeItem(atPath: mixedVideoURL.path)
            }
            
            let exporter : AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)!
            exporter.determineCompatibleFileTypes { ( all: [AVFileType]
                ) in
                print("supported")
                print(all)
                exporter.outputURL = self.mixedVideoURL
                exporter.outputFileType = AVFileType.init("public.mpeg-4")
                exporter.shouldOptimizeForNetworkUse = true
                exporter.exportAsynchronously {
                    DispatchQueue.main.async {
                        if exporter.status == .completed {
                            //export Complete
                            print("URLMIXED:",self.mixedVideoURL.path)
                            
                            let q = self.storyboard?.instantiateViewController(withIdentifier: "SaveAndShareController") as! SaveAndShareController
                            q.Songs = self.Songs
                            q.index = self.index
                            q.isDuoCreate = self.isDuoCreate
                            q.SongToSave = self.mixedVideoURL
                            q.typeOfMedia = "Video"
                            q.CustomLyrics = self.CustomLyrics
                            q.navigation = self.navigation
                            self.navigation.pushViewController(q, animated: true)
                            
                        }else{
                            //export failed
                             SwiftSpinner.hide()
                            print(exporter.error.debugDescription)
                        }
                    }
                }
            }
            
            
            
            
        } else {
         
     
            print("SourceVideo: ",SourceVideo)
            print("recordVideoURL: ",recordVideoURL)
             print("recordVoiceURL: ",recordVoiceURL)
    
            
            self.processVideoWithAudio(SourceVideo: mixedVideoURL, FirstSourceAudio: self.audioPart, SecondSourceAudio: RecorderFile) { (url, error) in
                self.clearAllNotice()
                if error == nil {
                    let q = self.storyboard?.instantiateViewController(withIdentifier: "SaveAndShareController") as! SaveAndShareController
                    q.Songs = self.Songs
                    q.index = self.index
                    q.SongToSave = url
                    q.typeOfMedia = "Video"
                    q.CustomLyrics = self.CustomLyrics
                    q.isDuoCreate = self.isDuoCreate
                    q.navigation = self.navigation
                    self.navigation.pushViewController(q, animated: true)
                }
            }
           
           
            
           
            
         
        }
    
    }
    func fireTimers(){
        // self.playerEngine.play()
       /* do {
            try _ = AudioPlayerManager.shared.play(at: self.tempSong)
            
        }catch(let error) {
            print(error.localizedDescription)
        } */
        
       self.startStudio()
    }
    @IBAction func Play_Pause(_ sender: UIButton) {
        if sender.image(for: .normal) == #imageLiteral(resourceName: "Controls_Play") {
            sender.setImage(#imageLiteral(resourceName: "Controls_Pause"), for: .normal)
          
            if Stop_resume == 0 {
            self.fireTimers()
       
            }else{
                self.ResumeTimers()
            }
             self.Stop_resume = 1
        }else{
          sender.setImage(#imageLiteral(resourceName: "Controls_Play"), for: .normal)
              self.Stop_resume = 1
         self.StopTimers()
            
        }
    }
    func ResumeTimers(){
       
       /* if AudioKit.engine.isRunning == false {
             print("AudioKit is not running")
            do {
                try AudioKit.engine.start()
                player.setPosition( self.player.duration / self.AKplayerTime )
                player.play(from: self.AKplayerTime)
                
                Vlc_player_Song.play()
                if isVideo {
                    Vlc_VideoPlayer.play()
                }
            }catch(let error as NSError ) {
                print("AudioKit restart: ",error)
            }
        }else{
            print("AudioKit is running")
            player.play()
            
            Vlc_player_Song.play()
            if isVideo {
                Vlc_VideoPlayer.play()
            }
        } */
        do {
        file = try AKAudioFile(forReading: recordVoiceURL)
        player =  AKPlayer(audioFile: file)
        self.player.preroll(from: self.AKplayerTime, to: self.player.duration)
        delay = AKVariableDelay(player)
        delay.rampTime = 0.5
        delayMixer = AKDryWetMixer(player, delay)
        
        reverb = AKCostelloReverb(delayMixer)
        reverbMixer = AKDryWetMixer(delayMixer, reverb)
        booster = AKBooster(reverbMixer)
        booster.gain = (UIApplication.shared.delegate as! AppDelegate).booster.gain
        self.volumeSlider.value = Float((UIApplication.shared.delegate as! AppDelegate).booster.gain)
        self.VolumeLabel.text = String(format: "%0.2f", self.volumeSlider.value * 100) + "%"
        
        AudioKit.output = booster
        try AudioKit.start()
            player.play()
            
            Vlc_player_Song.play()
            if isVideo {
                Vlc_VideoPlayer.play()
            }
        }catch (let error as NSError) {
            print("No changes error: ", error)
        }
        
        
     
    }
    func StopTimers(){
        //self.playerEngine.pause()
        self.AKplayerTime = self.player.currentTime
        player.stop()
        
        
        
        Vlc_player_Song.pause()
        if isVideo {
            Vlc_VideoPlayer.pause()
        }
        do {
            try AudioKit.stop()
            AudioKit.disconnectAllInputs()
        }catch(let error as NSError) {
            print("Disconnecting error: ",error)
        }
       
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        if self.isDuoCreate != "DUOJ" && self.isVideo {
            if selectedFilter != 0 {
                DispatchQueue.main.async {
                    SwiftSpinner.show("Applying Filters...")
                }
                
            }else{
                DispatchQueue.main.async {
                    SwiftSpinner.show("Please wait!...")
                }
            }
        }else{
            self.pleaseWait()
        }
        
        self.player.stop()
        self.Vlc_player_Song.stop()
        self.Vlc_player_Song = nil
        if isVideo {
            self.Vlc_VideoPlayer.stop()
            self.Vlc_VideoPlayer = nil
        }
        
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
          
       
        
        AKSettings.bufferLength = .medium
        AKSettings.numberOfChannels = 2
        AKSettings.sampleRate = 44100
           
            
                self.offlineRender.enableManualRendering()
        // let sampleTimeZero = AVAudioTime(sampleTime: 0, atRate: AudioKit.format.sampleRate)
        let settings = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
                self.player.preroll(from: 0, to: self.player.duration)
        
        let renderURL =  self.documentFolderPath.appendingPathComponent("processed.m4a")
        if FileManager.default.fileExists(atPath: renderURL.path) {
            try? FileManager.default.removeItem(atPath: renderURL.path)
        }
        
        let sampleTimeZero = AVAudioTime(sampleTime: 0, atRate: AudioKit.format.sampleRate)
                self.player.play(at: sampleTimeZero)
        do {
            
            try self.offlineRender.renderToURL(renderURL, length: self.player.audioFile!.length, settings: settings)
        } catch {
            print("renderError:",error)
        }
                self.player.stop()
                self.offlineRender.disableManualRendering()
        print("we are ready...")
        if self.isVideo {
            //self.mixVoiceToBeat(type: "Video",RecorderFile: renderURL)
            if self.isSolo {
                self.mixVoiceToBeat(type: "SoloVideo",RecorderFile: renderURL)
            }else{
                if self.isDuoCreate == "DUOC" {
                self.mixVoiceToBeat(type: "DuoCVideo", RecorderFile: renderURL)
                }else{
                    SwiftSpinner.hide()
                   self.mixVoiceToBeat(type: "DuoJVideo", RecorderFile: renderURL)
                }
            }
            
            }else{
            if self.isSolo || self.isDuoCreate != "DUOJ" {
                    self.mixVoiceToBeat(type: "Audio",RecorderFile: renderURL)
            }else{
                
                if self.Songs[self.index]["type"].exists() {
                    if self.Songs[self.index]["type"].stringValue == "Audio" {
                        self.mixVoiceToBeat(type: "DUOJOnlyAudio",RecorderFile: renderURL)
                    }else{
                        self.mixVoiceToBeat(type: "DUOJOnlyAudioFromVideo",RecorderFile: renderURL)
                    }
                    
                    
                }
                
            }
            }
            
            }
        
    }
    
    @IBAction func EffectsAction(_ sender: UIButton) {
        let shouldExpand = self.OptionsViewHeight.constant == 0
        self.OptionsViewHeight.constant = shouldExpand ? 94.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.volumeEffectsContainer.subviews.forEach { if ( $0.tag != 5 && $0.tag != 6 )  {$0.alpha = shouldExpand ? 1.0 : 0.0 } else{ $0.alpha = 0} }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func VolumeAction(_ sender: UIButton) {
        let shouldExpand = self.OptionsViewHeight.constant == 0
        self.OptionsViewHeight.constant = shouldExpand ? 94.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.volumeEffectsContainer.subviews.forEach { if ( $0.tag == 5 || $0.tag == 6 )  {$0.alpha = shouldExpand ? 1.0 : 0.0 } else { $0.alpha = 0} }
            self.view.layoutIfNeeded()
        }
    }
    
    /***** Effects Delegate and datasource *********/
    func numberOfSections(in tableView: BWHorizontalTableView!) -> Int {
        return 1
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, numberOfColumnsInSection section: Int) -> Int {
        return EffectsObject.count
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, cellForColumnAt indexPath: IndexPath!) -> BWHorizontalTableViewCell! {
        
        let idientifier = "HorizontalTableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: idientifier) as? HorizontalTableViewCell
        if cell == nil {
            cell = HorizontalTableViewCell(reuseIdentifier: idientifier)
            cell?.selectionStyle = UITableViewCell.SelectionStyle.blue
            
        }
        // image Cell
        // name Cell
        cell?.showPlanet(EffectsObject[indexPath.row].name)
      
        cell?.planetImageView.image = imageColor(with: .white, andBounds: (cell?.planetImageView.bounds)!)
        cell?.planetNameLabel.textColor = UIColor(red: 0, green: 0.360784, blue: 0.458824, alpha: 1)
        cell?.planetImageView.backgroundColor = .white
         //   cell?.planetImageView.image = EffectsObject[indexPath.row].image
       // cell?.planetImageView.contentMode = .scaleToFill
        
        
        return cell
    }
    func imagePrimaryColor(imageV:UIImageView, completionHandler: @escaping (UIImageColors) -> Void)  {
        imageV.image!.getColors(scaleDownSize: CGSize(width: imageV.frame.width, height: imageV.frame.height), completionHandler: { (colors) in
            
            
            completionHandler(colors)
        })
    }
    func imageColor(with color: UIColor, andBounds imgBounds: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imgBounds.size, false, 0)
        color.setFill()
        UIRectFill(imgBounds)
        let img = UIGraphicsGetImageFromCurrentImageContext() as? UIImage
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    func horizontalTableView(_ tableView: BWHorizontalTableView!, widthForColumnAt indexPath: IndexPath!) -> CGFloat {
        return 84.0
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, widthForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, widthForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, viewForHeaderInSection section: Int) -> UIView! {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: tableView.frame.size.height))
        headerView.backgroundColor = UIColor.green.withAlphaComponent(0.1)
        return headerView
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, viewForFooterInSection section: Int) -> UIView! {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: tableView.frame.size.height))
        footerView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        return footerView
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, didSelectColumnAt indexPath: IndexPath!) {
        print("Cell At ",indexPath.section, ":",indexPath.row, "has been tapped.")
        self.selectedFilter = indexPath.row
        self.selectedIndexPath = indexPath
        if FirstEntry == false {
            if FirstDeselect {
                if indexPath.row != 0 {
                    tableView.delegate?.horizontalTableView!(tableView, didDeselectColumnAt: IndexPath(row: 0, section: 0))
                }
                FirstDeselect = false
            }
            self.delay.feedback = EffectsObject[indexPath.row].delay!
            self.delayMixer.balance = EffectsObject[indexPath.row].delayMixer!
            self.reverb.feedback = EffectsObject[indexPath.row].reverb!
            self.reverbMixer.balance = EffectsObject[indexPath.row].reverbMixer!
        }else{
            FirstEntry = false
            
        }
        ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.image = imageColor(with: UIColor.blue.withAlphaComponent(0.5), andBounds: ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.bounds)
        
        
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, didDeselectColumnAt indexPath: IndexPath!) {
        print("Cell At ",indexPath.section, ":",indexPath.row, "has been Deselected.")
        for q in tableView!.indexPathsForVisibleColumns! {
            if q  == indexPath {
                ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.image = imageColor(with: .white, andBounds: ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.bounds)
            }
        }
        
    }
    
    func horizontalTableView(_ tableView: BWHorizontalTableView!, willDisplay cell: BWHorizontalTableViewCell!, forColumnAt indexPath: IndexPath!) {
        print("Cell At ",indexPath.section, ":",indexPath.row, "will be displayed.")
        if indexPath == self.selectedIndexPath {
            if tableView.cellForColumn(at: indexPath) != nil {
              ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.image = imageColor(with: UIColor.blue.withAlphaComponent(0.5), andBounds: ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.bounds)
            }
        }else{
            if tableView.cellForColumn(at: indexPath) != nil {
             ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.image = imageColor(with: .white, andBounds: ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.bounds)
            }
        }
        
        
        
        
        
    }
    @IBAction func SliderAction(_ sender: UISlider) {
        
        self.VolumeLabel.text = String(format: "%0.2f", sender.value * 100) + "%"
        self.booster.gain = Double(sender.value)
        
    }
    /***** END *********/
    
}
class OfflineRenderer: AKNode {
    public func enableManualRendering() {
        do {
            AudioKit.engine.stop()
            
            let maxNumberOfFrames: AVAudioFrameCount = 4096
            try AudioKit.engine.enableManualRenderingMode(.offline, format: AudioKit.format, maximumFrameCount: maxNumberOfFrames)
            
            try AudioKit.engine.start()
        } catch {
            print("could not enable manual rendering mode, \(error)")
        }
    }
    
    public func disableManualRendering() {
        AudioKit.engine.disableManualRenderingMode()
    }
    
    public func renderToURL(_ url: URL, length: AVAudioFramePosition, settings: [String : Any]) throws {
        let outputFile = try AVAudioFile(forWriting: url, settings: settings)
        let engine = AudioKit.engine
        
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                                        frameCapacity:  engine.manualRenderingMaximumFrameCount)!
        
        while engine.manualRenderingSampleTime < length {
            do {
               
                let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(length - engine.manualRenderingSampleTime))
                let status = try engine.renderOffline(framesToRender, to: buffer)
                
                if status == .success {
                    try outputFile.write(from: buffer)
                }
            } catch {
                print("render failed, \(error)")
            }
        }
    }
}
extension StudioController {
    /// Merges video and sound while keeping sound of the video too
    ///
    /// - Parameters:
    ///   - videoUrl: URL to video file
    ///   - audioUrl: URL to audio file
    ///   - shouldFlipHorizontally: pass True if video was recorded using frontal camera otherwise pass False
    ///   - completion: completion of saving: error or url with final video
    func mergeVideoAndAudio(videoUrl: URL,
                            audioUrl: URL,
                            shouldFlipHorizontally: Bool = false,
                            completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
        
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioOfVideoTrack = [AVMutableCompositionTrack]()
        
        //start merge
        
        let aVideoAsset = AVAsset(url: videoUrl)
        let aAudioAsset = AVAsset(url: audioUrl)
        
        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                        preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
        let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        // Default must have tranformation
        compositionAddVideo!.preferredTransform = aVideoAssetTrack.preferredTransform
        
        if shouldFlipHorizontally {
            // Flip video horizontally
            var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
            frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
            compositionAddVideo!.preferredTransform = frontalTransform
        }
        
        mutableCompositionVideoTrack.append(compositionAddVideo!)
        mutableCompositionAudioTrack.append(compositionAddAudio!)
        mutableCompositionAudioOfVideoTrack.append(compositionAddAudioOfVideo!)
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: CMTime.zero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                duration: aVideoAssetTrack.timeRange.duration),
                                                                of: aAudioAssetTrack,
                                                                at: CMTime.zero)
            
            // adding audio (of the video if exists) asset to the final composition
            if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
                try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                                                           duration: aVideoAssetTrack.timeRange.duration),
                                                                           of: aAudioOfVideoAssetTrack,
                                                                           at: CMTime.zero)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // Exporting
        let savePathUrl: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl)
        } catch { print(error.localizedDescription) }
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                print("success")
                completion(nil, savePathUrl)
            case AVAssetExportSession.Status.failed:
                print("failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil)
            default:
                print("complete")
                completion(assetExport.error, nil)
            }
        }
        
    }
    /// Merges two video while keeping sound of the  two videos too
    ///
    /// - Parameters:
    ///   - videoUrlOne: URL to video file
    ///   - videoUrlTwo: URL to audio file
    ///   - shouldFlipHorizontally: pass True if video was recorded using frontal camera otherwise pass False
    ///   - completion: completion of saving: error or url with final video
    func mergeTwoVideos(videoUrlOne: URL,
                            videoUrlTwo: URL,
                            audioOfVideoTwo: URL,
                            shouldFlipHorizontally: Bool = false,
                            completion: @escaping (_ error: Error?, _ url: URL?) -> Void) {
        let session = AVAudioSession.sharedInstance()
        let originalSessionCategory = session.category
        do {
          try session.setCategory(AVAudioSession.Category.multiRoute, mode: .measurement, options: [])
        }catch (let error) {
            print("Erros multiRoute:",error.localizedDescription)
        }
        let videoAssets1 = AVAsset(url: videoUrlOne)
        let videoAssets2 = AVAsset(url: videoUrlTwo)
        let audioAsset = AVAsset(url: audioOfVideoTwo)
        let mixComposition = AVMutableComposition()
        
        // Create composition track for first video
        let firstCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try firstCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: videoAssets1.duration), of: videoAssets1.tracks(withMediaType: .video)[0], at: CMTime.zero)
        } catch {
            print("ErrorTimeRange = \(error.localizedDescription)")
        }
        
        // Create composition track for second video
        let secondCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try secondCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: videoAssets2.duration), of: videoAssets2.tracks(withMediaType: .video)[0], at: CMTime.zero)
        } catch {
            print("ErrorTimeRange = \(error.localizedDescription)")
        }
        let FirstCompostionTrackAudio = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do{
            try FirstCompostionTrackAudio?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: audioAsset.duration), of: audioAsset.tracks(withMediaType: .audio)[0] , at: CMTime.zero)
            FirstCompostionTrackAudio?.preferredVolume = 1.0
        }catch {
            print("ErrorTrack = \(error.localizedDescription)")
        }
       /* let secondCompostionTrackAudio = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do{
            try secondCompostionTrackAudio?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: videoAssets1.duration), of: videoAssets1.tracks(withMediaType: .audio)[0] , at: CMTime.zero)
            secondCompostionTrackAudio?.preferredVolume = 0.2
        }catch {
            print("ErrorTrack = \(error.localizedDescription)")
        } */
        //See how we are creating AVMutableVideoCompositionInstruction object.This object will contain the array of our AVMutableVideoCompositionLayerInstruction objects.You set the duration of the layer.You should add the lenght equal to the lingth of the longer asset in terms of duration.
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: CMTime.zero, duration: videoAssets1.duration)
        
        // We will be creating 2 AVMutableVideoCompositionLayerInstruction objects.
        // Each for our 2 AVMutableCompositionTrack.
        // Here we are creating AVMutableVideoCompositionLayerInstruction for out first track.
        // See how we make use of CGAffineTransform to move and scale our First Track.
        // So it is displayed at the bottom of the screen in smaller size.
        // (First track in the one that remains on top).
        let firstLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstCompositionTrack!)
        let firstScale : CGAffineTransform = CGAffineTransform(scaleX: 1, y: 1)
        let firstMove: CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)
        firstLayerInstruction.setTransform(firstScale.concatenating(firstMove), at: CMTime.zero)
        
        
        // Here we are creating AVMutableVideoCompositionLayerInstruction for second track.
        // See how we make use of CGAffineTransform to move and scale our second Track.
        let secondLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondCompositionTrack!)
        let secondScale : CGAffineTransform = CGAffineTransform(scaleX: 1, y: 1)
        let secondMove : CGAffineTransform = CGAffineTransform(translationX: (firstCompositionTrack?.naturalSize.width)! + CGFloat(20), y: 0)
        secondLayerInstruction.setTransform(secondScale.concatenating(secondMove), at: CMTime.zero)
        
        //Now we add our 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction in form of an array.
        mainInstruction.layerInstructions = [firstLayerInstruction, secondLayerInstruction]
        
        // Get the height and width of video.
        let height = (Float((firstCompositionTrack?.naturalSize.height)!) > Float((secondCompositionTrack?.naturalSize.height)!)) ? firstCompositionTrack?.naturalSize.height : secondCompositionTrack?.naturalSize.height
        
        //  height will be larger in both and width is total of both video.
        let width = CGFloat((Float((firstCompositionTrack?.naturalSize.width)!) + Float((secondCompositionTrack?.naturalSize.width)!))) + CGFloat(20)
        
        //Now we create AVMutableVideoComposition object.
        //We can add mutiple AVMutableVideoCompositionInstruction to this object.
        //We have only one AVMutableVideoCompositionInstruction object in our example.
        //You can use multiple AVMutableVideoCompositionInstruction objects to add multiple layers of effects such as fade and transition but make sure that time ranges of the AVMutableVideoCompositionInstruction objects don't overlap.
        let mainCompositionInst = AVMutableVideoComposition()
        mainCompositionInst.instructions = [mainInstruction]
        
        mainCompositionInst.frameDuration = CMTime(value: CMTimeValue(1), timescale: CMTimeScale(30))
        print(CGSize(width: width, height: height!))
        mainCompositionInst.renderSize = CGSize(width: width, height: height!)
        
        
        // Create the export session with the composition and set the preset to the highest quality.
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetPassthrough)
        if FileManager.default.fileExists(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").path) {
            try? FileManager.default.removeItem(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").path)
        }
        // Set the desired output URL for the file created by the export process.
        exporter?.outputURL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4")
        exporter?.videoComposition = mainCompositionInst
        
        // Set the output file type to be a mp4 movie.
        exporter?.outputFileType = AVFileType.init("public.mpeg-4")
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.determineCompatibleFileTypes(completionHandler: { (types) in
        
       
            types.forEach({ (item) in
                print("type:",item.rawValue)
            })
            
            
            
        })
        exporter?.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if exporter?.status == .completed {
                    
                    do {
                        let videoData = try Data(contentsOf: exporter!.outputURL!)
                        
                        // Here video will save in document directory path, you can use your requirement.
                        try videoData.write(to:  URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"), options: Data.WritingOptions.atomic)
                        print( URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").absoluteString, " succesfully saved.")
                        completion(nil,URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"))
                    } catch {
                        print("Failed to Save video ===>>> \(error.localizedDescription)")
                         completion(error,nil)
                    }
                }else{
                //export failed
                    print("ExportFailed:",exporter?.error?.localizedDescription)
            }
            })
        })
        
}
}
