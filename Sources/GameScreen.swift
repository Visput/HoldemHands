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
    
    private var currentHandOddsCalculator: HandOddsCalculator!
    private var nextHandOddsCalculator: HandOddsCalculator!
    private var needsShowNextHandImmediately: Bool = true
    
    private var gameView: GameView {
        return view as! GameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.configureCollectionViewLayoutForNumberOfHands(level.numberOfHands)
        generateNextHand()
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
    
    private func generateNextHand() {
        gameView.swipeRecognizer.enabled = false
        gameView.tapRecognizer.enabled = false
        
        if currentHandOddsCalculator == nil {
            gameView.handsCollectionView.userInteractionEnabled = false
            
            currentHandOddsCalculator = HandOddsCalculator(numberOfHands: level.numberOfHands)
            currentHandOddsCalculator.calculateOdds({ handsOdds in
                self.gameView.handsCollectionView.reloadData()
                self.gameView.handsCollectionView.userInteractionEnabled = true
                
                self.needsShowNextHandImmediately = false
                self.generateNextHand()
            })
        } else if nextHandOddsCalculator?.handsOdds == nil {
            if !needsShowNextHandImmediately {
                nextHandOddsCalculator = HandOddsCalculator(numberOfHands: level.numberOfHands)
                nextHandOddsCalculator.calculateOdds({ handsOdds in
                    if self.needsShowNextHandImmediately {
                        self.currentHandOddsCalculator = self.nextHandOddsCalculator
                        self.nextHandOddsCalculator = nil
                        self.gameView.handsCollectionView.reloadData()
                        self.gameView.handsCollectionView.userInteractionEnabled = true
                        
                        self.needsShowNextHandImmediately = false
                        self.generateNextHand()
                    }
                })
            } else {
                currentHandOddsCalculator = nextHandOddsCalculator
                gameView.handsCollectionView.reloadData()
                gameView.handsCollectionView.userInteractionEnabled = false
            }
        } else {
            currentHandOddsCalculator = nextHandOddsCalculator
            nextHandOddsCalculator = nil
            gameView.handsCollectionView.reloadData()
            gameView.handsCollectionView.userInteractionEnabled = true
            
            self.needsShowNextHandImmediately = false
            self.generateNextHand()
        }
    }
    
    private func updateChipsCountLabel() {
        gameView.chipsCountLabel.text = NSString(format: NSLocalizedString("Chips: %@   x%lld", comment: ""),
            model.playerManager.playerData.chipsCount.formattedChipsCountString,
            model.playerManager.chipsMultiplierForLevel(level)) as String
    }
}

extension GameScreen {
    
    @IBAction private func nextHandGestureDidSwipe(sender: AnyObject) {
        needsShowNextHandImmediately = true
        generateNextHand()
    }
    
    @IBAction private func menuButtonDidPress(sender: AnyObject) {
        Analytics.doneClickedInGame()
        model.navigationManager.dismissScreenAnimated(true)
    }
}

extension GameScreen: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentHandOddsCalculator.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandCell.className(),
            forIndexPath: indexPath) as! HandCell
        
        let item = HandCellItem(handOdds: currentHandOddsCalculator.handsOdds?[indexPath.item], needsShowOdds: false, isSuccessSate: nil)
        cell.fillWithItem(item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! HandCell
        
        for cell in collectionView.visibleCells() as! [HandCell] {
            var isSuccessState: Bool? = nil
            if currentCell == cell {
                isSuccessState = cell.item.handOdds!.wins
                if isSuccessState! {
                    model.playerManager.trackNewWinInLevel(level)
                } else {
                    model.playerManager.trackNewLossInLevel(level)
                }
                updateChipsCountLabel()
            }
            let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
            cell.fillWithItem(item)
        }
        
        gameView.swipeRecognizer.enabled = true
        gameView.tapRecognizer.enabled = true
        gameView.handsCollectionView.userInteractionEnabled = false
        Analytics.gameRoundPlayed()
    }
}

extension GameScreen: PlayerManagerObserving {
    
    func playerManager(manager: PlayerManager, didUnlockLevel levelProgress: LevelProgress) {
        let levelName = levelProgress.level.name
        let text =  NSString(format: NSLocalizedString("Congratulations. %@ is unlocked now!", comment: ""), levelName)
        
        Analytics.unlockBannerShownInGame(levelProgress.level)
        model.navigationManager.showBannerWithText(text as String, tapAction: { [unowned self] in
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
