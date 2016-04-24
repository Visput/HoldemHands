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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustFontSizeRecursively(true)
    }
    
    func fillWithItem(item: HandCellItem) {
        self.item = item
        
        if item.handOdds == nil {
            setHandVisible(false, animated: false)
            winningProbabilityLabel.hidden = true
            backgroundColor = UIColor.clearColor()
        } else {
            winningProbabilityLabel.hidden = !item.needsShowOdds
            winningProbabilityLabel.text = NSString(format: "Win: %.2f%%\nTie: %.2f%%",
                                                    item.handOdds!.winningProbability(),
                                                    item.handOdds!.tieProbability()) as String
            
            if item.isSuccessSate == nil {
                backgroundColor = item.needsShowOdds! ? UIColor.darkGrayColor() : UIColor.clearColor()
                winningProbabilityLabel.backgroundColor = UIColor.darkGrayColor()
            } else if item.isSuccessSate! {
                backgroundColor = UIColor.greenColor()
                winningProbabilityLabel.backgroundColor = UIColor.greenColor()
            } else {
                backgroundColor = UIColor.redColor()
                winningProbabilityLabel.backgroundColor = UIColor.redColor()
            }
        }
    }
    
    func setHandVisible(visible: Bool, animated: Bool, completionHandler: (() -> Void)? = nil) {
        let animationDuration = 0.6
        
        if animated {
            UIView.transitionWithView(firstCardImageView,
                                      duration: animationDuration,
                                      options: [.TransitionFlipFromLeft, .CurveEaseInOut],
                                      animations: {
                                        self.updateFirstCard(visible)
                }, completion: nil)
            
            UIView.transitionWithView(secondCardImageView,
                                      duration: animationDuration,
                                      options: [.TransitionFlipFromLeft, .CurveEaseInOut],
                                      animations: {
                                        self.updateSecondCard(visible)
                }, completion: { _ in
                    completionHandler?()
            })
        } else {
            updateFirstCard(visible)
            updateSecondCard(visible)
            completionHandler?()
        }
    }
}

extension HandCell {
    
    private func updateFirstCard(visible: Bool) {
        if visible && item.handOdds != nil {
            firstCardImageView.image = imageForCard(item.handOdds!.hand.firstCard)
        } else {
            firstCardImageView.image = UIImage(named: "card_back")
        }
    }
    
    private func updateSecondCard(visible: Bool) {
        if visible && item.handOdds != nil {
            secondCardImageView.image = imageForCard(item.handOdds!.hand.secondCard)
        } else {
            secondCardImageView.image = UIImage(named: "card_back")
        }
    }
    
    private func imageForCard(card: Card) -> UIImage {
        let imageName = "card_suit\(card.suit.rawValue)_rank\(card.rank.rawValue)"
        return UIImage(named: imageName)!
    }
}
