//
//  MainScreen.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreen: UIViewController {
    
    let numberOfHands: Int = 2
    var oddsCalculator: OddsCalculator!

    override func viewDidLoad() {
        super.viewDidLoad()
        //generateNextHand()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.updateCollectionViewLayoutForNumberOfCells(numberOfHands)
    }
    
    private var mainView: MainView {
        return view as! MainView
    }
    
    private func generateNextHand() {
        let firstHand = Hand(firstCard: Card(rank: .Ace, suit: .Diamonds), secondCard: Card(rank: .King, suit: .Hearts))
        let secondHand = Hand(firstCard: Card(rank: .Nine, suit: .Spades), secondCard: Card(rank: .Five, suit: .Clubs))

        var deck = Deck()
        deck.removeHand(firstHand)
        deck.removeHand(secondHand)
        
        var oddsCalculator = OddsCalculator(hands: [firstHand, secondHand], deck: deck)
        let time = CFAbsoluteTimeGetCurrent()
        oddsCalculator.calculateOdds()
        print(CFAbsoluteTimeGetCurrent() - time)
        
        print("\(oddsCalculator.handsOdds[0].hand)\nWins: \(oddsCalculator.handsOdds[0].winningProbability())\nTie: \(oddsCalculator.handsOdds[0].tieProbability())")
        print("\(oddsCalculator.handsOdds[0].hand)\nWins: \(oddsCalculator.handsOdds[1].winningProbability())\nTie: \(oddsCalculator.handsOdds[1].tieProbability())")
        
        
        mainView.handsCollectionView.reloadData()
    }
    
    @IBAction private func nextHandButtonDidPress(sender: AnyObject) {
        generateNextHand()
    }
}

extension MainScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return oddsCalculator.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HandCell",
            forIndexPath: indexPath) as! HandCell

        let item = HandCellItem(handOdds: oddsCalculator.handsOdds[indexPath.item], needsShowOdds: false, isSuccessSate: nil)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return mainView.cellSizeForNumberOfCells(numberOfHands)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HandCell
        
        let isSuccessState = cell.item.handOdds.hand == oddsCalculator.sortedHandsOdds[0].hand
        let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
        cell.fillWithItem(item)
    }
}

