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
import SwiftTask

final class ChipsView: UIView {

    @IBOutlet private(set) weak var chipsDifferenceLabel: UILabel!
    @IBOutlet private weak var chipsDifferenceLabelTopSpace: NSLayoutConstraint!
    @IBOutlet private(set) weak var chipsCountLabel: UICountingLabel! {
        didSet {
            chipsCountLabel.animationDuration = 1.0
            chipsCountLabel.method = .Linear
            chipsCountLabel.formatBlock = { chipsCount -> String in
                let chipsCountInt64 = Int64(chipsCount)
                return chipsCountInt64.formattedChipsCountString()
            }
        }
    }
    
    private var chipsUpdatingQueue = SimpleTaskQueue.simpleQueue()
    
    func updateChipsLabelWithCount(newCount: Int64,
                                   oldCount: Int64 = 0,
                                   chipsMultiplier: Int64 = 1,
                                   animated: Bool) {
        chipsUpdatingQueue.addTask() {
            self.chipsDifferenceLabel.alpha = 0.0
            
            guard animated else {
                self.chipsCountLabel.countFromCurrentValueTo(CGFloat(newCount), withDuration: 0.0)
                return SimpleTask.empty()
            }
            
            SimpleTask.delay(0.1).thenDo {
                self.chipsCountLabel.countFromCurrentValueTo(CGFloat(newCount))
            }
            
            let won = newCount > oldCount
            let chipsDifference = abs(newCount - oldCount)
            var chipsDifferenceText = (chipsDifference / chipsMultiplier).formattedChipsCountString()
            if chipsMultiplier > 1 {
                chipsDifferenceText.appendContentsOf(" x \(chipsMultiplier)")
            }
            
            if won {
                self.chipsDifferenceLabelTopSpace.constant = 15.0
                self.layoutIfNeeded()
                
                self.chipsDifferenceLabel.text = "+ " + chipsDifferenceText
                self.chipsDifferenceLabel.textColor = UIColor.green2Color()
                
                return SimpleTask.animateWithDuration(0.2, options: .CurveLinear) {
                    self.chipsDifferenceLabel.alpha = 1.0
                }.then {
                    return SimpleTask.animateWithDuration(0.5, options: .CurveEaseInOut) {
                        self.chipsDifferenceLabelTopSpace.constant = 0.0
                        self.layoutIfNeeded()
                        self.chipsDifferenceLabel.alpha = 0.0
                    }
                }
                
            } else {
                self.chipsDifferenceLabelTopSpace.constant = 0.0
                self.layoutIfNeeded()
                
                self.chipsDifferenceLabel.text = "- " + chipsDifferenceText
                self.chipsDifferenceLabel.textColor = UIColor.gray2Color()
                
                return SimpleTask.animateWithDuration(0.5, options: .CurveLinear) {
                    self.chipsDifferenceLabelTopSpace.constant = 15.0
                    self.layoutIfNeeded()
                    self.chipsDifferenceLabel.alpha = 1.0
                }.then {
                    return SimpleTask.animateWithDuration(0.3, delay: 0.3, options: .CurveEaseInOut) {
                        self.chipsDifferenceLabel.alpha = 0.0
                    }
                }
            }
        }
    }
}
