//
//  PlayerDataSynchronizer.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/30/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class PlayerDataSynchronizer {
    
    let loadHandler: () -> Void
    let saveHandler: () -> Void
    
    private var autoSaveTimer: NSTimer?
    private let autoSaveTimerInterval = 120.0 // Secs.
    
    init(loadHandler: () -> Void, saveHandler: () -> Void) {
        self.loadHandler = loadHandler
        self.saveHandler = saveHandler
        registerForAppLifeCycleNotifications()
    }
    
    deinit {
        unregisterFromAppLifeCycleNotifications()
    }
}

extension PlayerDataSynchronizer {
    
    private func startAutoSaveTimer() {
        stopAutoSaveTimer()
        autoSaveTimer = NSTimer.scheduledTimerWithTimeInterval(autoSaveTimerInterval,
                                                               target: self,
                                                               selector: #selector(PlayerDataSynchronizer.autoSaveTimerDidFire),
                                                               userInfo: nil,
                                                               repeats: true)
    }
    
    private func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
    }
    
    @objc private func autoSaveTimerDidFire() {
        saveHandler()
    }
}

extension PlayerDataSynchronizer {
    
    private func registerForAppLifeCycleNotifications() {
        unregisterFromAppLifeCycleNotifications()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                       selector: #selector(PlayerDataSynchronizer.appWillResignActive(_:)),
                                       name: UIApplicationWillResignActiveNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(PlayerDataSynchronizer.appDidBecomeActive(_:)),
                                       name: UIApplicationDidBecomeActiveNotification,
                                       object: nil)
    }
    
    private func unregisterFromAppLifeCycleNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func appWillResignActive(notification: NSNotification) {
        saveHandler()
        stopAutoSaveTimer()
    }
    
    @objc private func appDidBecomeActive(notification: NSNotification) {
        loadHandler()
        startAutoSaveTimer()
    }
}
