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
    @IBOutlet private(set) weak var detailsScrollView: UIScrollView!
    @IBOutlet private(set) weak var levelsContainerView: UIView!
    @IBOutlet private(set) weak var detailsTitleLabel: UILabel!
    
    @IBOutlet private(set) var menuButtons: [UIButton]!
    @IBOutlet private(set) weak var menuView: UIView!
    @IBOutlet private weak var menuViewLeadingSpace: NSLayoutConstraint!
    
    private var isDetailsViewShown: Bool {
        return contentScrollView.contentOffset.x != 0.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let levelsView = levelsContainerView.subviews.first! as! LevelsView
        levelsView.menuSize = menuView.frame.size
    }
    
    func scrollToDetailsViewAtPage(page: Int, completionHandler: (() -> Void)? = nil) {
        guard !menuButtons[page].selected else {
            completionHandler?()
            return
        }
        
        selectMenuButtonForPage(page)
        
        if isDetailsViewShown {
            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.detailsScrollView.contentOffset = CGPoint(x: 0.0, y: self.detailsScrollView.frame.size.height * CGFloat(page))
                }, completion: { _ in
                    completionHandler?()
            })
        } else {
            detailsScrollView.contentOffset = CGPoint(x: 0.0, y: detailsScrollView.frame.size.height * CGFloat(page))
            scrollToDetailsView(completionHandler)
        }
    }
    
    func selectMenuButtonForPage(page: Int) {
        for (index, button) in menuButtons.enumerate() {
            button.selected = index == page
        }
    }
    
    private func scrollToDetailsView(completionHandler: (() -> Void)? = nil) {
        menuViewLeadingSpace.constant = -menuView.frame.size.width
        layoutIfNeeded()
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.bounds.size.width, y: 0.0)
            
            }, completion: { _ in
                completionHandler?()
                
                // Show menu.
                UIView.animateWithDuration(0.3, delay: 0.3, options: .CurveEaseOut, animations: {
                    self.menuViewLeadingSpace.constant = 0.0
                    self.layoutIfNeeded()
                    }, completion: nil)
        })
    }
}
