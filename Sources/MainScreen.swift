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
        }
    }
    
    private var levelsController: LevelsViewController!
    private var statsController: StatsViewController!
    private var sharingController: SharingViewController!

    private var mainView: MainView {
        return view as! MainView
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
        Analytics.playClicked()
        currentDetailsPage = .Levels
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Levels.rawValue)
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClicked()
        currentDetailsPage = .Stats
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Stats.rawValue, completionHandler: {
            self.statsController.reloadRanks()
        })
    }
    
    @IBAction private func shareButtonDidPress(sender: AnyObject) {
        Analytics.shareClickedInMainScreen()
        currentDetailsPage = .Sharing
        mainView.scrollToDetailsViewAtPage(DetailsViewPage.Sharing.rawValue)
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
