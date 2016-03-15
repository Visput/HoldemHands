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
    }
}

extension StatsScreen {
    
    @IBAction private func closeButtonDidPress(sender: AnyObject) {
        model.navigationManager.dismissScreenAnimated(true)
    }
    
    @IBAction private func leaderboardsButtonDidPress(sender: AnyObject) {
        model.navigationManager.presentLeaderboardWithID(nil, animated: true)
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
}

extension StatsScreen: PlayerManagerObserving {
    
    func playerManagerDidAuthenticateNewPlayer(manager: PlayerManager) {
        fillViewsWithModel()
    }
}

extension StatsScreen {
    
    private func fillViewsWithModel() {
        progressItems = model.playerManager.progressItems()
        statsView.statsCollectionView.reloadData()
        statsView.leaderboardsButton.hidden = !model.playerManager.authenticated
    }
}
