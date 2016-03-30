//
//  HandCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class HandCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var firstCardImageView: UIImageView!
    @IBOutlet private(set) weak var secondCardImageView: UIImageView!
    
    @IBOutlet private(set) weak var firstCardView: UIView!
    @IBOutlet private(set) weak var firstCardTopLabel: UILabel!
    @IBOutlet private(set) weak var firstCardCenterLabel: UILabel!
    @IBOutlet private(set) weak var firstCardBottomLabel: UILabel!
    
    @IBOutlet private(set) weak var secondCardView: UIView!
    @IBOutlet private(set) weak var secondCardTopLabel: UILabel!
    @IBOutlet private(set) weak var secondCardCenterLabel: UILabel!
    @IBOutlet private(set) weak var secondCardBottomLabel: UILabel!
    
    @IBOutlet private(set) weak var winningProbabilityLabel: UILabel!
 
    private(set) var item: HandCellItem!
    
    func fillWithItem(item: HandCellItem) {
        self.item = item
        
        if item.handOdds == nil {
            setHandVisible(false, animated: false)
            winningProbabilityLabel.hidden = true
            backgroundColor = UIColor.backgroundColor()
        } else {
            winningProbabilityLabel.hidden = !item.needsShowOdds
            winningProbabilityLabel.text = NSString(format: "Win: %.2f%%", item.handOdds!.winningProbability()) as String
            
            if item.isSuccessSate == nil {
                backgroundColor = UIColor.backgroundColor()
                winningProbabilityLabel.backgroundColor = UIColor.darkGrayColor()
            } else if item.isSuccessSate! {
                backgroundColor = UIColor.lightPrimaryColor()
                winningProbabilityLabel.backgroundColor = UIColor.lightPrimaryColor()
            } else {
                backgroundColor = UIColor.lightSecondaryColor()
                winningProbabilityLabel.backgroundColor = UIColor.lightSecondaryColor()
            }
        }
    }
    
    func setHandVisible(visible: Bool, animated: Bool, completionHandler: (() -> Void)? = nil) {
        let animationDuration = 0.6
        
        func updateFirstCard() {
            if visible {
                firstCardTopLabel.text = titleForCard(item.handOdds!.hand.firstCard)
                firstCardTopLabel.textColor = colorForCard(item.handOdds!.hand.firstCard)
                firstCardCenterLabel.text = firstCardTopLabel.text
                firstCardCenterLabel.textColor = firstCardTopLabel.textColor
                firstCardBottomLabel.text = firstCardTopLabel.text
                firstCardBottomLabel.textColor = firstCardTopLabel.textColor
            } else {
                firstCardTopLabel.text = ""
                firstCardCenterLabel.text = ""
                firstCardBottomLabel.text = ""
            }
        }
        
        func updateSecondCard() {
            if visible {
                secondCardTopLabel.text = titleForCard(item.handOdds!.hand.secondCard)
                secondCardTopLabel.textColor = colorForCard(item.handOdds!.hand.secondCard)
                secondCardCenterLabel.text = secondCardTopLabel.text
                secondCardCenterLabel.textColor = secondCardTopLabel.textColor
                secondCardBottomLabel.text = secondCardTopLabel.text
                secondCardBottomLabel.textColor = secondCardTopLabel.textColor
            } else {
                secondCardTopLabel.text = ""
                secondCardCenterLabel.text = ""
                secondCardBottomLabel.text = ""
            }
        }
        
        if animated {
            UIView.transitionWithView(firstCardView, duration: animationDuration, options: [.TransitionFlipFromLeft, .CurveEaseOut], animations: {
                updateFirstCard()
                }, completion: nil)
            
            UIView.transitionWithView(secondCardView, duration: animationDuration, options: [.TransitionFlipFromLeft, .CurveEaseOut], animations: {
                updateSecondCard()
                }, completion: { _ in
                    completionHandler?()
            })
        } else {
            updateFirstCard()
            updateSecondCard()
            completionHandler?()
        }
    }
}

extension HandCell {
    
    private func colorForCard(card: Card) -> UIColor {
        switch card.suit {
        case .Hearts: return UIColor.secondaryColor()
        case .Spades: return UIColor.primaryTextColor()
        case .Clubs: return UIColor.primaryColor()
        case .Diamonds: return UIColor.tertiaryColor()
        }
    }
    
    private func titleForCard(card: Card) -> String {
        switch card.rank {
        case .Two: return "2"
        case .Three: return "3"
        case .Four: return "4"
        case .Five: return "5"
        case .Six: return "6"
        case .Seven: return "7"
        case .Eight: return "8"
        case .Nine: return "9"
        case .Ten: return "10"
        case .Jack: return "J"
        case .Queen: return "Q"
        case .King: return "K"
        case .Ace: return "A"
        }
    }
}
