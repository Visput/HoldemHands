//
//  StatsCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var chipsCountLabel: UILabel!
    @IBOutlet private(set) weak var winPercentLabel: UILabel!
    @IBOutlet private(set) weak var handsCountLabel: UILabel!
    @IBOutlet private(set) weak var winsInRowLabel: UILabel!
 
    private(set) var item: StatsCellItem!
    
    func fillWithItem(item: StatsCellItem) {
        self.item = item
    }
}
