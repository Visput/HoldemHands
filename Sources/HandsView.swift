//
//  HandsView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/9/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class HandsView: UIView {
    
    @IBOutlet private(set) weak var handsCollectionView: UICollectionView!
    @IBOutlet private(set) weak var tieOddsLabel: UILabel!
    
    var isPresented: Bool {
        let window = UIApplication.sharedApplication().keyWindow!
        let windowFrame = window.frame
        let viewFrame = convertRect(bounds, toView: window)
        return CGRectContainsRect(windowFrame, viewFrame)
    }
    
    func configureLayoutForNumberOfHands(numberOfHands: Int) {
        let layout = HandsCollectionViewLayout(numberOfHands: numberOfHands)
        handsCollectionView.collectionViewLayout = layout
    }
    
    func flipHandsWithDelay(delayDuration: Double) {
        executeAfterDelay(delayDuration, task: {
            let delayCoefficient = 0.1
            let cells = self.handsCollectionView.orderedVisibleCells() as! [HandCell]
            for (index, cell) in cells.enumerate() {
                self.executeAfterDelay(Double(index) * delayCoefficient, task: {
                    cell.setHandVisible(true, animated: true, completionHandler: {
                        if index == cells.count - 1 {
                            self.handsCollectionView.userInteractionEnabled = true
                        }
                    })
                })
            }
        })
    }
    
    func setTieOddsVisible(visible: Bool) {
        UIView.animateWithDuration(0.4, animations: {
            self.tieOddsLabel.alpha = visible ? 1.0 : 0.0
        })
    }
}
