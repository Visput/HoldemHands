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
    
    func scrollToOverallStatsAnimated(animated: Bool) {
        statsView.statsCollectionView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: animated)
    }
}

extension StatsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progressItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatsCell.className(),
                                                                         forIndexPath: indexPath) as! StatsCell
        
        let progressItem: Progress = progressItems[indexPath.item]
        let item = StatsCellItem(progressItem: progressItem)
        cell.fillWithItem(item)
        
        return cell
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
        progressItems = model.playerManager.progressItems()
        
        statsView.statsCollectionView.reloadData()
        
        guard level != nil else { return }
        // Execute scrolling after short delay to be sure that collection view layout is configured.
        executeAfterDelay(0.05, task: {
            let statsIndex = self.model.playerManager.progressItemForLevel(self.level!).index + 1 // + 1 for overall progress item.
            self.statsView.scrollToStatsAtIndex(statsIndex, animated: false)
        })
    }
}
