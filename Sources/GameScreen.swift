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
    
    private var firstHandsController: HandsViewController!
    private var secondHandsController: HandsViewController!
    
    private var gameView: GameView {
        return view as! GameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.levelNameLabel.text = level.name
        
        firstHandsController.numberOfHands = level.numberOfHands
        firstHandsController.didPlayRoundHandler = { [unowned self] won in
            self.didPlayRoundHandler(won)
        }
        firstHandsController.nextController = secondHandsController
        
        secondHandsController.numberOfHands = level.numberOfHands
        secondHandsController.didPlayRoundHandler = { [unowned self] won in
            self.didPlayRoundHandler(won)
        }
        secondHandsController.nextController = firstHandsController
        
        gameView.controlsEnabled = false
    
        model.playerManager.observers.addObserver(self)
        
        firstHandsController.generateHands()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        model.playerManager.savePlayerData()
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
        if segue.identifier == "FirstHands" {
            firstHandsController = segue.destinationViewController as! HandsViewController
            
        } else if segue.identifier == "SecondHands" {
            secondHandsController = segue.destinationViewController as! HandsViewController
        }
    }
    
    private func didPlayRoundHandler(won: Bool) {
        if won {
            model.playerManager.trackNewWinInLevel(level)
        } else {
            model.playerManager.trackNewLossInLevel(level)
        }
        
        gameView.controlsEnabled = true
        Analytics.gameRoundPlayed()
    }
}

extension GameScreen {
    
    @IBAction private func nextHandGestureDidSwipe(sender: AnyObject) {
        gameView.controlsEnabled = false
        gameView.scrollToNextHandsView({
            self.firstHandsController.viewDidChangePosition()
            self.secondHandsController.viewDidChangePosition()
        })
    }
    
    @IBAction private func doneButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInGameScreen()
        model.navigationManager.dismissGameScreenAnimated(true)
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClickedInGameScreen()
        model.navigationManager.presentStatsScreenWithLevel(level, animated: true)
    }
}

extension GameScreen: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress) {
        let levelIndex = manager.progressItemForLevel(levelProgress.level).index
        let text = NSString(format: NSLocalizedString("banner_format_unlocked_level", comment: ""), levelProgress.level.name) as String
        
        Analytics.unlockedLevelBannerShownInGameScreen(levelProgress.level)
        model.navigationManager.presentBannerWithText(text, tapHandler: { [unowned self] in
            Analytics.unlockBannerClickedInGameScreen(levelProgress.level)
            self.model.navigationManager.dismissScreenAnimated(true, completion: {
                self.model.navigationManager.mainScreen.levelsController.scrollToLevelAtIndex(levelIndex, animated: true)
            })
        })
    }
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        if manager.isLockedLevel(level) {
            model.navigationManager.dismissGameScreenAnimated(true)
        }
    }
}
