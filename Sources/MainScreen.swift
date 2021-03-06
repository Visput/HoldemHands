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
            
            if currentDetailsPage != nil {
                switch currentDetailsPage! {
                case .Levels:
                    levelsController.beginAppearanceTransition(false, animated: false)
                    levelsController.endAppearanceTransition()
                case .Stats:
                    statsController.beginAppearanceTransition(false, animated: false)
                    statsController.endAppearanceTransition()
                case .Sharing:
                    sharingController.beginAppearanceTransition(false, animated: false)
                    sharingController.endAppearanceTransition()
                }
            }
            
            if newPage != nil {
                switch newPage! {
                case .Levels:
                    levelsController.beginAppearanceTransition(true, animated: false)
                    levelsController.endAppearanceTransition()
                case .Stats:
                    statsController.beginAppearanceTransition(true, animated: false)
                    statsController.endAppearanceTransition()
                case .Sharing:
                    sharingController.beginAppearanceTransition(true, animated: false)
                    sharingController.endAppearanceTransition()
                }
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

    var mainView: MainScreenView {
        return view as! MainScreenView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentDetailsPage == nil {
            // Notify details view controllers are hidden when details view isn't presented.
            levelsController.beginAppearanceTransition(false, animated: animated)
            levelsController.endAppearanceTransition()
            statsController.beginAppearanceTransition(false, animated: animated)
            statsController.endAppearanceTransition()
            sharingController.beginAppearanceTransition(false, animated: animated)
            sharingController.endAppearanceTransition()
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
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        Analytics.playClicked()
        currentDetailsPage = .Levels
        mainView.scrollToDetailsViewAtPage(MainScreenView.DetailsViewPage.Levels.rawValue, completionHandler: {
            self.statsController.scrollToOverallStatsAnimated(false)
        })
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClicked()
        currentDetailsPage = .Stats
        mainView.scrollToDetailsViewAtPage(MainScreenView.DetailsViewPage.Stats.rawValue, completionHandler: {
            self.statsController.reloadRanks()
        })
    }
    
    @IBAction private func shareButtonDidPress(sender: AnyObject) {
        Analytics.shareClickedInMainScreen()
        currentDetailsPage = .Sharing
        mainView.scrollToDetailsViewAtPage(MainScreenView.DetailsViewPage.Sharing.rawValue)
    }
    
    @IBAction private func leaderboardsButtonDidPress(sender: UIButton) {
        Analytics.leaderboardsClicked()
        let leaderboardID = model.playerManager.playerData.overallLeaderboardID
        model.navigationManager.presentLeaderboardScreenWithLeaderboardID(leaderboardID, animated: true)
    }
}

extension MainScreen: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(scrollView.contentOffset.y / scrollView.frame.size.height))
        
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
