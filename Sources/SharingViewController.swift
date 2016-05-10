//
//  SharingViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class SharingViewController: BaseViewController {
    
    var appLink: NSURL {
        return NSURL(string: NSBundle.mainBundle().objectForInfoDictionaryKey("AppURL") as! String)!
    }
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        Analytics.facebookClicked()
        
        let imageURL = NSURL(string: "https://scontent-dfw1-1.xx.fbcdn.net/t31.0-8/13198627_1261277187234266_633424816393798658_o.jpg")
        let item = SharingItem(title: NSLocalizedString("title_sharing_facebook", comment: ""),
                               message: nil,
                               linkURL: appLink,
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
                               message: NSLocalizedString("title_sharing_twitter", comment: ""),
                               linkURL: appLink,
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
                               message: NSLocalizedString("title_sharing_instagram", comment: ""),
                               linkURL: nil,
                               image: UIImage(named: "share_screen_instagram"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(NSLocalizedString("error_share_with_instagram", comment: ""))
        }
        
        model.sharingManager.shareWithInstagram(item, inView: view)
    }
}
