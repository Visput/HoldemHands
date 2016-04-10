//
//  MainScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreen: BaseViewController {
    
    private var levelsController: LevelsViewController!
    private var statsController: StatsViewController!
    private var sharingController: SharingViewController!

    private var mainView: MainView {
        return view as! MainView
    }
    
    private enum DetailsViewPage: Int {
        case Levels = 0
        case Stats = 1
        case Sharing = 2
    }
    
    override func viewDidShow() {
        super.viewDidShow()
        if mainView.isDetailsViewShown {
            Analytics.levelsAppeared()
        } else {
            Analytics.menuAppeared()
        }
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        if mainView.isDetailsViewShown {
            Analytics.levelsDisappeared()
        } else {
            Analytics.menuDisappeared()
        }
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
        Analytics.playClickedInMenu()
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Levels.rawValue)
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClickedInMenu()
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Stats.rawValue, completionHandler: {
            self.statsController.reloadRanks()
        })
    }
    
    @IBAction private func shareButtonDidPress(sender: AnyObject) {
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Sharing.rawValue)
    }
}

extension MainScreen: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(scrollView.contentOffset.y / scrollView.frame.size.height))
        mainView.selectMenuButtonForPage(page)
        
        if page == DetailsViewPage.Stats.rawValue {
            statsController.reloadRanks()
        }
    }
}
