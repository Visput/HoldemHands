//
//  UIView+FontSize.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/14/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

extension UIView {
    
    private static var labelKey = "LabelKey"
    
    /**
     Adjusts font size according to iPhone screen height. Bigger height means bigger font size.
     For example: iPhone 5 will have smaller fonts sizes than iPhone 6
     Original font size (set in code or storyboard) has to be accurate for iPhone 6 Plus screen size.
     
     - parameter recursively: Set true if you need to adjust font size recursively through subviews.
     */
    func adjustFontSizeRecursively(recursively: Bool) {
        let screenDimensionIPhone6Plus: CGFloat = 414.0
        let screenSize = UIApplication.sharedApplication().keyWindow!.bounds.size
        let screenDimension = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? screenSize.width : screenSize.height
        let fontScale = screenDimension / screenDimensionIPhone6Plus
        
        if self is UILabel {
            var label = self as! UILabel
            adjustFontSizeForLabel(&label, fontScale: fontScale)
        } else {
            guard recursively else { return }
            
            for subview in subviews {
                subview.adjustFontSizeRecursively(true)
            }
        }
    }
    
    private func adjustFontSizeForLabel(inout label: UILabel, fontScale: CGFloat) {
        let attributedText = label.attributedText?.copy() as? NSAttributedString
        var view = label as UIView
        label.font = fontWithFont(label.font, fontScale: fontScale, view: &view, key: &UIView.labelKey)
        label.attributedText = stringWithString(attributedText, fontScale: fontScale, view: &view, key: &UIView.labelKey)
    }
    
    private func fontWithFont(font: UIFont, fontScale: CGFloat, inout view: UIView, key: UnsafePointer<Void>) -> UIFont {
        guard !isFontScaled(font, forView: view, key: key) else { return font }
        
        let scaledFont = font.fontWithSize(round(font.pointSize * fontScale))
        setFontScaled(scaledFont, forView: &view, key: key)
        
        return scaledFont
    }
    
    private func stringWithString(string: NSAttributedString?,
                                  fontScale: CGFloat,
                                  inout view: UIView,
                                  key: UnsafePointer<Void>) -> NSAttributedString? {
        guard string != nil else { return nil }
        
        let mutableString = string!.mutableCopy() as! NSMutableAttributedString
        let stringRange = NSRange(location: 0, length: mutableString.length)
        mutableString.enumerateAttribute(NSFontAttributeName, inRange: stringRange, options: [], usingBlock: { value, range, _ in
            guard value != nil else { return }
            
            let scaledFont = self.fontWithFont(value! as! UIFont, fontScale: fontScale, view: &view, key: key)
            mutableString.removeAttribute(NSFontAttributeName, range: range)
            mutableString.addAttribute(NSFontAttributeName, value: scaledFont, range: range)
        })
        
        return mutableString.copy() as? NSAttributedString
    }
    
    private func isFontScaled(font: UIFont, forView view: UIView, key: UnsafePointer<Void>) -> Bool {
        let views = objc_getAssociatedObject(font, key) as? NSHashTable
        guard views != nil else { return false }
        
        var isFontScaled = false
        for aView in views!.allObjects as! [UIView] {
            if view === aView {
                isFontScaled = true
                break
            }
        }
        
        return isFontScaled
    }
    
    private func setFontScaled(font: UIFont, inout forView view: UIView, key: UnsafePointer<Void>) {
        // Internal implementation of NSFont allows its instance to be shared between different objects.
        // For example two labels with the same font family and size will use one shared instance of NSFont class.
        // For this reason weak pointer array with views is used. It tracks if font is scaled for requested view.
        guard !isFontScaled(font, forView: view, key: key) else { return }
        
        var views = objc_getAssociatedObject(font, key) as? NSHashTable
        if views == nil {
            views = NSHashTable.weakObjectsHashTable()
        }
        views!.addObject(view)
        objc_setAssociatedObject(font, key, views, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
