//
//  StatsScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/10/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class StatsScreen: BaseViewController {
    
    private var statsView: StatsView {
        return view as! StatsView
    }
}

extension StatsScreen {
    
    @IBAction private func closeButtonDidPress(sender: AnyObject) {
        model.navigationManager.dismissScreenAnimated(true)
    }
}
