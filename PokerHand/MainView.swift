
//
//  MainView.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainView: UIView {
    
    @IBOutlet private(set) weak var handsCollectionView: UICollectionView!
    
    func updateCollectionViewLayoutForNumberOfCells(numberOfCells: Int) {
        let collectionViewLayout = handsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewLayout.sectionInset.top = 0.0
        collectionViewLayout.sectionInset.bottom = 0.0

        let contentWidth = handsCollectionView.frame.size.width
        let spacing = contentWidth / CGFloat((numberOfCells + 1) * (numberOfCells + 1))
        
        collectionViewLayout.minimumLineSpacing = spacing
        collectionViewLayout.minimumInteritemSpacing = spacing
        collectionViewLayout.sectionInset.left = spacing
        collectionViewLayout.sectionInset.right = spacing
    }
    
    func cellSizeForNumberOfCells(numberOfCells: Int) -> CGSize {
        var cellSize = CGSize(width: 0.0, height: 0.0)
        
        cellSize.width = handsCollectionView.frame.size.width / CGFloat(numberOfCells + 1)
        cellSize.height = handsCollectionView.frame.size.height
        
        return cellSize
    }
}
