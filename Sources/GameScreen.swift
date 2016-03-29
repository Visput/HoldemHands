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
        firstHandsController.generateHands()
        
        secondHandsController.numberOfHands = level.numberOfHands
        secondHandsController.didPlayRoundHandler = { [unowned self] won in
            self.didPlayRoundHandler(won)
        }
        secondHandsController.nextController = firstHandsController
        
        gameView.swipeRecognizer.enabled = false
        gameView.tapRecognizer.enabled = false
        
        updateChipsCountLabel()
        model.playerManager.observers.addObserver(self)
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
        if segue.identifier! == "FirstHands" {
            firstHandsController = segue.destinationViewController as! HandsCollectionViewController
            
        } else if segue.identifier! == "SecondHands" {
            secondHandsController = segue.destinationViewController as! HandsCollectionViewController
        }
    }
    
    private func didPlayRoundHandler(won: Bool) {
        if won {
            model.playerManager.trackNewWinInLevel(level)
        } else {
            model.playerManager.trackNewLossInLevel(level)
        }
        updateChipsCountLabel()
        gameView.swipeRecognizer.enabled = true
        gameView.tapRecognizer.enabled = true
        Analytics.gameRoundPlayed()
    }
    
    private func updateChipsCountLabel() {
        gameView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %@   x%lld", comment: ""),
            model.playerManager.playerData.chipsCount.formattedChipsCountString,
            model.playerManager.chipsMultiplierForLevel(level)) as String
    }
}

extension GameScreen {
    
    @IBAction private func nextHandGestureDidSwipe(sender: AnyObject) {
        gameView.swipeRecognizer.enabled = false
        gameView.tapRecognizer.enabled = false
        gameView.scrollToNextHandsView()
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInGame()
        model.navigationManager.dismissScreenAnimated(true)
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
        } else {
            updateChipsCountLabel()
        }
    }
}
