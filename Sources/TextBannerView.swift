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
    
    func presentInView(view: UIView,
                       withText text: String,
                       backgroundImage: UIImage? = nil,
                       duration: NSTimeInterval = 0.0,
                       tapHandler: (() -> Void)? = nil) {
        
        textLabel.text = text
        fixLineSpacing()
        if backgroundImage != nil {
            backgroundImageView.image = backgroundImage
        }
        super.presentInView(view, duration: duration, tapHandler: tapHandler)
    }
    
    private func fixLineSpacing() {
        // App custom font has very small line spacing.
        // Increase space manually.
        let maxLineSpacing = CGFloat(8)
        
        let attributedText = NSMutableAttributedString(string: textLabel.text!)
        let textRange = NSRange(location: 0, length: attributedText.length)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = maxLineSpacing * UIScreen.mainScreen().sizeScaleToIPhone6Plus()
        paragraphStyle.alignment = .Center
        attributedText.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:textRange)
        attributedText.addAttribute(NSFontAttributeName, value: textLabel.font, range: textRange)
        
        textLabel.attributedText = attributedText
        adjustFontSizeRecursively(false)
    }
}
