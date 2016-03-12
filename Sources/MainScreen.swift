//
//  MainScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreen: BaseViewController {

    private var mainView: MainView {
        return view as! MainView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fillViewsWithModel()
    }
}

extension MainScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.levelsProvider.levels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LevelCell.className(),
            forIndexPath: indexPath) as! LevelCell
        
        let level = model.levelsProvider.levels[indexPath.item]
        let item = LevelCellItem(level: level,
            locked: model.playerManager.isLockedLevel(level),
            canUnlock: model.playerManager.canUnlockLevel(level),
            buttonsTag: indexPath.item)
        cell.fillWithItem(item)
        cell.playButton.addTarget(self, action: Selector("startLevelButtonDidPress:"), forControlEvents: .TouchUpInside)
        cell.unlockButton.addTarget(self, action: Selector("unlockLevelButtonDidPress:"), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = mainView.levelsCollectionView.cellForItemAtIndexPath(indexPath) as! LevelCell
        startLevelButtonDidPress(cell.playButton)
    }
}

extension MainScreen {
    
    @objc private func startLevelButtonDidPress(sender: UIButton) {
        let cell = mainView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! LevelCell
        if !cell.item.locked {
            model.navigationManager.presentGameScreenWithLevel(cell.item.level, animated: true)
        }
    }
    
    @objc private func unlockLevelButtonDidPress(sender: UIButton) {
        let cell = mainView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! LevelCell
        model.playerManager.unlockLevel(cell.item.level)
        mainView.levelsCollectionView.reloadData()
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        mainView.scrollToMainView()
    }
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        mainView.scrollToLevelsView()
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        model.navigationManager.presentStatsScreenAnimated(true)
    }
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        let item = SharingItem(title: NSLocalizedString("HoldemHands", comment: ""),
            message: NSLocalizedString("Check this out", comment: ""),
            linkURL: NSURL(string: "https://apple.com"),
            image: nil,
            imageURL: NSURL(string: "https://d13yacurqjgara.cloudfront.net/users/3511/screenshots/827275/prvw.jpg"))
        
        model.sharingManager.didFailToShareAction = { [unowned self] _ in
            self.model.navigationManager.showBannerWithText(NSLocalizedString("Unable to locate your \"Facebook\" account", comment: ""))
        }
        
        model.sharingManager.shareWithFacebook(item, inViewController: self)
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        let item = SharingItem(title: nil,
            message: NSLocalizedString("Check this out: HoldemHands", comment: ""),
            linkURL: NSURL(string: "https://apple.com"),
            image: UIImage(named: "test.jpg"),
            imageURL: nil)
        
        model.sharingManager.didFailToShareAction = { [unowned self] _ in
            self.model.navigationManager.showBannerWithText(NSLocalizedString("Unable to locate your \"Twitter\" account", comment: ""))
        }
        
        model.sharingManager.shareWithTwitter(item, inViewController: self)
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        let item = SharingItem(title: nil,
            message: NSLocalizedString("Check this out: #HoldemHands", comment: ""),
            linkURL: nil,
            image: UIImage(named: "test.jpg"),
            imageURL: nil)
        
        model.sharingManager.didFailToShareAction = { [unowned self] _ in
            self.model.navigationManager.showBannerWithText(NSLocalizedString("Unable to locate your \"Instagram\" account", comment: ""))
        }
        
        model.sharingManager.shareWithInstagram(item, inView: mainView)
    }
}

extension MainScreen {
    
    private func fillViewsWithModel() {
        mainView.levelsCollectionView.reloadData()
        mainView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %.0f", comment: ""),
            model.playerManager.player.chipsCount) as String
    }
}
