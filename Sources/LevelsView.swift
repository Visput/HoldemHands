//
//  LevelsView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class LevelsView: UIView {
 
    @IBOutlet private(set) weak var levelsCollectionView: UICollectionView!
    @IBOutlet private weak var contentViewLeadingSpace: NSLayoutConstraint!
    
    var menuSize = CGSize(width: 0.0, height: 0.0)
    
    private var zoomApplied = false
    private let zoomLevel: CGFloat = 3.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthRatio: CGFloat = 2.0
        
        contentViewLeadingSpace.constant = menuSize.width
        
        let flowLayout = levelsCollectionView.flowLayout!
        flowLayout.itemSize.height = floor(menuSize.height)
        flowLayout.itemSize.width = floor(flowLayout.itemSize.height * widthRatio)
        
        flowLayout.sectionInset.top = floor((levelsCollectionView.frame.height - flowLayout.itemSize.height) / 2.0)
        flowLayout.sectionInset.bottom = flowLayout.sectionInset.top
        
        flowLayout.sectionInset.right = floor((frame.width - flowLayout.itemSize.width) / 2.0)
        flowLayout.sectionInset.left = flowLayout.sectionInset.right - menuSize.width
        
        flowLayout.minimumLineSpacing = flowLayout.sectionInset.left
        flowLayout.minimumInteritemSpacing = flowLayout.sectionInset.left
    }
    
    func scrollToNearestLevelAnimated(animated: Bool) {
        let offset = levelsCollectionView.contentOffset.x
        let levelDecimalIndex = offset / (levelsCollectionView.flowLayout!.itemSize.width + levelsCollectionView.flowLayout!.minimumInteritemSpacing)
        let levelIndex = Int(round(levelDecimalIndex))
        
        scrollToLevelAtIndex(levelIndex, animated: animated)
    }
    
    func scrollToLevelAtIndex(index: Int, animated: Bool) {
        var targetOffset: CGFloat = 0.0
        if index != 0 {
            targetOffset = levelsCollectionView.flowLayout!.sectionInset.left +
                levelsCollectionView.flowLayout!.minimumInteritemSpacing * CGFloat(index - 1) +
                levelsCollectionView.flowLayout!.itemSize.width * CGFloat(index)
        }
        
        levelsCollectionView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: animated)
        
        // Call `layoutIfNeeded` to avoid immediate cell hiding (UICollectionView behaviour).
        self.levelsCollectionView.layoutIfNeeded()
    }
    
    func zoomInLevelAtIndex(index: Int, mainView: UIView, animated: Bool, completionHandler: (() -> Void)? = nil) {
        zoomApplied = true
        
        let animationDuration = animated ? 0.4 : 0.0
        UIView.animateWithDuration(animationDuration, animations: {
            self.scrollToLevelAtIndex(index, animated: false)
            
            }, completion: { _ in
                // Call completion block before animation finished for smoother animation.
                self.executeAfterDelay(0.2, task: {
                    completionHandler?()
                })
                
                UIView.animateWithDuration(0.5, animations: {
                    mainView.transform = CGAffineTransformMakeScale(self.zoomLevel, self.zoomLevel)
                    }, completion: { _ in
                        // Reset transform after delay when game screen is presented and levels are not visible.
                        // It's needed to avoid issues with constraints when app goes to background and then back
                        // to foreground while transform is applied.
                        self.executeAfterDelay(0.5, task: {
                            mainView.transform = CGAffineTransformIdentity
                        })
                })
        })
    }
    
    func zoomOutLevelIfNeeded(mainView: UIView, animated: Bool) {
        guard zoomApplied else {
            mainView.transform = CGAffineTransformIdentity
            return
        }
        
        if animated {
            // Apply scale transform before animation started.
            // It's needed because transform was reseted when `zoom in` operation completed.
            mainView.transform = CGAffineTransformMakeScale(zoomLevel, zoomLevel)
            
            UIView.animateWithDuration(0.4, animations: {
                mainView.transform = CGAffineTransformIdentity
                
                }, completion: { _ in
                    self.zoomApplied = false
            })
        } else {
            mainView.transform = CGAffineTransformIdentity
        }
    }
}
