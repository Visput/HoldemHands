//
//  UIScreen+Size.swift
//  Workouter
//
//  Created by Uladzimir Papko on 11/27/15.
//  Copyright © 2015 visput. All rights reserved.
//

import UIKit

// swiftlint:disable type_name
enum SizeType: CGFloat {
    case Unknown = 0.0
    case iPhone4 = 960.0
    case iPhone5 = 1136.0
    case iPhone6 = 1334.0
    case iPhone6Plus = 1920.0
}

extension UIScreen {
    
    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}
