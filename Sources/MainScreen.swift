//
//  MainScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreen: BaseViewController {
    
    private(set) var currentDetailsPage: MainScreenView.DetailsViewPage? {
        set (newPage) {
            Analytics.detailsViewPageOnMainScreenChanged(currentDetailsPage, newPage: newPage!)
            
            guard currentDetailsPage != newPage else { return }
            
            if let currentDetailsPage = currentDetailsPage {
                let controller = detailsControllers[currentDetailsPage.rawValue]
                controller.beginAppearanceTransition(false, animated: false)
                controller.endAppearanceTransition()
            }
            
            if let newPage = newPage {
                let controller = detailsControllers[newPage.rawValue]
                controller.beginAppearanceTransition(true, animated: false)
                controller.endAppearanceTransition()
            }
            
            mainView.currentDetailsPage = newPage
        }
        
        get {
            return mainView.currentDetailsPage
        }
    }
    
    private(set) var levelsController: LevelsViewController!
    private var statsController: StatsViewController!
    private var sharingController: SharingViewController!
    private var detailsControllers: [UIViewController]!

    var mainView: MainScreenView {
        return view as! MainScreenView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsControllers = [levelsController, statsController, sharingController]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentDetailsPage == nil {
            // Notify details view controllers are hidden when details view isn't presented.
            for controller in detailsControllers {
                controller.beginAppearanceTransition(false, animated: animated)
                controller.endAppearanceTransition()
            }
        }
    }
    
    override func viewDidShow() {
        super.viewDidShow()
        Analytics.mainScreenAppeared()
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        Analytics.mainScreenDisappeared()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = R.segue.mainScreen.levels(segue: segue) {
            levelsController = segue.destinationViewController
        } else if let segue = R.segue.mainScreen.stats(segue: segue) {
            statsController = segue.destinationViewController
        } else if let segue = R.segue.mainScreen.sharing(segue: segue) {
            sharingController = segue.destinationViewController
        }
    }
}

extension MainScreen {
    
    func startGameAtLevel(level: Level, animated: Bool) -> SimpleTask {
        return mainView.scrollToDetailsViewAtPage(.Levels, animated: animated).then {
            return self.levelsController.startGameAtLevel(level, animated: animated)
        }
    }
}

extension MainScreen {
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        Analytics.playClicked()
        currentDetailsPage = .Levels
        mainView.scrollToDetailsViewAtPage(.Levels, animated: true).then {
            return self.statsController.scrollToOverallStatsAnimated(false)
        }
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClicked()
        currentDetailsPage = .Stats
        mainView.scrollToDetailsViewAtPage(.Stats, animated: true).thenDo {
            self.statsController.reloadRanks()
        }
    }
    
    @IBAction private func shareButtonDidPress(sender: AnyObject) {
        Analytics.shareClickedInMainScreen()
        currentDetailsPage = .Sharing
        mainView.scrollToDetailsViewAtPage(.Sharing, animated: true)
    }
    
    @IBAction private func leaderboardsButtonDidPress(sender: UIButton) {
        Analytics.leaderboardsClicked()
        let leaderboardID = model.playerManager.playerData.overallLeaderboardID
        model.navigationManager.presentLeaderboardScreenWithLeaderboardID(leaderboardID, animated: true)
    }
}

extension MainScreen: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(scrollView.contentOffset.y / scrollView.frame.height))
        
        currentDetailsPage = MainScreenView.DetailsViewPage(rawValue: page)
        mainView.selectMenuButtonForPage(page)
        
        if currentDetailsPage == .Stats {
            statsController.reloadRanks()
        } else if currentDetailsPage == .Levels {
            statsController.scrollToOverallStatsAnimated(false)
        }
        
        mainView.updateDetailsViewHeaderWithPage(page)
        
        Analytics.detailsViewSwipedInMainScreen()
    }
}
