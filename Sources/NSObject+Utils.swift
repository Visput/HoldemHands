//
//  NSObject+Utils.swift
//  Workouter
//
//  Created by Uladzimir Papko on 10/26/15.
//  Copyright © 2015 visput. All rights reserved.
//

import Foundation

extension NSObject {
    
    class func className() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    func executeAfterDelay(delayInSeconds: Double, task: () -> ()) {
        let delayInMilliseconds = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(delayInMilliseconds, dispatch_get_main_queue(), task)
    }
}
