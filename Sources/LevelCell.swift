//
//  LevelCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/4/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class LevelCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var tableBackgroundImageView: UIImageView!
    @IBOutlet private(set) weak var tableOverlayImageView: UIImageView!
    
    private(set) var item: LevelCellItem!
    
    override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.2, animations: {
                let zoomLevel: CGFloat = self.highlighted ? 0.9 : 1.0
                self.transform = CGAffineTransformMakeScale(zoomLevel, zoomLevel)
            })
        }
    }
    
    func fillWithItem(item: LevelCellItem) {
        self.item = item
        
        if item.levelProgress.locked! {
            tableBackgroundImageView.image = UIImage(named: "background_table_level_locked")
        } else {
            tableBackgroundImageView.image = UIImage(named: "background_table_level_\(item.levelProgress.level.identifier)")
        }
        tableOverlayImageView.image = UIImage(named: "overlay_table_level_\(item.levelProgress.level.identifier)")
    }
}
