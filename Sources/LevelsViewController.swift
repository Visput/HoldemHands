//
//  LevelsViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class LevelsViewController: BaseViewController {
    
    private var levelsView: LevelsView {
        return view as! LevelsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.playerManager.observers.addObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fillViewsWithModelWithScrollingToLastPlayedLevel(false)
        levelsView.zoomOutLevelIfNeeded(model.navigationManager.mainScreen.view)
    }
    
    func scrollToLevelAtIndex(index: Int, animated: Bool) {
        levelsView.scrollToLevelAtIndex(index, animated: animated)
    }
}

extension LevelsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.playerManager.playerData.levelProgressItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.levelCell, forIndexPath: indexPath)!
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let levelProgress = model.playerManager.playerData.levelProgressItems[indexPath.item]
        let item = LevelCellItem(levelProgress: levelProgress, buttonsTag: indexPath.item)
        let levelCell = cell as! LevelCell
        levelCell.fillWithItem(item)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = levelsView.levelsCollectionView.cellForItemAtIndexPath(indexPath) as! LevelCell
        Analytics.levelClickedInMainScreen(cell.item.levelProgress)
        
        if cell.item.levelProgress.locked! {
            let level = cell.item.levelProgress.level
            let chipsToUnlock = model.playerManager.chipsToUnlockLevel(level).formattedChipsCountString(needsReplaceZerosWithO: false)
            let text = R.string.localizable.bannerChipsToUnlockLevel(chipsToUnlock, level.name)
            model.navigationManager.presentBannerWithText(text)
            
            levelsView.scrollToLevelAtIndex(indexPath.item, animated: true)
        } else {
            levelsView.zoomInLevelAtIndex(indexPath.item, mainView: model.navigationManager.mainScreen.view, completionHandler: {
                self.model.navigationManager.presentGameScreenWithLevel(cell.item.levelProgress.level, animated: true)
            })
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        levelsView.scrollToNearestLevelAnimated(true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        levelsView.scrollToNearestLevelAnimated(true)
    }
}

extension LevelsViewController: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        fillViewsWithModelWithScrollingToLastPlayedLevel(true)
    }
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress) {
        let levelIndex = manager.progressItemForLevel(levelProgress.level).index
        levelsView.levelsCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: levelIndex, inSection: 0)])
    }
}

extension LevelsViewController {
    
    private static var autoScrollingEnabled = true
    
    private func fillViewsWithModelWithScrollingToLastPlayedLevel(scrollToLastPlayedLevel: Bool) {
        levelsView.levelsCollectionView.reloadData()
        
        guard LevelsViewController.autoScrollingEnabled &&
            scrollToLastPlayedLevel &&
            model.playerManager.playerData.lastPlayedLevelID != nil else { return }
        
        // Auto scrolling needed only for the first time.
        LevelsViewController.autoScrollingEnabled = false
        
        // Execute scrolling after short delay to be sure that collection view layout is configured.
        executeAfterDelay(0.05, task: {
            for (index, levelProgress) in self.model.playerManager.playerData.levelProgressItems.enumerate() {
                guard levelProgress.levelID == self.model.playerManager.playerData.lastPlayedLevelID else { continue }
                
                self.levelsView.scrollToLevelAtIndex(index, animated: false)
                break
            }
        })
    }
}
