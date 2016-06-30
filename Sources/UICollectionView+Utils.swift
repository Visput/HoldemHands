//
//  UICollectionView+Utils.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/7/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func orderedVisibleCells() -> [UICollectionViewCell] {
        // Method `visibleCells()` provides cells in random order.
        let cells = visibleCells().sort({ (cell1, cell2) -> Bool in
            return indexPathForCell(cell1)!.item < indexPathForCell(cell2)!.item
        })
        
        return cells
    }
    
    func reloadDataTask() -> SimpleTask {
        reloadData()
        // Collection view doesn't provide a way to know that data reloading completed.
        // Call completion after short delay.
        return SimpleTask.delay(0.05)
    }
}
