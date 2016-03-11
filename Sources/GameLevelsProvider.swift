//
//  GameLevelsProvider.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/2/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class GameLevelsProvider {
    
    let levels: [GameLevel]
    
    init() {
        var levels = [GameLevel]()
        
        levels.append(GameLevel(numberOfHands: 2,
            chipsToUnlock: 0,
            chipsPerWin: 1,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 1", comment: ""),
            identifier: 1))
        
        levels.append(GameLevel(numberOfHands: 3,
            chipsToUnlock: 2,
            chipsPerWin: 2,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 2", comment: ""),
            identifier: 2))
        
        levels.append(GameLevel(numberOfHands: 4,
            chipsToUnlock: 250,
            chipsPerWin: 10,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 3", comment: ""),
            identifier: 3))
        
        levels.append(GameLevel(numberOfHands: 5,
            chipsToUnlock: 1000,
            chipsPerWin: 50,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 4", comment: ""),
            identifier: 4))
        
        levels.append(GameLevel(numberOfHands: 6,
            chipsToUnlock: 5000,
            chipsPerWin: 250,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 5", comment: ""),
            identifier: 5))
        
        levels.append(GameLevel(numberOfHands: 7,
            chipsToUnlock: 25000,
            chipsPerWin: 1000,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 6", comment: ""),
            identifier: 6))
        
        levels.append(GameLevel(numberOfHands: 8,
            chipsToUnlock: 100000,
            chipsPerWin: 5000,
            winsInRowToDoubleChips: 10,
            name: NSLocalizedString("Level 7", comment: ""),
            identifier: 7))
        
        self.levels = levels
    }
}
