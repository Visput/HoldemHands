//
//  MenuScreen.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MenuScreen: BaseScreen {

    private var menuView: MenuView {
        return view as! MenuView
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
            unlocked: model.playerManager.isUnlockedLevel(level),
            buttonsTag: indexPath.item)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = menuView.levelsCollectionView.cellForItemAtIndexPath(indexPath) as! GameLevelCell
        playButtonDidPress(cell.playButton)
    }
}

extension MenuScreen {
    
    @objc private func playButtonDidPress(sender: UIButton) {
        let cell = menuView.levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(index: sender.tag)) as! GameLevelCell
        if cell.item.unlocked {
            model.navigationManager.presentGameScreenWithLevel(cell.item.level, animated: true)
        }
    }
    
    @IBAction private func facebookButtonDidPress(sender: AnyObject) {
        
    }
    
    @IBAction private func twitterButtonDidPress(sender: AnyObject) {
        
    }
    
    @IBAction private func instagramButtonDidPress(sender: AnyObject) {
        
    }
}
