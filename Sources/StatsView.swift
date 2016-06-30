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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthRatio: CGFloat = 2.0
        
        contentViewLeadingSpace.constant = menuSize.width
        
        let flowLayout = statsCollectionView.flowLayout!
        flowLayout.itemSize.height = floor(menuSize.height)
        flowLayout.itemSize.width = floor(flowLayout.itemSize.height * widthRatio)
        
        flowLayout.sectionInset.top = floor((statsCollectionView.frame.height - flowLayout.itemSize.height) / 2.0)
        flowLayout.sectionInset.bottom = flowLayout.sectionInset.top
        
        flowLayout.sectionInset.right = floor((frame.width - flowLayout.itemSize.width) / 2.0)
        flowLayout.sectionInset.left = flowLayout.sectionInset.right - menuSize.width
        
        let spacing = menuSize.width > 0.0 ? flowLayout.sectionInset.left : flowLayout.sectionInset.left / 2.0
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
    }
    
    func scrollToNearestStatsAnimated(animated: Bool) -> SimpleTask {
        let offset = statsCollectionView.contentOffset.x
        let statsDecimalIndex = offset / (statsCollectionView.flowLayout!.itemSize.width + statsCollectionView.flowLayout!.minimumInteritemSpacing)
        let statsIndex = Int(round(statsDecimalIndex))
        
        return scrollToStatsAtIndex(statsIndex, animated: animated)
    }
    
    func scrollToStatsAtIndex(index: Int, animated: Bool) -> SimpleTask {
        var targetOffset: CGFloat = 0.0
        if index != 0 {
            targetOffset = statsCollectionView.flowLayout!.sectionInset.left +
                statsCollectionView.flowLayout!.minimumInteritemSpacing * CGFloat(index - 1) +
                statsCollectionView.flowLayout!.itemSize.width * CGFloat(index)
            
            if menuSize.width == 0 {
                targetOffset -= statsCollectionView.flowLayout!.sectionInset.left - statsCollectionView.flowLayout!.minimumInteritemSpacing
            }
        }
        
        statsCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
        return SimpleTask.empty()
    }
}
