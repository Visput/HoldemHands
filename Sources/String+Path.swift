//
//  String+Path.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/14/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

extension String {
    
    func pathInDocumentsDirectory() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
        return documentsDirectory.stringByAppendingPathComponent(self)
    }
    
    func pathInResourcesBundle() -> String {
        let nameComponents = componentsSeparatedByString(".")
        return NSBundle.mainBundle().pathForResource(nameComponents.first, ofType: nameComponents.last)!
    }
}
