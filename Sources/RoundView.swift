//
//  RoundView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class RoundView: UIView {
    
    @IBOutlet private(set) weak var handsCollectionView: UICollectionView!
    
    var visible = false
    
    var controlsEnabled: Bool {
        set {
            handsCollectionView.userInteractionEnabled = controlsEnabled
        }
        get {
            return handsCollectionView.userInteractionEnabled
        }
    }
    
    func configureLayoutForNumberOfHands(numberOfHands: Int) {
        let layout = HandsCollectionViewLayout(numberOfHands: numberOfHands)
        handsCollectionView.collectionViewLayout = layout
    }
    
    func flipHandsAfterDelay(delayDuration: Double, completion: () -> Void) {
        executeAfterDelay(delayDuration, task: {
            let delayCoefficient = 0.1
            let cells = self.handsCollectionView.orderedVisibleCells() as! [HandCell]
            for (index, cell) in cells.enumerate() {
                self.executeAfterDelay(Double(index) * delayCoefficient, task: {
                    cell.setHandVisible(true, animated: true, completionHandler: {
                        if index == cells.count - 1 {
                            completion()
                        }
                    })
                })
            }
        })
    }
}
