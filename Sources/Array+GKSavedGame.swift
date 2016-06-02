//
//  Array+GKSavedGame.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/31/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import GameKit

extension Array where Element: GKSavedGame {
    
    func mostRecentSavedGameWithName(name: String) -> GKSavedGame? {
        var recentSavedGame: GKSavedGame? = nil
        for game in self where game.name == name {
            if recentSavedGame == nil || game.modificationDate!.compare(recentSavedGame!.modificationDate!) == .OrderedDescending {
                recentSavedGame = game
            }
        }
        
        return recentSavedGame
    }
}
