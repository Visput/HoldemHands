//
//  CustomFontLabel.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/30/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class CustomFontLabel: UILabel {
    
    override func drawTextInRect(rect: CGRect) {
        let pointSize = font.pointSize
        var newRect = rect
        newRect.origin.y -= pointSize * 0.1
        
        super.drawTextInRect(newRect)
    }
}
