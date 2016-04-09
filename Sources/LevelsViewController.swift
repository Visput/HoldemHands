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
        fillViewsWithModel()
    }
}

extension LevelsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.playerManager.playerData.levelProgressItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LevelCell.className(),
                                                                         forIndexPath: indexPath) as! LevelCell
        
        let levelProgress = model.playerManager.playerData.levelProgressItems[indexPath.item]
        let item = LevelCellItem(levelProgress: levelProgress, buttonsTag: indexPath.item)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = levelsView.levelsCollectionView.cellForItemAtIndexPath(indexPath) as! LevelCell
        Analytics.levelClickedInLevels(cell.item.levelProgress)
        if !cell.item.levelProgress.locked {
            model.navigationManager.presentGameScreenWithLevel(cell.item.levelProgress.level, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        levelsView.scrollToNearestLevel()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        levelsView.scrollToNearestLevel()
    }
}

extension LevelsViewController: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        fillViewsWithModel()
    }
}

extension LevelsViewController {
    
    private func fillViewsWithModel() {
        levelsView.levelsCollectionView.reloadData()
    }
}
