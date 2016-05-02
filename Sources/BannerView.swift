//
//  BannerView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

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
                       tapHandler: (() -> Void)? = nil) {
        
        self.tapHandler = tapHandler
        presented = true
        
        frame.origin.x = (view.bounds.size.width - bounds.size.width) / 2.0
        frame.origin.y = -bannerSize.height
        view.addSubview(self)
        view.addGestureRecognizer(swipeRecognizer)
        
        UIView.animateWithDuration(animationDuration,
                                   delay: 0.0,
                                   options: .CurveEaseOut,
                                   animations: { () -> Void in
                                    self.frame.origin.y = 0.0
                                    
            }, completion: { _ in
                if duration != 0.0 {
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(duration,
                        target: self,
                        selector: #selector(BannerView.dismissByTimer),
                        userInfo: nil,
                        repeats: false)
                }
        })
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        timer?.invalidate()
        timer = nil
        superview?.removeGestureRecognizer(swipeRecognizer)
        tapHandler = nil
        
        UIView.animateWithDuration(animationDuration,
                                   delay: 0.0,
                                   options: .CurveEaseOut,
                                   animations: { () -> Void in
                                    self.frame.origin.y = -self.bannerSize.height
                                    
            }, completion: { _ in
                self.removeFromSuperview()
                self.presented = false
                completion?()
        })
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
