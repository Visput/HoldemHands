//
//  GameView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameView: UIView {
    
    @IBOutlet private(set) weak var chipsCountLabel: UILabel!
    @IBOutlet private(set) weak var swipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet private(set) weak var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet private(set) weak var firstHandsView: UIView!
    @IBOutlet private(set) weak var secondHandsView: UIView!
    
    func scrollToNextHandsView() {
        let animationDuration = 0.4
        var viewToShow = firstHandsView
        var viewToHide = secondHandsView
        
        if firstHandsView.frame.origin.x == 0.0 {
            viewToShow = secondHandsView
            viewToHide = firstHandsView
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: .CurveEaseInOut, animations: {
            viewToShow.frame.origin.x = 0.0
            viewToHide.frame.origin.x = -self.frame.size.width
            
            }, completion: { _ in
                viewToHide.frame.origin.x = self.frame.size.width
        })
    }
}
