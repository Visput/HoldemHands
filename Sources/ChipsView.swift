//
//  ChipsView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/6/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit
import UICountingLabel

final class ChipsView: UIView {

    @IBOutlet private(set) weak var chipsDifferenceLabel: UILabel!
    @IBOutlet private weak var chipsDifferenceLabelTopSpace: NSLayoutConstraint!
    @IBOutlet private(set) weak var chipsCountLabel: UICountingLabel! {
        didSet {
            chipsCountLabel.animationDuration = 1.0
            chipsCountLabel.formatBlock = { chipsCount -> String in
                let chipsCountInt64 = Int64(chipsCount)
                return chipsCountInt64.formattedChipsCountString
            }
        }
    }
    
    func updateChipsLabelWithCount(newCount: Int64, oldCount: Int64 = 0, chipsMultiplier: Int64 = 1, animated: Bool) {
        chipsDifferenceLabel.alpha = 0.0
        
        if animated {
            let won = newCount > oldCount
            let chipsDifference = abs(newCount - oldCount)
            
            if won {
                chipsDifferenceLabelTopSpace.constant = 20.0
                chipsDifferenceLabel.text = "+ " + chipsDifference.formattedChipsCountString
                chipsDifferenceLabel.textColor = UIColor.primaryColor()
                
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {
                    self.chipsDifferenceLabel.alpha = 1.0
                    
                    }, completion: { _ in
                        UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseInOut, animations: {
                            self.chipsDifferenceLabelTopSpace.constant = 0.0
                            self.layoutIfNeeded()
                            self.chipsDifferenceLabel.alpha = 0.0
                            
                            }, completion: nil)
                        
                })
                
            } else {
                chipsDifferenceLabelTopSpace.constant = 0.0
                chipsDifferenceLabel.text = "- " + chipsDifference.formattedChipsCountString
                chipsDifferenceLabel.textColor = UIColor.backgroundColor()
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: {
                    self.chipsDifferenceLabelTopSpace.constant = 20.0
                    self.layoutIfNeeded()
                    self.chipsDifferenceLabel.alpha = 1.0
                    
                    }, completion: { _ in
                        UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseInOut, animations: {
                            self.chipsDifferenceLabel.alpha = 0.0
                            
                            }, completion: nil)
                        
                })
            }
            
            executeAfterDelay(0.2, task: {
                self.chipsCountLabel.countFromCurrentValueTo(CGFloat(newCount))
            })
            
        } else {
            chipsCountLabel.countFromCurrentValueTo(CGFloat(newCount), withDuration: 0.0)
        }
    }
}
