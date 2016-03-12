//
//  NavigationManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/3/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class NavigationManager {
    
    var window: UIWindow! {
        didSet {
            navigationController = window.rootViewController! as! UINavigationController
        }
    }
    
    private var navigationController: UINavigationController!
    
    private var storyboard: UIStoryboard {
        return window.rootViewController!.storyboard!
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
    
    func dismissScreenAnimated(animated: Bool) {
        navigationController.dismissViewControllerAnimated(animated, completion: nil)
    }
    
    func showBannerWithText(text: String, duration: NSTimeInterval = 5.0, tapAction: (() -> Void)? = nil) -> BannerView {
        let banner: TextBannerView = TextBannerView.fromNib()
        banner.showInView(window, withText: text, duration: duration, tapAction: tapAction)
        return banner
    }
}
