//
//  UIView+Nib.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

extension UIView {
    
    class func fromNib<T: UIView>(nibNameOrNil: String? = nil) -> T {
        let view: T? = fromNib(nibNameOrNil)
        return view!
    }
    
    class func fromNib<T: UIView>(nibNameOrNil: String? = nil) -> T? {
        var view: T? = nil
        var name: String! = nil
        
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly.
            name = "\(T.self)".componentsSeparatedByString(".").last
        }
        
        let nibViews = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        
        for nibView in nibViews {
            if let aNibView = nibView as? T {
                view = aNibView
                break
            }
        }
        return view
    }
}
