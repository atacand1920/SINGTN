//
//  AppDelegate.swift
//  SINGTN
//
//  Created by macbook on 2018-05-14.
//  Copyright © 2018 Velox-IT. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import AudioKit
import OneSignal
import GoogleMobileAds
import FBSDKLoginKit
import GoogleSignIn
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var window: UIWindow?
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!
    var tracker : AKAmplitudeTracker!
    var input  = AKMicrophone()
    var DesctructionActivated = false
    var SelectedFilter = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        clearDiskCache()
        EVURLCache.LOGGING = true
        EVURLCache.MAX_FILE_SIZE = 26
        EVURLCache.MAX_CACHE_SIZE = 30
        EVURLCache.activate()
        UIApplication.shared.isIdleTimerDisabled = true
            UIApplication.shared.statusBarOrientation = .portrait
         GADMobileAds.configure(withApplicationID: "ca-app-pub-8565728245106741~8970187710")
          let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true , kOSSettingsKeyInAppLaunchURL: true ]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "6d29ede4-cbba-45b1-957b-29daa3cfd603",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
         OneSignal.inFocusDisplayType = OSNotificationDisplayType.none
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        let _: OSHandleNotificationReceivedBlock = { notification in
            //  _ = SweetAlert().showAlert("Push", subTitle: "Vous etes connecté", style: AlertStyle.success)
            print("Received Notification: \(notification!.payload.notificationID ?? "")")
        }
        let _: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            //_ = SweetAlert().showAlert("Push", subTitle: "Vous etes connecté", style: AlertStyle.success)
            var fullMessage = payload.body
            print("Message = ",fullMessage ?? "")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: " + (additionalData!["actionSelected"] as! String)
                }
            }
        }
       preapare_audioKit()
    
        //sleep(3)
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        do {
        
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord,mode: .default,options: [AVAudioSession.CategoryOptions.mixWithOthers, .defaultToSpeaker])
            print("AVAudioSessionCategoryPlayAndRecord OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                UIApplication.shared.beginReceivingRemoteControlEvents()
                
                print("AVAudioSession is Active")
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        // Override point for customization after application launch.
        return true
    }
    func preapare_audioKit(){
        if delay != nil {
        AudioKit.disconnectAllInputs()
            
        }
        //input = AKMicrophone()
        delay = AKVariableDelay(input)
        delay.rampTime = 0.5 // Allows for some cool effects
        delayMixer = AKDryWetMixer(input, delay)
        
        reverb = AKCostelloReverb(delayMixer)
        reverbMixer = AKDryWetMixer(delayMixer, reverb)
        booster = AKBooster(reverbMixer)
        booster.gain = 1.5
        tracker = AKAmplitudeTracker(booster)
        AudioKit.output = tracker
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options))! {
            return true
        }else if (GIDSignIn.sharedInstance()?.handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]))!{
            return true
        }
        return false
    }
    func clearDiskCache() {
        if DesctructionActivated {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        var desc = myDocuments.description
       
        let range =  desc.index(desc.startIndex, offsetBy: 0)..<desc.index(desc.startIndex, offsetBy: 8)
        desc.removeSubrange(range)
        desc = "file:///private/" + desc + "Cache/"
        print("Diff: ",desc)
        for filePath in filePaths {
            print("Saif:",filePath)
            if filePath != URL(string: desc) {
            try? fileManager.removeItem(at: filePath)
            }else{
                print("Cache exist")
            }
        }
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        clearDiskCache()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SINGTN")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

