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
        model.navigationManager.dismissScreenAnimated(true)
    }
    
    @objc private func leaderboardButtonDidPress(sender: UIButton) {
        let progressItem = progressItems[sender.tag]
        model.navigationManager.presentLeaderboardWithID(progressItem.leaderboardID, animated: true)
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
        let item = StatsCellItem(progressItem: progressItem, index: indexPath.item, playerAuthenticated: model.playerManager.authenticated)
        cell.fillWithItem(item)
        cell.leaderboardButton.addTarget(self, action: Selector("leaderboardButtonDidPress:"), forControlEvents: .TouchUpInside)
        
        return cell
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
        
        model.playerManager.loadProgressItemsIncludingRank({ progressItems, error in
            guard error == nil else { return }
            self.progressItems = progressItems
            self.statsView.statsCollectionView.reloadData()
        })
    }
}
