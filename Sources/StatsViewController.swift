//
//  StatsViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsViewController: BaseViewController {
    
    var level: Level?
    
    private var progressItems: [Progress]!
    
    var statsView: StatsView {
        return view as! StatsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.playerManager.observers.addObserver(self)
        fillViewsWithModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fillViewsWithModel()
    }
    
    func reloadRanks() {
        model.playerManager.loadProgressItemsIncludingRank({ progressItems, error in
            guard error == nil else { return }
            
            self.progressItems = progressItems
            let cells = self.statsView.statsCollectionView.visibleCells() as! [StatsCell]
            for cell in cells {
                let index = self.statsView.statsCollectionView.indexPathForCell(cell)!.item
                let progressItem: Progress = progressItems![index]
                let item = StatsCellItem(progressItem: progressItem)
                cell.fillWithItem(item)
            }
        })
    }
    
    func scrollToOverallStatsAnimated(animated: Bool) -> SimpleTask {
        statsView.statsCollectionView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: animated)
        return SimpleTask.empty()
    }
}

extension StatsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progressItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.statsCell, forIndexPath: indexPath)!
        
        let progressItem = progressItems[indexPath.item]
        let item = StatsCellItem(progressItem: progressItem)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // Load images in `willDisplayCell` to make animation smoother.
        (cell as! StatsCell).loadImages()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! StatsCell!
        Analytics.statsItemClicked(cell.item.progressItem)
        
        let leaderboardID = cell.item.progressItem.leaderboardID
        model.navigationManager.presentLeaderboardScreenWithLeaderboardID(leaderboardID, animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        statsView.scrollToNearestStatsAnimated(true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        statsView.scrollToNearestStatsAnimated(true)
    }
}

extension StatsViewController: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        fillViewsWithModel()
    }
}

extension StatsViewController {
    
    private func fillViewsWithModel() {
        progressItems = model.playerManager.playerData.progressItems()
        
        statsView.statsCollectionView.reloadDataTask().thenDo {
            guard self.level != nil else { return }
            
            let statsIndex = self.model.playerManager.playerData.progressForLevel(self.level!).index + 1 // + 1 for overall progress item.
            self.statsView.scrollToStatsAtIndex(statsIndex, animated: false)
        }
    }
}
