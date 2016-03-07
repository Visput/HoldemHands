//
//  GameView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameView: UIView {
    
    @IBOutlet private(set) weak var handsCollectionView: UICollectionView!
    @IBOutlet private(set) weak var nextHandButton: UIButton!
    @IBOutlet private(set) weak var chipsCountLabel: UILabel!
    
    func updateCollectionViewLayoutForNumberOfCells(numberOfCells: Int) {
        let collectionViewLayout = handsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout

        let contentSize = handsCollectionView.frame.size
        let horizontalSpacing = contentSize.width / CGFloat((numberOfCells + 1) * (numberOfCells + 1))
        let verticalSpacing = (contentSize.height - (contentSize.width / CGFloat(numberOfCells + 1))) / 2.0
        
        collectionViewLayout.minimumLineSpacing = horizontalSpacing
        collectionViewLayout.minimumInteritemSpacing = horizontalSpacing
        collectionViewLayout.sectionInset.left = horizontalSpacing
        collectionViewLayout.sectionInset.right = horizontalSpacing
        collectionViewLayout.sectionInset.top = verticalSpacing
        collectionViewLayout.sectionInset.bottom = verticalSpacing
    }
    
    func cellSizeForNumberOfCells(numberOfCells: Int) -> CGSize {
        var cellSize = CGSize(width: 0.0, height: 0.0)
        
        cellSize.width = handsCollectionView.frame.size.width / CGFloat(numberOfCells + 1)
        cellSize.height = cellSize.width
        
        return cellSize
    }
}
