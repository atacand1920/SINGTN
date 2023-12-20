//
//  ProgressViewController.swift
//  SINGTN
//
//  Created by macbook on 2018-08-03.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SwiftyJSON
class ProgressViewController : UIViewController,URLSessionDownloadDelegate{
    
    @IBOutlet weak var LyricsHintsView: UIView!
    @IBOutlet weak var startBTN: UIButton!
    @IBOutlet weak var progress: UIView!
    @IBOutlet weak var Switch : UISwitch!
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var i = 1
    var song: JSON = []
    var index = 0
    var lyric = ""
    var songToPlay : URL!
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var videoOn : Bool = false
    var isSolo = true
    var isDuoCreate = ""
    var CustomLyrics : [String] = []
    @IBOutlet weak var cameraview: UIView!
    var documentFolderPath : URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    var audioPart : URL {
        return documentFolderPath.appendingPathComponent("audioPart.m4a")
    }
    @IBOutlet weak var LoadingStatus: UILabel!
    @IBOutlet weak var progressAnimation: ProgressLabel!
    @IBOutlet weak var switchLabel: UILabel!
    
    // let timer = Timer()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoOn = false
        print("ViewWillAppear")
        self.tabBarController?.tabBar.isHidden = true
        DispatchQueue.main.async {
            self.updateLabelProgress()
            self.addAnimationProgress()
        }
        if isSolo == false && isDuoCreate == "DUOC" {
            if song[index]["type"].stringValue == "Audio" {
                self.switchLabel.isHidden = true
                self.Switch.isHidden = true
            }
        }
        self.startBTN.isHidden = true
       
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration,delegate: self, delegateQueue: OperationQueue.main)
        
        
        if isSolo {
            if let url = URL(string: (self.song[index]["lyric_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                do {
                    let contents = try String(contentsOf: url)
                    lyric = contents
                } catch {
                    // contents could not be loaded
                    print(error.localizedDescription)
                }
                
            } else {
                // the URL was bad!
                print("URL BAD")
            }
             if isDuoCreate != "DUOC" {
            self.LyricsHintsView.isHidden = true
            }
        }else{
            if let url = URL(string: (self.song[index]["song"]["lyric_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                do {
                    let contents = try String(contentsOf: url)
                    lyric = contents
                } catch {
                    // contents could not be loaded
                    print(error.localizedDescription)
                }
                
            } else {
                // the URL was bad!
                print("URL BAD")
            }
        }
        
        let url = URL(string: (self.song[index]["song_src"].stringValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        print("URL:",url.absoluteString)
        
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
 
    }
    func addAnimationProgress(){
        // Add gradient to progress label
        let colors = [UIColor.red, UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)]
        let locations: [CGFloat] = [0.0, 1.0]
        let gradientImage = UIImage.gradientImage(colors: colors, locations: locations, size: progressAnimation.bounds.size)
        progressAnimation.textColor = UIColor(patternImage: gradientImage)
       
        // Add appear animations
        
        let moveRight = CASpringAnimation(keyPath: "transform.translation.x")
        moveRight.fromValue = -view.bounds.width
        moveRight.toValue = 0
        moveRight.duration = moveRight.settlingDuration
        moveRight.fillMode = CAMediaTimingFillMode.backwards
        progressAnimation.layer.add(moveRight, forKey: nil)
        
        moveRight.beginTime = CACurrentMediaTime() + 0.2
        LoadingStatus.layer.add(moveRight, forKey: nil)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressAnimation.layer.removeAllAnimations()
        LoadingStatus.layer.removeAllAnimations()
        progressAnimation.progress = 0
        LoadingStatus.text = String(format: "%.0f%%", progressAnimation.progress * 100.0)
        if downloadTask != nil {
        downloadTask.cancel { (data) in
            
        }
        }
         backgroundSession.finishTasksAndInvalidate()
        
    }
    
    func updateLabelProgress(){
    LoadingStatus.text = String(format: "%.0f%%", progressAnimation.progress * 100.0)
    }
   
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if self.downloadTask != nil {
            print("download Finished")
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            var destinationUrl : URL!
            if self.song[index]["type"].exists() {
            if self.song[index]["type"].stringValue == "Audio" {
             destinationUrl = documentsUrl!.appendingPathComponent("/song.mp3")
            }else{
                destinationUrl = documentsUrl!.appendingPathComponent("/song.mp4")
            }
            
        
            }else{
                destinationUrl = documentsUrl!.appendingPathComponent("/song.mp3")
            }
            let dataFromURL = NSData(contentsOf: location)
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                try? FileManager.default.removeItem(atPath: destinationUrl.path)
            }
            dataFromURL?.write(to: destinationUrl, atomically: true)
            
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        progressAnimation.progress = (CGFloat(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)))
        updateLabelProgress()
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error != nil) {
            print("ErrorOnComplete:",error!.localizedDescription)
        }else{
            if downloadTask != nil {
                print("The task finished transferring data successfully")
                downloadTask = nil
               // progressView.setProgress(1, animated: true)
                finishedLoading()
                if self.song[index]["type"].exists() {
                    if self.song[index]["type"].stringValue == "Video" {
                        let asset = AVURLAsset(url: documentFolderPath.appendingPathComponent("/song.mp4"))
                        if FileManager.default.fileExists(atPath: self.audioPart.path) {
                            try? FileManager.default.removeItem(atPath: self.audioPart.path)
                        }
                        asset.writeAudioTrackToURL(self.audioPart, completion: { (success, error) in
                            
                            if !(success) {
                                print(error as Any)
                            }else{
                                print("audio extracted from video with success")
                                DispatchQueue.main.async(execute: {
                                     self.startBTN.isHidden = false
                                })
                               
                                
                                
                            }
                            
                        })
                    }else{
                        self.songToPlay = documentFolderPath.appendingPathComponent("/song.mp3")
                        DispatchQueue.main.async(execute: {
                            self.startBTN.isHidden = false
                        })
                    }
                }else{
                    self.songToPlay = documentFolderPath.appendingPathComponent("/song.mp3")
                    DispatchQueue.main.async(execute: {
                        self.startBTN.isHidden = false
                    })
                }
            }else{
                
            }
            
        }
    }
    func finishedLoading() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.15
        pulse.toValue = 1.0
        pulse.damping = 7.5
        pulse.duration = pulse.settlingDuration
        progressAnimation.layer.add(pulse, forKey: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func SwitchAction(_ sender: UISwitch) {
        if sender.isOn {
          self.videoOn = true
        self.switchLabel.isHidden = true
            if isSolo == false || isDuoCreate == "DUOC" {
                
            self.LyricsHintsView.isHidden = true
                
            }
        captureSession.sessionPreset = AVCaptureSession.Preset.high
           
            let devices  = cameraWithPosition(position: AVCaptureDevice.Position.front )
                
                    
            
            captureDevice = devices
            if captureDevice != nil
            {
                print("Capture device found")
                beginSession()
            }else{
                print("No Capture device found")
            }
            
            
        }else{
           self.videoOn = false
           
           captureSession.stopRunning()
             self.switchLabel.isHidden = false
            if isSolo == false || isDuoCreate == "DUOC" {
               
            self.LyricsHintsView.isHidden = false
                
            }
           // captureSession.remove(<#T##connection: AVCaptureConnection##AVCaptureConnection#>)
            do {
            try captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice!))
             captureSession.removeOutput(stillImageOutput)
                self.cameraview.layer.sublayers?.forEach({ (a) in
                    a.removeFromSuperlayer()
                })
               
            }catch{
                print("error: \(error.localizedDescription)")
            }
        }
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
    func beginSession()
    {
        do
        {
            if captureSession.canAddInput(try! AVCaptureDeviceInput(device: captureDevice!)) {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
            //stillImageOutput.sett = [AVVideoCodecKey:AVVideoCodecType.jpeg]
        
            if captureSession.canAddOutput(stillImageOutput)
            {
                captureSession.addOutput(stillImageOutput)
            }
            }
        }
        catch
        {
            print("error: \(error.localizedDescription)")
        }
       previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = self.cameraview.layer.bounds
       // previewLayer?.position = CGPoint(x: self.cameraview.frame.origin.x, y: self.cameraview.frame.origin.y)
        self.cameraview.layer.addSublayer(previewLayer!)
      //self.cameraview.layoutSubviews()
        captureSession.startRunning()
        //self.view.addSubview(imageView)
    }
    
    @IBAction func StartAction(_ sender: UIButton) {
         let lyricParser = VTBasicKaraokeLyricParser()
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs != [] {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSession.Port.headphones {
                    print("OKay")
                    try? AVAudioSession.sharedInstance().setPreferredInput(description)
                    
                    var test = true
                    if test == false {
                   let q = self.storyboard?.instantiateViewController(withIdentifier: "KaraokeViewController") as! KaraokeViewController
                        q.song = self.song
                        q.isVideo = self.videoOn
                        
                        q.isSolo = self.isSolo
                        if isSolo {
                            q.SongToPlay = self.songToPlay
                            
                        }else{
                            if self.song[index]["type"] == "Video" {
                                print("Audio Part setted")
                                q.SongToPlay = self.audioPart
                            }else{
                                q.SongToPlay = self.songToPlay
                            }
                        }
                        if self.isDuoCreate != "" {
                            if videoOn && self.isDuoCreate == "DUOJ" {
                                print("DUOJVideo")
                                
                                q.isDuoCreate = "DUOJVideo"
                            }else{
                                q.isDuoCreate = self.isDuoCreate
                            }
                        }
                        if self.CustomLyrics.count != 0 {
                            q.CustomLyrics = self.CustomLyrics
                            
                        }
                        if self.videoOn {
                            self.stopRunningVideo()
                        }
                        q.lyric = lyricParser.lyricFromLRCString(lrcStr: self.lyric)
                        q.index = self.index
                        q.navigation = self.navigationController
                        self.navigationController?.pushViewController(q, animated: true)

                    }else{
                     let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
                        
                        q.Songs = self.song
                        q.isVideo = self.videoOn
                        
                        q.isSolo = self.isSolo
                        if isSolo {
                            q.SongToPlay = self.songToPlay
                            
                        }else{
                            if self.song[index]["type"] == "Video" {
                                print("Audio Part setted")
                                q.SongToPlay = self.audioPart
                            }else{
                                q.SongToPlay = self.songToPlay
                            }
                        }
                        if self.isDuoCreate != "" {
                            if videoOn && self.isDuoCreate == "DUOJ" {
                                print("DUOJVideo")
                                
                                q.isDuoCreate = "DUOJVideo"
                               
                            }else{
                                q.isDuoCreate = self.isDuoCreate
                            }
                        }
                        print("count: ",self.CustomLyrics.count)
                        if self.CustomLyrics.count != 0 {
                            q.CustomLyrics = self.CustomLyrics
                            
                        }
                        if self.videoOn {
                            self.stopRunningVideo()
                        }
                        //q.lyric = lyricParser.lyricFromLRCString(lrcStr: self.lyric)
                        q.index = self.index
                        q.navigation = self.navigationController
                        self.navigationController?.pushViewController(q, animated: true)
                    }
                
                 
                                    } else {
                    let alert = UIAlertController(title: "Headphones", message: "headphones are highly recommended,use them for better recording quality!(required)", preferredStyle: .alert)
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default,handler : { (_) -> Void in
   var test = false
 if test == true {
 let q = self.storyboard?.instantiateViewController(withIdentifier: "KaraokeViewController") as! KaraokeViewController
 q.song = self.song
 q.isVideo = self.videoOn
 
 q.isSolo = self.isSolo
    if self.isSolo {
 q.SongToPlay = self.songToPlay
 
 }else{
        if self.song[self.index]["type"] == "Video" {
 print("Audio Part setted")
 q.SongToPlay = self.audioPart
 }else{
 q.SongToPlay = self.songToPlay
 }
 }
 if self.isDuoCreate != "" {
    if self.videoOn && self.isDuoCreate == "DUOJ" {
 print("DUOJVideo")
 
 q.isDuoCreate = "DUOJVideo"
 }else{
 q.isDuoCreate = self.isDuoCreate
 }
 }
 if self.CustomLyrics.count != 0 {
 q.CustomLyrics = self.CustomLyrics
 
 }
 if self.videoOn {
 self.stopRunningVideo()
 }
 q.lyric = lyricParser.lyricFromLRCString(lrcStr: self.lyric)
 q.index = self.index
 q.navigation = self.navigationController
 self.navigationController?.pushViewController(q, animated: true)
 
 }else{
 let q = self.storyboard?.instantiateViewController(withIdentifier: "StudioController") as! StudioController
 
 q.Songs = self.song
 q.isVideo = self.videoOn
 
 q.isSolo = self.isSolo
    if self.isSolo {
 q.SongToPlay = self.songToPlay
 
 }else{
    if self.song[self.index]["type"] == "Video" {
 print("Audio Part setted")
 q.SongToPlay = self.audioPart
 }else{
 q.SongToPlay = self.songToPlay
 }
 }
 if self.isDuoCreate != "" {
    if self.videoOn && self.isDuoCreate == "DUOJ" {
 print("DUOJVideo")
 
 q.isDuoCreate = "DUOJVideo"
 
 }else{
 q.isDuoCreate = self.isDuoCreate
 }
 }
 print("count: ",self.CustomLyrics.count)
 if self.CustomLyrics.count != 0 {
 q.CustomLyrics = self.CustomLyrics
 
 }
 if self.videoOn {
 self.stopRunningVideo()
 }
 //q.lyric = lyricParser.lyricFromLRCString(lrcStr: self.lyric)
 q.index = self.index
 q.navigation = self.navigationController
 self.navigationController?.pushViewController(q, animated: true)
 }
                        
                    }    ))
                    
                    // show the alert
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        } else {
            print("requires connection to device")
        }
    }
    func stopRunningVideo(){
        captureSession.stopRunning()
        
        do {
            try captureSession.removeInput(AVCaptureDeviceInput(device: captureDevice!))
            captureSession.removeOutput(stillImageOutput)
            self.cameraview.layer.sublayers?.forEach({ (a) in
                a.removeFromSuperlayer()
            })
            
        }catch{
            print("error: \(error.localizedDescription)")
        }
    }
}

