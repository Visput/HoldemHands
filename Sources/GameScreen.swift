//
//  GameScreen.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameScreen: BaseScreen {
    
    let numberOfHands: Int = 5
    var handOddsCalculator: HandOddsCalculator!
    
    private var gameView: GameView {
        return view as! GameView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        generateNextHand()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gameView.updateCollectionViewLayoutForNumberOfCells(numberOfHands)
    }
    
    private func generateNextHand() {
        handOddsCalculator = HandOddsCalculator(numberOfHands: numberOfHands)
        
//        let firstHand = Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts))
//        let secondHand = Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))
//        var deck = Deck()
//        deck.removeHand(firstHand)
//        deck.removeHand(secondHand)
//        handOddsCalculator = HandOddsCalculator(hands: [firstHand, secondHand], deck: deck)
        
        let time = CFAbsoluteTimeGetCurrent()
        gameView.nextHandButton.enabled = false
        gameView.nextHandButton.alpha = 0.4
        
        handOddsCalculator.calculateOdds({
            self.gameView.nextHandButton.enabled = true
            self.gameView.nextHandButton.alpha = 1.0
            print(CFAbsoluteTimeGetCurrent() - time)
            
            for handOdds in self.handOddsCalculator.handsOdds {
                print("\(handOdds.hand)\nWins: \(handOdds.winningProbability())")
            }
            
            self.gameView.handsCollectionView.delegate = self
            self.gameView.handsCollectionView.dataSource = self
            self.gameView.handsCollectionView.reloadData()
        })
    }
    
    @IBAction private func nextHandButtonDidPress(sender: AnyObject) {
        generateNextHand()
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
            
            return gameView.cellSizeForNumberOfCells(numberOfHands)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! HandCell
        
        for cell in collectionView.visibleCells() as! [HandCell] {
            var isSuccessState: Bool? = nil
            if currentCell == cell {
                isSuccessState = handOddsCalculator.isWinningHandOdds(cell.item.handOdds)
            }
            let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
            cell.fillWithItem(item)
        }
    }
}
