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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GameLevelCell.className(),
            forIndexPath: indexPath) as! GameLevelCell
        
        let level = model.levelsProvider.levels[indexPath.item]
        let item = GameLevelCellItem(level: level,
            locked: model.playerManager.isLockedLevel(level),
            canUnlock: model.playerManager.canUnlockLevel(level),
            buttonsTag: indexPath.item)
        cell.fillWithItem(item)
        cell.playButton.addTarget(self, action: Selector("startLevelButtonDidPress:"), forControlEvents: .TouchUpInside)
        cell.unlockButton.addTarget(self, action: Selector("unlockLevelButtonDidPress:"), forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = mainView.levelsCollectionView.cellForItemAtIndexPath(indexPath) as! GameLevelCell
        startLevelButtonDidPress(cell.playButton)
    }
}

extension MainScreen {
    
    @objc private func startLevelButtonDidPress(sender: UIButton) {
        let cell = mainView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! GameLevelCell
        if !cell.item.locked {
            model.navigationManager.presentGameScreenWithLevel(cell.item.level, animated: true)
        }
    }
    
    @objc private func unlockLevelButtonDidPress(sender: UIButton) {
        let cell = mainView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! GameLevelCell
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
        
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        
    }
}

extension MainScreen {
    
    private func fillViewsWithModel() {
        mainView.levelsCollectionView.reloadData()
        mainView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %.0f", comment: ""),
            model.playerManager.player.chipsCount) as String
    }
}
