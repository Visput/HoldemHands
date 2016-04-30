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
    @IBOutlet private(set) weak var winOddsLabel: UILabel!
    @IBOutlet private(set) weak var tieOddsLabel: UILabel!
    @IBOutlet private(set) weak var oddsBackgroundView: UIImageView!
 
    private(set) var item: HandCellItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustFontSizeRecursively(true)
    }
    
    override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.2, animations: {
                let zoomLevel: CGFloat = self.highlighted ? 0.9 : 1.0
                self.transform = CGAffineTransformMakeScale(zoomLevel, zoomLevel)
            })
        }
    }
    
    func fillWithItem(item: HandCellItem) {
        self.item = item
        
        if item.handOdds == nil {
            setHandVisible(false, animated: false)
            winOddsLabel.alpha = 0.0
            tieOddsLabel.alpha = 0.0
            oddsBackgroundView.alpha = 0.0
        } else {
            winOddsLabel.text = NSString(format: NSLocalizedString("text_format_win_odds", comment: ""),
                                         item.handOdds!.winningProbability()) as String
            tieOddsLabel.text = NSString(format: NSLocalizedString("text_format_tie_odds", comment: ""),
                                         item.handOdds!.tieProbability()) as String
            
            if item.isSuccessSate == nil {
                oddsBackgroundView.image = UIImage(named: "background_hand_odds_grey")
            } else if item.isSuccessSate! {
                oddsBackgroundView.image = UIImage(named: "background_hand_odds_green")
            } else {
                oddsBackgroundView.image = UIImage(named: "background_hand_odds_red")
            }
            UIView.animateWithDuration(0.4, animations: {
                self.oddsBackgroundView.alpha = item.needsShowOdds! ? 1.0 : 0.0
                self.winOddsLabel.alpha = item.needsShowOdds! ? 1.0 : 0.0
                self.tieOddsLabel.alpha = item.needsShowOdds! ? 1.0 : 0.0
            })
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
