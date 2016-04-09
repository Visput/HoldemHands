//
//  MainScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/29/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class MainScreen: BaseViewController {

    private var mainView: MainView {
        return view as! MainView
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
}

extension MainScreen {
    
    @IBAction private func playButtonDidPress(sender: AnyObject) {
        Analytics.playClickedInMenu()
        mainView.scrollToLevelsView()
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClickedInMenu()
        mainView.scrollToStatsView()
    }
    
    @IBAction private func shareButtonDidPress(sender: AnyObject) {
        mainView.scrollToSharingView()
    }
}
