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
    
    private var navigationController: UINavigationController!
    
    private var storyboard: UIStoryboard {
        return window.rootViewController!.storyboard!
    }
    
    func presentScreen(screen: UIViewController, animated: Bool) {
        let presentingViewController = navigationController.presentedViewController ?? navigationController
        presentingViewController!.presentViewController(screen, animated: animated, completion: nil)
    }
    
    func dismissScreenAnimated(animated: Bool) {
        let presentedViewController = navigationController.presentedViewController?.presentedViewController ??
            navigationController.presentedViewController
        let presentingViewController = presentedViewController?.presentingViewController
        presentingViewController?.dismissViewControllerAnimated(animated, completion: nil)
    }
    
    func setMainScreenAsRootAnimated(animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(MainScreen.className()) as! MainScreen
        navigationController.setViewControllers([screen], animated: animated)
    }
    
    func presentGameScreenWithLevel(level: Level, animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(GameScreen.className()) as! GameScreen
        screen.level = level
        presentScreen(screen, animated: animated)
    }
    
    func presentStatsScreenAnimated(animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(StatsScreen.className()) as! StatsScreen
        presentScreen(screen, animated: animated)
    }
    
    func presentLeaderboardScreenWithLeaderboardID(leaderboardID: String?, animated: Bool) {
        Analytics.leaderboardsAppeared()
        let screen = GKGameCenterViewController()
        screen.leaderboardIdentifier = leaderboardID
        screen.viewState = .Leaderboards
        screen.gameCenterDelegate = self
        presentScreen(screen, animated: animated)
    }
    
    func showBannerWithText(text: String, duration: NSTimeInterval = 5.0, tapHandler: (() -> Void)? = nil) -> BannerView {
        let banner: TextBannerView = TextBannerView.fromNib()
        banner.showInView(window, withText: text, duration: duration, tapHandler: tapHandler)
        return banner
    }
}

extension NavigationManager: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        Analytics.leaderboardsDisappeared()
        dismissScreenAnimated(true)
    }
}
