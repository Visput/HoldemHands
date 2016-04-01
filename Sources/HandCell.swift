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
    @IBOutlet private(set) weak var winningProbabilityLabel: UILabel!
 
    private(set) var item: HandCellItem!
    
    func fillWithItem(item: HandCellItem) {
        self.item = item
        
        if item.handOdds == nil {
            setHandVisible(false, animated: false)
            winningProbabilityLabel.hidden = true
            backgroundColor = UIColor.clearColor()
        } else {
            winningProbabilityLabel.hidden = !item.needsShowOdds
            winningProbabilityLabel.text = NSString(format: "Win: %.2f%%", item.handOdds!.winningProbability()) as String
            
            if item.isSuccessSate == nil {
                backgroundColor = item.needsShowOdds! ? UIColor.darkGrayColor() : UIColor.clearColor()
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
                firstCardImageView.image = imageForCard(item.handOdds!.hand.firstCard)
            } else {
                firstCardImageView.image = nil
            }
        }
        
        func updateSecondCard() {
            if visible {
                secondCardImageView.image = imageForCard(item.handOdds!.hand.secondCard)
            } else {
                secondCardImageView.image = nil
            }
        }
        
        if animated {
            UIView.transitionWithView(firstCardImageView,
                                      duration: animationDuration,
                                      options: [.TransitionFlipFromLeft, .CurveEaseInOut],
                                      animations: {
                                        updateFirstCard()
                }, completion: nil)
            
            UIView.transitionWithView(secondCardImageView,
                                      duration: animationDuration,
                                      options: [.TransitionFlipFromLeft, .CurveEaseInOut],
                                      animations: {
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
    
    private func imageForCard(card: Card) -> UIImage {
        let imageName = "card_rank\(card.rank.rawValue)_suit\(card.suit.rawValue)"
        return UIImage(named: imageName)!
    }
}
