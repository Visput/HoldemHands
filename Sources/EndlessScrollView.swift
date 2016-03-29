//
//  EndlessScrollView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/28/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class EndlessScrollView: UIScrollView, UIScrollViewDelegate {
    
    @IBOutlet var viewObjects: [UIView]! {
        didSet {
            configure()
        }
    }
    
    var didShowViewHandler: ((view: UIView) -> Void)?
    var didHideViewHandler: ((view: UIView) -> Void)?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configure()
    }
    
    func scrollToNextPage(animated: Bool) {
        let animationDuration = 0.4
        let pageWidth = frame.size.width
        let page = currentPage()
        let viewToHide = viewObjects[viewIndexForPage(page)]
        let viewToShow = viewObjects[viewIndexForPage(page + 1)]
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.contentOffset.x -= pageWidth
            }, completion: { _ in
                self.didHideViewHandler?(view: viewToHide)
                self.didShowViewHandler?(view: viewToShow)
                self.scrollViewDidEndDecelerating(self)
        })
    }
    
    private func configure() {
        pagingEnabled = true
        delegate = self
        
        guard viewObjects != nil else { return }
        guard superview != nil else { return }
        
        contentSize = CGSize(width: frame.size.width * CGFloat(viewObjects.count + 2), height: frame.size.height)
        
        loadScrollViewWithPage(0)
        loadScrollViewWithPage(1)
        loadScrollViewWithPage(2)
        
        var newFrame = frame
        newFrame.origin.x = newFrame.size.width
        newFrame.origin.y = 0
        scrollRectToVisible(newFrame, animated: false)
        
        layoutIfNeeded()
    }
    
    private func loadScrollViewWithPage(page: Int) {
        guard page >= 0 else { return }
        guard page < viewObjects.count + 2 else { return }
        
        let index = viewIndexForPage(page)
        let view = viewObjects[index]
        
        var newFrame = frame
        newFrame.origin.x = frame.size.width * CGFloat(page)
        newFrame.origin.y = 0
        view.frame = newFrame
        
        if view.superview == nil {
            addSubview(view)
        }
        
        layoutIfNeeded()
    }
    
    private func currentPage() -> Int {
        let pageWidth = frame.size.width
        let page = Int(floor((contentOffset.x - pageWidth / 2.0) / pageWidth) + 1.0)
        
        return page
    }
    
    private func viewIndexForPage(page: Int) -> Int {
        var index = 0
        if page == 0 {
            index = viewObjects.count - 1
        } else if page == viewObjects.count + 1 {
            index = 0
        } else {
            index = page - 1
        }
        
        return index
    }
    
    @objc func scrollViewDidScroll(scrollView: UIScrollView) {
        let page = currentPage()
        
        loadScrollViewWithPage(page - 1)
        loadScrollViewWithPage(page)
        loadScrollViewWithPage(page + 1)
    }
    
    @objc func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page = currentPage()
        
        if page == 0 {
            contentOffset = CGPoint(x: pageWidth * CGFloat(viewObjects.count), y: 0.0)
        } else if page == viewObjects.count + 1 {
            contentOffset = CGPoint(x: pageWidth, y: 0.0)
        }
    }
}
