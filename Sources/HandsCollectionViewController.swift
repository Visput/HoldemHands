//
//  HandsCollectionViewController.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/28/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation
import UIKit

final class HandsCollectionViewController: UIViewController {
    
    var numberOfHands: Int! {
        didSet {
            let layout = HandsCollectionViewLayout(numberOfHands: numberOfHands)
            handsCollectionView.collectionViewLayout = layout
        }
    }
    
    weak var nextController: HandsCollectionViewController?
    
    var didPlayRoundHandler: ((won: Bool) -> Void)?
    
    @IBOutlet private(set) weak var handsCollectionView: UICollectionView!
    
    private var handOddsCalculator: HandOddsCalculator!
    private var needsGenerateHandsOnViewDisappear = false
    
    private var isViewPresented: Bool {
        let window = UIApplication.sharedApplication().keyWindow!
        let windowFrame = window.frame
        let viewFrame = view.convertRect(view.bounds, toView: window)
        return CGRectContainsRect(windowFrame, viewFrame)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handsCollectionView.userInteractionEnabled = false
    }
    
    func viewDidChangePosition() {
        if isViewPresented && handOddsCalculator.handsOdds != nil {
            flipHands()
        }
        
        if !isViewPresented && needsGenerateHandsOnViewDisappear {
            needsGenerateHandsOnViewDisappear = false
            generateHands()
        }
    }
    
    func generateHands() {
        handOddsCalculator = HandOddsCalculator(numberOfHands: numberOfHands)
        handsCollectionView.reloadData()
        
        handOddsCalculator.calculateOdds({ handsOdds in
            self.handsCollectionView.reloadData()
            self.handsCollectionView.userInteractionEnabled = true
            if self.isViewPresented {
                self.flipHands()
            }
            
            guard self.nextController != nil else { return }
            if self.nextController!.isViewPresented {
                self.nextController!.needsGenerateHandsOnViewDisappear = true
            } else {
                self.nextController!.generateHands()
            }
        })
    }
    
    private func flipHands() {
        
    }
}

extension HandsCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return handOddsCalculator.hands.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HandCell.className(),
                                                                         forIndexPath: indexPath) as! HandCell
        
        let item = HandCellItem(handOdds: handOddsCalculator.handsOdds?[indexPath.item], needsShowOdds: false, isSuccessSate: nil)
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
                    didPlayRoundHandler?(won: true)
                } else {
                    didPlayRoundHandler?(won: false)
                }
                
            } else {
                if cell.item.handOdds!.wins {
                    isSuccessState = true
                }
            }
            let item = HandCellItem(handOdds: cell.item.handOdds, needsShowOdds: true, isSuccessSate: isSuccessState)
            cell.fillWithItem(item)
        }
        
        handsCollectionView.userInteractionEnabled = false
    }
}
