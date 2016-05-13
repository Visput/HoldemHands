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
    private var currentTextBanner: TextBannerView?
    
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
        let screen = R.storyboard.main.mainScreen()!
        navigationController.setViewControllers([screen], animated: animated)
        mainScreen = screen
    }
    
    func presentGameScreenWithLevel(level: Level, animated: Bool, completion: (() -> Void)? = nil) {
        let screen = R.storyboard.main.gameScreen()!
        screen.level = level
        screen.modalPresentationStyle = .OverCurrentContext
        // Manually call `beginAppearanceTransition` and `endAppearanceTransition` 
        // as it's not called automatically when view controller is presented over current context.
        let presentingScreen = topViewController
        presentingScreen.beginAppearanceTransition(false, animated: animated)
        presentScreen(screen, animated: animated, completion: {
            presentingScreen.endAppearanceTransition()
            completion?()
        })
    }
    
    func dismissGameScreenAnimated(animated: Bool, completion: (() -> Void)? = nil) {
        // Manually call `beginAppearanceTransition` and `endAppearanceTransition`
        // as it's not called automatically when view controller is presented over current context.
        let presentingScreen = topViewController.presentingViewController!
        presentingScreen.beginAppearanceTransition(true, animated: animated)
        dismissScreenAnimated(animated, completion: {
            presentingScreen.endAppearanceTransition()
            completion?()
        })
    }
    
    func presentStatsScreenWithLevel(level: Level?, animated: Bool, completion: (() -> Void)? = nil) {
        let screen = R.storyboard.main.statsScreen()!
        screen.level = level
        presentScreen(screen, animated: animated, completion: completion)
    }
    
    func presentLeaderboardScreenWithLeaderboardID(leaderboardID: String?, animated: Bool, completion: (() -> Void)? = nil) {
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
            completion?()
        })
    }
    
    func presentBannerWithText(text: String,
                               backgroundImage: UIImage? = nil,
                               duration: NSTimeInterval = 5.0,
                               tapHandler: (() -> Void)? = nil) -> BannerView {
        // If current banner presented and shows the same text it's not needed to display new banner.
        guard !(currentTextBanner != nil &&
            currentTextBanner!.presented &&
            currentTextBanner!.textLabel.text == text) else {
                return currentTextBanner!
        }
        
        let newTextBanner = R.nib.textBannerView.firstView(owner: nil)!
        let showNewTextBanner = { [unowned self] in
            self.currentTextBanner = newTextBanner
            newTextBanner.presentInView(self.window,
                                        withText: text,
                                        backgroundImage: backgroundImage,
                                        duration: duration,
                                        tapHandler: tapHandler)
        }
        
        if currentTextBanner == nil || !currentTextBanner!.presented {
            showNewTextBanner()
        } else {
            currentTextBanner!.dismiss({
                showNewTextBanner()
            })
        }
        
        return newTextBanner
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
