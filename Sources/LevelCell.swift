//
//  LevelCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/4/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class LevelCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var levelLabel: UILabel!
    @IBOutlet private(set) weak var playButton: UIButton!
    @IBOutlet private(set) weak var lockedLabel: UILabel!
    @IBOutlet private(set) weak var priceLabel: UILabel!
    
    private(set) var item: LevelCellItem!
    
    func fillWithItem(item: LevelCellItem) {
        self.item = item
        
        levelLabel.text = item.levelProgress.level.name
        playButton.tag = item.buttonsTag
        priceLabel.text = NSString(format: NSLocalizedString("Chips: %lld", comment: ""), item.levelProgress.level.chipsToUnlock) as String
        if item.levelProgress.locked! {
            lockedLabel.hidden = false
            priceLabel.hidden = false
            
            playButton.hidden = true
            
        } else {
            playButton.hidden = false
            lockedLabel.hidden = true
            priceLabel.hidden = true
        }
    }
}
