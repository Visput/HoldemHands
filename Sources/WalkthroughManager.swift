//
//  WalkthroughManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 5/5/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

final class WalkthroughManager {
    
    private var navigationManager: NavigationManager
    private var playerManager: PlayerManager
    
    private var firstRoundBanner: BannerView?
    private var nextRoundBanner: BannerView?
    
    init(navigationManager: NavigationManager, playerManager: PlayerManager) {
        self.navigationManager = navigationManager
        self.playerManager = playerManager
    }
    
    func showFirstRoundBannerIfNeeded() {
        guard playerManager.playerData.playerProgress().handsCount == 0 else {
            hideBanners()
            return
        }
       
        let text = R.string.localizable.bannerWalkthroughChooseHand()
        firstRoundBanner = navigationManager.presentBannerWithText(text, duration: 0.0)
    }
    
    func showNextRoundBannerIfNeeded(won won: Bool) {
        guard playerManager.playerData.playerProgress().handsCount == 1 else {
            hideBanners()
            return
        }
        var text: String! = nil
        if won {
            text = R.string.localizable.bannerWalkthroughWon()
        } else {
            text = R.string.localizable.bannerWalkthroughLost()
        }
        nextRoundBanner = navigationManager.presentBannerWithText(text, duration: 0.0)
    }
    
    func hideBanners() {
        firstRoundBanner?.dismiss({
            self.firstRoundBanner = nil
        })
        nextRoundBanner?.dismiss({
            self.nextRoundBanner = nil
        })
    }
}
