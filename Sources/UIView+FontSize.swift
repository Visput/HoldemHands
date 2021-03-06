//
//  UIView+FontSize.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/14/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

extension UIView {
    
    private struct AssociatedObjectsKey {
        static var key = "AssociatedObjectsKey"
    }
    
    /**
     Adjusts font size according to iPhone screen height. Bigger height means bigger font size.
     For example: iPhone 5 will have smaller fonts sizes than iPhone 6
     Original font size (set in code or storyboard) has to be accurate for iPhone 6 Plus screen size.
     
     - parameter recursively: Set true if you need to adjust font size recursively through subviews.
     */
    func adjustFontSizeRecursively(recursively: Bool) {
        let fontScale = UIScreen.mainScreen().sizeScaleToIPhone6Plus()
        
        if self is UILabel {
            adjustFontSizeForLabelWithScale(fontScale)
        } else {
            guard recursively else { return }
            
            for subview in subviews {
                subview.adjustFontSizeRecursively(true)
            }
        }
    }
    
    private func adjustFontSizeForLabelWithScale(fontScale: CGFloat) {
        let label = self as! UILabel
        let attributedText = label.attributedText?.copy() as? NSAttributedString
        label.font = fontWithFont(label.font, fontScale: fontScale, key: &AssociatedObjectsKey.key)
        label.attributedText = stringWithString(attributedText, fontScale: fontScale, key: &AssociatedObjectsKey.key)
    }
    
    private func fontWithFont(font: UIFont, fontScale: CGFloat, key: UnsafePointer<Void>) -> UIFont {
        guard !isFontScaled(font, key: key) else { return font }
        
        let scaledFont = font.fontWithSize(round(font.pointSize * fontScale))
        setFontScaled(scaledFont, key: key)
        
        return scaledFont
    }
    
    private func stringWithString(string: NSAttributedString?, fontScale: CGFloat, key: UnsafePointer<Void>) -> NSAttributedString? {
        guard string != nil else { return nil }
        
        let mutableString = string!.mutableCopy() as! NSMutableAttributedString
        let stringRange = NSRange(location: 0, length: mutableString.length)
        mutableString.enumerateAttribute(NSFontAttributeName, inRange: stringRange, options: [], usingBlock: { value, range, _ in
            guard value != nil else { return }
            
            let scaledFont = self.fontWithFont(value! as! UIFont, fontScale: fontScale, key: key)
            mutableString.removeAttribute(NSFontAttributeName, range: range)
            mutableString.addAttribute(NSFontAttributeName, value: scaledFont, range: range)
        })
        
        return mutableString.copy() as? NSAttributedString
    }
    
    private func isFontScaled(font: UIFont, key: UnsafePointer<Void>) -> Bool {
        let views = objc_getAssociatedObject(font, key) as? NSHashTable
        guard views != nil else { return false }
        
        var isFontScaled = false
        for aView in views!.allObjects as! [UIView] {
            if self === aView {
                isFontScaled = true
                break
            }
        }
        
        return isFontScaled
    }
    
    private func setFontScaled(font: UIFont, key: UnsafePointer<Void>) {
        // Internal implementation of NSFont allows its instance to be shared between different objects.
        // For example two labels with the same font family and size will use one shared instance of NSFont class.
        // For this reason weak pointer array with views is used. It tracks if font is scaled for requested view.
        guard !isFontScaled(font, key: key) else { return }
        
        var views = objc_getAssociatedObject(font, key) as? NSHashTable
        if views == nil {
            views = NSHashTable.weakObjectsHashTable()
        }
        views!.addObject(self)
        objc_setAssociatedObject(font, key, views, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
