//
//  StatsScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsScreen: BaseViewController {
    
    private var progressItems: [Progress]!
    
    private var statsView: StatsView {
        return view as! StatsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.playerManager.observers.addObserver(self)
        fillViewsWithModel()
    }
}

extension StatsScreen {
    
    @IBAction private func closeButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInStats()
        model.navigationManager.dismissScreenAnimated(true)
    }
    
    @IBAction private func leaderboardsButtonDidPress(sender: UIButton) {
        let leaderboardID = model.playerManager.playerData.overallLeaderboardID
        Analytics.leaderboardClickedInStats(leaderboardID)
        model.navigationManager.presentLeaderboardScreenWithLeaderboardID(leaderboardID, animated: true)
    }
}

extension StatsScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
        let leaderboardID = cell.item.progressItem.leaderboardID
        Analytics.leaderboardClickedInStats(leaderboardID)
        model.navigationManager.presentLeaderboardScreenWithLeaderboardID(leaderboardID, animated: true)
    }
}

extension StatsScreen: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        fillViewsWithModel()
    }
}

extension StatsScreen {
    
    private func fillViewsWithModel() {
        progressItems = model.playerManager.progressItems()
        statsView.statsCollectionView.reloadData()
        statsView.leaderboardsButton.hidden = !model.playerManager.authenticated
        
        model.playerManager.loadProgressItemsIncludingRank({ progressItems, error in
            guard error == nil else { return }
            self.progressItems = progressItems
            self.statsView.statsCollectionView.reloadData()
        })
    }
}

extension StatsScreen {
    
    override func viewDidShow() {
        super.viewDidShow()
        Analytics.statsAppeared()
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        Analytics.statsDisappeared()
    }
}
