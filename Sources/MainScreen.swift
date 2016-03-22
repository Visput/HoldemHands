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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.playerManager.observers.addObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fillViewsWithModel()
    }
}

extension MainScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.playerManager.playerData.levelProgressItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LevelCell.className(),
            forIndexPath: indexPath) as! LevelCell
        
        let levelProgress = model.playerManager.playerData.levelProgressItems[indexPath.item]
        let item = LevelCellItem(levelProgress: levelProgress, buttonsTag: indexPath.item)
        cell.fillWithItem(item)
        cell.playButton.addTarget(self, action: #selector(MainScreen.startLevelButtonDidPress(_:)), forControlEvents: .TouchUpInside)
        
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
        Analytics.levelClickedInLevels(cell.item.levelProgress)
        if !cell.item.levelProgress.locked {
            model.navigationManager.presentGameScreenWithLevel(cell.item.levelProgress.level, animated: true)
        }
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        Analytics.menuClickedInLevels()
        mainView.scrollToMenuView()
    }
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        Analytics.playClickedInMenu()
        mainView.scrollToLevelsView()
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClickedInMenu()
        model.navigationManager.presentStatsScreenAnimated(true)
    }
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        Analytics.facebookClickedInMenu()
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
        Analytics.twitterClickedInMenu()
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
        Analytics.instagramClickedInMenu()
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

extension MainScreen: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        fillViewsWithModel()
    }
}

extension MainScreen {
    
    private func fillViewsWithModel() {
        mainView.levelsCollectionView.reloadData()
        mainView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %@", comment: ""),
            model.playerManager.playerData.chipsCount.formattedChipsCountString) as String
    }
}

extension MainScreen {
    
    override func viewDidShow() {
        super.viewDidShow()
        if mainView.isMenuShown {
            Analytics.menuAppeared()
        } else {
            Analytics.levelsAppeared()
        }
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        if mainView.isMenuShown {
            Analytics.menuDisappeared()
        } else {
            Analytics.levelsDisappeared()
        }
    }
}
