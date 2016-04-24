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
    @IBOutlet private weak var contentViewLeadingSpace: NSLayoutConstraint!
    
    var menuSize = CGSize(width: 0.0, height: 0.0)
    
    private var statsCollectionLayout: UICollectionViewFlowLayout {
        return statsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthRatio: CGFloat = 2.0
        
        contentViewLeadingSpace.constant = menuSize.width
        
        statsCollectionLayout.itemSize.height = floor(menuSize.height)
        statsCollectionLayout.itemSize.width = floor(statsCollectionLayout.itemSize.height * widthRatio)
        
        statsCollectionLayout.sectionInset.top = floor((statsCollectionView.frame.size.height - statsCollectionLayout.itemSize.height) / 2.0)
        statsCollectionLayout.sectionInset.bottom = statsCollectionLayout.sectionInset.top
        
        statsCollectionLayout.sectionInset.right = floor((frame.size.width - statsCollectionLayout.itemSize.width) / 2.0)
        statsCollectionLayout.sectionInset.left = statsCollectionLayout.sectionInset.right - menuSize.width
        
        let spacing = menuSize.width > 0.0 ? statsCollectionLayout.sectionInset.left : statsCollectionLayout.sectionInset.left / 2.0
        statsCollectionLayout.minimumLineSpacing = spacing
        statsCollectionLayout.minimumInteritemSpacing = spacing
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
            
            if menuSize.width == 0 {
                targetOffset -= statsCollectionLayout.sectionInset.left - statsCollectionLayout.minimumInteritemSpacing
            }
        }
        
        statsCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
    }
}
