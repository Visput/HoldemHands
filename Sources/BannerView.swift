//
//  BannerView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import SwiftTask

class BannerView: UIControl {
    
    private(set) var presented = false
    
    private let animationDuration: NSTimeInterval = 0.5
    private var bannerSize = CGSize(width: 344.0, height: 66.0)
    
    private var tapHandler: (() -> Void)?
    private var timer: NSTimer?
    private var swipeRecognizer: UISwipeGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func presentInView(view: UIView,
                       duration: NSTimeInterval = 0.0,
                       tapHandler: (() -> Void)? = nil) -> SimpleTask {
        
        self.tapHandler = tapHandler
        presented = true
        
        frame.origin.x = (view.bounds.width - bounds.width) / 2.0
        frame.origin.y = -bannerSize.height
        view.addSubview(self)
        view.addGestureRecognizer(swipeRecognizer)
        
        return SimpleTask.animateWithDuration(animationDuration, options: .CurveEaseOut) {
            self.frame.origin.y = 0.0
        }.thenDo {
            if duration != 0.0 {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(duration,
                    target: self,
                    selector: #selector(BannerView.dismissByTimer),
                    userInfo: nil,
                    repeats: false)
            }
        }
    }
    
    func dismiss() -> SimpleTask {
        timer?.invalidate()
        timer = nil
        superview?.removeGestureRecognizer(swipeRecognizer)
        tapHandler = nil
        
        return SimpleTask.animateWithDuration(animationDuration, options: .CurveEaseOut) {
            self.frame.origin.y = -self.bannerSize.height
        }.thenDo {
            self.removeFromSuperview()
            self.presented = false
        }
    }
}

extension BannerView {
    
    private func initialize() {
        let sizeScale = UIScreen.mainScreen().sizeScaleToIPhone6Plus()
        bannerSize.width *= sizeScale
        bannerSize.height *= sizeScale
        frame.size = bannerSize
        
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(BannerView.dismissBySwipe))
        swipeRecognizer.direction = .Up
        
        addTarget(self, action: #selector(BannerView.bannerDidTap(_:)), forControlEvents: .TouchUpInside)
    }
    
    @objc private func bannerDidTap(sender: AnyObject) {
        tapHandler?()
        dismiss()
    }
    
    @objc private func dismissByTimer() {
        dismiss()
    }
    
    @objc private func dismissBySwipe() {
        dismiss()
    }
}
