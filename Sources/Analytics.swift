//
//  Analytics.swift
//  Workouter
//
//  Created by Uladzimir Papko on 3/30/15.
//  Copyright (c) 2015 visput. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK
import Fabric
import Crashlytics
import TwitterKit
import FBSDKCoreKit

final class Analytics {
    
    class func startSession() {
        let flurryKey = NSBundle.mainBundle().objectForInfoDictionaryKey("FlurryKey") as! String
        #if DEBUG
            Flurry.setLogLevel(FlurryLogLevelCriticalOnly)
        #endif
        Flurry.startSession(flurryKey)
        Fabric.with([Crashlytics(), Twitter()])
    }
    
    class func appDidBecomeActive() {
        FBSDKAppEvents.activateApp()
    }
    
    class func error(error: NSError?) {
        guard error != nil else { return }
        print(error)
        Crashlytics.sharedInstance().recordError(error!)
    }
    
    class func userName(userName: String) {
        Crashlytics.sharedInstance().setUserName(userName)
    }
    
    class func userID(userID: String) {
        Crashlytics.sharedInstance().setUserIdentifier(userID)
        Flurry.setUserID(userID)
    }
}

extension Analytics {
    
    class func facebookSharingInitiated() {
        Flurry.logEvent("sharing_facebook", timed: true)
    }
    
    class func facebookSharingCanceled() {
        Flurry.endTimedEvent("sharing_facebook", withParameters: ["action" : "canceled"])
    }
    
    class func facebookSharingCompleted() {
        Flurry.endTimedEvent("sharing_facebook", withParameters: ["action" : "completed"])
    }
    
    class func facebookSharingFailed(error: NSError) {
        self.error(error)
        Flurry.endTimedEvent("sharing_facebook", withParameters: ["action" : "failed"])
    }
    
    class func twitterSharingInitiated() {
        Flurry.logEvent("sharing_twitter", timed: true)
    }
    
    class func twitterSharingCanceled() {
        Flurry.endTimedEvent("sharing_twitter", withParameters: ["action" : "canceled"])
    }
    
    class func twitterSharingCompleted() {
        Flurry.endTimedEvent("sharing_twitter", withParameters: ["action" : "completed"])
    }
    
    class func twitterSharingFailed(error: NSError) {
        self.error(error)
        Flurry.endTimedEvent("sharing_twitter", withParameters: ["action" : "failed"])
    }
    
    class func instagramSharingInitiated() {
        Flurry.logEvent("sharing_instagram", timed: true)
    }
    
    class func instagramSharingCompleted() {
        Flurry.endTimedEvent("sharing_instagram", withParameters: ["action" : "completed"])
    }
    
    class func instagramSharingFailed(error: NSError) {
        self.error(error)
        Flurry.endTimedEvent("sharing_instagram", withParameters: ["action" : "failed"])
    }
}
