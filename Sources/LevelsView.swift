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
    
    var levelsCollectionLayout: UICollectionViewFlowLayout {
        return levelsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var zoomedCell: LevelCell?
    private let zoomLevel: CGFloat = 3.0
    
    private var currentLevelIndex: Int {
        let offset = levelsCollectionView.contentOffset.x
        let levelDecimalIndex = offset / (levelsCollectionLayout.itemSize.width + levelsCollectionLayout.minimumInteritemSpacing)
        let levelIndex = Int(round(levelDecimalIndex))
        
        return levelIndex
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing: CGFloat = UIScreen.mainScreen().sizeType == .iPhone4 ? 32.0 : 48.0
        let widthRatio: CGFloat = 1.4
        let heightRatio: CGFloat = 2.0
        
        levelsCollectionLayout.itemSize.width = floor(levelsCollectionView.frame.size.width / widthRatio)
        levelsCollectionLayout.itemSize.height = floor(levelsCollectionLayout.itemSize.width / heightRatio)
        
        levelsCollectionLayout.sectionInset.top = floor((levelsCollectionView.frame.size.height -
            levelsCollectionLayout.itemSize.height) / 2.0)
        levelsCollectionLayout.sectionInset.bottom = levelsCollectionLayout.sectionInset.top
        
        levelsCollectionLayout.sectionInset.left = floor((levelsCollectionView.frame.size.width -
            levelsCollectionLayout.itemSize.width) / 2.0)
        levelsCollectionLayout.sectionInset.right = levelsCollectionLayout.sectionInset.left
        
        levelsCollectionLayout.minimumLineSpacing = spacing
        levelsCollectionLayout.minimumInteritemSpacing = spacing
    }
    
    func scrollToNearestLevel() {
        levelsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: currentLevelIndex, inSection: 0),
                                                     atScrollPosition: .CenteredHorizontally,
                                                     animated: true)
    }
    
    func zoomInLevelAtIndex(index: Int, mainView: UIView, completionHandler: (() -> Void)? = nil) {
        zoomedCell = levelsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? LevelCell
        
        UIView.animateWithDuration(0.4, animations: {
            self.levelsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0),
                atScrollPosition: .CenteredHorizontally,
                animated: false)
            
            }, completion: { _ in
                // Call completion block before animation finished for smoother animation.
                self.executeAfterDelay(0.2, task: {
                    completionHandler?()
                })
                
                UIView.animateWithDuration(0.5, animations: {
                    self.zoomedCell!.handsCountLabel.alpha = 0.0
                    self.zoomedCell!.priceLabel.alpha = 0.0
                    self.zoomedCell!.chipsImageView.alpha = 0.0
                    self.zoomedCell!.levelLabel.alpha = 0.0
                    
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
    
    func zoomOutLevelIfNeeded(mainView: UIView) {
        guard zoomedCell != nil else { return }
        
        // Apply scale transform before animation started.
        // It's needed because transform was reseted when `zoom in` operation completed.
        mainView.transform = CGAffineTransformMakeScale(zoomLevel, zoomLevel)
        
        UIView.animateWithDuration(0.4, animations: {
            self.zoomedCell!.handsCountLabel.alpha = 1.0
            self.zoomedCell!.priceLabel.alpha = 1.0
            self.zoomedCell!.chipsImageView.alpha = 1.0
            self.zoomedCell!.levelLabel.alpha = 1.0
            
            mainView.transform = CGAffineTransformIdentity
            
            }, completion: { _ in
                self.zoomedCell = nil
        })
        
    }
}
