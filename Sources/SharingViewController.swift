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
        Analytics.facebookClicked()
        
        let imageURL = NSURL(string: "https://scontent-dfw1-1.xx.fbcdn.net/t31.0-8/13173070_250586265330553_3591325401914814681_o.jpg")
        let item = SharingItem(title: NSLocalizedString("title_app_sharing", comment: ""),
                               message: nil,
                               linkURL: NSURL(string: "https://apple.com"),
                               image: nil,
                               imageURL: imageURL)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(NSLocalizedString("error_share_with_facebook", comment: ""))
        }
        
        model.sharingManager.shareWithFacebook(item, inViewController: self)
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        Analytics.twitterClicked()
        
        let item = SharingItem(title: nil,
                               message: NSLocalizedString("title_app_sharing", comment: ""),
                               linkURL: NSURL(string: "https://apple.com"),
                               image: UIImage(named: "share_screen_twitter"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(NSLocalizedString("error_share_with_twitter", comment: ""))
        }
        
        model.sharingManager.shareWithTwitter(item, inViewController: self)
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        Analytics.instagramClicked()
        
        let item = SharingItem(title: nil,
                               message: NSLocalizedString("title_app_sharing", comment: ""),
                               linkURL: nil,
                               image: UIImage(named: "share_screen_instagram"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(NSLocalizedString("error_share_with_instagram", comment: ""))
        }
        
        model.sharingManager.shareWithInstagram(item, inView: view)
    }
}
