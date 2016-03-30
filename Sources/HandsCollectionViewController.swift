//
//  HandsCollectionViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/28/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class HandsCollectionViewController: UIViewController {
    
    var numberOfHands: Int! {
        didSet {
            handOddsCalculator = HandOddsCalculator(numberOfHands: numberOfHands)
            let layout = HandsCollectionViewLayout(numberOfHands: numberOfHands)
            handsCollectionView.collectionViewLayout = layout
        }
    }
    
    weak var nextController: HandsCollectionViewController?
    
    var didPlayRoundHandler: ((won: Bool) -> Void)?
    
    @IBOutlet private(set) weak var handsCollectionView: UICollectionView!
    
    private var handOddsCalculator: HandOddsCalculator!
    private var needsGenerateHandsOnViewDisappear = false
    
    private var isViewPresented: Bool {
        let window = UIApplication.sharedApplication().keyWindow!
        let windowFrame = window.frame
        let viewFrame = view.convertRect(view.bounds, toView: window)
        return CGRectContainsRect(windowFrame, viewFrame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handsCollectionView.userInteractionEnabled = false
    }
    
    func viewDidChangePosition() {
        if isViewPresented && handOddsCalculator.handsOdds != nil {
            let delayDuration = 0.2
            // Use delay for better usability.
            // Helps to understand better what is going on from user perspective.
            flipHandsWithDelay(delayDuration)
        }
        
        if !isViewPresented && needsGenerateHandsOnViewDisappear {
            needsGenerateHandsOnViewDisappear = false
            generateHands()
        }
    }
    
    func generateHands() {
        handOddsCalculator = HandOddsCalculator(numberOfHands: numberOfHands)
        reloadHandsCollectionViewDeeply(true)
        
        handOddsCalculator.calculateOdds({ handsOdds in
            self.reloadHandsCollectionViewDeeply(true)
            if self.isViewPresented {
                self.flipHandsWithDelay(0.0)
            }
            
            guard self.nextController != nil else { return }
            if self.nextController!.isViewPresented {
                self.nextController!.needsGenerateHandsOnViewDisappear = true
            } else {
                self.nextController!.generateHands()
            }
        })
    }
    
    private func flipHandsWithDelay(delayDuration: Double) {
        executeAfterDelay(delayDuration, task: {
            let delayCoefficient = 0.1
            let cells = self.orderedCells()
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
    
    private func reloadHandsCollectionViewDeeply(deeply: Bool) {
        if deeply {
            handsCollectionView.reloadData()
        } else {  
            let cells = orderedCells()
            for (index, cell) in cells.enumerate() {
                let item = HandCellItem(handOdds: handOddsCalculator.handsOdds?[index], needsShowOdds: false, isSuccessSate: nil)
                cell.fillWithItem(item)
            }
        }
    }
    
    private func orderedCells() -> [HandCell] {
        // Method `visibleCells()` provides cells in random order.
        // Sort cells from left top to right bottom corner.
        let cells = self.handsCollectionView.visibleCells().sort({ (cell1, cell2) -> Bool in
            return self.handsCollectionView.indexPathForCell(cell1)!.item < self.handsCollectionView.indexPathForCell(cell2)!.item
        }) as! [HandCell]
        
        return cells
    }
}

extension HandsCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return handOddsCalculator.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandCell.className(),
                                                                         forIndexPath: indexPath) as! HandCell
        
        let item = HandCellItem(handOdds: handOddsCalculator.handsOdds?[indexPath.item], needsShowOdds: false, isSuccessSate: nil)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! HandCell
        
        for cell in collectionView.visibleCells() as! [HandCell] {
            var isSuccessState: Bool? = nil
            if currentCell == cell {
                isSuccessState = cell.item.handOdds!.wins
                if isSuccessState! {
                    didPlayRoundHandler?(won: true)
                } else {
                    didPlayRoundHandler?(won: false)
                }
                
            } else {
                if cell.item.handOdds!.wins {
                    isSuccessState = true
                }
            }
            let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
            cell.fillWithItem(item)
        }
        
        handsCollectionView.userInteractionEnabled = false
    }
}
