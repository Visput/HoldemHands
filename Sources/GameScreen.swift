//
//  GameScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameScreen: BaseScreen {
    
    var level: GameLevel!
    
    private var currentHandOddsCalculator: HandOddsCalculator!
    private var nextHandOddsCalculator: HandOddsCalculator!
    private var needsShowNextHandImmediately: Bool = true
    
    private var gameView: GameView {
        return view as! GameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateNextHand()
        updateChipsCountLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gameView.updateCollectionViewLayoutForNumberOfCells(level.numberOfHands)
    }
    
    private func generateNextHand() {
        if currentHandOddsCalculator == nil {
            currentHandOddsCalculator = HandOddsCalculator(numberOfHands: level.numberOfHands)
            currentHandOddsCalculator.calculateOdds({ handsOdds in
                self.gameView.handsCollectionView.delegate = self
                self.gameView.handsCollectionView.dataSource = self
                self.gameView.handsCollectionView.reloadData()
                
                self.needsShowNextHandImmediately = false
                self.generateNextHand()
            })
        } else if nextHandOddsCalculator?.handsOdds == nil {
            guard !needsShowNextHandImmediately else { return }
            nextHandOddsCalculator = HandOddsCalculator(numberOfHands: level.numberOfHands)
            nextHandOddsCalculator.calculateOdds({ handsOdds in
                if self.needsShowNextHandImmediately {
                    self.currentHandOddsCalculator = self.nextHandOddsCalculator
                    self.nextHandOddsCalculator = nil
                    self.gameView.handsCollectionView.reloadData()
                    
                    self.needsShowNextHandImmediately = false
                    self.generateNextHand()
                }
            })
        } else {
            currentHandOddsCalculator = nextHandOddsCalculator
            nextHandOddsCalculator = nil
            gameView.handsCollectionView.reloadData()
            
            self.needsShowNextHandImmediately = false
            self.generateNextHand()
        }
    }
    
    private func updateChipsCountLabel() {
        gameView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %.0f", comment: ""),
        model.playerManager.player.chipsCount) as String
    }
}

extension GameScreen {
    
    @IBAction private func nextHandGestureDidSwipe(sender: AnyObject) {
        needsShowNextHandImmediately = true
        generateNextHand()
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        model.navigationManager.dismissScreenAnimated(true)
    }
}

extension GameScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentHandOddsCalculator.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandCell.className(),
            forIndexPath: indexPath) as! HandCell
        
        let item = HandCellItem(handOdds: currentHandOddsCalculator.handsOdds[indexPath.item], needsShowOdds: false, isSuccessSate: nil)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return gameView.cellSizeForNumberOfCells(level.numberOfHands)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! HandCell
        
        for cell in collectionView.visibleCells() as! [HandCell] {
            var isSuccessState: Bool? = nil
            if currentCell == cell {
                isSuccessState = cell.item.handOdds.wins
                if isSuccessState! {
                    model.playerManager.trackNewWinInLevel(level)
                } else {
                    model.playerManager.trackNewLossInLevel(level)
                }
                updateChipsCountLabel()
            }
            let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
            cell.fillWithItem(item)
        }
    }
}
