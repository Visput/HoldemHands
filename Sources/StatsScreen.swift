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
    
    private var statsController: StatsViewController!
    
    override func viewDidShow() {
        super.viewDidShow()
        Analytics.statsAppeared()
        
        statsController.reloadRanks()
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        Analytics.statsDisappeared()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Stats" {
            statsController = segue.destinationViewController as! StatsViewController
            statsController.level = level
        }
    }
}

extension StatsScreen {
    
    @IBAction private func doneButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInStats()
        model.navigationManager.dismissScreenAnimated(true)
    }
}
