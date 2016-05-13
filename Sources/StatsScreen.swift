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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Stats view uses menu height as measure for table height.
        statsController.statsView.menuSize = CGSize(width: 0.0, height: model.navigationManager.mainScreen.mainView.menuView.frame.size.height)
    }
    
    override func viewDidShow() {
        super.viewDidShow()
        Analytics.statsScreenAppeared()
        statsController.reloadRanks()
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        Analytics.statsScreenDisappeared()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = R.segue.statsScreen.stats(segue: segue) {
            statsController = segue.destinationViewController
            statsController.level = level
        }
    }
}

extension StatsScreen {
    
    @IBAction private func doneButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInStatsScreen()
        model.navigationManager.dismissScreenAnimated(true)
    }
    
    @IBAction private func leaderboardsButtonDidPress(sender: UIButton) {
        Analytics.leaderboardsClicked()
        let leaderboardID = model.playerManager.playerData.overallLeaderboardID
        model.navigationManager.presentLeaderboardScreenWithLeaderboardID(leaderboardID, animated: true)
    }
}
