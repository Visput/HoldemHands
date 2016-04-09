//
//  SharingViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class SharingViewController: BaseViewController {
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        Analytics.facebookClickedInMenu()
        let item = SharingItem(title: NSLocalizedString("HoldemHands", comment: ""),
                               message: NSLocalizedString("Check this out", comment: ""),
                               linkURL: NSURL(string: "https://apple.com"),
                               image: nil,
                               imageURL: NSURL(string: "https://d13yacurqjgara.cloudfront.net/users/3511/screenshots/827275/prvw.jpg"))
        
        model.sharingManager.didFailToShareHandler = { [unowned self] _ in
            self.model.navigationManager.showBannerWithText(NSLocalizedString("Unable to locate your \"Facebook\" account", comment: ""))
        }
        
        model.sharingManager.shareWithFacebook(item, inViewController: self)
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        Analytics.twitterClickedInMenu()
        let item = SharingItem(title: nil,
                               message: NSLocalizedString("Check this out: HoldemHands", comment: ""),
                               linkURL: NSURL(string: "https://apple.com"),
                               image: UIImage(named: "test.jpg"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [unowned self] _ in
            self.model.navigationManager.showBannerWithText(NSLocalizedString("Unable to locate your \"Twitter\" account", comment: ""))
        }
        
        model.sharingManager.shareWithTwitter(item, inViewController: self)
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        Analytics.instagramClickedInMenu()
        let item = SharingItem(title: nil,
                               message: NSLocalizedString("Check this out: #HoldemHands", comment: ""),
                               linkURL: nil,
                               image: UIImage(named: "test.jpg"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [unowned self] _ in
            self.model.navigationManager.showBannerWithText(NSLocalizedString("Unable to locate your \"Instagram\" account", comment: ""))
        }
        
        model.sharingManager.shareWithInstagram(item, inView: view)
    }
}
