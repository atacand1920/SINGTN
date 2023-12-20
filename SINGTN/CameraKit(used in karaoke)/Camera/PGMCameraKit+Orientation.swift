/*
 Copyright (c) 2015 Pablo GM <invanzert@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation
import UIKit
import AVFoundation

extension PGMCameraKit {
    
    
    // MARK: Associated objects
    
    private struct AssociatedKeys {
        static var CamIsObsDevOrKey = "cameraIsObservingDeviceOrientationKey"
    }
    
    var cameraIsObservingDeviceOrientation: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.CamIsObsDevOrKey) as? Bool
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.CamIsObsDevOrKey, newValue as Bool?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    // MARK: Start / Stop orientation changed listener
    
    internal func startFollowingDeviceOrientation() {
        
        if cameraIsObservingDeviceOrientation == nil ||  cameraIsObservingDeviceOrientation == false {
            
            NotificationCenter.default.addObserver(self, selector: #selector(PGMCameraKit.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
            cameraIsObservingDeviceOrientation = true
        }
    }
    
    internal func stopFollowingDeviceOrientation() {
        
        if cameraIsObservingDeviceOrientation == true {
            
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
            cameraIsObservingDeviceOrientation = false
        }
    }
    
    @objc internal func orientationChanged() {
        
        
        
        var currentConnection: AVCaptureConnection?;
        switch cameraOutputMode {
        case .StillImage:
            currentConnection = stillImageOutput?.connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        case .VideoOnly, .VideoWithMic:
            currentConnection = getMovieOutput().connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        }
        if let validPreviewLayer = previewLayer {
            if let validPreviewLayerConnection = validPreviewLayer.connection {
                if validPreviewLayerConnection.isVideoOrientationSupported {
                    validPreviewLayerConnection.videoOrientation = .portrait
                }
            }
            if let validOutputLayerConnection = currentConnection {
                if validOutputLayerConnection.isVideoOrientationSupported {
                    validOutputLayerConnection.videoOrientation = .portrait
                }
            }
            DispatchQueue.main.async {
                if let validEmbedingView = self.embedingView {
                    validPreviewLayer.frame = validEmbedingView.bounds
                }
            }
            
        }
    }
    
    
    // MARK: Private Functions
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
        
        switch UIDevice.current.orientation {
            
        case .landscapeLeft:
            return .portrait
            
        case .landscapeRight:
            return .portrait
            
        case .portraitUpsideDown:
            return .portrait
            
        default:
            return .portrait
        }
    }
}

extension AVCaptureVideoOrientation {
    
    var uiDeviceOrientation: UIDeviceOrientation {
        get {
            switch self {
            case .landscapeLeft:        return .portrait
            case .landscapeRight:       return .portrait
            case .portrait:             return .portrait
            case .portraitUpsideDown:   return .portrait
            }
        }
    }
    
    init(ui:UIDeviceOrientation) {
        switch ui {
        case .landscapeRight:
            self = .portrait
        //print("LandscapeRight")
        case .landscapeLeft:
            self = .portrait
        //print("LandscapeLeft")
        case .portrait:
            self = .portrait
        //print("Portrait")
        case .portraitUpsideDown:
            self = .portrait
        //print("PortraitUpsideDown")
        default:
            self = .portrait
            //print("Portrait")
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
    return input.rawValue
}
