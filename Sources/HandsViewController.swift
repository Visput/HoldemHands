//
//  HandsViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/28/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class HandsViewController: UIViewController {
    
    var numberOfHands: Int! {
        didSet {
            handOddsCalculator = HandOddsCalculator(numberOfHands: numberOfHands)
            handsView.configureLayoutForNumberOfHands(numberOfHands)
        }
    }
    
    weak var nextController: HandsViewController?
    
    var didPlayRoundHandler: ((won: Bool, tieProbability: Double) -> Void)?
    
    var tieProbability: Double? {
        return handOddsCalculator.handsOdds?.first?.tieProbability()
    }
    
    private var handsView: HandsView {
        return view as! HandsView
    }
    
    private var handOddsCalculator: HandOddsCalculator!
    private var needsGenerateHandsOnViewDisappear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handsView.handsCollectionView.userInteractionEnabled = false
    }
    
    func viewDidChangePosition() {
        if handsView.isPresented && handOddsCalculator.handsOdds != nil {
            let delayDuration = 0.2
            // Use delay for better usability.
            // Helps to understand better what is going on from user perspective.
            handsView.flipHandsWithDelay(delayDuration)
        }
        
        if !handsView.isPresented && needsGenerateHandsOnViewDisappear {
            needsGenerateHandsOnViewDisappear = false
            generateHands()
        }
    }
    
    func generateHands() {
        handOddsCalculator = HandOddsCalculator(numberOfHands: numberOfHands)
        reloadHandsCollectionViewDeeply(true)
        
        handOddsCalculator.calculateOdds({ handsOdds in
            self.reloadHandsCollectionViewDeeply(true)
            if self.handsView.isPresented {
                self.handsView.flipHandsWithDelay(0.0)
            }
            
            guard self.nextController != nil else { return }
            if self.nextController!.handsView.isPresented {
                self.nextController!.needsGenerateHandsOnViewDisappear = true
            } else {
                self.nextController!.generateHands()
            }
        })
    }
    
    private func reloadHandsCollectionViewDeeply(deeply: Bool) {
        if deeply {
            handsView.handsCollectionView.reloadData()
        } else {  
            let cells = handsView.handsCollectionView.orderedVisibleCells() as! [HandCell]
            for (index, cell) in cells.enumerate() {
                let item = HandCellItem(handOdds: handOddsCalculator.handsOdds?[index], needsShowOdds: false, isSuccessSate: nil)
                cell.fillWithItem(item)
            }
        }
    }
}

extension HandsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
                didPlayRoundHandler?(won: isSuccessState!, tieProbability: cell.item.handOdds!.tieProbability())
                
            } else {
                if cell.item.handOdds!.wins {
                    isSuccessState = true
                }
            }
            let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
            cell.fillWithItem(item)
        }
        
        handsView.handsCollectionView.userInteractionEnabled = false
    }
}
