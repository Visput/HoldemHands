//
//  MainScreenView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreenView: UIView {
    
    enum DetailsViewPage: Int {
        case Levels = 0
        case Stats = 1
        case Sharing = 2
    }
    
    var currentDetailsPage: DetailsViewPage?
    
    @IBOutlet private(set) weak var contentScrollView: UIScrollView!
    @IBOutlet private(set) weak var detailsScrollView: UIScrollView!
    @IBOutlet private(set) weak var levelsContainerView: UIView!
    @IBOutlet private(set) weak var statsContainerView: UIView!
    @IBOutlet private(set) weak var sharingContainerView: UIView!
    @IBOutlet private(set) weak var detailsTitleLabel: UILabel!
    @IBOutlet private(set) weak var headerGradientView: UIImageView!
    @IBOutlet private(set) weak var leaderboardsButton: UIButton!
    
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
        
        let statsView = statsContainerView.subviews.first! as! StatsView
        statsView.menuSize = menuView.frame.size
    }
    
    func scrollToDetailsViewAtPage(page: DetailsViewPage, animated: Bool, completionHandler: (() -> Void)? = nil) {
        if !animated {
            // Layout if called without animation.
            // It's needed to fix layout issue when app is launched by app shortcut (3D Touch).
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        let pageIndex = page.rawValue
        guard !menuButtons[pageIndex].selected else {
            completionHandler?()
            return
        }
        
        updateDetailsViewHeaderWithPage(pageIndex)
        selectMenuButtonForPage(pageIndex)
        
        if isDetailsViewShown {
            let animationDuration = animated ? 0.4 : 0.0
            UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.detailsScrollView.contentOffset = CGPoint(x: 0.0, y: self.detailsScrollView.frame.height * CGFloat(pageIndex))
            }, completion: { _ in
                completionHandler?()
            })
        } else {
            detailsScrollView.contentOffset = CGPoint(x: 0.0, y: detailsScrollView.frame.height * CGFloat(pageIndex))
            scrollToDetailsViewAnimated(animated, completionHandler: completionHandler)
        }
    }
    
    func selectMenuButtonForPage(page: Int) {
        for (index, button) in menuButtons.enumerate() {
            button.selected = index == page
        }
    }
    
    func updateDetailsViewHeaderWithPage(page: Int) {
        UIView.transitionWithView(detailsTitleLabel, duration: 0.4, options: [.TransitionCrossDissolve], animations: {
            var text: String! = nil
            
            switch DetailsViewPage(rawValue: page)! {
            case .Levels:
                text = R.string.localizable.titleDetailsLevels()
                self.leaderboardsButton.alpha = 0.0
            case .Stats:
                text = R.string.localizable.titleDetailsStats()
                self.leaderboardsButton.alpha = 1.0
            case .Sharing:
                self.leaderboardsButton.alpha = 0.0
                text = R.string.localizable.titleDetailsSharing()
            }
            
            self.detailsTitleLabel.text = text
            }, completion: nil)
    }
    
    private func scrollToDetailsViewAnimated(animated: Bool, completionHandler: (() -> Void)? = nil) {
        menuViewLeadingSpace.constant = -menuView.frame.width
        layoutIfNeeded()
        
        let animationDuration = animated ? 0.6 : 0.0
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.bounds.width, y: 0.0)
            
        }, completion: { _ in
            completionHandler?()
            
            // Show menu and gradient header.
            UIView.animateWithDuration(0.3, delay: 0.3, options: .CurveEaseOut, animations: {
                self.menuViewLeadingSpace.constant = 0.0
                self.headerGradientView.alpha = 1.0
                self.layoutIfNeeded()
            }, completion: nil)
        })
    }
}
