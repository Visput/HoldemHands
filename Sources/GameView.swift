//
//  GameView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameView: UIView {
    
    @IBOutlet private(set) weak var swipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet private(set) weak var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet private(set) weak var levelNameLabel: UILabel!
    
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
        let offset: CGFloat = 65.0
        
        var shownView = firstHandsView
        var hiddenView = secondHandsView
        
        if firstHandsView.frame.origin.x != 0.0 {
            shownView = secondHandsView
            hiddenView = firstHandsView
        }
        var initialFrame = bounds
        initialFrame.origin.y = offset
        initialFrame.size.height -= offset
        
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
}
