//
//  StatsView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsView: UIView {
    
    @IBOutlet private(set) weak var statsCollectionView: UICollectionView!
    @IBOutlet private(set) weak var leaderboardsButton: UIButton!
    
    private var statsCollectionLayout: UICollectionViewFlowLayout {
        return statsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        statsCollectionLayout.itemSize.width = statsCollectionView.frame.size.width / CGFloat(1.5)
        statsCollectionLayout.itemSize.height = statsCollectionLayout.itemSize.width / CGFloat(1.8)
        statsCollectionLayout.sectionInset.top = (statsCollectionView.frame.size.height - statsCollectionLayout.itemSize.height) / CGFloat(2.0)
        statsCollectionLayout.sectionInset.bottom = statsCollectionLayout.sectionInset.top
    }
    
    func scrollToNearestStats() {
        let offset = statsCollectionView.contentOffset.x
        let levelDecimalIndex = offset / (statsCollectionLayout.itemSize.width + statsCollectionLayout.minimumInteritemSpacing)
        let levelIndex = Int(roundf(Float(levelDecimalIndex)))
        
        statsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: levelIndex, inSection: 0),
                                                    atScrollPosition: .CenteredHorizontally,
                                                    animated: true)
    }
}
