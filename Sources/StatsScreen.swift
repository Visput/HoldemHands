//
//  StatsScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsScreen: BaseViewController {
    
    var level: Level!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Stats" {
            let statsController = segue.destinationViewController as! StatsViewController
            statsController.level = level
        }
    }
}

extension StatsScreen {
    
    @IBAction private func closeButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInStats()
        model.navigationManager.dismissScreenAnimated(true)
    }
}
