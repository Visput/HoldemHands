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
    
    var round: Round!
    
    weak var nextController: HandsViewController?
    
    var didSelectHandHandler: ((hand: Hand) -> Void)?
    
    private var handsView: HandsView {
        return view as! HandsView
    }
    
    private var needsGenerateHandsOnViewDisappear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handsView.configureLayoutForNumberOfHands(round.hands.count)
        handsView.handsCollectionView.userInteractionEnabled = false
    }
    
    func viewDidChangePosition() {
        if handsView.isPresented && round.oddsCalculator.handsOdds != nil {
            let delayDuration = 0.2
            // Use delay for better usability.
            // Helps to understand better what is going on from user perspective.
            handsView.flipHandsWithDelay(delayDuration)
        }
        
        if !handsView.isPresented && needsGenerateHandsOnViewDisappear {
            needsGenerateHandsOnViewDisappear = false
            calculateHandOdds()
        }
    }
    
    func calculateHandOdds(completion: (() -> Void)? = nil) {
        reloadHandsCollectionViewDeeply(true, needsShowOdds: false)
        
        round.oddsCalculator.calculateOdds({ handsOdds in
            completion?()
            self.reloadHandsCollectionViewDeeply(true, needsShowOdds: false)
            if self.handsView.isPresented {
                self.handsView.flipHandsWithDelay(0.0)
            }
            
            guard self.nextController != nil else { return }
            if self.nextController!.handsView.isPresented {
                self.nextController!.needsGenerateHandsOnViewDisappear = true
            } else {
                self.nextController!.calculateHandOdds()
            }
        })
    }
    
    private func reloadHandsCollectionViewDeeply(deeply: Bool, needsShowOdds: Bool) {
        if deeply {
            handsView.handsCollectionView.reloadData()
        } else {  
            let cells = handsView.handsCollectionView.orderedVisibleCells() as! [HandCell]
            for (index, cell) in cells.enumerate() {
                let item = HandCellItem(handOdds: round.oddsCalculator.handsOdds?[index], needsShowOdds: needsShowOdds)
                cell.fillWithItem(item)
            }
        }
    }
}

extension HandsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return round.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.handCell, forIndexPath: indexPath)!
        let item = HandCellItem(handOdds: round.oddsCalculator.handsOdds?[indexPath.item], needsShowOdds: false)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelectHandHandler?(hand: round.hands[indexPath.item])
        
        reloadHandsCollectionViewDeeply(false, needsShowOdds: true)
        handsView.handsCollectionView.userInteractionEnabled = false
    }
}
