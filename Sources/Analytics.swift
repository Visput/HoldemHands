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
import AdSupport

final class Analytics {
    
    private static var gameRoundsCount = 0
    private static var screenAppearTime = 0.0
    private static var screenDisappearTime: Double {
        return CFAbsoluteTimeGetCurrent() - screenAppearTime
    }
    private typealias Event = (name: String, params: [String : AnyObject])
    
    class func startSession() {
        let flurryKey = NSBundle.mainBundle().objectForInfoDictionaryKey("FlurryKey") as! String
        #if DEBUG
            Flurry.setLogLevel(FlurryLogLevelCriticalOnly)
        #endif
        Flurry.startSession(flurryKey)
        Fabric.with([Crashlytics(), Twitter(), Answers()])
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
        let event = (name: "sharing_facebook", params: ["action" : "canceled"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func facebookSharingCompleted() {
        let event = (name: "sharing_facebook", params: ["action" : "completed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func facebookSharingFailed(error: NSError) {
        self.error(error)
        let event = (name: "sharing_facebook", params: ["action" : "failed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func twitterSharingInitiated() {
        Flurry.logEvent("sharing_twitter", timed: true)
    }
    
    class func twitterSharingCanceled() {
        let event = (name: "sharing_twitter", params: ["action" : "canceled"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func twitterSharingCompleted() {
        let event = (name: "sharing_twitter", params: ["action" : "completed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func twitterSharingFailed(error: NSError) {
        self.error(error)
        let event = (name: "sharing_twitter", params: ["action" : "failed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func instagramSharingInitiated() {
        Flurry.logEvent("sharing_instagram", timed: true)
    }
    
    class func instagramSharingCompleted() {
        let event = (name: "sharing_instagram", params: ["action" : "completed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func instagramSharingFailed(error: NSError) {
        self.error(error)
        let event = (name: "sharing_instagram", params: ["action" : "failed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
}

extension Analytics {
    
    class func playClickedInMenu() {
        let event = (name: "click_menu_play", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
        menuDisappeared()
        levelsAppeared()
    }
    
    class func statsClickedInMenu() {
        let event = (name: "click_menu_stats", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func facebookClickedInMenu() {
        let event = (name: "click_menu_facebook", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func twitterClickedInMenu() {
        let event = (name: "click_menu_twitter", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func instagramClickedInMenu() {
        let event = (name: "click_menu_instagram", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func leaderboardClickedInStats(leaderboardID: String) {
        let event = (name: "click_stats_leaderboard", params: ["id" : leaderboardID])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func doneClickedInStats() {
        let event = (name: "click_stats_done", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func menuClickedInLevels() {
        let event = (name: "click_levels_menu", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
        levelsDisappeared()
        menuAppeared()
    }
    
    class func levelClickedInLevels(progress: LevelProgress) {
        let event = (name: "click_levels_level", params: ["id" : progress.levelID, "locked" : progress.locked])
        Flurry.logEvent(event.name, withParameters: event.params as [NSObject : AnyObject])
        Answers.logCustomEventWithName(event.name, customAttributes: (event.params as! [String : AnyObject]))
    }
    
    class func doneClickedInGame() {
        let event = (name: "click_game_done", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func menuAppeared() {
        Flurry.logEvent("screen_menu", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func menuDisappeared() {
        let event = (name: "screen_menu", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func levelsAppeared() {
        Flurry.logEvent("screen_levels", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func levelsDisappeared() {
        let event = (name: "screen_levels", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func statsAppeared() {
        Flurry.logEvent("screen_stats", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func statsDisappeared() {
        let event = (name: "screen_stats", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func leaderboardsAppeared() {
        Flurry.logEvent("screen_leaderboards", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func leaderboardsDisappeared() {
        let event = (name: "screen_leaderboards", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func gameAppeared(level: Level) {
        Flurry.logEvent("screen_game_\(level.identifier)", timed: true)
        Answers.logLevelStart("level_\(level.identifier)", customAttributes: nil)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func gameRoundPlayed() {
        gameRoundsCount += 1
    }
    
    class func gameDisappeared(level: Level) {
        Flurry.endTimedEvent("screen_game_\(level.identifier)", withParameters: ["rounds" : gameRoundsCount])
        Answers.logCustomEventWithName("screen_game_\(level.identifier)",
                                       customAttributes: ["rounds" : gameRoundsCount, "time" : screenDisappearTime])
        
        Answers.logLevelEnd("level_\(level.identifier)",
                            score: gameRoundsCount,
                            success: true,
                            customAttributes: ["time" : screenDisappearTime])
        gameRoundsCount = 0
    }
}

extension Analytics {
    
    class func unlockBannerShownInGame(level: Level) {
        let event = (name: "show_game_unlock_banner", params: ["id" : level.identifier])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func unlockBannerClickedInGame(level: Level) {
        let event = (name: "click_game_unlock_banner", params: ["id" : level.identifier])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
}
