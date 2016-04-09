//
//  MainView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainView: UIView {
    
    @IBOutlet private(set) weak var contentScrollView: UIScrollView!
    
    var isMenuShown: Bool {
        return contentScrollView.contentOffset.x == 0.0
    }
    
    func scrollToLevelsView() {
        UIView.animateWithDuration(0.6,
            delay: 0.0,
            options: .CurveEaseInOut,
            animations: { () -> Void in
                self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.bounds.size.width, y: 0.0)
            }, completion: nil)
    }
}
