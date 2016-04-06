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
    
    private var firstHandsController: HandsCollectionViewController!
    private var secondHandsController: HandsCollectionViewController!
    
    private var gameView: GameView {
        return view as! GameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        gameView.swipeRecognizer.enabled = false
        gameView.tapRecognizer.enabled = false
    
        model.playerManager.observers.addObserver(self)
        
        firstHandsController.generateHands()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        model.playerManager.savePlayerData()
    }
    
    override func viewDidShow() {
        super.viewDidShow()
        Analytics.gameAppeared(level)
    }
    
    override func viewDidHide() {
        super.viewDidHide()
        Analytics.gameDisappeared(level)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FirstHands" {
            firstHandsController = segue.destinationViewController as! HandsCollectionViewController
            
        } else if segue.identifier == "SecondHands" {
            secondHandsController = segue.destinationViewController as! HandsCollectionViewController
        }
    }
    
    private func didPlayRoundHandler(won: Bool) {
        if won {
            model.playerManager.trackNewWinInLevel(level)
        } else {
            model.playerManager.trackNewLossInLevel(level)
        }
        
        gameView.swipeRecognizer.enabled = true
        gameView.tapRecognizer.enabled = true
        Analytics.gameRoundPlayed()
    }
}

extension GameScreen {
    
    @IBAction private func nextHandGestureDidSwipe(sender: AnyObject) {
        gameView.swipeRecognizer.enabled = false
        gameView.tapRecognizer.enabled = false
        gameView.scrollToNextHandsView({
            self.firstHandsController.viewDidChangePosition()
            self.secondHandsController.viewDidChangePosition()
        })
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInGame()
        model.navigationManager.dismissScreenAnimated(true)
    }
    
    @IBAction private func statsButtonDidPress(sender: AnyObject) {
        Analytics.statsClickedInGame()
        model.navigationManager.presentStatsScreenWithLevel(level, animated: true)
    }
}

extension GameScreen: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress) {
        let levelName = levelProgress.level.name
        let text =  NSString(format: NSLocalizedString("Congratulations. %@ is unlocked now!", comment: ""), levelName)
        
        Analytics.unlockBannerShownInGame(levelProgress.level)
        model.navigationManager.showBannerWithText(text as String, tapHandler: { [unowned self] in
            Analytics.unlockBannerClickedInGame(levelProgress.level)
            self.model.navigationManager.dismissScreenAnimated(true)
        })
    }
    
    func playerManager(manager: PlayerManager, didLoadPlayerData playerData: PlayerData) {
        if manager.isLockedLevel(level) {
            model.navigationManager.dismissScreenAnimated(true)
        }
    }
}
