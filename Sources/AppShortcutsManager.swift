//
//  AppShortcutsManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 10/27/15.
//  Copyright © 2015 visput. All rights reserved.
//

import UIKit

final class AppShortcutsManager {
    
    private let navigationManager: NavigationManager
    private let playerManager: PlayerManager
    private let shortcutTypeStats = "StatsShortcut"
    
    private var launchedShortcut: AnyObject?
    
    required init(navigationManager: NavigationManager, playerManager: PlayerManager) {
        self.navigationManager = navigationManager
        self.playerManager = playerManager
        self.playerManager.observers.addObserver(self)
        updateShortcuts()
    }
    
    func handleShortcutInAppLaunchOptions(launchOptions: [NSObject: AnyObject]?) -> Bool {
        if #available(iOS 9, *) {
            guard let shortcut = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem else { return false }
            launchedShortcut = shortcut
            return true
        } else {
            return false
        }
    }
    
    func performActionForLaunchedShortcutIfNeeded() {
        if #available(iOS 9, *) {
            guard launchedShortcut != nil else { return }
            performActionForShortcut(launchedShortcut! as! UIApplicationShortcutItem)
            launchedShortcut = nil
        }
    }
    
    @available(iOS 9.0, *)
    func performActionForShortcut(shortcut: UIApplicationShortcutItem) -> Bool {
        if shortcut.type == shortcutTypeStats {
            performActionForStatsShortcut(shortcut)
        } else {
            performActionForLevelShortcut(shortcut)
        }
            
        return true
    }
}

extension AppShortcutsManager {
    
    private func updateShortcuts() {
        if #available(iOS 9, *) {
            let level = playerManager.playerData.lastPlayedLevel() ?? playerManager.playerData.firstLevel()
            let levelShortcut = UIApplicationShortcutItem(type: String(level.identifier),
                                                          localizedTitle: level.name,
                                                          localizedSubtitle: nil,
                                                          icon: nil,
                                                          userInfo: nil)
            
            let statsShortcut = UIApplicationShortcutItem(type: shortcutTypeStats,
                                                          localizedTitle: R.string.localizable.titleDetailsStats(),
                                                          localizedSubtitle: nil,
                                                          icon: nil,
                                                          userInfo: nil)
            
            UIApplication.sharedApplication().shortcutItems = [levelShortcut, statsShortcut]
        }
    }
    
    @available(iOS 9.0, *)
    private func performActionForLevelShortcut(shortcut: UIApplicationShortcutItem) {
        
    }
    
    @available(iOS 9.0, *)
    private func performActionForStatsShortcut(shortcut: UIApplicationShortcutItem) {
        
    }
}

extension AppShortcutsManager: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUpdateLastPlayedLevel level: Level) {
        updateShortcuts()
    }
}
