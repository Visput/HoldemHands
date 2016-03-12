//
//  ServicesProvider.swift
//  Workouter
//
//  Created by Uladzimir Papko on 1/20/15.
//  Copyright (c) 2015 visput. All rights reserved.
//

import Foundation

final class ModelProvider {
    
    static let provider = ModelProvider()
    
    let levelsProvider: LevelsProvider
    let playerManager: PlayerManager
    let navigationManager: NavigationManager
    let sharingManager: SharingManager
    
    init() {
        levelsProvider = LevelsProvider()
        playerManager = PlayerManager(levelsProvider: levelsProvider)
        navigationManager = NavigationManager()
        sharingManager = SharingManager()
    }
}
