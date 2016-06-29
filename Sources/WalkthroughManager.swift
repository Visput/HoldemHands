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
    
    private var banner: BannerView?
    
    var playedHandsCount: Int {
        return playerManager.playerData.playerProgress().handsCount
    }
    
    init(navigationManager: NavigationManager, playerManager: PlayerManager) {
        self.navigationManager = navigationManager
        self.playerManager = playerManager
    }
    
    func showBannerForStartedLevelIfNeeded() {
        hideBanner({
            var text: String? = nil
            
            if self.playedHandsCount == 0 {
                text = R.string.localizable.bannerWalkthroughChooseHand()
            }
            
            if self.playedHandsCount == 1 {
                text = R.string.localizable.bannerWalkthroughTimeBonus()
            }
            
            if let text = text {
                self.banner = self.navigationManager.presentBannerWithText(text, duration: 0.0)
            }
        })
    }
    
    func showBannerForCompletedLevelIfNeeded(won won: Bool) {
        hideBanner({
            if self.playedHandsCount == 1 {
                var text: String! = nil
                if won {
                    text = R.string.localizable.bannerWalkthroughWon()
                } else {
                    text = R.string.localizable.bannerWalkthroughLost()
                }
                self.banner = self.navigationManager.presentBannerWithText(text, duration: 0.0)
            }
        })
    }
    
    func hideBanner(completion: (() -> Void)? = nil) {
        if let banner = banner {
            banner.dismiss({
                self.banner = nil
                completion?()
            })
        } else {
            completion?()
        }
    }
}
