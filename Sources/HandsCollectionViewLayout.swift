//
//  HandsCollectionViewLayout.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/23/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class HandsCollectionViewLayout: UICollectionViewFlowLayout {

    let numberOfHands: Int
    
    init(numberOfHands: Int) {
        self.numberOfHands = numberOfHands
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let contentSize = collectionView!.frame.size
        let spacing: CGFloat = 16.0
        let linesCount: CGFloat = numberOfHands < 4 ? 1.0 : 2.0
        let cellsPerLine = CGFloat(ceilf(Float(CGFloat(numberOfHands) / linesCount)))
        let maxCellSize: CGFloat = contentSize.height / 2
        
        var verticalSpacing = spacing
        var cellSize = (contentSize.height - verticalSpacing * (linesCount + 1.0)) / linesCount
        if cellSize > maxCellSize {
            cellSize = maxCellSize
            verticalSpacing = (contentSize.height - cellSize * linesCount) / (linesCount + 1.0)
        }
        let horizontalSpacing = (contentSize.width - cellSize * cellsPerLine) / (cellsPerLine + 1.0)
        
        itemSize.width = cellSize
        itemSize.height = cellSize
        
        if linesCount == 1 {
            minimumInteritemSpacing = horizontalSpacing
            minimumLineSpacing = horizontalSpacing
        } else {
            minimumInteritemSpacing = verticalSpacing
            minimumLineSpacing = verticalSpacing
        }
        
        sectionInset.left = horizontalSpacing
        sectionInset.right = horizontalSpacing
        
        sectionInset.top = verticalSpacing
        sectionInset.bottom = verticalSpacing
        
        let attributes = super.layoutAttributesForElementsInRect(rect)
        return attributes
    }
}
