//
//  Task+Simple.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 6/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import SwiftTask

typealias SimpleTask = Task<Float, Void, Void>

extension Task {
    
    class func empty() -> SimpleTask {
        return SimpleTask(initClosure: { progress, fulfill, reject, configure in
            fulfill()
        })
    }
    
    class func animateWithDuration(duration: NSTimeInterval,
                                   delay: NSTimeInterval = 0,
                                   options: UIViewAnimationOptions = [],
                                   animations: () -> Void) -> SimpleTask {
        return SimpleTask(initClosure: { progress, fulfill, reject, configure in
            UIView.animateWithDuration(duration,
                delay: delay,
                options: options,
                animations: animations,
                completion: { _ in
                    fulfill()
            })
        })
    }
    
    func then(nextClosure: () -> SimpleTask) -> SimpleTask {
        return then({ value, errorInfo -> SimpleTask in
            return nextClosure()
        })
    }
    
    func thenDo(doClosure: () -> Void) -> SimpleTask {
        return then {
            return SimpleTask(initClosure: { progress, fulfill, reject, configure in
                doClosure()
                fulfill()
            })
        }
    }
}
