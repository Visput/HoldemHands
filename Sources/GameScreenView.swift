//
//  GameScreenView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import LTMorphingLabel

final class GameScreenView: UIView {

    @IBOutlet private(set) weak var levelNameLabel: UILabel!
    @IBOutlet private(set) weak var tieOddsLabel: UILabel!
    @IBOutlet private(set) weak var tapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet private(set) weak var timeBonusLabel: LTMorphingLabel! {
        didSet {
            timeBonusLabel.morphingEffect = .Sparkle
        }
    }
    
    @IBOutlet private(set) weak var swipeRecognizer: UISwipeGestureRecognizer! {
        didSet {
            swipeRecognizer.direction = [.Left, .Right]
        }
    }
    
    @IBOutlet private(set) var doneButtons: [UIButton]! {
        didSet {
            for button in doneButtons {
                button.exclusiveTouch = true
            }
        }
    }
    
    @IBOutlet private(set) var statsButtons: [UIButton]! {
        didSet {
            for button in doneButtons {
                button.exclusiveTouch = true
            }
        }
    }
    
    @IBOutlet private(set) weak var firstRoundContainerView: UIView! {
        didSet {
            firstRoundContainerView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet private(set) weak var secondRoundContainerView: UIView! {
        didSet {
            secondRoundContainerView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    var controlsEnabled: Bool {
        set {
            swipeRecognizer.enabled = newValue
            tapRecognizer.enabled = newValue
        }
        get {
            return swipeRecognizer.enabled
        }
    }
    
    private var firstRoundView: RoundView {
        return firstRoundContainerView.subviews.first! as! RoundView
    }
    
    private var secondRoundView: RoundView {
        return secondRoundContainerView.subviews.first! as! RoundView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        var shownView = firstRoundContainerView
        var hiddenView = secondRoundContainerView
        
        if firstRoundContainerView.frame.origin.x != 0.0 {
            shownView = secondRoundContainerView
            hiddenView = firstRoundContainerView
        }
        var initialFrame = bounds
        initialFrame.origin.y = levelNameLabel.frame.origin.y + levelNameLabel.frame.height
        initialFrame.size.height = tieOddsLabel.frame.origin.y - initialFrame.origin.y
        
        shownView.frame = initialFrame
        hiddenView.frame = initialFrame
        hiddenView.frame.origin.x = frame.width
        
        firstRoundView.visible = shownView === self.firstRoundContainerView
        secondRoundView.visible = shownView === self.secondRoundContainerView
    }
    
    func scrollToNextRoundView(completionHandler: () -> Void) {
        let animationDuration = 0.6
        var viewToShow = firstRoundContainerView
        var viewToHide = secondRoundContainerView
        
        if firstRoundContainerView.frame.origin.x == 0.0 {
            viewToShow = secondRoundContainerView
            viewToHide = firstRoundContainerView
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseOut, animations: {
            viewToShow.frame.origin.x = 0.0
            viewToHide.frame.origin.x = -self.frame.width
            
            }, completion: { _ in
                viewToHide.frame.origin.x = self.frame.width
                
                self.firstRoundView.visible = viewToShow === self.firstRoundContainerView
                self.secondRoundView.visible = viewToShow === self.secondRoundContainerView
                
                completionHandler()
        })
    }
    
    func setTieOddsVisible(visible: Bool, tieProbability: Double?, animated: Bool, completion: (() -> Void)? = nil) {
        if let tieProbability = tieProbability {
            tieOddsLabel.text = R.string.localizable.textTieOdds(tieProbability)
        }
        
        let animationDuration = animated ? 0.4 : 0.0
        UIView.animateWithDuration(animationDuration, animations: {
            self.tieOddsLabel.alpha = visible ? 1.0 : 0.0
        }, completion: { _ in
            completion?()
        })
    }
    
    func setTimeBonusVisible(visible: Bool, bonus: Int64?, animated: Bool, completion: (() -> Void)? = nil) {
        if let bonus = bonus {
            timeBonusLabel.morphingEnabled = timeBonusLabel.alpha != 0
            timeBonusLabel.text = R.string.localizable.textTimeBonus(bonus.formattedChipsCountString(needsReplaceZerosWithO: false))
        }
        
        let animationDuration = animated ? 0.4 : 0.0
        UIView.animateWithDuration(animationDuration, animations: {
            self.timeBonusLabel.alpha = visible ? 1.0 : 0.0
        }, completion: { _ in
            completion?()
        })
    }
}
