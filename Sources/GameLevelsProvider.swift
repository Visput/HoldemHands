//
//  GameLevelsProvider.swift
//  PokerHand
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
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 1", comment: ""),
            identifier: 1))
        
        levels.append(GameLevel(numberOfHands: 3,
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 2", comment: ""),
            identifier: 2))
        
        levels.append(GameLevel(numberOfHands: 4,
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 3", comment: ""),
            identifier: 3))
        
        levels.append(GameLevel(numberOfHands: 5,
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 4", comment: ""),
            identifier: 4))
        
        levels.append(GameLevel(numberOfHands: 6,
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 5", comment: ""),
            identifier: 5))
        
        levels.append(GameLevel(numberOfHands: 7,
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 6", comment: ""),
            identifier: 6))
        
        levels.append(GameLevel(numberOfHands: 8,
            numberOfWinsInRowToComplete: 20,
            name: NSLocalizedString("Level 7", comment: ""),
            identifier: 7))
        
        self.levels = levels
    }
}
