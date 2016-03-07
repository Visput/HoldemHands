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
    
    private(set) var item: GameLevelCellItem!
    
    func fillWithItem(item: GameLevelCellItem) {
        self.item = item
        
        levelLabel.text = item.level.name
        playButton.tag = item.buttonsTag
        if item.locked {
            playButton.enabled = false
            playButton.setTitle(NSLocalizedString("Locked", comment: ""), forState: .Normal)
            backgroundColor = UIColor.secondaryTextColor()
            
        } else {
            playButton.enabled = true
            playButton.setTitle(NSLocalizedString("Play", comment: ""), forState: .Normal)
            backgroundColor = UIColor.primaryColor()
        }
    }
}
