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
        
        super.layoutSubviews()
        let spacing: CGFloat = UIScreen.mainScreen().sizeType == .iPhone4 ? 32.0 : 48.0
        let widthRatio: CGFloat = 1.4
        let heightRatio: CGFloat = 2.0
        
        statsCollectionLayout.itemSize.width = floor(statsCollectionView.frame.size.width / widthRatio)
        statsCollectionLayout.itemSize.height = floor(statsCollectionLayout.itemSize.width / heightRatio)
        
        statsCollectionLayout.sectionInset.top = floor((statsCollectionView.frame.size.height -
            statsCollectionLayout.itemSize.height) / 2.0)
        statsCollectionLayout.sectionInset.bottom = statsCollectionLayout.sectionInset.top
        
        statsCollectionLayout.sectionInset.left = floor((statsCollectionView.frame.size.width -
            statsCollectionLayout.itemSize.width) / 2.0)
        statsCollectionLayout.sectionInset.right = statsCollectionLayout.sectionInset.left
        
        statsCollectionLayout.minimumLineSpacing = spacing
        statsCollectionLayout.minimumInteritemSpacing = spacing
    }
    
    func scrollToNearestStats() {
        let offset = statsCollectionView.contentOffset.x
        let statDecimalIndex = offset / (statsCollectionLayout.itemSize.width + statsCollectionLayout.minimumInteritemSpacing)
        let statIndex = Int(round(statDecimalIndex))
        
        statsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: statIndex, inSection: 0),
                                                    atScrollPosition: .CenteredHorizontally,
                                                    animated: true)
    }
}
