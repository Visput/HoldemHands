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
    @IBOutlet private(set) weak var chipsCountLabel: UILabel!
    @IBOutlet private(set) weak var winPercentLabel: UILabel!
    @IBOutlet private(set) weak var winsInRowLabel: UILabel!
    @IBOutlet private(set) weak var handsCountLabel: UILabel!
 
    private(set) var item: StatsCellItem!
    
    func fillWithItem(item: StatsCellItem) {
        self.item = item
        
        if let title = item.progressItem.title {
            nameLabel.text = title
        } else {
            nameLabel.text = NSLocalizedString("Overall", comment: "")
        }
        
        if item.progressItem.handsCount != 0 {
            statsContentView.hidden = false
            noStatsView.hidden = true
            
            chipsCountLabel.text = NSString(format: "%.0f", item.progressItem.chipsCount) as String
            winPercentLabel.text = NSString(format: "%.2f%%", item.progressItem.winPercent) as String
            winsInRowLabel.text = NSString(format: "%d", item.progressItem.maxNumberOfWinsInRow) as String
            handsCountLabel.text = NSString(format: "%d", item.progressItem.handsCount) as String
        } else {
            statsContentView.hidden = true
            noStatsView.hidden = false
        }
    }
}
