//
//  SharingViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class SharingViewController: BaseViewController {
    
    var appLink: (short: NSURL, full: NSURL) {
        let shortUrl = NSURL(string: NSBundle.mainBundle().objectForInfoDictionaryKey("AppShortURL") as! String)!
        let fullUrl = NSURL(string: NSBundle.mainBundle().objectForInfoDictionaryKey("AppFullURL") as! String)!
        
        return (short: shortUrl, full: fullUrl)
    }
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        Analytics.facebookClicked()
        
        let imageURL = NSURL(string: "https://scontent-dfw1-1.xx.fbcdn.net/t31.0-8/13198627_1261277187234266_633424816393798658_o.jpg")
        let item = SharingItem(title: R.string.localizable.appName(),
                               message: R.string.localizable.titleSharingFacebook(),
                               linkURL: appLink.full,
                               image: nil,
                               imageURL: imageURL)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(R.string.localizable.errorShareWithFacebook())
        }
        
        model.sharingManager.shareWithFacebook(item, inViewController: self)
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        Analytics.twitterClicked()
        
        let item = SharingItem(title: nil,
                               message: R.string.localizable.titleSharingTwitter(),
                               linkURL: appLink.short,
                               image: UIImage(named: "share_screen_twitter"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(R.string.localizable.errorShareWithTwitter())
        }
        
        model.sharingManager.shareWithTwitter(item, inViewController: self)
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        Analytics.instagramClicked()
        
        let item = SharingItem(title: nil,
                               message: R.string.localizable.titleSharingInstagram(),
                               linkURL: nil,
                               image: UIImage(named: "share_screen_instagram"),
                               imageURL: nil)
        
        model.sharingManager.didFailToShareHandler = { [weak self] _ in
            self?.model.navigationManager.presentBannerWithText(R.string.localizable.errorShareWithInstagram())
        }
        
        model.sharingManager.shareWithInstagram(item, inView: view)
    }
}
