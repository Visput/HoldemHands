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
    private var handOddsCalculator: HandOddsCalculator!
    
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
        handOddsCalculator = HandOddsCalculator(numberOfHands: level.numberOfHands)
        
        let time = CFAbsoluteTimeGetCurrent()
        gameView.nextHandButton.enabled = false
        gameView.nextHandButton.alpha = 0.4
        
        handOddsCalculator.calculateOdds({ handsOdds in
            self.gameView.nextHandButton.enabled = true
            self.gameView.nextHandButton.alpha = 1.0
            print(CFAbsoluteTimeGetCurrent() - time)
            
            self.gameView.handsCollectionView.delegate = self
            self.gameView.handsCollectionView.dataSource = self
            self.gameView.handsCollectionView.reloadData()
        })
    }
    
    private func updateChipsCountLabel() {
        gameView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %d", comment: ""),
        model.playerManager.player.chipsCount) as String
    }
}

extension GameScreen {
    
    @IBAction private func nextHandButtonDidPress(sender: AnyObject) {
        generateNextHand()
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        model.navigationManager.dismissScreenAnimated(true)
    }
}

extension GameScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return handOddsCalculator.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandCell.className(),
            forIndexPath: indexPath) as! HandCell
        
        let item = HandCellItem(handOdds: handOddsCalculator.handsOdds[indexPath.item], needsShowOdds: false, isSuccessSate: nil)
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
