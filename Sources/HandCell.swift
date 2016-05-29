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
            
            winOddsLabel.text = R.string.localizable.textWinOdds(item.handOdds!.winningProbability())
            winOddsLabel.font = textFont
            
            if item.isSuccessSate != nil {
                if item.isSuccessSate! {
                    oddsBackgroundView.image = R.image.backgroundHandOddsGreen()
                } else {
                    oddsBackgroundView.image = R.image.backgroundHandOddsGrey()
                }
            } else {
                oddsBackgroundView.image = R.image.backgroundHandOddsGrey()
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
            firstCardImageView.image = R.image.cardBack()
        }
    }
    
    private func updateSecondCard(visible: Bool) {
        if visible && item.handOdds != nil {
            secondCardImageView.image = imageForCard(item.handOdds!.hand.secondCard)
        } else {
            secondCardImageView.image = R.image.cardBack()
        }
    }
    
    private func imageForCard(card: Card) -> UIImage {
        let imageName = "card.suit\(card.suit.rawValue).rank\(card.rank.rawValue)"
        return UIImage(named: imageName)!
    }
    
    private func setHandSelectionVisible(visible: Bool, isSuccessState: Bool?) {
        selectionLayer?.removeFromSuperlayer()
        
        guard visible else {
            selectionLayer = nil
            return
        }
        
        selectionLayer = HandSelectionLayer(frame: bounds,
                                            scale: currentScale,
                                            isSuccessState: isSuccessState!)
        
        layer.addSublayer(selectionLayer!)
    }
}
