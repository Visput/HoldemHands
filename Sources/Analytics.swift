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
    
    weak static var navigationManager: NavigationManager!
    
    private static var gameRoundsCount = 0
    private static var screenAppearTime = 0.0
    private static var screenDisappearTime: Double {
        return CFAbsoluteTimeGetCurrent() - screenAppearTime
    }
    private typealias Event = (name: String, params: [String : AnyObject])
    
    class func startSession() {
        let flurryKey = NSBundle.mainBundle().objectForInfoDictionaryKey("FlurryKey") as! String
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
    
    class func userName(userName: String?) {
        Crashlytics.sharedInstance().setUserName(userName)
    }
    
    class func userID(userID: String?) {
        Crashlytics.sharedInstance().setUserIdentifier(userID)
        Flurry.setUserID(userID)
    }
}

extension Analytics {
    
    class func facebookSharingInitiated() {
        Flurry.logEvent("share.facebook", timed: true)
    }

    class func facebookSharingCanceled() {
        let event = (name: "share.facebook", params: ["action" : "canceled"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func facebookSharingCompleted() {
        let event = (name: "share.facebook", params: ["action" : "completed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func facebookSharingFailed(error: NSError) {
        self.error(error)
        let event = (name: "share.facebook", params: ["action" : "failed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func twitterSharingInitiated() {
        Flurry.logEvent("share.twitter", timed: true)
    }
    
    class func twitterSharingCanceled() {
        let event = (name: "share.twitter", params: ["action" : "canceled"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func twitterSharingCompleted() {
        let event = (name: "share.twitter", params: ["action" : "completed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func twitterSharingFailed(error: NSError) {
        self.error(error)
        let event = (name: "share.twitter", params: ["action" : "failed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func instagramSharingInitiated() {
        Flurry.logEvent("share.instagram", timed: true)
    }
    
    class func instagramSharingCompleted() {
        let event = (name: "share.instagram", params: ["action" : "completed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func instagramSharingFailed(error: NSError) {
        self.error(error)
        let event = (name: "share.instagram", params: ["action" : "failed"])
        Flurry.endTimedEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
}

extension Analytics {
    
    class func statsItemClicked(progress: Progress) {
        if navigationManager.mainScreen.presentedViewController == nil {
            Analytics.statsItemClickedInMainScreen(progress)
        } else {
            Analytics.statsItemClickedInStatsScreen(progress)
        }
    }
    
    class func leaderboardsClicked() {
        if navigationManager.mainScreen.presentedViewController == nil {
            Analytics.leaderboardsClickedInMainScreen()
        } else {
            Analytics.leaderboardsClickedInStatsScreen()
        }
    }
    
    private class func statsItemClickedInMainScreen(progress: Progress) {
        let event = (name: "click.main_screen.stats_item", params: ["leaderboard_id" : progress.leaderboardID])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: (event.params))
    }
    
    private class func leaderboardsClickedInMainScreen() {
        let event = (name: "click.main_screen.leaderboards", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func statsItemClickedInStatsScreen(progress: Progress) {
        let event = (name: "click.stats_screen.stats_item", params: ["leaderboard_id" : progress.leaderboardID])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: (event.params))
    }
    
    class func leaderboardsClickedInStatsScreen() {
        let event = (name: "click.stats_screen.leaderboards", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func facebookClicked() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            Analytics.facebookClickedInMenuScreen()
        } else {
            Analytics.facebookClickedInMainScreen()
        }
    }
    
    class func twitterClicked() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            Analytics.twitterClickedInMenuScreen()
        } else {
            Analytics.twitterClickedInMainScreen()
        }
    }
    
    class func instagramClicked() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            Analytics.instagramClickedInMenuScreen()
        } else {
            Analytics.instagramClickedInMainScreen()
        }
    }
    
    private class func facebookClickedInMainScreen() {
        let event = (name: "click.main_screen.facebook", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func twitterClickedInMainScreen() {
        let event = (name: "click.main_screen.twitter", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func instagramClickedInMainScreen() {
        let event = (name: "click.main_screen.instagram", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func facebookClickedInMenuScreen() {
        let event = (name: "click.menu_screen.facebook", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func twitterClickedInMenuScreen() {
        let event = (name: "click.menu_screen.twitter", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func instagramClickedInMenuScreen() {
        let event = (name: "click.menu_screen.instagram", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func playClicked() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            playClickedInMenuScreen()
        } else {
            playClickedInMainScreen()
        }
    }
    
    private class func playClickedInMainScreen() {
        let event = (name: "click.main_screen.play", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func playClickedInMenuScreen() {
        let event = (name: "click.menu_screen.play", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func statsClicked() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            statsClickedInMenuScreen()
        } else {
            statsClickedInMainScreen()
        }
    }
    
    private class func statsClickedInMainScreen() {
        let event = (name: "click.main_screen.stats", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func statsClickedInMenuScreen() {
        let event = (name: "click.menu_screen.stats", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func detailsViewSwipedInMainScreen() {
        switch navigationManager.mainScreen.currentDetailsPage! {
        case .Levels:
            playSwipedInMainScreen()
        case .Stats:
            statsSwipedInMainScreen()
        case .Sharing:
            shareSwipedInMainScreen()
        }
    }
    
    private class func playSwipedInMainScreen() {
        let event = (name: "swipe.main_screen.play", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func statsSwipedInMainScreen() {
        let event = (name: "swipe.main_screen.stats", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    private class func shareSwipedInMainScreen() {
        let event = (name: "swipe.main_screen.share", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func shareClickedInMainScreen() {
        let event = (name: "click.main_screen.share", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func levelClickedInMainScreen(progress: LevelProgress) {
        let event = (name: "click.main_screen.level", params: ["level_id" : progress.levelID, "locked" : progress.locked])
        Flurry.logEvent(event.name, withParameters: event.params as [NSObject : AnyObject])
        Answers.logCustomEventWithName(event.name, customAttributes: (event.params as! [String : AnyObject]))
    }
}

extension Analytics {
    
    class func doneClickedInGameScreen() {
        let event = (name: "click.game_screen.done", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func statsClickedInGameScreen() {
        let event = (name: "click.game_screen.stats", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
    
    class func unlockedLevelBannerShownInGameScreen(level: Level) {
        let event = (name: "show.game_screen.unlock_banner", params: ["level_id" : level.identifier])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func unlockBannerClickedInGameScreen(level: Level) {
        let event = (name: "click.game_screen.unlock_banner", params: ["level_id" : level.identifier])
        Flurry.logEvent(event.name, withParameters: event.params)
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
}
    
extension Analytics {
    
    class func doneClickedInStatsScreen() {
        let event = (name: "click.stats_screen.done", params: [:])
        Flurry.logEvent(event.name)
        Answers.logCustomEventWithName(event.name, customAttributes: nil)
    }
}

extension Analytics {
    
    class func mainScreenAppeared() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            menuScreenAppeared()
        } else {
            switch navigationManager.mainScreen.currentDetailsPage! {
            case .Levels:
                mainScreenLevelsAppeared()
            case .Stats:
                mainScreenStatsAppeared()
            case .Sharing:
                mainScreenShareAppeared()
            }
        }
    }
    
    class func mainScreenDisappeared() {
        if navigationManager.mainScreen.currentDetailsPage == nil {
            menuScreenDisappeared()
        } else {
            switch navigationManager.mainScreen.currentDetailsPage! {
            case .Levels:
                mainScreenLevelsDisappeared()
            case .Stats:
                mainScreenStatsDisappeared()
            case .Sharing:
                mainScreenShareDisappeared()
            }
        }
    }
    
    class func detailsViewPageOnMainScreenChanged(oldPage: MainView.DetailsViewPage?, newPage: MainView.DetailsViewPage) {
        guard oldPage != newPage else { return }
        
        if oldPage == nil {
            menuScreenDisappeared()
        } else {
            switch oldPage! {
            case .Levels:
                mainScreenLevelsDisappeared()
            case .Stats:
                mainScreenStatsDisappeared()
            case .Sharing:
                mainScreenShareDisappeared()
            }
        }
        
        switch newPage {
        case .Levels:
            mainScreenLevelsAppeared()
        case .Stats:
            mainScreenStatsAppeared()
        case .Sharing:
            mainScreenShareAppeared()
        }
    }
    
    private class func menuScreenAppeared() {
        Flurry.logEvent("screen.menu", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    private class func menuScreenDisappeared() {
        let event = (name: "screen.menu", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    private class func mainScreenLevelsAppeared() {
        Flurry.logEvent("screen.main.levels", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    private class func mainScreenLevelsDisappeared() {
        let event = (name: "screen.main.levels", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    private class func mainScreenStatsAppeared() {
        Flurry.logEvent("screen.main.stats", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    private class func mainScreenStatsDisappeared() {
        let event = (name: "screen.main.stats", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    private class func mainScreenShareAppeared() {
        Flurry.logEvent("screen.main.share", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    private class func mainScreenShareDisappeared() {
        let event = (name: "screen.main.share", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
}

extension Analytics {
    
    class func gameScreenAppeared(level: Level) {
        let eventName = "screen.game.level_\(level.identifier)"
        Flurry.logEvent(eventName, timed: true)
        Answers.logLevelStart("level_\(level.identifier)", customAttributes: nil)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func gameRoundPlayed() {
        gameRoundsCount += 1
    }
    
    class func gameScreenDisappeared(level: Level) {
        let eventName = "screen.game.level_\(level.identifier)"
        Flurry.endTimedEvent(eventName, withParameters: ["rounds" : gameRoundsCount])
        Answers.logCustomEventWithName(eventName, customAttributes: ["rounds" : gameRoundsCount, "time" : screenDisappearTime])
        
        Answers.logLevelEnd("level_\(level.identifier)",
                            score: gameRoundsCount,
                            success: true,
                            customAttributes: ["time" : screenDisappearTime])
        gameRoundsCount = 0
    }
}

extension Analytics {
    
    class func statsScreenAppeared() {
        Flurry.logEvent("screen.stats", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func statsScreenDisappeared() {
        let event = (name: "screen.stats", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
    
    class func leaderboardsScreenAppeared() {
        Flurry.logEvent("screen.leaderboards", timed: true)
        screenAppearTime = CFAbsoluteTimeGetCurrent()
    }
    
    class func leaderboardsScreenDisappeared() {
        let event = (name: "screen.leaderboards", params: ["time" : screenDisappearTime])
        Flurry.endTimedEvent(event.name, withParameters: [:])
        Answers.logCustomEventWithName(event.name, customAttributes: event.params)
    }
}
