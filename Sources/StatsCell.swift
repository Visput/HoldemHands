//
//  StatsCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var statsContentView: UIView!
    @IBOutlet private(set) weak var noStatsView: UIView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var winPercentLabel: UILabel!
    @IBOutlet private(set) weak var winsInRowLabel: UILabel!
    @IBOutlet private(set) weak var handsCountLabel: UILabel!
    @IBOutlet private(set) weak var rankLabel: UILabel!
 
    private(set) var item: StatsCellItem!
    
    func fillWithItem(item: StatsCellItem) {
        self.item = item
        
        nameLabel.text = item.progressItem.title
        
        if item.progressItem.handsCount != 0 {
            statsContentView.hidden = false
            noStatsView.hidden = true

            winPercentLabel.text = NSString(format: "%.2f%%", item.progressItem.winPercent) as String
            winsInRowLabel.text = String(item.progressItem.maxWinsCountInRow)
            handsCountLabel.text = String(item.progressItem.handsCount)
            rankLabel.text = item.progressItem.rank != nil ? String(item.progressItem.rank!) : "-"
        } else {
            statsContentView.hidden = true
            noStatsView.hidden = false
        }
    }
}
