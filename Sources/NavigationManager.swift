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
    
    func presentScreen(screen: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        navigationController.presentViewController(screen, animated: animated, completion: completion)
    }
    
    func dismissScreenAnimated(animated: Bool) {
        navigationController.dismissViewControllerAnimated(animated, completion: nil)
    }
    
    func setMainScreenAsRootAnimated(animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(MainScreen.className()) as! MainScreen
        navigationController.setViewControllers([screen], animated: animated)
    }
    
    func presentGameScreenWithLevel(level: Level, animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(GameScreen.className()) as! GameScreen
        screen.level = level
        navigationController.presentViewController(screen, animated: animated, completion: nil)
    }
    
    func presentStatsScreenAnimated(animated: Bool) {
        let screen = storyboard.instantiateViewControllerWithIdentifier(StatsScreen.className()) as! StatsScreen
        navigationController.presentViewController(screen, animated: animated, completion: nil)
    }
    
    func presentLeaderboardWithID(leaderboardID: String?, animated: Bool) {
        let screen = GKGameCenterViewController()
        screen.leaderboardIdentifier = leaderboardID
        screen.viewState = .Leaderboards
        screen.delegate = self
        navigationController.presentViewController(screen, animated: animated, completion: nil)
    }
    
    func showBannerWithText(text: String, duration: NSTimeInterval = 5.0, tapAction: (() -> Void)? = nil) -> BannerView {
        let banner: TextBannerView = TextBannerView.fromNib()
        banner.showInView(window, withText: text, duration: duration, tapAction: tapAction)
        return banner
    }
}

extension NavigationManager: GKGameCenterControllerDelegate, UINavigationControllerDelegate {
    
    @objc func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        dismissScreenAnimated(true)
    }
}
