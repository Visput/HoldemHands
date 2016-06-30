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
    
    private var roundView: RoundView {
        return view as! RoundView
    }
    
    private var needsLoadNewRoundOnViewDisappear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let roundManager = roundManager {
            roundView.configureLayoutForNumberOfHands(roundManager.level.numberOfHands)
        }
        roundView.controlsEnabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        roundManager.stopRound(saveRoundIfNeeded: roundView.visible)
        super.viewWillDisappear(animated)
    }
    
    func viewDidChangePosition() {
        if roundView.visible && roundManager.roundLoaded {
            // Use delay for better usability.
            // Helps to understand better what is going on from user perspective.
            startRoundAfterDelay(0.2)
        }
        
        if !roundView.visible && needsLoadNewRoundOnViewDisappear {
            needsLoadNewRoundOnViewDisappear = false
            loadNewRound()
        }
    }
    
    func loadNewRound(completion: (() -> Void)? = nil) {
        reloadHandsCollectionViewDeeply(true, needsShowOdds: false)
        
        roundManager.loadNewRound({
            completion?()
            self.reloadHandsCollectionViewDeeply(true, needsShowOdds: false)
            if self.roundView.visible {
                self.startRoundAfterDelay(0.0)
            }
            
            guard self.nextController != nil else { return }
            if self.nextController!.roundView.visible {
                self.nextController!.needsLoadNewRoundOnViewDisappear = true
            } else {
                self.nextController!.loadNewRound()
            }
        })
    }
}

extension RoundViewController {
    
    private func startRoundAfterDelay(delay: Double) {
        roundView.flipHandsAfterDelay(delay).thenDo {
            self.model.walkthroughManager.showBannerForStartedLevelIfNeeded()
            self.roundManager.startRound()
            self.roundView.controlsEnabled = true
        }
    }
    
    private func reloadHandsCollectionViewDeeply(deeply: Bool, needsShowOdds: Bool) {
        if deeply {
            roundView.handsCollectionView.reloadData()
        } else {
            let cells = roundView.handsCollectionView.orderedVisibleCells() as! [HandCell]
            for (index, cell) in cells.enumerate() {
                let item = HandCellItem(handOdds: roundManager.round?.handsOdds?[index], needsShowOdds: needsShowOdds)
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
        let item = HandCellItem(handOdds: roundManager.round?.handsOdds?[indexPath.item], needsShowOdds: false)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let hand = roundManager.round!.hands[indexPath.item]
        roundManager.selectHand(hand)
        model.walkthroughManager.showBannerForCompletedLevelIfNeeded(won: roundManager.round!.won!)
        
        reloadHandsCollectionViewDeeply(false, needsShowOdds: true)
        roundView.controlsEnabled = false
    }
}
