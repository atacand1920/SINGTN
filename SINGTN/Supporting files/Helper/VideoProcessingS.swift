//
//  VideoProcessingS.swift
//  SINGTN
//
//  Created by macbook on 2018-10-23.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SwiftSpinner
import AudioKitUI
extension KaraokeViewController {
 
    var SecondVideo : URL {
        return documentFolderPath.appendingPathComponent("videoRec.mp4")
    }
    var AudioToAdd : URL {
         return documentFolderPath.appendingPathComponent("recording.m4a")
    }
    var Generated : URL {
        return documentFolderPath.appendingPathComponent("mixedVideos.mp4")
    }
    
   
   
    func ProcessVideo(FirstSourceVideo:URL,SecondSourceVideo:URL,completion: @escaping (URL, Error?) -> ()){
        let videoAssets1 = AVAsset(url: FirstSourceVideo)
        let videoAssets2 = AVAsset(url: SecondSourceVideo)
        let mixComposition = AVMutableComposition()
        // Create composition track for first video
        let timeRange = CMTimeRangeFromTimeToTime(start: CMTime.zero, end: videoAssets1.duration)
        let firstCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: 1)
        do {
            
            try firstCompositionTrack?.insertTimeRange(timeRange, of: videoAssets1.tracks(withMediaType: .video).first!, at: CMTime.zero)
        } catch {
            print("ErrorTimeRange = \(error.localizedDescription)")
        }
        
        // Create composition track for second video
        let secondCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: 2)
        do {
            try secondCompositionTrack?.insertTimeRange(timeRange, of: videoAssets2.tracks(withMediaType: .video).first!, at: CMTime.zero)
        } catch {
            print("ErrorTimeRange = \(error.localizedDescription)")
        }
        let mainCompositionInst = AVMutableVideoComposition()
        
        let firstVideoTrack = videoAssets1.tracks(withMediaType: AVMediaType.video).first
            let secondVideoTrack = videoAssets2.tracks(withMediaType: AVMediaType.video).first
        
        mainCompositionInst.renderSize = CGSize(width: (firstVideoTrack?.naturalSize.width)! + (secondVideoTrack?.naturalSize.width)!, height: (firstVideoTrack?.naturalSize.height)!)
        
        mainCompositionInst.frameDuration =  CMTime(seconds: 1.0 / (firstVideoTrack?.nominalFrameRate)!, preferredTimescale: (firstVideoTrack?.naturalTimeScale)!)
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = (mixComposition.tracks.first?.timeRange)!


        let firstLayerInstruction = AVMutableVideoCompositionLayerInstruction()
        firstLayerInstruction.trackID = 1
        
       
        let secondLayerInstruction = AVMutableVideoCompositionLayerInstruction()
       secondLayerInstruction.trackID = 2
        
       
        mainInstruction.layerInstructions = [firstLayerInstruction,secondLayerInstruction ]
        mainCompositionInst.instructions = [mainInstruction]
       mainCompositionInst.customVideoCompositorClass = CustomVideoCompositor.self
        
 
    let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        
        // Set the desired output URL for the file created by the export process.
        exporter?.outputURL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4")
       
         exporter?.outputFileType = AVFileType.mov
        
         exporter?.shouldOptimizeForNetworkUse = true
      
          exporter?.videoComposition = mainCompositionInst
        // Set the output file type to be a mp4 movie.
       
        if FileManager.default.fileExists(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4").path) {
            try? FileManager.default.removeItem(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4").path)
        }
        exporter?.determineCompatibleFileTypes(completionHandler: { (types) in
            
            
            types.forEach({ (item) in
                print("type:",item.rawValue)
            })
            
            
            
        })
       exporter?.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if exporter?.status == .completed {
                        print( URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4").absoluteString, " succesfully saved.")
                       self.passToNextWithSuccess(destinationVideoURL: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4"))
                    completion(URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4"),nil)
                    
                }else{
                    //export failed
                     completion(URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideo.mp4"),exporter?.error)
                    print("ExportFailed:",exporter?.error)
                }
            })
        })
        DispatchQueue.main.async {
            var x = true
            
            _ = AKPlaygroundLoop(every: 0.1) {
                if x {
                    SwiftSpinner.show(progress: Double((exporter?.progress)! ), title: "Please Wait, Compressing the video....")
                    if exporter?.progress == 1 {
                        x = false
                    }
                }else{
                    SwiftSpinner.hide()
                }
            }
        }
       
        
        // Set the desired output URL for the file created by the export process.
      
        
    }
    func processVideoWithAudio(SourceVideo:URL,FirstSourceAudio:URL,SecondSourceAudio:URL,completion: @escaping (URL, Error?) -> ()) {
        let audioAssetOne = AVAsset(url: FirstSourceAudio)
        let audioAssetTwo = AVAsset(url: SecondSourceAudio)
        let videoAsset = AVAsset(url: SourceVideo)
        
         let timeRange = CMTimeRangeFromTimeToTime(start: CMTime.zero, end: videoAsset.duration)
        
        let mixComposition = AVMutableComposition()
        let firstAudioComposition = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 3)
        let secondAudioComposition = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 4)
        let videoComposition = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: videoAsset.unusedTrackID())
        
        
        let audioMix: AVMutableAudioMix = AVMutableAudioMix()
        var audioMixParam: [AVMutableAudioMixInputParameters] = []
        
        let assetVideoAudioTrack: AVAssetTrack = audioAssetTwo.tracks(withMediaType: AVMediaType.audio).first!
        let assetMusicTrack: AVAssetTrack = audioAssetOne.tracks(withMediaType: .audio).first!
        
        
        let videoParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetVideoAudioTrack)
        videoParam.trackID = (firstAudioComposition?.trackID)!
        
        let musicParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetMusicTrack)
        musicParam.trackID = (secondAudioComposition?.trackID)!
        
        
        
        videoParam.setVolume(1.0, at: CMTime.zero)
        musicParam.setVolume(1.0, at: CMTime.zero)
        audioMixParam.append(videoParam)
        audioMixParam.append(musicParam)
        
        do {
            try firstAudioComposition?.insertTimeRange(timeRange, of: audioAssetOne.tracks(withMediaType: .audio).first!, at: CMTime.zero)
        }catch{
            
        }
        do {
            try secondAudioComposition?.insertTimeRange(timeRange, of: audioAssetTwo.tracks(withMediaType: .audio).first!, at: CMTime.zero)
        }catch{
            
        }
        do {
            try videoComposition?.insertTimeRange(timeRange, of: videoAsset.tracks(withMediaType: .video).first!, at: CMTime.zero)
        }catch{
            
        }
        audioMix.inputParameters = audioMixParam
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        
        // Set the desired output URL for the file created by the export process.
        exporter?.outputURL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4")
        
        exporter?.outputFileType = AVFileType.mov
        
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.audioMix = audioMix
        // Set the output file type to be a mp4 movie.
        
        if FileManager.default.fileExists(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").path) {
            try? FileManager.default.removeItem(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").path)
        }
        exporter?.determineCompatibleFileTypes(completionHandler: { (types) in
            
            
            types.forEach({ (item) in
                print("type:",item.rawValue)
            })
            
            
            
        })
        exporter?.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if exporter?.status == .completed {
                    print( URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").absoluteString, " succesfully saved.")
                    //self.passToNextWithSuccess(destinationVideoURL: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"))
                    completion(URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"),nil)
                }else{
                    //export failed
                     completion(URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"),exporter?.error)
                    print("ExportFailed:",exporter?.error)
                }
            })
        })
        var x = true
      
            _ = AKPlaygroundLoop(every: 0.1) {
                if x {
                    SwiftSpinner.show(progress: Double((exporter?.progress)! ), title: "Please Wait:  processing....")
                    if exporter?.progress == 1 {
                        x = false
                    }
                }else{
                    SwiftSpinner.hide()
                }
            }
        
    }
    func passToNextWithSuccess(destinationVideoURL:URL) {
        
       // self.processVideoWithAudio(SourceVideo: destinationVideoURL, FirstSourceAudio: self.SourceVideo, SecondSourceAudio: self.AudioToAdd)
    }
    
  
}
extension StudioController {
    
    var SecondVideo : URL {
        return documentFolderPath.appendingPathComponent("videoRec.mp4")
    }
    var AudioToAdd : URL {
        return documentFolderPath.appendingPathComponent("recording.m4a")
    }
    var Generated : URL {
        return documentFolderPath.appendingPathComponent("mixedVideos.mp4")
    }
    
    func processVideoWithAudio(SourceVideo:URL,FirstSourceAudio:URL,SecondSourceAudio:URL,completion: @escaping (URL, Error?) -> ()) {
        let audioAssetOne = AVAsset(url: FirstSourceAudio)
        let audioAssetTwo = AVAsset(url: SecondSourceAudio)
        let videoAsset = AVAsset(url: SourceVideo)
        
        let timeRange = CMTimeRangeFromTimeToTime(start: CMTime.zero, end: videoAsset.duration)
        
        let mixComposition = AVMutableComposition()
        let firstAudioComposition = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 3)
        let secondAudioComposition = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 4)
        let videoComposition = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: videoAsset.unusedTrackID())
        
        
        let audioMix: AVMutableAudioMix = AVMutableAudioMix()
        var audioMixParam: [AVMutableAudioMixInputParameters] = []
        
        let assetVideoAudioTrack: AVAssetTrack = audioAssetTwo.tracks(withMediaType: AVMediaType.audio).first!
        let assetMusicTrack: AVAssetTrack = audioAssetOne.tracks(withMediaType: .audio).first!
        
        
        let videoParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetVideoAudioTrack)
        videoParam.trackID = (firstAudioComposition?.trackID)!
        
        let musicParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: assetMusicTrack)
        musicParam.trackID = (secondAudioComposition?.trackID)!
        
        
        
        videoParam.setVolume(1.0, at: CMTime.zero)
        musicParam.setVolume(1.0, at: CMTime.zero)
        audioMixParam.append(videoParam)
        audioMixParam.append(musicParam)
        
        do {
            try firstAudioComposition?.insertTimeRange(timeRange, of: audioAssetOne.tracks(withMediaType: .audio).first!, at: CMTime.zero)
        }catch{
            
        }
        do {
            try secondAudioComposition?.insertTimeRange(timeRange, of: audioAssetTwo.tracks(withMediaType: .audio).first!, at: CMTime.zero)
        }catch{
            
        }
        do {
            try videoComposition?.insertTimeRange(timeRange, of: videoAsset.tracks(withMediaType: .video).first!, at: CMTime.zero)
        }catch{
            
        }
        audioMix.inputParameters = audioMixParam
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        
        // Set the desired output URL for the file created by the export process.
        exporter?.outputURL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4")
        
        exporter?.outputFileType = AVFileType.mov
        
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.audioMix = audioMix
        // Set the output file type to be a mp4 movie.
        
        if FileManager.default.fileExists(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").path) {
            try? FileManager.default.removeItem(atPath: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").path)
        }
        exporter?.determineCompatibleFileTypes(completionHandler: { (types) in
            
            
            types.forEach({ (item) in
                print("type:",item.rawValue)
            })
            
            
            
        })
        exporter?.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if exporter?.status == .completed {
                    print( URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4").absoluteString, " succesfully saved.")
                    //self.passToNextWithSuccess(destinationVideoURL: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"))
                    completion(URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"),nil)
                }else{
                    //export failed
                    completion(URL(fileURLWithPath: NSHomeDirectory() + "/Documents/mixedVideos.mp4"),exporter?.error)
                    print("ExportFailed:",exporter?.error)
                }
            })
        })
        
    }
}
