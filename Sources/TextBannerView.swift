//
//  TextBannerView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class TextBannerView: BannerView {
    
    @IBOutlet private(set) weak var textLabel: UILabel!
    
    func showInView(view: UIView, withText
        text: String,
        duration: NSTimeInterval = 0.0,
        tapHandler: (() -> Void)? = nil) {
            
            textLabel.text = text
            super.showInView(view, duration: duration, tapHandler: tapHandler)
    }
}
