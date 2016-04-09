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
        if mainView.isMenuShown {
            Analytics.menuAppeared()
        } else {
            Analytics.levelsAppeared()
        }
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        if mainView.isMenuShown {
            Analytics.menuDisappeared()
        } else {
            Analytics.levelsDisappeared()
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
        model.navigationManager.presentStatsScreenWithLevel(nil, animated: true)
    }
}
