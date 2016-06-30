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
    
    class func execute(action: (completion: (succeed: Bool) -> Void) -> Void) -> SimpleTask {
        return SimpleTask(initClosure: { progress, fulfill, reject, configure in
            action { succeed in
                if succeed {
                    fulfill()
                } else {
                    reject()
                }
            }
        })
    }
    
    class func delay(delayInSeconds: Double) -> SimpleTask {
        return SimpleTask.execute({ completion in
            let delayInMilliseconds = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(delayInMilliseconds, dispatch_get_main_queue(), {
                completion(succeed: true)
            })
        })
    }
    
    class func empty() -> SimpleTask {
        return execute({ completion in
            completion(succeed: true)
        })
    }
    
    func then(taskClosure: () -> SimpleTask) -> SimpleTask {
        return then({ value, error -> SimpleTask in
            return taskClosure()
        })
    }
    
    func thenDo(doClosure: () -> Void) -> SimpleTask {
        return then {
            return SimpleTask.execute({ completion in
                doClosure()
                completion(succeed: true)
            })
        }
    }
    
    func success(taskClosure: () -> SimpleTask) -> SimpleTask {
        return success({ value -> SimpleTask in
            return taskClosure()
        })
    }
    
    func successDo(doClosure: () -> Void) -> SimpleTask {
        return success {
            return SimpleTask.execute({ completion in
                doClosure()
                completion(succeed: true)
            })
        }
    }
    
    func failure(taskClosure: () -> SimpleTask) -> SimpleTask {
        return failure({ error -> SimpleTask in
            return taskClosure()
        })
    }
    
    func failureDo(doClosure: () -> Void) -> SimpleTask {
        return failure {
            return SimpleTask.execute({ completion in
                doClosure()
                completion(succeed: true)
            })
        }
    }
    
    func on(success: (() -> Void)? = nil, failure: (() -> Void)? = nil) {
        on(success: { value in
            success?()
        }, failure: { error, isCancelled in
            failure?()
        })
    }
}

extension Task {
    
    class func animateWithDuration(duration: NSTimeInterval,
                                   delay: NSTimeInterval = 0,
                                   options: UIViewAnimationOptions = [],
                                   animations: () -> Void) -> SimpleTask {
        return SimpleTask.execute({ completion in
            UIView.animateWithDuration(duration,
                delay: delay,
                options: options,
                animations: animations,
                completion: { _ in
                    completion(succeed: true)
            })
        })
    }
}
