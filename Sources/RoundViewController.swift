//
//  RoundViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/28/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class RoundViewController: BaseViewController {
    
    var roundManager: RoundManager! {
        didSet {
            guard isViewLoaded() else { return }
            roundView.configureLayoutForNumberOfHands(roundManager.level.numberOfHands)
        }
    }
    
    weak var nextController: RoundViewController?
    
    var didPlayRoundHandler: ((round: Round) -> Void)?
    
    private var roundView: RoundView {
        return view as! RoundView
    }
    
    private var needsStartRoundOnViewDisappear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let roundManager = roundManager {
            roundView.configureLayoutForNumberOfHands(roundManager.level.numberOfHands)
        }
        roundView.handsCollectionView.userInteractionEnabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        roundManager.stop(saveRoundIfNeeded: roundView.isPresented)
        super.viewWillDisappear(animated)
    }
    
    func viewDidChangePosition() {
        if roundView.isPresented && roundManager.round?.oddsCalculator.handsOdds != nil {
            let delayDuration = 0.2
            // Use delay for better usability.
            // Helps to understand better what is going on from user perspective.
            roundView.flipHandsWithDelay(delayDuration)
        }
        
        if !roundView.isPresented && needsStartRoundOnViewDisappear {
            needsStartRoundOnViewDisappear = false
            startRound()
        }
    }
    
    func startRound(completion: (() -> Void)? = nil) {
        roundManager.start()
        reloadHandsCollectionViewDeeply(true, needsShowOdds: false)
        
        roundManager.round!.oddsCalculator.calculateOdds({ handsOdds in
            self.model.walkthroughManager.showFirstRoundBannerIfNeeded()
            
            completion?()
            self.reloadHandsCollectionViewDeeply(true, needsShowOdds: false)
            if self.roundView.isPresented {
                self.roundView.flipHandsWithDelay(0.0)
            }
            
            guard self.nextController != nil else { return }
            if self.nextController!.roundView.isPresented {
                self.nextController!.needsStartRoundOnViewDisappear = true
            } else {
                self.nextController!.startRound()
            }
        })
    }
    
    private func reloadHandsCollectionViewDeeply(deeply: Bool, needsShowOdds: Bool) {
        if deeply {
            roundView.handsCollectionView.reloadData()
        } else {  
            let cells = roundView.handsCollectionView.orderedVisibleCells() as! [HandCell]
            for (index, cell) in cells.enumerate() {
                let item = HandCellItem(handOdds: roundManager.round?.oddsCalculator.handsOdds?[index], needsShowOdds: needsShowOdds)
                cell.fillWithItem(item)
            }
        }
    }
}

extension RoundViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roundManager.level.numberOfHands
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.handCell, forIndexPath: indexPath)!
        let item = HandCellItem(handOdds: roundManager.round?.oddsCalculator.handsOdds?[indexPath.item], needsShowOdds: false)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let hand = roundManager.round!.hands[indexPath.item]
        roundManager.selectHand(hand)
        model.walkthroughManager.showNextRoundBannerIfNeeded(won: roundManager.round!.won!)
        
        didPlayRoundHandler?(round: roundManager.round!)
        
        reloadHandsCollectionViewDeeply(false, needsShowOdds: true)
        roundView.handsCollectionView.userInteractionEnabled = false
    }
}
