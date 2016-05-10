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
    @IBOutlet private(set) weak var oddsBackgroundView: UIImageView!
    
    private var selectionLayer: CAShapeLayer?
 
    private(set) var item: HandCellItem!
    
    private var currentScale: CGFloat {
        let maxCellWidth = CGFloat(255.0)
        let scale = frame.size.width / maxCellWidth
        return scale
    }
    
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
            oddsBackgroundView.alpha = 0.0
        } else {
            let maxFontSize = CGFloat(21.0)
            let textFont = UIFont(name: winOddsLabel.font!.fontName, size: maxFontSize * currentScale)
            
            winOddsLabel.text = NSString(format: NSLocalizedString("text_format_win_odds", comment: ""),
                                         item.handOdds!.winningProbability()) as String
            winOddsLabel.font = textFont
            
            if item.isSuccessSate != nil {
                if item.isSuccessSate! {
                    oddsBackgroundView.image = UIImage(named: "background_hand_odds_green")
                } else {
                    oddsBackgroundView.image = UIImage(named: "background_hand_odds_grey")
                }
            } else {
                oddsBackgroundView.image = UIImage(named: "background_hand_odds_grey")
            }
            
            UIView.animateWithDuration(0.4, animations: {
                self.oddsBackgroundView.alpha = item.needsShowOdds! ? 1.0 : 0.0
                self.winOddsLabel.alpha = item.needsShowOdds! ? 1.0 : 0.0
            })
        }
        
        setHandSelectionVisible(selected, isSuccessState: item.isSuccessSate)
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
    
    private func setHandSelectionVisible(visible: Bool, isSuccessState: Bool?) {
        guard visible else {
            selectionLayer?.removeFromSuperlayer()
            selectionLayer = nil
            return
        }

        let halfPi = CGFloat(M_PI_2)
        let lineWidth = ceil(3.0 * currentScale)
        let arcRadius = ceil(12.0 * currentScale)
        let inset = ceil(-6.0 * currentScale)
        
        selectionLayer?.removeFromSuperlayer()
        selectionLayer = CAShapeLayer()
        selectionLayer!.fillColor = nil
        selectionLayer!.lineWidth = lineWidth
        selectionLayer!.lineJoin = kCALineJoinRound
        selectionLayer!.frame = bounds.insetBy(dx: inset, dy: inset)
        
        let path = UIBezierPath()
        // Move to bottom left.
        path.moveToPoint(CGPoint(x: 0.0, y: selectionLayer!.bounds.size.height - arcRadius))
        
        // Draw to top left.
        path.addLineToPoint(CGPoint(x: 0.0, y: arcRadius))
        path.addArcWithCenter(CGPoint(x: arcRadius, y: arcRadius),
                              radius: arcRadius,
                              startAngle: 2 * halfPi,
                              endAngle: 3 * halfPi,
                              clockwise: true)
        // Draw to top right.
        path.addLineToPoint(CGPoint(x: selectionLayer!.bounds.size.width - arcRadius, y: 0.0))
        path.addArcWithCenter(CGPoint(x: selectionLayer!.bounds.size.width - arcRadius, y: arcRadius),
                              radius: arcRadius,
                              startAngle: 3 * halfPi,
                              endAngle: 4 * halfPi,
                              clockwise: true)
        
        // Draw to bottom right.
        path.addLineToPoint(CGPoint(x: selectionLayer!.bounds.size.width, y: selectionLayer!.bounds.size.height - arcRadius))
        path.addArcWithCenter(CGPoint(x: selectionLayer!.bounds.size.width - arcRadius, y: selectionLayer!.bounds.size.height - arcRadius),
                              radius: arcRadius,
                              startAngle: 0,
                              endAngle: halfPi,
                              clockwise: true)
        
        // Draw to bottom left.
        path.addLineToPoint(CGPoint(x: arcRadius, y: selectionLayer!.bounds.size.height))
        path.addArcWithCenter(CGPoint(x: arcRadius, y: selectionLayer!.bounds.size.height - arcRadius),
                              radius: arcRadius,
                              startAngle: halfPi,
                              endAngle: 2 * halfPi,
                              clockwise: true)
        
        selectionLayer!.path = path.CGPath
        layer.addSublayer(selectionLayer!)
        
        var animation: CABasicAnimation! = nil
        if isSuccessState! {
            selectionLayer!.strokeColor = UIColor.green1Color().CGColor
            
            animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.8
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.removedOnCompletion = false
        } else {
            selectionLayer!.strokeColor = UIColor.gray3Color().CGColor
            
            animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.4
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.removedOnCompletion = false
        }
        selectionLayer!.addAnimation(animation, forKey: nil)
    }
}
