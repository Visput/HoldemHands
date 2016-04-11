//
//  MainScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreen: BaseViewController {
    
    enum DetailsViewPage: Int {
        case Levels = 0
        case Stats = 1
        case Sharing = 2
    }
    
    private(set) var currentDetailsPage: DetailsViewPage? {
        willSet (newPage) {
            Analytics.detailsViewPageOnMainScreenChanged(currentDetailsPage, newPage: newPage!)
        }
    }
    
    private var levelsController: LevelsViewController!
    private var statsController: StatsViewController!
    private var sharingController: SharingViewController!

    private var mainView: MainView {
        return view as! MainView
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
        if segue.identifier == "Levels" {
            levelsController = segue.destinationViewController as! LevelsViewController
        } else if segue.identifier == "Stats" {
            statsController = segue.destinationViewController as! StatsViewController
        } else if segue.identifier == "Sharing" {
            sharingController = segue.destinationViewController as! SharingViewController
        }
    }
}

extension MainScreen {
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        currentDetailsPage = .Levels
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Levels.rawValue)
        Analytics.playClicked()
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        currentDetailsPage = .Stats
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Stats.rawValue, completionHandler: {
            self.statsController.reloadRanks()
        })
        Analytics.statsClicked()
    }
    
    @IBAction private func shareButtonDidPress(sender: AnyObject) {
        currentDetailsPage = .Sharing
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Sharing.rawValue)
        Analytics.shareClickedInMainScreen()
    }
}

extension MainScreen: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(scrollView.contentOffset.y / scrollView.frame.size.height))
        
        currentDetailsPage = DetailsViewPage(rawValue: page)
        mainView.selectMenuButtonForPage(page)
        
        if currentDetailsPage == .Stats {
            statsController.reloadRanks()
        }
        
        Analytics.detailsViewSwipedInMainScreen()
    }
}
