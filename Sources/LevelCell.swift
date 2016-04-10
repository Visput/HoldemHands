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
    @IBOutlet private(set) weak var lockedLabel: UILabel!
    @IBOutlet private(set) weak var priceLabel: UILabel!
    @IBOutlet private(set) weak var tableImageView: UIImageView!
    @IBOutlet private(set) weak var handsCountLabel: UILabel!
    @IBOutlet private(set) weak var chipsImageView: UIImageView!
    
    private(set) var item: LevelCellItem!
    
    func fillWithItem(item: LevelCellItem) {
        self.item = item
        
        if item.levelProgress.locked! {
            tableImageView.image = UIImage(named: "background_table_level_locked")
        } else {
            tableImageView.image = UIImage(named: "background_table_level_\(item.levelProgress.level.identifier)")
        }
        handsCountLabel.text = NSString.localizedStringWithFormat("%d hands", item.levelProgress.level.numberOfHands) as String
        levelLabel.text = item.levelProgress.level.name
        
        if item.levelProgress.locked! {
            lockedLabel.hidden = false
            priceLabel.text = item.levelProgress.level.chipsToUnlock.formattedChipsCountString
            
        } else {
            lockedLabel.hidden = true
            priceLabel.text = item.levelProgress.level.chipsPerWin.formattedChipsCountString
        }
    }
}
