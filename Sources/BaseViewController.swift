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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidShow()
        self.registerForAppLifeCycleNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.unregisterFromAppLifeCycleNotifications()
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
        viewDidShow()
    }
    
    @objc private func appDidBecomeActive(notification: NSNotification) {
        viewDidHide()
    }
}
