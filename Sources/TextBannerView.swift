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
    @IBOutlet private(set) weak var backgroundImageView: UIImageView!
    
    func presentInView(view: UIView, withText
        text: String,
        backgroundImage: UIImage? = nil,
        duration: NSTimeInterval = 0.0,
        tapHandler: (() -> Void)? = nil) {
        
        textLabel.text = text
        if backgroundImage != nil {
            backgroundImageView.image = backgroundImage
        }
        super.presentInView(view, duration: duration, tapHandler: tapHandler)
    }
}
