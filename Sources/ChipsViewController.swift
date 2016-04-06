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
        updateChipsCountLabel()
    }
}

extension ChipsViewController: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUpdateChipsCount newChipsCount: Int64, oldChipsCount: Int64, chipsMultiplier: Int64) {
        guard newChipsCount != oldChipsCount else { return }
        updateChipsCountLabel()
    }
}

extension ChipsViewController {
    
    private func updateChipsCountLabel() {
        chipsView.chipsCountLabel.text = model.playerManager.playerData.chipsCount.formattedChipsCountString
    }
}
