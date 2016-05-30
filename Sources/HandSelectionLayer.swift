//
//  HandSelectionLayer.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class HandSelectionLayer: CAShapeLayer {
    
    init(frame: CGRect, scale: CGFloat, isSuccessState: Bool) {
        super.init()
        
        let halfPi = CGFloat(M_PI_2)
        let lineWidth = ceil(3.0 * scale)
        let arcRadius = ceil(12.0 * scale)
        let inset = ceil(-6.0 * scale)
        
        self.frame = frame.insetBy(dx: inset, dy: inset)
        self.lineWidth = lineWidth
        lineJoin = kCALineJoinRound
        fillColor = nil
        
        
        let selectionPath = UIBezierPath()
        // Move to bottom left.
        selectionPath.moveToPoint(CGPoint(x: 0.0, y: bounds.height - arcRadius))
        
        // Draw to top left.
        selectionPath.addLineToPoint(CGPoint(x: 0.0, y: arcRadius))
        selectionPath.addArcWithCenter(CGPoint(x: arcRadius, y: arcRadius),
                                       radius: arcRadius,
                                       startAngle: 2 * halfPi,
                                       endAngle: 3 * halfPi,
                                       clockwise: true)
        // Draw to top right.
        selectionPath.addLineToPoint(CGPoint(x: bounds.width - arcRadius, y: 0.0))
        selectionPath.addArcWithCenter(CGPoint(x: bounds.width - arcRadius, y: arcRadius),
                                       radius: arcRadius,
                                       startAngle: 3 * halfPi,
                                       endAngle: 4 * halfPi,
                                       clockwise: true)
        
        // Draw to bottom right.
        selectionPath.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height - arcRadius))
        selectionPath.addArcWithCenter(CGPoint(x: bounds.width - arcRadius, y: bounds.height - arcRadius),
                                       radius: arcRadius,
                                       startAngle: 0,
                                       endAngle: halfPi,
                                       clockwise: true)
        
        // Draw to bottom left.
        selectionPath.addLineToPoint(CGPoint(x: arcRadius, y: bounds.height))
        selectionPath.addArcWithCenter(CGPoint(x: arcRadius, y: bounds.height - arcRadius),
                                       radius: arcRadius,
                                       startAngle: halfPi,
                                       endAngle: 2 * halfPi,
                                       clockwise: true)
        
        path = selectionPath.CGPath
        
        
        var animation: CABasicAnimation! = nil
        if isSuccessState {
            strokeColor = UIColor.green1Color().CGColor
            
            animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.5
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.removedOnCompletion = false
        } else {
            strokeColor = UIColor.gray3Color().CGColor
            
            animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.4
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.removedOnCompletion = false
        }
        addAnimation(animation, forKey: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
