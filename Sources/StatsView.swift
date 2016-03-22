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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let collectionViewLayout = statsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.itemSize.width = statsCollectionView.frame.size.width / CGFloat(1.5)
        collectionViewLayout.itemSize.height = collectionViewLayout.itemSize.width / CGFloat(1.8)
        collectionViewLayout.sectionInset.top = (statsCollectionView.frame.size.height - collectionViewLayout.itemSize.height) / CGFloat(2.0)
        collectionViewLayout.sectionInset.bottom = collectionViewLayout.sectionInset.top
    }
}
