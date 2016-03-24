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
        
        let linesCount: CGFloat = numberOfHands < 4 ? 1.0 : 2.0
        let cellsPerLine = CGFloat(ceil(CGFloat(numberOfHands) / linesCount))
        let maxCellHeight: CGFloat = contentSize.height / 2.0
        let minSpacing: CGFloat = 24.0
        let cellSizeRatio: CGFloat = 1.4
        
        // Calculate layout based on screen height.
        var verticalSpacing = minSpacing
        var cellHeight = floor((contentSize.height - verticalSpacing * (linesCount + 1.0)) / linesCount)
        if cellHeight > maxCellHeight {
            cellHeight = maxCellHeight
            verticalSpacing = floor((contentSize.height - cellHeight * linesCount) / (linesCount + 1.0))
        }
        var cellWidth = floor(cellHeight * cellSizeRatio)
        var horizontalSpacing = floor((contentSize.width - cellWidth * cellsPerLine) / (cellsPerLine + 1.0))
        
        if horizontalSpacing < minSpacing {
            // Calculate layout based on screen width.
            horizontalSpacing = minSpacing
            cellWidth = floor((contentSize.width - horizontalSpacing * (cellsPerLine + 1.0)) / cellsPerLine)
            cellHeight = floor(cellWidth / cellSizeRatio)
            verticalSpacing = floor((contentSize.height - cellHeight * linesCount) / (linesCount + 1.0))
        }
        
        // Make vertical and horizontal spacing equal.
        var cellSpacing: CGFloat = 0.0
        if horizontalSpacing > verticalSpacing {
            cellSpacing = verticalSpacing
            let totalInteritemSpacing = cellSpacing * (cellsPerLine - 1)
            horizontalSpacing = floor((contentSize.width - totalInteritemSpacing - cellWidth * cellsPerLine) / 2.0)
        } else {
            cellSpacing = horizontalSpacing
            let totalLineSpacing = cellSpacing * (linesCount - 1)
            verticalSpacing = floor((contentSize.height - totalLineSpacing - cellHeight * linesCount) / 2.0)
        }
        
        itemSize.width = cellWidth
        itemSize.height = cellHeight
        
        minimumInteritemSpacing = cellSpacing
        minimumLineSpacing = cellSpacing
        
        sectionInset.left = horizontalSpacing
        sectionInset.right = horizontalSpacing
        
        sectionInset.top = verticalSpacing
        sectionInset.bottom = verticalSpacing
        
        var attributes = Array(super.layoutAttributesForElementsInRect(rect)!)
        
        // Center items for second line if it's not full.
        if attributes.count == 5 || attributes.count == 7 {
            let cellsInLine = cellsPerLine - 1.0
            let spacesInLine = cellsInLine - 1.0
            let shift = floor((contentSize.width - spacesInLine * cellSpacing - cellsInLine * cellWidth) / 2.0 - horizontalSpacing)
            
            for index in attributes.count - Int(cellsInLine) ..< attributes.count {
                attributes[index].frame.origin.x += shift
            }
        }
        
        return attributes
    }
}
