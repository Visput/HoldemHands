//
//  GameScreenView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import UICountingLabel

final class GameScreenView: UIView {

    @IBOutlet private(set) weak var levelNameLabel: UILabel!
    @IBOutlet private(set) weak var tieOddsLabel: UILabel!
    @IBOutlet private(set) weak var tapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet private(set) weak var timeBonusLabel: UICountingLabel! {
        didSet {
            timeBonusLabel.animationDuration = 2.0
            timeBonusLabel.method = .Linear
            timeBonusLabel.formatBlock = { chipsCount -> String in
                let chipsCountString = Int64(chipsCount).formattedChipsCountString()
                var text: String! = nil
                if self.currentBonusMultiplier > 1 {
                    text = R.string.localizable.textTimeBonusWithMultiplier(chipsCountString, String(self.currentBonusMultiplier))
                } else {
                    text = R.string.localizable.textTimeBonus(chipsCountString)
                }
                return text
            }
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
    
    private var currentBonusMultiplier = Int64(0)
    
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
    
    func scrollToNextRoundView() -> SimpleTask {
        let animationDuration = 0.6
        var viewToShow = firstRoundContainerView
        var viewToHide = secondRoundContainerView
        
        if firstRoundContainerView.frame.origin.x == 0.0 {
            viewToShow = secondRoundContainerView
            viewToHide = firstRoundContainerView
        }
        
        return SimpleTask.animateWithDuration(animationDuration, options: .CurveEaseOut) {
            viewToShow.frame.origin.x = 0.0
            viewToHide.frame.origin.x = -self.frame.width
        }.thenDo {
            viewToHide.frame.origin.x = self.frame.width
            
            self.firstRoundView.visible = viewToShow === self.firstRoundContainerView
            self.secondRoundView.visible = viewToShow === self.secondRoundContainerView
        }
    }
    
    func setTieOddsVisible(visible: Bool, tieProbability: Double?, animated: Bool) -> SimpleTask {
        if let tieProbability = tieProbability {
            tieOddsLabel.text = R.string.localizable.textTieOdds(tieProbability)
        }
        
        let animationDuration = animated ? 0.4 : 0.0
        return SimpleTask.animateWithDuration(animationDuration) {
            self.tieOddsLabel.alpha = visible ? 1.0 : 0.0
        }
    }
    
    func setTimeBonusVisible(visible: Bool, bonus: Int64?, bonusMultiplier: Int64?, animated: Bool) -> SimpleTask {
        var needsToShow = visible
        
        if let bonus = bonus, bonusMultiplier = bonusMultiplier {
            let animationDuration = timeBonusLabel.alpha != 0 ? 2.0 : 0.0
            currentBonusMultiplier = bonusMultiplier
            timeBonusLabel.countFromCurrentValueTo(CGFloat(bonus), withDuration: animationDuration)
            
            needsToShow = visible && bonus != 0
        }
        
        let animationDuration = animated ? 0.4 : 0.0
        return SimpleTask.animateWithDuration(animationDuration) {
            self.timeBonusLabel.alpha = needsToShow ? 1.0 : 0.0
        }
    }
}
