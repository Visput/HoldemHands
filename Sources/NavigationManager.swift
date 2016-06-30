//
//  NavigationManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/3/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import GameKit
import SwiftTask

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
    
    func presentScreen(screen: UIViewController, animated: Bool) -> SimpleTask {
        return SimpleTask(initClosure: { progress, fulfill, reject, configure in
            let needsToManageAppearanceTransition = screen.modalPresentationStyle != .FullScreen
            let presentingScreen = self.topViewController
            
            if needsToManageAppearanceTransition {
                presentingScreen.beginAppearanceTransition(false, animated: animated)
            }
            self.topViewController.presentViewController(screen, animated: animated, completion: {
                if needsToManageAppearanceTransition {
                    presentingScreen.endAppearanceTransition()
                }
                
                fulfill()
            })
        })
    }
    
    func dismissScreenAnimated(animated: Bool) -> SimpleTask {
        return SimpleTask(initClosure: { progress, fulfill, reject, configure in
            let needsToManageAppearanceTransition = self.topViewController.modalPresentationStyle != .FullScreen
            let presentingScreen = self.topViewController.presentingViewController
            
            if needsToManageAppearanceTransition {
                presentingScreen?.beginAppearanceTransition(true, animated: animated)
            }
            self.topViewController.dismissViewControllerAnimated(animated, completion: {
                if needsToManageAppearanceTransition {
                    presentingScreen?.endAppearanceTransition()
                }
                
                fulfill()
            })
        })
    }
    
    func dismissToMainScreenAnimated(animated: Bool) -> SimpleTask {
        if topViewController === navigationController {
            return SimpleTask.empty()
        } else {
            return dismissScreenAnimated(animated).then {
                return self.dismissToMainScreenAnimated(animated)
            }
        }
    }
    
    func setMainScreenAsRootAnimated(animated: Bool) {
        let screen = R.storyboard.main.mainScreen()!
        navigationController.setViewControllers([screen], animated: animated)
        mainScreen = screen
    }
    
    func presentGameScreenWithLevel(level: Level, animated: Bool) -> SimpleTask {
        let screen = R.storyboard.main.gameScreen()!
        screen.level = level
        return presentScreen(screen, animated: animated)
    }
    
    func presentStatsScreenWithLevel(level: Level?, animated: Bool) -> SimpleTask {
        let screen = R.storyboard.main.statsScreen()!
        screen.level = level
        return presentScreen(screen, animated: animated)
    }
    
    func presentLeaderboardScreenWithLeaderboardID(leaderboardID: String?, animated: Bool) -> SimpleTask {
        let screen = GKGameCenterViewController()
        screen.leaderboardIdentifier = leaderboardID
        screen.viewState = .Leaderboards
        screen.gameCenterDelegate = self
        return presentScreen(screen, animated: animated).thenDo {
            Analytics.leaderboardsScreenAppeared()
        }
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
            currentTextBanner!.dismiss().then({ _ in
                showNewTextBanner()
            })
        }
        
        return newTextBanner
    }
}

extension NavigationManager: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        dismissScreenAnimated(true).then({ _ in
            Analytics.leaderboardsScreenDisappeared()
        })
    }
}
