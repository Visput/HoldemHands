//
//  StatsCell.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/12/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import UICountingLabel

final class StatsCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var statsContentView: UIView!
    @IBOutlet private(set) weak var noStatsView: UIView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var winPercentLabel: UILabel!
    @IBOutlet private(set) weak var winsInRowLabel: UILabel!
    @IBOutlet private(set) weak var handsCountLabel: UILabel!
    @IBOutlet private(set) weak var rankDifferenceLabel: UILabel!
    @IBOutlet private(set) weak var rankLabel: UICountingLabel! {
        didSet {
            rankLabel.format = "%d"
            rankLabel.animationDuration = 1.0
            rankLabel.method = .Linear
        }
    }
 
    private(set) var item: StatsCellItem!
    
    override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.2, animations: {
                let zoomLevel: CGFloat = self.highlighted ? 0.9 : 1.0
                self.transform = CGAffineTransformMakeScale(zoomLevel, zoomLevel)
            })
        }
    }
    
    func fillWithItem(item: StatsCellItem) {
        updateRankLabelWithItem(item, oldItem: self.item)
        
        self.item = item
        
        nameLabel.text = item.progressItem.title
        
        if item.progressItem.handsCount != 0 {
            statsContentView.hidden = false
            noStatsView.hidden = true

            winPercentLabel.text = NSString(format: "%.2f%%", item.progressItem.winPercent) as String
            winsInRowLabel.text = String(item.progressItem.maxWinsCountInRow)
            handsCountLabel.text = String(item.progressItem.handsCount)

        } else {
            statsContentView.hidden = true
            noStatsView.hidden = false
        }
    }
    
    func updateRankLabelWithItem(newItem: StatsCellItem, oldItem: StatsCellItem?) {
        rankDifferenceLabel.alpha = 0.0
        
        let newRank = newItem.progressItem.rank
        let oldRank = oldItem?.progressItem.rank
        
        if newRank != nil && oldRank != nil && newRank! != oldRank! && newItem.progressItem.title == oldItem?.progressItem.title {
            let rankRaised = newRank < oldRank
            let rankDifference = abs(newRank! - oldRank!)
            
            if rankRaised {
                rankDifferenceLabel.text = "+\(rankDifference)"
                rankDifferenceLabel.textColor = UIColor.primaryColor()
            } else {
                rankDifferenceLabel.text = "-\(rankDifference)"
                rankDifferenceLabel.textColor = UIColor.backgroundColor()
            }
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {
                self.rankDifferenceLabel.alpha = 1.0
                
                }, completion: { _ in
                    UIView.animateWithDuration(0.1, delay: 0.7, options: .CurveEaseInOut, animations: {
                        self.rankDifferenceLabel.alpha = 0.0
                        
                        }, completion: { _ in
                            self.rankLabel.countFrom(CGFloat(oldRank!), to: CGFloat(newRank!))
                    })   
            })
            
        } else {
            if newRank != nil {
                rankLabel.countFrom(0, to: CGFloat(newRank!), withDuration: 0.0)
            } else {
                rankLabel.text = "-"
            }
        }
    }
}
