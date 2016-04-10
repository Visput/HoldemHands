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
    @IBOutlet private weak var menuViewWidth: NSLayoutConstraint!
    
    var isDetailsViewShown: Bool {
        return contentScrollView.contentOffset.x != 0.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let levelsView = levelsContainerView.subviews.first! as! LevelsView
        menuViewWidth.constant = levelsView.levelsCollectionLayout.sectionInset.left - levelsView.levelsCollectionLayout.minimumInteritemSpacing
    }
    
    func scrollToLevelsView() {
        selectMenuButtonForPage(0)
        if isDetailsViewShown {
            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.detailsScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
                }, completion: nil)
        } else {
            scrollToDetailsView()
        }
    }
    
    func scrollToStatsView() {
        selectMenuButtonForPage(1)
        if isDetailsViewShown {
            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.detailsScrollView.contentOffset = CGPoint(x: 0.0, y: self.detailsScrollView.frame.size.height)
                }, completion: nil)
        } else {
            detailsScrollView.contentOffset = CGPoint(x: 0.0, y: detailsScrollView.frame.size.height)
            scrollToDetailsView()
        }
    }
    
    func scrollToSharingView() {
        selectMenuButtonForPage(2)
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.detailsScrollView.contentOffset = CGPoint(x: 0.0, y: 2.0 * self.detailsScrollView.frame.size.height)
            }, completion: nil)
    }
    
    func selectMenuButtonForCurrentPage() {
        let page = lroundf(Float(detailsScrollView.contentOffset.y / detailsScrollView.frame.size.height))
        selectMenuButtonForPage(page)
    }
    
    private func selectMenuButtonForPage(page: Int) {
        for (index, button) in menuButtons.enumerate() {
            button.selected = index == page
        }
    }
    
    private func scrollToDetailsView() {
        menuViewLeadingSpace.constant = -menuViewWidth.constant
        layoutIfNeeded()
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.bounds.size.width, y: 0.0)
            
            }, completion: { _ in
                UIView.animateWithDuration(0.3, delay: 0.3, options: .CurveEaseOut, animations: {
                    self.menuViewLeadingSpace.constant = 0.0
                    self.layoutIfNeeded()
                    }, completion: nil)
        })
    }
}
