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
            
            if item.isSuccessSate != nil {
                if item.isSuccessSate! {
                    oddsBackgroundView.image = UIImage(named: "background_hand_odds_green")
                } else {
                    oddsBackgroundView.image = UIImage(named: "background_hand_odds_grey")
                }
                animateHandSelection()
            } else {
                oddsBackgroundView.image = UIImage(named: "background_hand_odds_grey")
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
    
    private func animateHandSelection() {
        let lineWidth: CGFloat = 1.0
        let pathRightToTop = UIBezierPath()
        pathRightToTop.lineWidth = lineWidth * 2.0
        
        pathRightToTop.moveToPoint(CGPoint(x: lineWidth, y: bounds.size.height - lineWidth))
        pathRightToTop.addLineToPoint(CGPoint(x: bounds.size.width - lineWidth, y: bounds.size.height - lineWidth))
        pathRightToTop.addLineToPoint(CGPoint(x: bounds.size.width - lineWidth, y: lineWidth))
        
        let pathTopToRight = UIBezierPath()
        pathTopToRight.lineWidth = lineWidth
        
        pathTopToRight.moveToPoint(CGPoint(x: lineWidth, y: bounds.size.height - lineWidth))
        pathTopToRight.addLineToPoint(CGPoint(x: lineWidth, y: lineWidth))
        pathTopToRight.addLineToPoint(CGPoint(x: bounds.size.width - lineWidth, y: lineWidth))
        
        let startPath = UIBezierPath()
        startPath.moveToPoint(CGPoint(x: lineWidth, y: bounds.size.height - lineWidth))
        
        for path in [pathRightToTop, pathTopToRight] {
            let pathLayer = CAShapeLayer()
            pathLayer.path = startPath.CGPath
            pathLayer.strokeColor = UIColor.aquamarine1Color().CGColor
            pathLayer.fillColor = UIColor.clearColor().CGColor
            layer.addSublayer(pathLayer)
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = 2.0
            animation.toValue = path.CGPath
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fillMode = kCAFillModeForwards
            animation.removedOnCompletion = false
            
            pathLayer.addAnimation(animation, forKey: nil)
        }
        
    }
}
