//
//  AppDelegate.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var model: ModelProvider!

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        R.assertValid()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Analytics.startSession()
        
        model = ModelProvider.provider
        model.navigationManager.window = window
        model.navigationManager.setMainScreenAsRootAnimated(false)
        
        return !model.appShortcutsManager.handleShortcutInAppLaunchOptions(launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
        Analytics.appDidBecomeActive()
        model.appShortcutsManager.performActionForLaunchedShortcutIfNeeded()
    }

    func applicationWillTerminate(application: UIApplication) {

    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication,
                     performActionForShortcutItem shortcutItem: UIApplicationShortcutItem,
                     completionHandler: Bool -> Void) {
        
        let handled = model.appShortcutsManager.performActionForShortcut(shortcutItem)
        completionHandler(handled)
    }
}
