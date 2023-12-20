//
//  ScriptBase.swift
//  SpotifyTest
//
//  Created by macbook on 2018-07-07.
//  Copyright © 2018 Seth Rininger. All rights reserved.
//

import Foundation
import UIKit
class ScriptBase {
    static var sharedInstance = ScriptBase()
    private init(){}
     //****************BackEnd-Server**************************///
    static let  server = "https://singtn.herokuapp.com/API/"
    
     //****************Storage-Server**************************///
    static let serverTwo = "http://velox-it.com/SINGTN/"
    
    //****************USERS**************************///
    var login = server + "loginuser"
    var verifyemail = server + "verifyemail"
    var register = server + "registeruser"
    var LyricsApi = "http://lyric-api.herokuapp.com/api/find/artist/song"
    var changeInfoUser = server + "changeInfoUser"
    var setIosPlayerId = server + "setIOS"
    var getAllUsers = server + "getAllUsers"
    var getUserInfo = server + "getUserInfo"
    var facebookLogReg = server + "registerLoginFacebook"
    var googleLogReg = server  + "registerLoginGoogle"
     //****************SONGS**************************///
    var songs  = server + "getAllSongs"
    var save_song = server + "saveSong"
    var history_song = server + "getHistory"
    var uploadViaFTP = serverTwo + "ftpUpload.php"
    var uploadViaPost = serverTwo + "uploadimage.php"
    var uploadFTPVideo = serverTwo + "images/"
    var getCategorySong = server + "getCategorySong"
    var getDuoGroupSongs = server + "getDuoGroupSongs"
     //****************PUBLICATIONS**************************///
    var create_publication = server + "createPublication"
    var get_publication = server + "getPublications"
    var SharePublication = server + "sharePublicationUser"
    
    //****************FOLLOWERS**************************///
    var get_followers = server + "getFollowers"
    var follow = server + "followUser"
    var unfollow = server + "unfollowUser"
    var getAllFollowing = server + "getAllFollowing"
    var getAllFollowers = server + "getAllFollowers"
    // il manque follow et unfllow
    //****************COMMENTS**************************///
    var addComment = server + "addComment"
    var getComments = server + "getPublicationComments"
    var modifyComment = server + "modifyPublicationComments"
    var deleteComment = server + "deletePublicationComments"
    
     //****************LIKES**************************///
    var AddLikeToPublication = server + "AddLike"
    var GetLikes = server + "getLikes"
    var RemoveLikeFromPublication = server + "removeLike"
    
    //****************NOTIFICATIONS**************************///
   var getNotifications = server + "getNotifications"
   var ChangePush = server  + "ChangeStatusPush"
    
    //***************HELPERS*******************************////
    func getLanguage() -> String {
        let lang = Locale.current.languageCode
        return lang!
    }
    var DUOC_or_DUOJ = ""
    
}
