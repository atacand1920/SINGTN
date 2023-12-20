//
//  FTPUpload.swift
//  SINGTN
//
//  Created by macbook on 2018-10-11.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import Foundation
import CFNetwork

public class FTPUpload {
    
    let request : LxFTPRequest!
    var NameVideo : String = ""
    init() {
        request = LxFTPRequest.upload()
        NameVideo = generateUUID()
        request.serverURL = URL(string: "ftp://ftp.cluster020.hosting.ovh.net")?.appendingPathComponent("/www/SINGTN/images/" + NameVideo + ".mp4")
        request.username = "veloxitcuo"
        request.password = "V15jgw29"
/*request.progressAction = { totalSize, finishedSize, finishedPercent in
    print(String(format: "totalSize = %ld, finishedSize = %ld, finishedPercent = %f", totalSize, finishedSize, finishedPercent)) //
    totalSize = max(totalSize, finishedSize)
    var strongSelf = weakSelf
    strongSelf.progressHUD.progress = CGFloat(finishedSize) / CGFloat(totalSize)
} */

        //request.progressAction = (totalsize : NSInteger, finishedSize : NSInteger, finishedPercent: CGFloat) {
            
        //}
    }
    func getRequest() -> LxFTPRequest {
        return request
    }
    func uploadFile(fileToUpload : URL) {
        
        request.localFileURL = fileToUpload
        
        request.start()
        
        
      
        
        
    }
    func generateUUID() -> String {

        return UUID().uuidString
    }

}
