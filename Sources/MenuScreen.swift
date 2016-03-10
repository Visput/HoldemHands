//
//  MenuScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MenuScreen: BaseScreen {

    private var menuView: MenuView {
        return view as! MenuView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        menuView.levelsCollectionView.reloadData()
    }
}

extension MenuScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
        let cell = menuView.levelsCollectionView.cellForItemAtIndexPath(indexPath) as! GameLevelCell
        startLevelButtonDidPress(cell.playButton)
    }
}

extension MenuScreen {
    
    @objc private func startLevelButtonDidPress(sender: UIButton) {
        let cell = menuView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! GameLevelCell
        if !cell.item.locked {
            model.navigationManager.presentGameScreenWithLevel(cell.item.level, animated: true)
        }
    }
    
    @objc private func unlockLevelButtonDidPress(sender: UIButton) {
        let cell = menuView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! GameLevelCell
        model.playerManager.unlockLevel(cell.item.level)
        menuView.levelsCollectionView.reloadData()
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        menuView.scrollToMenuView()
    }
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        menuView.scrollToLevelsView()
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        
    }
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        
    }
}
