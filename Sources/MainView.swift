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
    @IBOutlet private(set) weak var chipsCountLabel: UILabel!
    @IBOutlet private(set) weak var contentScrollView: UIScrollView!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let collectionViewLayout = levelsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.itemSize.width = levelsCollectionView.frame.size.width / CGFloat(2.5)
        collectionViewLayout.itemSize.height = collectionViewLayout.itemSize.width / CGFloat(1.5)
        collectionViewLayout.sectionInset.top = (levelsCollectionView.frame.size.height - collectionViewLayout.itemSize.height) / CGFloat(2.0)
        collectionViewLayout.sectionInset.bottom = collectionViewLayout.sectionInset.top
    }
    
    func scrollToMainView() {
        contentScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    func scrollToLevelsView() {
        contentScrollView.setContentOffset(CGPoint(x: contentScrollView.bounds.size.width, y: 0.0), animated: true)
    }
}
