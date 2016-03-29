//
//  GameView.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 2/18/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit

final class GameView: UIView {
    
    @IBOutlet private(set) weak var chipsCountLabel: UILabel!
    @IBOutlet private(set) weak var swipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet private(set) weak var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet private(set) weak var handsScrollView: EndlessScrollView!
}
