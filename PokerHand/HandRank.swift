//
//  HandRank.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/20/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

protocol HandRank: Equatable, Comparable {
    
    init?(orderedCards: OrderedCards)
}