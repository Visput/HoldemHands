//
//  GameScreenView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameScreenView: UIView {

    @IBOutlet private(set) weak var levelNameLabel: UILabel!
    @IBOutlet private(set) weak var tieOddsLabel: UILabel!
    @IBOutlet private(set) weak var tapRecognizer: UITapGestureRecognizer!
    
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
    
    @IBOutlet private(set) weak var firstHandsView: UIView! {
        didSet {
            firstHandsView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet private(set) weak var secondHandsView: UIView! {
        didSet {
            secondHandsView.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        var shownView = firstHandsView
        var hiddenView = secondHandsView
        
        if firstHandsView.frame.origin.x != 0.0 {
            shownView = secondHandsView
            hiddenView = firstHandsView
        }
        var initialFrame = bounds
        initialFrame.origin.y = levelNameLabel.frame.origin.y + levelNameLabel.frame.size.height
        initialFrame.size.height = tieOddsLabel.frame.origin.y - initialFrame.origin.y
        
        shownView.frame = initialFrame
        hiddenView.frame = initialFrame
        hiddenView.frame.origin.x = frame.size.width
    }
    
    func scrollToNextHandsView(completionHandler: () -> Void) {
        let animationDuration = 0.6
        var viewToShow = firstHandsView
        var viewToHide = secondHandsView
        
        if firstHandsView.frame.origin.x == 0.0 {
            viewToShow = secondHandsView
            viewToHide = firstHandsView
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseOut, animations: {
            viewToShow.frame.origin.x = 0.0
            viewToHide.frame.origin.x = -self.frame.size.width
            
            }, completion: { _ in
                viewToHide.frame.origin.x = self.frame.size.width
                completionHandler()
        })
    }
    
    func setTieOddsVisible(visible: Bool, tieProbability: Double?) {
        if tieProbability != nil {
            self.tieOddsLabel.text = R.string.localizable.textTieOdds(tieProbability!)
        }
        
        UIView.animateWithDuration(0.4, animations: {
            self.tieOddsLabel.alpha = visible ? 1.0 : 0.0
        })
    }
}
