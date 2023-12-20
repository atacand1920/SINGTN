//
//  SaveAndShareController.swift
//  SINGTN
//
//  Created by macbook on 2018-08-24.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import MapleBacon
import Alamofire
import SwiftSpinner
import Social
struct LyricsJson : Codable {
    var position : Int!
    var owner : String!
}
class SaveAndShareController : UIViewController ,URLSessionDelegate,URLSessionTaskDelegate,URLSessionDataDelegate{
    @IBOutlet weak var LoadingStatus: UILabel!
    @IBOutlet weak var progressAnimation: ProgressLabel!
    
    @IBOutlet weak var finish: UIButton!
    
    @IBOutlet weak var song_image: UIImageView!
    
    @IBOutlet weak var song_name: UILabel!
    
    @IBOutlet weak var lineOne: UIView!
    
    @IBOutlet weak var ShareLabel: UILabel!
    
    @IBOutlet weak var shareContainer: UIView!
    
    
    
    @IBOutlet weak var lineTwo: UIView!
    
    @IBOutlet weak var facebookBTN: UIButton!
    var navigation : UINavigationController!
    var Songs : JSON = []
    var index : Int = 0
    var idPublication = ""
    @IBOutlet weak var otherBTN: UIButton!
    @IBOutlet weak var twiterBTN: UIButton!
    fileprivate var buffer:NSMutableData = NSMutableData()
    var SongToSave : URL! = URL(string: "http://adcarryteam.000webhostapp.com/images/5b897f5bac41b.m4a")
    var SongImage : String!
    var SongName : String!
    var URLSong : String!
    var typeOfMedia : String!
    var CustomLyrics : [String] = []
    var isDuoCreate = ""
    var JsonStringToSave : JSON = []
    override func viewDidLoad() {
        super.viewDidLoad()
        hideContainers(hide: true)
        self.ShareLabel.text = self.getMessage()
        if self.Songs[index]["image_src"].exists() {
        self.song_image.setImage(with: URL(string: self.Songs[index]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: #imageLiteral(resourceName: "User"), transformer: nil, progress: nil, completion: nil)
        self.song_name.text = self.Songs[index]["song_name"].stringValue
        }else{
            self.song_image.setImage(with: URL(string: self.Songs[index]["song"]["image_src"].stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!), placeholder: #imageLiteral(resourceName: "User"), transformer: nil, progress: nil, completion: nil)
            self.song_name.text = self.Songs[index]["song"]["song_name"].stringValue
        }
            var lyricsJson : [LyricsJson] = []
            if CustomLyrics.count != 0 {
               
                for i in 0...self.CustomLyrics.count - 1 {
                    lyricsJson.append(LyricsJson(position: i, owner: self.CustomLyrics[i]))
                    
                    //LyricsJson.updateValue(self.CustomLyrics[i], forKey: i)
                    //LyricsJson[i] = self.CustomLyrics[i]
                }
            }
            
            do {
                let jsonData = try JSONEncoder().encode(lyricsJson)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                self.JsonStringToSave = JSON(stringLiteral: jsonString)
                
            } catch { print(error) }
        
           // URLSong = "http://velox-it.com/SINGTN/images/AACB8DD2-8DD6-4740-A0E7-68142154EF13.mp4"
           // hideContainers(hide: false)
        if typeOfMedia == "Audio" {
            //
             uploadMusic()
        }else{
            self.uploadVideoFTP()
        }
    }
    func getMessage() -> String{
        return ScriptBase.sharedInstance.getLanguage() == "fr" ? "partager avec" : "Share it with"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tweakDuoVar(s:String) -> String {
        switch s {
        case "DUOJOnlyAudio":
            return "DUOJ"
        case "DUOJOnlyAudioFromVideo":
            return "DUOJ"
        case "SoloVideo" :
            return "SOLO"
        case "DuoCVideo" :
            return "DUOC"
        case "DuoJVideo" :
            return "DUOJ"
        case "Audio" :
            if self.CustomLyrics.count != 0 {
                return "DUOC"
            }else{
                return "SOLO"
            }
            
        default:
            return s
        }
    }
    @IBAction func finishAction(_ sender: Any) {
        
         self.navigation.popToRootViewController(animated: true)
        
    }
    func shareSongScript(response:JSON,audience:String, share: Bool){
        if share {
        SwiftSpinner.show("Sharing the Song...")
        let ab = UserDefaults.standard.value(forKey: "User") as! String
        let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            let a = try JSON(data: dataFromString!)
            print(a)
        let params: Parameters = [
            "id_user" : a["id"].stringValue,
            "song_id" : response["data"]["id"].stringValue
        ]
            Alamofire.request(ScriptBase.sharedInstance.create_publication , method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    SwiftSpinner.hide()
                    //print(response.data)
                    let q = JSON(response.data)
                    if q["status"].stringValue == "true" {
                        if q["message"].stringValue == "successful" {
                            self.idPublication = q["data"]["id"].stringValue
                             self.hideContainers(hide: false)
                            
                        }else{
                            print("error while the saving phase")
                        }
                    }
                    
                    
            }
            
            
            
        }catch {
            print(error)
        }
        }else{
            SwiftSpinner.hide()
             self.navigation.popToRootViewController(animated: true)
        }
    }
    func uploadMusic(){
       
      let boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW"
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        
        let filename = SongToSave.lastPathComponent
        var mimeType = ""
       
         mimeType = "audio/m4a"
        
        let fieldName = "userfile"
    let uploadScriptUrl = URL(string:ScriptBase.sharedInstance.uploadViaPost)
        var fileData : Data?
        if let fileContents = FileManager.default.contents(atPath: SongToSave.path) {
            fileData = fileContents
        }
        let requestBodyData : NSMutableData = NSMutableData()
        requestBodyData.append(("--\(boundaryConstant)\r\n").data(using: String.Encoding.utf8)!)
      
         requestBodyData.append(( "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n").data(using: String.Encoding.utf8)!)
        requestBodyData.append(( "Content-Type: \(mimeType)\r\n\r\n").data(using: String.Encoding.utf8)!)
        //dataString += String(contentsOfFile: SongToSave.path, encoding: NSUTF8StringEncoding, error: &error)!
        requestBodyData.append(fileData!)
       // dataString += try! String(contentsOfFile: SongToSave.path, encoding: String.Encoding.utf8)
      requestBodyData.append(("\r\n").data(using: String.Encoding.utf8)!)
        requestBodyData.append(("--\(boundaryConstant)--\r\n").data(using: String.Encoding.utf8)!)
          var request = URLRequest(url: uploadScriptUrl!)
        
      
        request.httpMethod = "POST"
        request.httpBody = requestBodyData as Data
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.uploadTask(withStreamedRequest: request)
        
        task.resume()
        
    }
    func hideContainers(hide:Bool) {
 
        
        self.lineOne.isHidden = hide
        self.lineTwo.isHidden = hide
        self.shareContainer.isHidden = hide
        self.finish.isHidden = hide
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("didCompleteWithError")
        if (error != nil) {
            
        }else{
            print("Data:",buffer)
            let q = JSON(buffer)
            print(q)
            if q["error"].boolValue == false{
            if q["url"].stringValue != ""{
                self.URLSong = q["url"].stringValue
                self.saveDataToDataBase()
               
            }else{
                print("errror with uploading the file")
            }
            }else{
                if q["message"].stringValue == "Please choose a file"{
                 print("errror with uploading the file")
                }
            }
        }
        
       
    }
    func saveDataToDataBase(){
        print(isDuoCreate)
        self.isDuoCreate = tweakDuoVar(s: self.isDuoCreate)
        var alert : UIAlertController!
        print(isDuoCreate)
        if isDuoCreate != "DUOC" {
            
            alert = UIAlertController(title: "Publication", message: "Do you want to share this music with your friends or in public mode? you can't change audience after your choice", preferredStyle: .alert)
        }else{
            alert = UIAlertController(title: "Publication", message: "Do you want us to notify your friends to join your song? you can also share it in public mode", preferredStyle: .alert)
        }
        
        if self.CustomLyrics.count == 0 {
            alert.addAction(UIAlertAction(title: "Keep in private", style: UIAlertAction.Style.destructive,handler : { (_) -> Void in
                //self.email.text = ""
                SwiftSpinner.show("Saving the Song...")
                
                
                let ab = UserDefaults.standard.value(forKey: "User") as! String
                let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
                do {
                    let a = try JSON(data: dataFromString!)
                    print(a)
                    
                    let params: Parameters = [
                        "song_src" : self.URLSong.description ,
                        "id_user" : a["id"].stringValue,
                        "id_song" : self.Songs[self.index]["id"].stringValue,
                        "type" :  self.typeOfMedia.description ,
                        "audience" : "private",
                        "category" : "SOLO",
                        "lyricJ" : self.JsonStringToSave
                    ]
                    print(params)
                    Alamofire.request(ScriptBase.sharedInstance.save_song , method: .post, parameters: params, encoding: JSONEncoding.default)
                        .responseJSON { response in
                            
                            //print(response.data)
                            let q = JSON(response.data)
                            print(q)
                            if q["status"].stringValue == "true" {
                                if q["message"].stringValue == "go on" {
                                    
                                    //self.shareSongScript(response: q)
                                     self.hideContainers(hide: false)
                                   
                                }else{
                                    SwiftSpinner.hide()
                                    print("error while the saving phase")
                                }
                            }else{
                                SwiftSpinner.hide()
                            }
                            
                            
                    }
                }catch {
                    print(error)
                }
                
                
            }))
        }
        alert.addAction(UIAlertAction(title: "Friends", style: UIAlertAction.Style.default,handler : { (_) -> Void in
            //self.email.text = ""
            SwiftSpinner.show("Saving the Song...")
            
            
            let ab = UserDefaults.standard.value(forKey: "User") as! String
            let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
            do {
                let a = try JSON(data: dataFromString!)
                print(a)
                var category = ""
                if self.CustomLyrics.count == 0 {
                    category = "SOLO"
                }else{
                    if self.isDuoCreate != ""{
                        category = self.isDuoCreate
                    }
                }
                let params: Parameters = [
                    "song_src" : self.URLSong.description ,
                    "id_user" : a["id"].stringValue,
                    "id_song" : self.Songs[self.index]["id"].stringValue,
                    "type" :  self.typeOfMedia.description ,
                    "audience" : "friends",
                    "category" : category  ,
                    "lyricJ" : self.JsonStringToSave.rawValue
                ]
                print(params)
                Alamofire.request(ScriptBase.sharedInstance.save_song , method: .post, parameters: params, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        
                        //print(response.data)
                        let q = JSON(response.data)
                        print(q)
                        if q["status"].stringValue == "true" {
                            if q["message"].stringValue == "go on" {
                                
                                self.shareSongScript(response: q, audience: "friends",share: category == "DUOC" ? false : true)
                                
                            }else{
                                SwiftSpinner.hide()
                                print("error while the saving phase")
                            }
                        }else{
                            SwiftSpinner.hide()
                        }
                        
                        
                }
            }catch {
                print(error)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Public", style: UIAlertAction.Style.default,handler : { (_) -> Void in
            //self.email.text = ""
            SwiftSpinner.show("Saving the Song...")
            
            
            let ab = UserDefaults.standard.value(forKey: "User") as! String
            let dataFromString = ab.data(using: String.Encoding.utf8, allowLossyConversion: false)
            do {
                let a = try JSON(data: dataFromString!)
                print(a)
                var category = ""
                if self.CustomLyrics.count == 0 {
                    category = "SOLO"
                }else{
                    if self.isDuoCreate != ""{
                        category = self.isDuoCreate
                    }
                }
                let params: Parameters = [
                    "song_src" : self.URLSong.description ,
                    "id_user" : a["id"].stringValue,
                    "id_song" : self.Songs[self.index]["id"].stringValue,
                    "type" :  self.typeOfMedia.description ,
                    "audience" : "public",
                    "category" : category ,
                    "lyricJ" : self.JsonStringToSave
                ]
                print(params)
                Alamofire.request(ScriptBase.sharedInstance.save_song , method: .post, parameters: params, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        
                        //print(response.data)
                        let q = JSON(response.data)
                        print(q)
                        if q["status"].stringValue == "true" {
                            if q["message"].stringValue == "go on" {
                                self.shareSongScript(response: q, audience: "public",share: category == "DUOC" ? false : true)
                                //self.navigationController?.popToRootViewController(animated: true)
                            }else{
                                SwiftSpinner.hide()
                                print("error while the saving phase")
                            }
                        }else{
                            SwiftSpinner.hide()
                        }
                        
                        
                }
            }catch {
                print(error)
            }
            
        }))
        // show the alert
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("didSendBodyData")
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        progressAnimation.progress = CGFloat(uploadProgress)
        updateLabelProgress()
        
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceiveResponse")
       
        completionHandler(URLSession.ResponseDisposition.allow)
        
      
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceiveData")
       
        buffer.append(data)
        
    }
    func updateLabelProgress(){
        LoadingStatus.text = String(format: "%.0f%%", progressAnimation.progress * 100.0)
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
    func uploadVideoFTP(){
        let  FtpUpload = FTPUpload()
        FtpUpload.getRequest().progressAction = { totalSize, finishedSize, finishedPercent in
            print(String(format: "totalSize = %ld, finishedSize = %ld, finishedPercent = %f", totalSize, finishedSize, finishedPercent)) //
            let totalSiz = max(totalSize, finishedSize)
            
            self.progressAnimation.progress = CGFloat(finishedSize) / CGFloat(totalSiz)
            
            self.updateLabelProgress()
        }
        
        FtpUpload.getRequest().successAction = { x  in
            
            
            self.URLSong = ScriptBase.sharedInstance.uploadFTPVideo +  FtpUpload.NameVideo + ".mp4"
            //self.hideContainers(hide: false)
           self.saveDataToDataBase()
            
        }
        FtpUpload.getRequest().failAction = { domain, error, errorMessage in
            
            print(String(format: "error = %ld, errorMessage = %@", error as NSInteger, errorMessage as! NSString))
        }
        FtpUpload.uploadFile(fileToUpload: self.SongToSave)
        
    }
    @IBAction func facebookShareAction(_ sender: UIButton){
        let reach = Reachability()
        if reach.isReachable()  && self.idPublication != ""{
            let share = ["https://singtn.herokuapp.com/publication/" + self.idPublication]
            print(share[0])
            let activityVc = UIActivityViewController(activityItems: share, applicationActivities: nil)
            activityVc.popoverPresentationController?.sourceView = self.view
           
            activityVc.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.markupAsPDF,
            UIActivity.ActivityType.openInIBooks
            ]
            self.present(activityVc, animated: true, completion: nil)
        }
    }
    @IBAction func twiterShareAction(_ sender: UIButton){
        let reach = Reachability()
        if reach.isReachable()  && self.idPublication != ""{
            let share = ["https://singtn.herokuapp.com/publication/" + self.idPublication]
            let activityVc = UIActivityViewController(activityItems: share, applicationActivities: nil)
            activityVc.popoverPresentationController?.sourceView = self.view
            
            activityVc.excludedActivityTypes = [
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.message,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.copyToPasteboard,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.airDrop,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.mail,
                UIActivity.ActivityType.markupAsPDF,
                UIActivity.ActivityType.openInIBooks
            ]
            self.present(activityVc, animated: true, completion: nil)
        }
    }
    @IBAction func othersShareAction(_ sender: UIButton){
        let reach = Reachability()
        if reach.isReachable()  && self.idPublication != ""{
            let share = ["https://singtn.herokuapp.com/publication/" + self.idPublication]
            let activityVc = UIActivityViewController(activityItems: share, applicationActivities: nil)
            activityVc.popoverPresentationController?.sourceView = self.view
            
            activityVc.excludedActivityTypes = [
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.copyToPasteboard,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.openInIBooks
            ]
            self.present(activityVc, animated: true, completion: nil)
        }
    }
}
