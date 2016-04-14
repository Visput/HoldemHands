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
    @IBOutlet private(set) weak var contentViewLeadingSpace: NSLayoutConstraint!
    
    var leadingContentSpaceEnabled = true
    
    private var statsCollectionLayout: UICollectionViewFlowLayout {
        return statsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        super.layoutSubviews()
        let spacing: CGFloat = UIScreen.mainScreen().sizeType == .iPhone4 ? 32.0 : 48.0
        let widthRatio: CGFloat = 1.4
        let heightRatio: CGFloat = 2.0
        
        statsCollectionLayout.itemSize.width = floor(frame.size.width / widthRatio)
        statsCollectionLayout.itemSize.height = floor(statsCollectionLayout.itemSize.width / heightRatio)
        
        statsCollectionLayout.sectionInset.top = floor((statsCollectionView.frame.size.height - statsCollectionLayout.itemSize.height) / 2.0)
        statsCollectionLayout.sectionInset.bottom = statsCollectionLayout.sectionInset.top
        
        statsCollectionLayout.minimumLineSpacing = spacing
        statsCollectionLayout.minimumInteritemSpacing = spacing
        
        statsCollectionLayout.sectionInset.right = floor((frame.size.width - statsCollectionLayout.itemSize.width) / 2.0)
        
        if leadingContentSpaceEnabled {
            statsCollectionLayout.sectionInset.left = spacing
            contentViewLeadingSpace.constant = statsCollectionLayout.sectionInset.right - statsCollectionLayout.sectionInset.left
        } else {
            statsCollectionLayout.sectionInset.left = statsCollectionLayout.sectionInset.right
            contentViewLeadingSpace.constant = 0.0
        }
    }
    
    func scrollToNearestStatsAnimated(animated: Bool) {
        let offset = statsCollectionView.contentOffset.x
        let statsDecimalIndex = offset / (statsCollectionLayout.itemSize.width + statsCollectionLayout.minimumInteritemSpacing)
        let statsIndex = Int(round(statsDecimalIndex))
        
        scrollToStatsAtIndex(statsIndex, animated: animated)
    }
    
    func scrollToStatsAtIndex(index: Int, animated: Bool) {
        var targetOffset: CGFloat = 0.0
        if index != 0 {
            targetOffset = statsCollectionLayout.sectionInset.left +
                statsCollectionLayout.minimumInteritemSpacing * CGFloat(index - 1) +
                statsCollectionLayout.itemSize.width * CGFloat(index)
            
            if !leadingContentSpaceEnabled {
                targetOffset -= statsCollectionLayout.sectionInset.left - statsCollectionLayout.minimumInteritemSpacing
            }
        }
        
        statsCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
    }
}
