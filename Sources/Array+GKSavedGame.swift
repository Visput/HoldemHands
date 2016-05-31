//
//  Array+GKSavedGame.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/31/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import GameKit

extension Array where Element: GKSavedGame {
    
    func mostRecentSavedGame() -> GKSavedGame? {
        guard var recentSavedGame = first else { return nil }
        
        for index in 1 ..< count {
            if self[index].modificationDate!.compare(recentSavedGame.modificationDate!) == .OrderedDescending {
                recentSavedGame = self[index]
            }
        }
        
        return recentSavedGame
    }
}
