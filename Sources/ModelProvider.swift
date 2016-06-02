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
    
    let playerManager: PlayerManager
    let navigationManager: NavigationManager
    let sharingManager: SharingManager
    let walkthroughManager: WalkthroughManager
    let appShortcutsManager: AppShortcutsManager
    
    init() {
        navigationManager = NavigationManager()
        playerManager = PlayerManager(navigationManager: navigationManager)
        sharingManager = SharingManager()
        walkthroughManager = WalkthroughManager(navigationManager: navigationManager,
                                                playerManager: playerManager)
        
        
        appShortcutsManager = AppShortcutsManager(navigationManager: navigationManager,
                                                  playerManager: playerManager)
        
        Analytics.navigationManager = navigationManager
    }
}
