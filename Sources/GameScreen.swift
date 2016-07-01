//
//  GameScreen.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/15/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameScreen: BaseViewController {
    
    var level: Level!
    
    private var firstRoundController: RoundViewController!
    private var secondRoundController: RoundViewController!
    
    private var gameView: GameScreenView {
        return view as! GameScreenView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.levelNameLabel.text = level.name

        for controller in [firstRoundController, secondRoundController] {
            controller.roundManager = model.newRoundForLevel(level)
            controller.roundManager.didUpdateTimeBonusHandler = { [unowned self] bonus, bonusMultiplier in
                self.gameView.setTimeBonusVisible(true, bonus: bonus, bonusMultiplier: bonusMultiplier, animated: true)
            }
            controller.roundManager.didPlayRoundHandler = { [unowned self] round in
                self.gameView.setTimeBonusVisible(false, bonus: nil, bonusMultiplier: nil, animated: true).thenDo {
                    self.gameView.setTieOddsVisible(true, tieProbability: round.tieProbability!, animated: true)
                }
                self.gameView.controlsEnabled = true
            }
        }
        
        firstRoundController.nextController = secondRoundController
        secondRoundController.nextController = firstRoundController
        
        gameView.controlsEnabled = false
        model.playerManager.observers.addObserver(self)
        
        firstRoundController.loadNewRound()
    }
    
    override func viewWillDisappear(animated: Bool) {
        model.walkthroughManager.hideBanner()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidShow() {
        super.viewDidShow()
        Analytics.gameScreenAppeared(level)
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        Analytics.gameScreenDisappeared(level)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = R.segue.gameScreen.firstRound(segue: segue) {
            firstRoundController = segue.destinationViewController
        } else if let segue = R.segue.gameScreen.secondRound(segue: segue) {
            secondRoundController = segue.destinationViewController
        }
    }
}

extension GameScreen {
    
    @IBAction private func nextHandGestureDidSwipe(sender: AnyObject) {
        model.walkthroughManager.hideBanner()
        gameView.setTieOddsVisible(false, tieProbability: nil, animated: true)
        gameView.controlsEnabled = false
        gameView.scrollToNextRoundView().thenDo {
            self.firstRoundController.viewDidChangePosition()
            self.secondRoundController.viewDidChangePosition()
        }
    }
    
    @IBAction private func doneButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInGameScreen()
        model.navigationManager.dismissScreenAnimated(true)
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClickedInGameScreen()
        model.navigationManager.presentStatsScreenWithLevel(level, animated: true)
    }
}

extension GameScreen: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress) {
        let levelIndex = manager.playerData.progressForLevel(levelProgress.level).index
        let text = R.string.localizable.bannerUnlockedLevel(levelProgress.level.name)
        let backgroundImage = UIImage(named: "banner.unlock.level.\(levelProgress.level.identifier)")!
        
        Analytics.unlockedLevelBannerShownInGameScreen(levelProgress.level)
        model.navigationManager.presentBannerWithText(text, backgroundImage: backgroundImage, tapHandler: { [unowned self] in
            Analytics.unlockBannerClickedInGameScreen(levelProgress.level)
            self.model.navigationManager.dismissScreenAnimated(true).then({ _ in
                self.model.navigationManager.mainScreen.levelsController.levelsView.scrollToLevelAtIndex(levelIndex, animated: true)
            })
        })
    }
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        if manager.playerData.isLockedLevel(level) {
            model.navigationManager.dismissScreenAnimated(true)
        }
    }
}
