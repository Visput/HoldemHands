//
//  BaseViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    let model = ModelProvider.provider
    
    var isViewDisplayed: Bool {
        get {
            return isViewLoaded() && view.window != nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidShow()
        registerForAppLifeCycleNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unregisterFromAppLifeCycleNotifications()
        viewDidHide()
        super.viewWillDisappear(animated)
    }
    
    func viewDidShow() {
        // Implement in subclasses.
    }
    
    func viewDidHide() {
        // Implement in subclasses.
    }
}

extension BaseViewController {
    
    private func registerForAppLifeCycleNotifications() {
        unregisterFromAppLifeCycleNotifications()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
                                       selector: #selector(BaseViewController.appWillResignActive(_:)),
                                       name: UIApplicationWillResignActiveNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(BaseViewController.appDidBecomeActive(_:)),
                                       name: UIApplicationDidBecomeActiveNotification,
                                       object: nil)
    }
    
    private func unregisterFromAppLifeCycleNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func appWillResignActive(notification: NSNotification) {
        viewDidHide()
    }
    
    @objc private func appDidBecomeActive(notification: NSNotification) {
        viewDidShow()
    }
}
