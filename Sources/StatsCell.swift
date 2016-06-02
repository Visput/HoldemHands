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
    
    @IBOutlet private(set) weak var statsBackgroundImageView: UIImageView!
    @IBOutlet private(set) weak var statsOverlayImageView: UIImageView!
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustFontSizeRecursively(true)
    }
    
    func fillWithItem(item: StatsCellItem) {
        let hasProgress = item.progressItem.handsCount != 0
        
        if hasProgress {
            updateRankLabelWithItem(item, oldItem: self.item)
        } else {
            rankLabel.text = "-"
        }
        
        self.item = item
        
        if item.progressItem.locked! {
            rankLabel.textColor = UIColor.gray1Color()
            winPercentLabel.textColor  = UIColor.gray1Color()
            winsInRowLabel.textColor = UIColor.gray1Color()
            handsCountLabel.textColor = UIColor.gray1Color()
        } else {
            rankLabel.textColor = UIColor.aquamarine1Color()
            winPercentLabel.textColor  = UIColor.aquamarine1Color()
            winsInRowLabel.textColor = UIColor.aquamarine1Color()
            handsCountLabel.textColor = UIColor.aquamarine1Color()
        }
        
        winPercentLabel.text = hasProgress ? NSString(format: "%.2f%%", item.progressItem.winPercent) as String : "-"
        winsInRowLabel.text = hasProgress ? String(item.progressItem.maxWinsCountInRow) : "-"
        handsCountLabel.text = hasProgress ? String(item.progressItem.handsCount) : "-"
    }
    
    func loadImages() {
        if item.progressItem.locked! {
            statsBackgroundImageView.image = R.image.backgroundTableLocked()
            statsOverlayImageView.image = UIImage(named: "overlay.stats.locked.level.\(item.progressItem.identifier)")
        } else {
            statsBackgroundImageView.image = UIImage(named: "background.stats.level.\(item.progressItem.identifier)")
            statsOverlayImageView.image = nil
        }
    }
    
    func updateRankLabelWithItem(newItem: StatsCellItem, oldItem: StatsCellItem?) {
        rankDifferenceLabel.alpha = 0.0
        
        let newRank = newItem.progressItem.rank
        let oldRank = oldItem?.progressItem.rank
        
        if newRank != nil && oldRank != nil && newRank! != oldRank! && newItem.progressItem.identifier == oldItem?.progressItem.identifier {
            let rankRaised = newRank < oldRank
            let rankDifference = abs(newRank! - oldRank!)
            
            if rankRaised {
                rankDifferenceLabel.text = "+\(rankDifference)"
                rankDifferenceLabel.textColor = UIColor.green2Color()
            } else {
                rankDifferenceLabel.text = "-\(rankDifference)"
                rankDifferenceLabel.textColor = UIColor.gray2Color()
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
