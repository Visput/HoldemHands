//
//  HandCell.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class HandCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var firstCardImageView: UIImageView!
    @IBOutlet private(set) weak var secondCardImageView: UIImageView!
    @IBOutlet private(set) weak var winningOddsLabel: UILabel!
    @IBOutlet private(set) weak var tieOddsLabel: UILabel!
 
    private(set) var item: HandCellItem!
    
    func fillWithItem(item: HandCellItem) {
        self.item = item
        
    }
}
