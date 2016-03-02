//
//  ServicesProvider.swift
//  Workouter
//
//  Created by Uladzimir Papko on 1/20/15.
//  Copyright (c) 2015 visput. All rights reserved.
//

import Foundation

struct ModelProvider {
    
    static let provider = ModelProvider()
    
    let gameLevelsProvider: GameLevelsProvider
    let accountManager: AccountManager
    
    init() {
        accountManager = AccountManager()
        gameLevelsProvider = GameLevelsProvider()
    }
}
