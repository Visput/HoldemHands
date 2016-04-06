//
//  MainView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainView: UIView {
    
    @IBOutlet private(set) weak var levelsCollectionView: UICollectionView!
    @IBOutlet private(set) weak var contentScrollView: UIScrollView!

    private var levelsCollectionLayout: UICollectionViewFlowLayout {
        return levelsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    var isMenuShown: Bool {
        return contentScrollView.contentOffset.x == 0.0
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
    
    func scrollToMenuView() {
        UIView.animateWithDuration(0.6,
            delay: 0.0,
            options: .CurveEaseInOut,
            animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
            }, completion: nil)
    }
    
    func scrollToLevelsView() {
        UIView.animateWithDuration(0.6,
            delay: 0.0,
            options: .CurveEaseInOut,
            animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.bounds.size.width, y: 0.0)
            }, completion: nil)
    }
    
    func scrollToNearestLevel() {
        let offset = levelsCollectionView.contentOffset.x
        let levelDecimalIndex = offset / (levelsCollectionLayout.itemSize.width + levelsCollectionLayout.minimumInteritemSpacing)
        let levelIndex = Int(round(levelDecimalIndex))
    
        levelsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: levelIndex, inSection: 0),
                                                     atScrollPosition: .CenteredHorizontally,
                                                     animated: true)
    }
}
