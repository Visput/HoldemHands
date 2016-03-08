//
//  GameLevelCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/4/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameLevelCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var levelLabel: UILabel!
    @IBOutlet private(set) weak var playButton: UIButton!
    @IBOutlet private(set) weak var unlockButton: UIButton!
    @IBOutlet private(set) weak var lockedLabel: UILabel!
    @IBOutlet private(set) weak var priceLabel: UILabel!
    
    private(set) var item: GameLevelCellItem!
    
    func fillWithItem(item: GameLevelCellItem) {
        self.item = item
        
        levelLabel.text = item.level.name
        playButton.tag = item.buttonsTag
        unlockButton.tag = item.buttonsTag
        priceLabel.text = NSString(format: NSLocalizedString("Chips: %.0f", comment: ""), item.level.chipsToUnlock) as String
        if item.locked {
            if item.canUnlock {
                unlockButton.hidden = false
                lockedLabel.hidden = true
                priceLabel.hidden = false
            } else {
                unlockButton.hidden = true
                lockedLabel.hidden = false
                priceLabel.hidden = false
            }
            
            playButton.hidden = true
            backgroundColor = UIColor.secondaryTextColor()
            
        } else {
            playButton.hidden = false
            unlockButton.hidden = true
            lockedLabel.hidden = true
            priceLabel.hidden = true
            backgroundColor = UIColor.primaryColor()
        }
    }
}
