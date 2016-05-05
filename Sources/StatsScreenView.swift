//
//  StatsScreenView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/4/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsScreenView: UIView {
    
    @IBOutlet private(set) var doneButtons: [UIButton]! {
        didSet {
            for button in doneButtons {
                button.exclusiveTouch = true
            }
        }
    }
    
    @IBOutlet private(set) var leaderboardButtons: [UIButton]! {
        didSet {
            for button in doneButtons {
                button.exclusiveTouch = true
            }
        }
    }
}
