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
    
    func presentGameScreenWithLevel(level: GameLevel, animated: Bool) {
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
}
