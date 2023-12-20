//
//  KaraokeViewController.swift
//  SINGTN
//
//  Created by macbook on 2018-08-06.
//  Copyright © 2018 Velox-IT. All rights reserved.
//
//factor Time : audioPlayer.currentTime / audioPlayer.duration
//slider.value : Float(factorTime)
import UIKit
import SwiftyJSON
import MapleBacon
import AudioKit
import AudioKitUI
import ReplayKit
import SwiftSpinner
import CoreData
struct SoundRecord {
    var audioFilePathLocal: URL?
    var meteringLevels: [Float]?
}
struct Effect {
    var name : String?
    var image: UIImage?
    var delay : Double?
    var delayMixer : Double?
    var reverb : Double?
    var reverbMixer : Double?
}

class KaraokeViewController: UIViewController,SRCountdownTimerDelegate,AVAudioRecorderDelegate,VTLyricPlayerViewDelegate,VTLyricPlayerViewDataSource,BWHorizontalTableViewDelegate,BWHorizontalTableViewDataSource {
    var navigation : UINavigationController!
    var FirstEntry : Bool = true
    var FirstDeselect : Bool = true
var currentAudioRecord: SoundRecord?
    @IBOutlet weak var picker: UIPickerView!
    var song: JSON = []
     var index = 0
     var lyric:VTKaraokeLyric?
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!
    var tracker : AKAmplitudeTracker!
    var firstSync = true
    @IBOutlet weak var volumeEffectsContainer: UIView!
    
    @IBOutlet weak var labelSlider: UILabel!
    
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var OptionsViewHeight: NSLayoutConstraint!
     private var timingKeys:Array<CGFloat> = [CGFloat]()
    @IBOutlet weak var XButoon: UIButton!
    @IBOutlet weak var containerTop: UIView!
    @IBOutlet weak var containerBot: UIView!
    @IBOutlet weak var effectsB: UIButton!
    
    @IBOutlet weak var containerBar: UIView!
    
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var user_picture: RoundedUIImageView!
    
    
    @IBOutlet weak var WaveFormRecorder: AudioVisualizationView!
    @IBOutlet weak var WaveForm: AudioVisualizationView!
    @IBOutlet weak var backgroundSilderBar: UIImageView!
    @IBOutlet weak var silderBar: LARSBar!
    @IBOutlet weak var containerMiddle: UIView!
    @IBOutlet weak var CountView: SRCountdownTimer!
     //var nowPlayingInfoCenter = NowPlayingInfoCenter()
    @IBOutlet weak var VolumeB: UIButton!
    @IBOutlet weak var tableView: BWHorizontalTableView!
    var EffectsObject : [Effect] = []
    @IBOutlet weak var lyricsV: VTKaraokeLyricPlayerView!
    
    @IBOutlet weak var SingerVideo: UIView!
    
    @IBOutlet weak var UserVideo: UIView!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var audioRecorder : AVAudioRecorder!
    
    var isVideo : Bool = false
    fileprivate var kBufferingRatioKVOKey = 1
    fileprivate var kDurationKVOKey = 1
    fileprivate var kStatusKVOKey = 1
    var LyricController : VTKaraokeLyricsController!
    var timer = Timer()
    var SongToPlay : URL!
    var cameraManager    :PGMCameraKit! = nil
    var helper              : PGMCameraKitHelper! = nil
    var CustomLyrics : [String] = []
    var isSolo = true
    var isDuoCreate = ""
    var VLC_Player : VLCMediaPlayer!
    var AV_Player : AVPlayer!
    var AV_Player_Layer : AVPlayerLayer!
    var documentFolderPath : URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    var recordVoiceURL : URL {
        return documentFolderPath.appendingPathComponent("recording.m4a")
    }
    var recordVideoURL : URL {
        return documentFolderPath.appendingPathComponent("videoRec.mp4")
    }
    var SourceVideo : URL {
        return documentFolderPath.appendingPathComponent("song.mp4")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.WaveForm.audioVisualizationMode = .write
        self.WaveFormRecorder.audioVisualizationMode = .write
        NotificationCenter.default.addObserver(self, selector: #selector(KaraokeViewController.didReceiveMeteringLevelUpdate),
                                               name: .audioPlayerManagerMeteringLevelDidUpdateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KaraokeViewController.didFinishRecordOrPlayAudio),
                                               name: .audioPlayerManagerMeteringLevelDidFinishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KaraokeViewController.didAudioPlayerStartPlays),
                                               name: .audioPlayerManagerDidStartPlaying, object: nil)
        
        if isVideo {
             cameraManager.resumeCaptureSession()
        }
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .audioPlayerManagerMeteringLevelDidUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioPlayerManagerMeteringLevelDidFinishNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioPlayerManagerDidStartPlaying, object: nil)
        
    }
    
    @objc private func didAudioPlayerStartPlays(_ notification: Notification){
        
       
        self.startRecording {
            if self.isVideo == false {
            self.timer.invalidate()
                 if self.audioRecorder.isRecording {
                  
                  self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                    
            }
                   }
            
        }
      
     
        
            
        
    
    }
    override var shouldAutorotate: Bool {
        return false
    }
    @objc private func didFinishRecordOrPlayAudio(_ notification: Notification) {
    self.LyricController.stop()
       
        if isVideo == false {
        self.WaveForm.stop()
        self.WaveFormRecorder.stop()
             self.audioRecorder.stop()
        }
        if VLC_Player != nil {
            VLC_Player.stop()
        }
        if AV_Player != nil {
            AV_Player.seek(to: CMTime(value: 0, timescale: 1))
            AV_Player.pause()
            AV_Player_Layer.removeFromSuperlayer()
            AV_Player = nil
        }
        do{
           
            if AudioKit.engine.isRunning {
                
                AudioKit.disconnectAllInputs()
            try AudioKit.stop()
            }
            
        }catch (let error) {
            print("AudioKitStop:",error.localizedDescription)
        }
        if isVideo {
        self.cameraManager.stopRecordingVideo { (videoURL, error, local) in
            if let err = error {
                print("Error ocurred: \(err)")
                
            }
            else {
                if FileManager.default.fileExists(atPath: (self.recordVideoURL.path)) {
                    do {
                        try FileManager.default.removeItem(at: self.recordVideoURL)
                    }
                    catch let error as NSError {
                        print(error)
                        // print("Failed to remove item \(tempPath), error = \(error)")
                    }
                }
                DispatchQueue.main.async(execute: {
                     SwiftSpinner.show("Video Processing...")
                })
           
                self.cameraManager.compressVideo(inputURL: videoURL!, outputURL: self.recordVideoURL as NSURL, outputFileType: AVFileType.mp4.rawValue, handler: { (session) in
                    if let currSession = session {
                        if currSession.status == .completed {
                            print("Video url:",  currSession.outputURL!.absoluteString)
                            SwiftSpinner.show("Extracting Audio...")
                            let asset = AVURLAsset(url: currSession.outputURL!)
                            if FileManager.default.fileExists(atPath: (self.recordVoiceURL.path)) {
                                do {
                                    try FileManager.default.removeItem(at: self.recordVoiceURL)
                                }
                                catch let error as NSError {
                                    print(error)
                                    // print("Failed to remove item \(tempPath), error = \(error)")
                                }
                            }
                            asset.writeAudioTrackToURL(self.recordVoiceURL, completion: { (success, error) in
                                DispatchQueue.main.async(execute: {
                                    SwiftSpinner.hide()
                                })
                                if !(success) {
                                    print("Error WriteAudioTrackToURL: ",error?.localizedDescription as Any)
                                }else{
                                    
                                    if self.isDuoCreate != "DUOJVideo"  {
                                 
                                        print("Video url:",  currSession.outputURL!.absoluteString)
                                        let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
                                        q.Songs = self.song
                                        q.index = self.index
                                        q.CustomLyrics = self.CustomLyrics
                                        q.navigation = self.navigation
                                        q.isVideo = true
                                        q.isSolo = self.isSolo
                                        q.SongToPlay = self.SongToPlay
                                        self.navigation.pushViewController(q, animated: true)
                                    }else{
                                       
                                        self.ProcessVideo(FirstSourceVideo:  self.recordVideoURL , SecondSourceVideo: self.SourceVideo , completion: { (url, error) in
                                            if error == nil {
                                                SwiftSpinner.hide()
                                                let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
                                                q.Songs = self.song
                                                q.index = self.index
                                                q.CustomLyrics = self.CustomLyrics
                                                q.navigation = self.navigation
                                                q.isVideo = true
                                                q.isSolo = self.isSolo
                                                q.SongToPlay = self.SongToPlay
                                                q.isDuoCreate = self.isDuoCreate
                                                self.navigation.pushViewController(q, animated: true)
                                            }
                                        })
                                        
                                    }
                                    
                                }})
                         
                            
                        /*    let asset = AVURLAsset(url: currSession.outputURL!)
                            if FileManager.default.fileExists(atPath: (self.recordVoiceURL.path)) {
                                do {
                                    try FileManager.default.removeItem(at: self.recordVoiceURL)
                                }
                                catch let error as NSError {
                                    print(error)
                                    // print("Failed to remove item \(tempPath), error = \(error)")
                                }
                            }
                            asset.writeAudioTrackToURL(self.recordVoiceURL, completion: { (success, error) in
                                 DispatchQueue.main.async(execute: {
                                SwiftSpinner.hide()
                                })
                                if !(success) {
                                    print("Error WriteAudioTrackToURL: ",error?.localizedDescription as Any)
                                }else{
                                    let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
                                    q.Songs = self.song
                                    q.index = self.index
                                    q.CustomLyrics = self.CustomLyrics
                                    q.navigation = self.navigation
                                    q.isVideo = true
                                    q.isSolo = self.isSolo
                                        q.SongToPlay = self.SongToPlay
                                    self.navigation.pushViewController(q, animated: true)
                                }
                                
                            }) */
 
                           
                            
                        } else if currSession.status == .failed {
                             DispatchQueue.main.async(execute: {
                             SwiftSpinner.hide()
                             })
                         
                            print(" There was a problem compressing the video maybe you can try again later. Error: \(currSession.error!.localizedDescription)")
                        }
                    }
                })
                
                
            }
        }
        }else{
            
        }
        
       
    }
    @objc private func didReceiveMeteringLevelUpdate(_ notification: Notification) {
        let percentage = notification.userInfo!["percentage"] as! Float
        if self.WaveForm.audioVisualizationMode == .write {
            
            
            self.WaveForm.addMeteringLevel(percentage)
        }
        //self.audioMeteringLevelUpdate?(percentage)
    }
    @IBAction func ViewDiDTap(_ sender: UITapGestureRecognizer) {
        print("go on baby")
      
        if (AudioPlayerManager.shared.audioPlayer?.isPlaying)! {
             self.view.hideToast()
            self.view.makeToast("Pause", duration: 3.0, position: .center, title: nil, image: #imageLiteral(resourceName: "bell").fillAlpha(fillColor: UIColor.white))
           // self.streamer.pause()
            try! AudioPlayerManager.shared.pause()
           
            self.LyricController.pause()
            if isVideo {
                self.cameraManager.pauseRecordingVideo()
                self.AV_Player.pause()
            }else{
                 self.audioRecorder.pause()
                self.timer.invalidate()
                
            }
        }else{
            self.view.hideToast()
            self.view.makeToast("Play", duration: 3.0, position: .center, title: nil, image: #imageLiteral(resourceName: "bell").fillAlpha(fillColor: UIColor.white))
          //  self.streamer.play()
            
            _ = try! AudioPlayerManager.shared.resume()
            
           
           
            self.LyricController.resume()
            if isVideo{
                self.cameraManager.resumeRecordingVideo()
                self.AV_Player.play()
                
            }else{
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                
               self.audioRecorder.record()
            }
        }
       
    }
    fileprivate func convertFromAVFileType(_ input: AVFileType) -> String {
        return input.rawValue
    }

    func show_hide_containers(hide:Bool){
        self.XButoon.isHidden = hide
        self.containerTop.isHidden = hide
        self.containerBot.isHidden = hide
        if hide {
            self.SingerVideo.isHidden = hide
            self.UserVideo.isHidden = hide
        }else{
            if self.song[index]["type"].stringValue == "Video" && self.isDuoCreate == "DUOJVideo" && isVideo {
                self.SingerVideo.isHidden = hide
                self.UserVideo.isHidden = hide
            }
        }
        if self.isVideo == false {
        self.WaveForm.isHidden = hide
        self.WaveFormRecorder.isHidden = hide
        }else{
            self.WaveForm.isHidden = true
            self.WaveFormRecorder.isHidden = true
        }
        if isVideo {
            self.containerMiddle.isHidden = hide
        }
        self.effectsB.isHidden = hide
        self.silderBar.isHidden = hide
        self.backgroundSilderBar.isHidden = hide
        self.containerBar.isHidden = hide
        self.user_picture.isHidden = hide
        self.user_name.isHidden = hide
        
        self.volumeEffectsContainer.isHidden = hide
        if hide == false {
            self.OptionsViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }
        
    }
    override func viewDidLayoutSubviews() {
        
        if self.AV_Player_Layer != nil {
            self.AV_Player_Layer.needsDisplayOnBoundsChange = true
            self.AV_Player_Layer.frame = self.SingerVideo.bounds
        }
        super.viewDidLayoutSubviews()
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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
         tableView.delegate?.horizontalTableView!(tableView, didSelectColumnAt: IndexPath(row: 0, section: 0))
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //filter things
        self.silderBar.rightChannelLevel = 0
        self.silderBar.leftChannelLevel = 0
        (UIApplication.shared.delegate as! AppDelegate).preapare_audioKit()
        getFilters()
        //end
        if isSolo == false {
             self.CustomLyrics = []
             do {
            var ab = self.song[index]["lyrics"].stringValue
           print(ab)
                ab.removeFirst()
                ab.removeLast()
                ab = ab.replacingOccurrences(of: "\\", with: "",options: NSString.CompareOptions.literal,range: nil)
                print(ab)
            let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
                print(dataFromString)
                let decodedSentences = try JSONDecoder().decode([LyricsJson].self, from: dataFromString!)
                print(decodedSentences)
            
                
                for i in 0...((decodedSentences.count) - 1) {
                    self.CustomLyrics.append(decodedSentences[i].owner)
                }

                } catch { print("ERROR: ",error) }
            print("CustomLyrics: ",self.CustomLyrics)
            //tempLyric = "{\"lyric\": " + tempLyric
           // tempLyric = tempLyric + "}"
           // lyricsArray = JSON(stringLiteral: tempLyric)
            //tempLyric = ""
            //print(lyricsArray["lyric"].arrayObject)
        /*    do {
            
                
                let decodedSentences = try JSONDecoder().decode([LyricsJson].self, from: lyricsArray.rawData())
                print(decodedSentences)
            } catch { print("ERROR: ",error) } */
            
            print(isDuoCreate)
            print(self.song[index]["type"].stringValue)
            print(isVideo)
            if isDuoCreate == "DUOJVideo" && self.song[index]["type"].stringValue == "Video" && isVideo {
                self.SingerVideo.backgroundColor = UIColor.black
                //self.VLC_Player = VLCMediaPlayer()
                self.AV_Player = AVPlayer(playerItem: AVPlayerItem(url: self.SourceVideo))
                self.AV_Player_Layer = AVPlayerLayer(player: self.AV_Player)
                self.AV_Player_Layer.frame = self.SingerVideo.bounds
                self.AV_Player_Layer.videoGravity = .resize
                //self.VLC_Player.media = VLCMedia(url: self.SourceVideo)
                //self.VLC_Player.audio.isMuted = true
                //self.VLC_Player.drawable = self.SingerVideo
                //self.VLC_Player.play()
               
                
            }
            
        }
        
        if let lyric = self.lyric , self.lyric?.content != nil {
           
            timingKeys = Array(lyric.content!.keys.sorted())
        }
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
            print("FirstName:", a["First_name"].stringValue)
            self.user_name.text = a["First_name"].stringValue + " " + a["Last_name"].stringValue
            if let photo = URL(string: (a["image_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                self.user_picture.setImage(with: photo, placeholder: #imageLiteral(resourceName: "User"), transformer: nil, progress: nil, completion: nil)
            }else{
                self.user_picture.image = #imageLiteral(resourceName: "User")
            }
        }catch {
            print(error)
        }
        
        self.picker.isUserInteractionEnabled = false
        self.containerTop.backgroundColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
        show_hide_containers(hide: true)
        XButoon.addTarget(self, action: #selector(CloseAction(sender:)), for: .touchUpInside)
        CountView .delegate = self
         CountView .timerFinishingText = "Let's sing"
       
        // self.nowPlayingInfoCenter.musicPlayerVC = self
        prepareAudio()
        self.labelSlider.text = "150.0%"
        self.sliderVolume.value = 1.5
        //lyricsV.prepareToPlay()
        LyricController = VTKaraokeLyricsController(picker: picker,timingKeys: timingKeys, lyrics: lyric!, LyricsKeys: self.CustomLyrics)
        LyricController.InitController()
        
       
        
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
        
        return cell
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
        if FirstEntry == false {
            if FirstDeselect {
                if indexPath.row != 0 {
                tableView.delegate?.horizontalTableView!(tableView, didDeselectColumnAt: IndexPath(row: 0, section: 0))
                }
                FirstDeselect = false
            }
            let delegate =  UIApplication.shared.delegate as! AppDelegate
            
       delegate.delay.feedback = EffectsObject[indexPath.row].delay!
        delegate.delayMixer.balance = EffectsObject[indexPath.row].delayMixer!
        delegate.reverb.feedback = EffectsObject[indexPath.row].reverb!
        delegate.reverbMixer.balance = EffectsObject[indexPath.row].reverbMixer!
        delegate.SelectedFilter = indexPath.row
        }else{
            FirstEntry = false
            
        }
        
       ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.image = imageColor(with: UIColor.blue.withAlphaComponent(0.5), andBounds: ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.bounds)
        
        
    }
    func horizontalTableView(_ tableView: BWHorizontalTableView!, didDeselectColumnAt indexPath: IndexPath!) {
        print("Cell At ",indexPath.section, ":",indexPath.row, "has been Deselected.")
         ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.image = imageColor(with: UIColor.white, andBounds: ( tableView.cellForColumn(at: indexPath) as! HorizontalTableViewCell).planetImageView.bounds)
    }
    
    func horizontalTableView(_ tableView: BWHorizontalTableView!, willDisplay cell: BWHorizontalTableViewCell!, forColumnAt indexPath: IndexPath!) {
         print("Cell At ",indexPath.section, ":",indexPath.row, "will be displayed.")
       
       
        
         
        
        
    }
    
     /***** END *********/
    func CalculateAMP(){
      // AudioKit.engine.
        _ = AKPlaygroundLoop(every: 0.1) {
            if AudioKit.engine.isRunning {
                
            self.silderBar.rightChannelLevel = CGFloat((UIApplication.shared.delegate as! AppDelegate).tracker.amplitude) * 10
             self.silderBar.leftChannelLevel = CGFloat((UIApplication.shared.delegate as! AppDelegate).tracker.amplitude) * 10
            }
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
         print("Flag:",flag)
        if flag {
            print("Flag:",flag)
          //mix voice into beats
            //mixVoiceToBeat()
            if isVideo == false {
            let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
            q.Songs = self.song
            q.index = self.index
                q.navigation = self.navigation
                q.CustomLyrics = self.CustomLyrics
                q.isVideo = false
                    q.isSolo = self.isSolo
                q.SongToPlay = self.SongToPlay
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(q, animated: true)
                }
            
            }else{
                
                    cameraManager.stopRecordingVideo { (videoURL, error, localIdentifier) in
                        if let err = error {
                            print("Error ocurred: \(err)")
                            
                        }
                        else {
                            if FileManager.default.fileExists(atPath: (self.recordVideoURL.path)) {
                                do {
                                    try FileManager.default.removeItem(at: self.recordVideoURL)
                                }
                                catch let error as NSError {
                                    print(error)
                                    // print("Failed to remove item \(tempPath), error = \(error)")
                                }
                            }
                            self.cameraManager.compressVideo(inputURL: videoURL!, outputURL: self.recordVideoURL as NSURL, outputFileType: AVFileType.mp4.rawValue, handler: { (session) in
                                 if let currSession = session {
                                       if currSession.status == .completed {
                                        if self.isDuoCreate != "DUOJVideo"  {
                                print("Video url:",  currSession.outputURL!.absoluteString)
                                let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
                                q.Songs = self.song
                                q.index = self.index
                                        q.CustomLyrics = self.CustomLyrics
                                        q.navigation = self.navigation
                                        q.isVideo = true
                                            q.isSolo = self.isSolo
                                            q.SongToPlay = self.SongToPlay
                                            DispatchQueue.main.async(execute: {
                                                 self.navigation.pushViewController(q, animated: true)
                                            })
                               
                                        }else{
                           
                            self.ProcessVideo(FirstSourceVideo: self.SourceVideo, SecondSourceVideo: self.recordVideoURL, completion: { (url, error) in
                                if error == nil {
                                let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
                                q.Songs = self.song
                                q.index = self.index
                                q.CustomLyrics = self.CustomLyrics
                                q.navigation = self.navigation
                                q.isVideo = true
                                q.isSolo = self.isSolo
                                q.SongToPlay = url
                                q.isDuoCreate = self.isDuoCreate
                                    DispatchQueue.main.async(execute: {
                                        self.navigation.pushViewController(q, animated: true)
                                    })
                                }
                                            })
                                        }
                                 } else if currSession.status == .failed {
                                     print(" There was a problem compressing the video maybe you can try again later. Error: \(currSession.error!.localizedDescription)")
                                }
                                }
                            })
                            
                          
                        }
                    }
                
            }
        } else {
            
        }
    }
    
    
    
    func prepareAudio(){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord,mode: .default,options: [AVAudioSession.CategoryOptions.mixWithOthers, .defaultToSpeaker])
            
            if audioSession.isOtherAudioPlaying {
            try audioSession.setActive(true)
            }
            if self.isVideo == false {
            audioSession.requestRecordPermission { [weak self](allowed) in
                guard let `self` = self else {return}
                if allowed {
                    self.CountView .start(beginingValue: 3, interval: 1)
                    
                   // self.streamer = DOUAudioStreamer(audioFile: AudioStreamFile(url: self.SongToPlay))
                  
                   // self.streamer.addObserver(self, forKeyPath: "bufferingRatio", options: NSKeyValueObservingOptions.new, context: &self.kBufferingRatioKVOKey)
                   // self.streamer.addObserver(self, forKeyPath: "duration", options: NSKeyValueObservingOptions.new, context: &self.kDurationKVOKey)
                   // self.streamer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: &self.kStatusKVOKey)
                }else{
                    self.navigation.popToRootViewController(animated: true)
                }
            }
            }else{
           
               cameraManager = PGMCameraKit()
                cameraManager.cameraOutputMode =  CameraOutputMode.VideoWithMic
                
                //helper = PGMCameraKitHelper()
                let currentCameraState = cameraManager.currentCameraStatus()
                
                if currentCameraState == .NotDetermined || currentCameraState == .AccessDenied {
                    
                    print("We don't have permission to use the camera.")
                    
                    cameraManager.askUserForCameraPermissions(completition: { [unowned self] permissionGranted in
                        
                        if permissionGranted {
                            self.addCameraToView()
                            self.cameraManager.cameraDevice = CameraDevice.Front
                            self.cameraManager.cameraOutputQuality = CameraOutputQuality.High
                            
                            self.cameraManager.resumeCaptureSession()
                            self.CountView .start(beginingValue: 3, interval: 1)
                        }
                        else {
                            self.addCameraAccessDeniedPopup(message: "Go to settings and grant access to the camera device to use it.")
                             self.navigation.popToRootViewController(animated: true)
                        }
                    })
                }
                else if (currentCameraState == .Ready) {
                    
                    addCameraToView()
                    self.cameraManager.cameraDevice = CameraDevice.Front
                    self.cameraManager.cameraOutputQuality = CameraOutputQuality.High
                    self.cameraManager.resumeCaptureSession()
                    
                    self.CountView .start(beginingValue: 3, interval: 1)
                }
            }
        }catch(let err){
            print("AudioSession:",err.localizedDescription)
            self.navigation.popToRootViewController(animated: true)
        }
    }
    //obsereValues
   /* override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if (context == &self.kBufferingRatioKVOKey) {
         DispatchQueue.main.async {
            if self.streamer == nil {
                return
            }
            
            }
        
        }else if (context == &self.kDurationKVOKey) {
             //Duration (we will implement the Timer Action here)
            DispatchQueue.main.async {
                if self.streamer == nil {
                    return
                }
                self.timerAction()
            }
       
        }else if (context == &self.kStatusKVOKey) {
        //here are the status of our player
           DispatchQueue.main.async {
            if self.streamer == nil {
                return
            }
             switch self.streamer.status {
             case .playing:
             print("Playing")
                //self.lyricsV.start()
                self.LyricController.start()
             case .paused:
                print("Paused")
             case .finished:
                print("Finished")
                self.streamer.stop()
                self.audioRecorder.stop()
                self.lyricsV.stop()
             case .buffering:
                print("Buffering")
             case .error:
                print("error")
             default:
                break
            }
            
            }
        }
        
    } */
    
    private func addCameraAccessDeniedPopup(message: String) {
        
        DispatchQueue.main.async {
            
            
            self.showAlert(title: "SINGTN", message: message, ok: "Ok", cancel: "", cancelAction: nil, okAction: { alert in
                
                switch UIDevice.current.systemVersion.compare("8.0.0", options: NSString.CompareOptions.numeric) {
                case .orderedSame, .orderedDescending:
                    UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
                 
                case .orderedAscending:
                    print("Not supported")
                    break
                }
            }, completion: nil)
        }
    }
    
    // MARK: Add / Revemo camera
    
    private func addCameraToView()
    {
        
        if isDuoCreate != "DUOJVideo" || isDuoCreate == "" {
            _ = cameraManager.addPreviewLayerToView(view: containerMiddle, newCameraOutputMode: CameraOutputMode.VideoWithMic, slider: self.silderBar, backgroundSlider: self.backgroundSilderBar, show: true)
        }else{
             _ = cameraManager.addPreviewLayerToView(view: self.UserVideo, newCameraOutputMode: CameraOutputMode.VideoWithMic, slider: self.silderBar, backgroundSlider: self.backgroundSilderBar, show: false)
        }
      
        
    }
    
    func PlayKaraoke(){
       
         self.LyricController.start()
            let when = DispatchTime.now()
      
         DispatchQueue.main.asyncAfter(deadline: when + 1.5) {
            do {
                
                try _ = AudioPlayerManager.shared.play(at: self.SongToPlay)
                
                if self.isVideo && self.isDuoCreate == "DUOJVideo" {
                    AudioPlayerManager.shared.audioPlayer?.volume = 0
                    self.SingerVideo.layer.insertSublayer(self.AV_Player_Layer, at: 0)
                    //self.AV_Player.volume = 0
                    self.AV_Player.play()
                }
                
            }catch(let error) {
                print(error.localizedDescription)
            }
        }
        
        
        
        
    }
    func startRecording(completion: @escaping  (() -> Void)){
        
       
        
        if isVideo {
            cameraManager.maxRecordedDuration = (AudioPlayerManager.shared.audioPlayer?.duration)! + TimeInterval(exactly: 120)!
            cameraManager.addCameraErrorListener( cameraError: { [unowned self] error in
                
                if let err = error {
                    
                    if err.code == CameraError.CameraAccessDeniend.rawValue {
                        
                        self.addCameraAccessDeniedPopup(message: err.localizedFailureReason!)
                    }
                }
            })
            
            cameraManager.addCameraTimeListener( cameraTime: { time in
                
                print("Time elapsed: \(String(describing: time)) sec")
                if self.VLC_Player != nil {
                    if self.firstSync {
                         let x = Float((AudioPlayerManager.shared.audioPlayer?.currentTime)!) / Float((AudioPlayerManager.shared.audioPlayer?.duration)!)
                    self.VLC_Player.position = x + 0.001
                       self.VLC_Player.drawable = self.SingerVideo
                        self.firstSync = false
                    }
                    
                }
            })
            cameraManager.startRecordingVideo( completion: {(error)->() in
                
                if let err = error {
                    print("Error ocurred: \(err)")
                }
                
            })
        }else{
            let settings = [
                AVFormatIDKey : Int(kAudioFormatMPEG4AAC) ,
                AVSampleRateKey : 32000,
                AVNumberOfChannelsKey : 1,
                AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                
            ]
            do {
                
                audioRecorder = try AVAudioRecorder(url: recordVoiceURL, settings : settings)
                audioRecorder.delegate = self
                
                audioRecorder.isMeteringEnabled = true
                if audioRecorder.record() {
                    print("AudioRecorder: recording...")
                }
                
                
            }catch(let error){
                print("AudioRecorder:",error.localizedDescription)
                let error = NSError(domain: NSOSStatusErrorDomain, code: 1718449215, userInfo: nil)
                print("Error: \(error.description)")
            }
        }
        AKSettings.playbackWhileMuted = true
        AKSettings.audioInputEnabled = true
        AKSettings.enableLogging = true
        do {
            try AudioKit.start()
            CalculateAMP()
            completion()
            
            
        }catch(let error){
            print("AudioKit:",error.localizedDescription)
              completion()
        }
        completion()
    }
    func StopRecording(){
        
       
        if isVideo {
        cameraManager.stopRecordingVideo { (videoURL, error, localIdentifier) in
            if let err = error {
                print("Error ocurred: \(err)")
            }
            else {
                print("Video url: \(String(describing: videoURL?.absoluteString)) with unique id \(String(describing: localIdentifier?.description))")
            }
        }
        }else{
             audioRecorder.stop()
        }
        do {
            try AudioPlayerManager.shared.stop()
        }catch{
            
        }
      
        self.lyricsV.stop()
    }
    func PauseRecording(){
       
        if isVideo {
        cameraManager.pauseRecordingVideo()
        }else{
             audioRecorder.pause()
        }
        do {
            try AudioPlayerManager.shared.pause()
        }catch{
            
        }
        self.lyricsV.pause()
    }
    func ResumeRecording(){
       
        if isVideo {
        cameraManager.resumeRecordingVideo()
        }else{
          audioRecorder.record()
        }
        do {
            try _ = AudioPlayerManager.shared.resume()
        }catch{
            
        }
        self.lyricsV.resume()
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice?
    {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                           mediaType: AVMediaType.video,
                                                                           position: position)
        
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
            
        }
        
        return nil
    }
   
    @objc func CloseAction(sender: UIButton) {
        
       
            self.LyricController.stop()
        
        do {
            try AudioPlayerManager.shared.stop()
            try AudioKit.stop()
        }catch (let error){
            print(error.localizedDescription)
        }
        
       
        if isVideo {
            if VLC_Player != nil {
            VLC_Player.stop()
            }
            cameraManager.stopRecordingVideo { (videoURL, error, localIdentifier) in
                if let err = error {
                    print("Error ocurred: \(err)")
                }
                else {
                    print("Video url: \(String(describing: videoURL?.absoluteString)) with unique id \(String(describing: localIdentifier?.description))")
                    DispatchQueue.main.async(execute: {
                        self.cameraManager.compressVideo(inputURL: videoURL!, outputURL: self.recordVideoURL as NSURL, outputFileType: AVFileType.mp4.rawValue, handler: { (session) in
                            if session?.status == .completed {
                                print("Check the ass")
                            }
                        })
                    })
                }
                self.cameraManager.stopCaptureSession()
            }
        }else{
            if self.audioRecorder != nil {
                self.audioRecorder.stop()
            }
        }
        self.navigation.popToRootViewController(animated: true)
    }
    func timerDidEnd() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.show_hide_containers(hide: false)
            self.CountView.isHidden = true
           
            self.PlayKaraoke()
            
        }
       
    }
    @objc func timerAction() {
     
            self.audioRecorder.updateMeters()
            let averagePower = audioRecorder!.averagePower(forChannel: 0)
            let percentage: Float = pow(10, (0.05 * averagePower))
       
            self.WaveFormRecorder.addMeteringLevel(percentage)
        
        
    }
    func hmsFrom(seconds: Int, completion: @escaping (_ minutes: Int, _ seconds: Int)->()) {
        completion((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func timesForLyricPlayerView(playerView: VTKaraokeLyricPlayerView) -> Array<CGFloat> {
        return timingKeys
    }
    
    func lyricPlayerView(playerView: VTKaraokeLyricPlayerView, atIndex: NSInteger) -> VTKaraokeLyricLabel {
        let lyricLabel          = playerView.reuseLyricView()
        lyricLabel.textColor    = UIColor.black
        lyricLabel.fillTextColor = UIColor.blue
        lyricLabel.font         = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        
        
        
        //lyricLabel.text = self.lyric?.content![key]
        return lyricLabel
    }
    
    func lyricPlayerView(playerView: VTKaraokeLyricPlayerView, allowLyricAnimationAtIndex: NSInteger) -> Bool {
        return true
    }
    func lyricPlayerViewDidStop(playerView: VTKaraokeLyricPlayerView) {
        
    }
    @IBAction func VolumeAction(_ sender: UIButton) {
        let shouldExpand = self.OptionsViewHeight.constant == 0
        self.OptionsViewHeight.constant = shouldExpand ? 86.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.volumeEffectsContainer.subviews.forEach { if ( $0.tag == 5 || $0.tag == 6 )  {$0.alpha = shouldExpand ? 1.0 : 0.0 } else { $0.alpha = 0} }
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func FilerButtonAction(_ sender: UIButton) {
        let shouldExpand = self.OptionsViewHeight.constant == 0
        self.OptionsViewHeight.constant = shouldExpand ? 86.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.volumeEffectsContainer.subviews.forEach { if ( $0.tag != 5 && $0.tag != 6 )  {$0.alpha = shouldExpand ? 1.0 : 0.0 } else{ $0.alpha = 0} }
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func SliderAction(_ sender: UISlider) {
      
        self.labelSlider.text = String(format: "%0.2f", sender.value * 100) + "%"
        
        (UIApplication.shared.delegate as! AppDelegate).booster.gain = Double(sender.value)
        
    }
    
    
}
extension AVAsset {
    func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        do {
            let audioAsset = try self.audioAsset()
            audioAsset.writeToURL(url, completion: completion)
        } catch (let error as NSError){
            completion(false, error)
        }
    }
    
    func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            completion(false, nil)
            return
        }
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL      = url
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true, nil)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                completion(false, nil)
            }
        }
    }
    
    func audioAsset() throws -> AVAsset {
        
        let composition = AVMutableComposition()
        
        let audioTracks = tracks(withMediaType: .audio)
        
        for track in audioTracks {
            
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition
    }
    
}
