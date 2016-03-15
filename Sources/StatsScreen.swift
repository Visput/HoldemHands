//
//  StatsScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsScreen: BaseViewController {
    
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
}

extension StatsScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.playerManager.playerData.levelProgressItems.count + 1 // + 1 for overall progress.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatsCell.className(),
            forIndexPath: indexPath) as! StatsCell
        
        var progressItem: Progress! = nil
        if indexPath.item == 0 {
            progressItem = model.playerManager.playerProgress()
        } else {
            progressItem = model.playerManager.playerData.levelProgressItems[indexPath.item - 1]
        }
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
        statsView.statsCollectionView.reloadData()
    }
}
