//
//  UIScreen+SizeRatio.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/30/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

extension UIScreen {
    
    func sizeScaleToIPhone6Plus() -> CGFloat {
        let screenDimensionIPhone6Plus: CGFloat = 414.0
        let screenSize = bounds.size
        let screenDimension = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? screenSize.width : screenSize.height
        let scale = screenDimension / screenDimensionIPhone6Plus
        
        return scale
    }
}
