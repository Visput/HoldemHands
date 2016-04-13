//
//  NavigationManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/3/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import GameKit

final class NavigationManager: NSObject {
    
    var window: UIWindow! {
        didSet {
            navigationController = window.rootViewController! as! UINavigationController
        }
    }
    
    private(set) var mainScreen: MainScreen!
    
    private var navigationController: UINavigationController!
    
    private var storyboard: UIStoryboard {
        return window.rootViewController!.storyboard!
    }
    
    private var topViewController: UIViewController {
        var topViewController = navigationController as UIViewController
        while topViewController.presentedViewController != nil {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
    func presentScreen(screen: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        topViewController.presentViewController(screen, animated: animated, completion: completion)
    }
    
    func dismissScreenAnimated(animated: Bool, completion: (() -> Void)? = nil) {
        topViewController.dismissViewControllerAnimated(animated, completion: completion)
    }
    
    func setMainScreenAsRootAnimated(animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(MainScreen.className()) as! MainScreen
        navigationController.setViewControllers([screen], animated: animated)
        mainScreen = screen
    }
    
    func presentGameScreenWithLevel(level: Level, animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(GameScreen.className()) as! GameScreen
        screen.level = level
        screen.modalPresentationStyle = .OverCurrentContext
        // Manually call `beginAppearanceTransition` and `endAppearanceTransition` 
        // as it's not called automatically when view controller is presented over current context.
        let presentingScreen = topViewController
        presentingScreen.beginAppearanceTransition(false, animated: animated)
        presentScreen(screen, animated: animated, completion: {
            presentingScreen.endAppearanceTransition()
        })
    }
    
    func dismissGameScreenAnimated(animated: Bool) {
        // Manually call `beginAppearanceTransition` and `endAppearanceTransition`
        // as it's not called automatically when view controller is presented over current context.
        let presentingScreen = topViewController.presentingViewController!
        presentingScreen.beginAppearanceTransition(true, animated: animated)
        dismissScreenAnimated(animated, completion: {
            presentingScreen.endAppearanceTransition()
        })
    }
    
    func presentStatsScreenWithLevel(level: Level?, animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(StatsScreen.className()) as! StatsScreen
        screen.level = level
        presentScreen(screen, animated: animated)
    }
    
    func presentLeaderboardScreenWithLeaderboardID(leaderboardID: String?, animated: Bool) {
        let screen = GKGameCenterViewController()
        screen.leaderboardIdentifier = leaderboardID
        screen.viewState = .Leaderboards
        screen.gameCenterDelegate = self
        
        // Manually call `beginAppearanceTransition` and `endAppearanceTransition`
        // as it's not called automatically when view controller is presented over current context.
        let presentingScreen = topViewController
        presentingScreen.beginAppearanceTransition(false, animated: animated)
        presentScreen(screen, animated: animated, completion: {
            presentingScreen.endAppearanceTransition()
            Analytics.leaderboardsScreenAppeared()
        })
    }
    
    func showBannerWithText(text: String, duration: NSTimeInterval = 5.0, tapHandler: (() -> Void)? = nil) -> BannerView {
        let banner: TextBannerView = TextBannerView.fromNib()
        banner.showInView(window, withText: text, duration: duration, tapHandler: tapHandler)
        return banner
    }
}

extension NavigationManager: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        // Manually call `beginAppearanceTransition` and `endAppearanceTransition`
        // as it's not called automatically when view controller is presented over current context.
        let presentingScreen = topViewController.presentingViewController!
        presentingScreen.beginAppearanceTransition(true, animated: true)
        dismissScreenAnimated(true, completion: {
            Analytics.leaderboardsScreenDisappeared()
            presentingScreen.endAppearanceTransition()
        })
    }
}
