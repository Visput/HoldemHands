//
//  ChipsViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 4/6/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class ChipsViewController: BaseViewController {
    
    private var chipsView: ChipsView {
        return view as! ChipsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.playerManager.observers.addObserver(self)
        chipsView.updateChipsLabelWithCount(model.playerManager.playerData.chipsCount, animated: false)
    }
}

extension ChipsViewController: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUpdateChipsCount newChipsCount: Int64, oldChipsCount: Int64, chipsMultiplier: Int64) {
        chipsView.updateChipsLabelWithCount(newChipsCount, oldCount: oldChipsCount, chipsMultiplier: chipsMultiplier, animated: true)
    }
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        chipsView.updateChipsLabelWithCount(model.playerManager.playerData.chipsCount, animated: false)
    }
}
