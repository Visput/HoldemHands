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
    
    private static var gameRoundsCount = 0
    
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

extension Analytics {
    
    class func playClickedInMenu() {
        Flurry.logEvent("click_menu_play")
    }
    
    class func statsClickedInMenu() {
        Flurry.logEvent("click_menu_stats")
    }
    
    class func facebookClickedInMenu() {
        Flurry.logEvent("click_menu_facebook")
    }
    
    class func twitterClickedInMenu() {
        Flurry.logEvent("click_menu_twitter")
    }
    
    class func instagramClickedInMenu() {
        Flurry.logEvent("click_menu_instagram")
    }
    
    class func leaderboardClickedInStats(leaderboardID: String) {
        Flurry.logEvent("click_stats_leaderboard", withParameters: ["id" : leaderboardID])
    }
    
    class func doneClickedInStats() {
        Flurry.logEvent("click_stats_done")
    }
    
    class func menuClickedInLevels() {
        Flurry.logEvent("click_levels_menu")
        levelsDisappeared()
        menuAppeared()
    }
    
    class func levelClickedInLevels(progress: LevelProgress) {
        Flurry.logEvent("click_levels_level", withParameters: ["id" : progress.levelID, "locked" : progress.locked])
        menuDisappeared()
        levelsAppeared()
    }
    
    class func doneClickedInGame() {
        Flurry.logEvent("click_game_done")
    }
}

extension Analytics {
    
    class func menuAppeared() {
        Flurry.logEvent("screen_menu", timed: true)
    }
    
    class func menuDisappeared() {
        Flurry.endTimedEvent("screen_menu", withParameters: [:])
    }
    
    class func levelsAppeared() {
        Flurry.logEvent("screen_levels", timed: true)
    }
    
    class func levelsDisappeared() {
        Flurry.endTimedEvent("screen_levels", withParameters: [:])
    }
    
    class func statsAppeared() {
        Flurry.logEvent("screen_stats", timed: true)
    }
    
    class func statsDisappeared() {
        Flurry.endTimedEvent("screen_stats", withParameters: [:])
    }
    
    class func leaderboardsAppeared() {
        Flurry.logEvent("screen_leaderboards", timed: true)
    }
    
    class func leaderboardsDisappeared() {
        Flurry.endTimedEvent("screen_leaderboards", withParameters: [:])
    }
    
    class func gameAppeared(level: Level) {
        Flurry.logEvent("screen_game_\(level.identifier)", timed: true)
    }
    
    class func gameRoundPlayed() {
        gameRoundsCount += 1
    }
    
    class func gameDisappeared(level: Level) {
        Flurry.endTimedEvent("screen_game_\(level.identifier)", withParameters: ["rounds" : gameRoundsCount])
        gameRoundsCount = 0
    }
}

extension Analytics {
    
    class func unlockBannerShownInGame(progress: LevelProgress) {
        Flurry.logEvent("show_game_unlock_banner", withParameters: ["id" : progress.levelID])
    }
    
    class func unlockBannerClickedInGame(progress: LevelProgress) {
        Flurry.logEvent("click_game_unlock_banner", withParameters: ["id" : progress.levelID])
    }
}
