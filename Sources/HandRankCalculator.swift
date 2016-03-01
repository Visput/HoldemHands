//
//  HandRankCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/20/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

// swiftlint:disable cyclomatic_complexity

struct HandRankCalculator: Equatable, Comparable {
    
    private var handRank: HandRank!

    private var fourOfKindCard: Card!
    private var threeOfKindCard: Card!
    private var highPairCard: Card!
    private var lowPairCard: Card!
    private var straightOrFlashCards: QuickArray<Card>
    
    private var cards: QuickArray<Card>
    private var spadesCards: QuickArray<Card>
    private var heartsCards: QuickArray<Card>
    private var diamondsCards: QuickArray<Card>
    private var clubsCards: QuickArray<Card>
    
    init() {
        straightOrFlashCards = QuickArray<Card>(5)
        
        let numberOfCards = 7
        cards = QuickArray<Card>(numberOfCards)
        spadesCards = QuickArray<Card>(numberOfCards)
        heartsCards = QuickArray<Card>(numberOfCards)
        diamondsCards = QuickArray<Card>(numberOfCards)
        clubsCards = QuickArray<Card>(numberOfCards)
    }
    
    func destroy() {
        straightOrFlashCards.destroy()
        cards.destroy()
        spadesCards.destroy()
        heartsCards.destroy()
        diamondsCards.destroy()
        clubsCards.destroy()
    }
    
    mutating func calculateRankForHand(inout hand: Hand, inout boardCards: QuickArray<Card>) {
        // Reset data.
        fourOfKindCard = nil
        threeOfKindCard = nil
        highPairCard = nil
        lowPairCard = nil
        straightOrFlashCards.removeAll()
        
        cards.removeAll()
        spadesCards.removeAll()
        heartsCards.removeAll()
        diamondsCards.removeAll()
        clubsCards.removeAll()
        
        // TODO: One cycle for sorting, suited cards filtering and rank calculation.
        
        // Sort cards.
        for index in 0 ..< boardCards.count {
            cards.append(boardCards[index])
        }
        
        var firstCardInserted = false
        for index in 0 ..< boardCards.count {
            let card = boardCards[index]
            if !firstCardInserted {
                if card.rank < hand.firstCard.rank {
                    firstCardInserted = true
                    
                    cards.insert(hand.firstCard, atIndex: index)
                    if card.rank < hand.secondCard.rank {
                        cards.insert(hand.secondCard, atIndex: index + 1)
                        break
                        
                    } else if index == boardCards.count - 1 {
                        cards.append(hand.secondCard)
                    }
                    
                } else if index == boardCards.count - 1 {
                    cards.append(hand.firstCard)
                    cards.append(hand.secondCard)
                }
                
            } else {
                if card.rank < hand.secondCard.rank {
                    cards.insert(hand.secondCard, atIndex: index + 1)
                    break
                    
                } else if index == boardCards.count - 1 {
                    cards.append(hand.secondCard)
                }
            }
        }
        
        // Calculate rank.
        for index in 0 ..< cards.count {
            let card1 = cards[index]
            
            if card1.suit == .Spades {
                spadesCards.append(card1)
            } else if card1.suit == .Hearts {
                heartsCards.append(card1)
            } else if card1.suit == .Diamonds {
                diamondsCards.append(card1)
            } else {
                clubsCards.append(card1)
            }
            
            if index < cards.count - 1 {
                let card2 = cards[index + 1]
                if card1.rank == card2.rank {
                    if index < cards.count - 2 {
                        let card3 = cards[index + 2]
                        if card1.rank == card3.rank {
                            if index < cards.count - 3 {
                                let card4 = cards[index + 3]
                                if card1.rank == card4.rank {
                                    fourOfKindCard = card1
                                    
                                    handRank = .FourOfKind
                                    return
                                    
                                } else {
                                    if threeOfKindCard == nil {
                                        threeOfKindCard = card1
                                    }
                                }
                                
                            } else {
                                if threeOfKindCard == nil {
                                    threeOfKindCard = card1
                                }
                            }
                            
                        } else {
                            if threeOfKindCard == nil || threeOfKindCard.rank != card1.rank {
                                if highPairCard == nil {
                                    highPairCard = card1
                                } else if lowPairCard == nil {
                                    lowPairCard = card1
                                }
                            }
                        }
                        
                    } else {
                        if threeOfKindCard == nil || threeOfKindCard.rank != card1.rank {
                            if highPairCard == nil {
                                highPairCard = card1
                            } else if lowPairCard == nil {
                                lowPairCard = card1
                            }
                        }
                    }
                }
            }
        }
        
        guard threeOfKindCard == nil || highPairCard == nil else {
            
            handRank = .FullHouse
            return
        }
        
        var suitedCards = spadesCards
        if suitedCards.count < heartsCards.count {
            suitedCards = heartsCards
        }
        if suitedCards.count < diamondsCards.count {
            suitedCards = diamondsCards
        }
        if suitedCards.count < clubsCards.count {
            suitedCards = clubsCards
        }
        
        if suitedCards.count >= 5 {
            var lastFlushCard: Card! = nil
            mainLoop: for index in 0 ... suitedCards.count - 4 {
                subLoop: for subIndex in index ..< suitedCards.count {
                    let flushCard = suitedCards[subIndex]
                    
                    if straightOrFlashCards.count == 0 {
                        straightOrFlashCards.append(flushCard)
                        lastFlushCard = flushCard
                        
                    } else if lastFlushCard.rank.rawValue == flushCard.rank.rawValue + 1 {
                        straightOrFlashCards.append(flushCard)
                        lastFlushCard = flushCard
                        
                        if straightOrFlashCards.count == 4 && lastFlushCard.rank == .Two && suitedCards.first!.rank == .Ace {
                            // Steel Wheel.
                            straightOrFlashCards.append(suitedCards.first!)
                            break mainLoop
                            
                        } else if straightOrFlashCards.count == 5 {
                            break mainLoop
                        }
                        
                    } else if lastFlushCard.rank.rawValue > flushCard.rank.rawValue + 1 {
                        straightOrFlashCards.removeAll()
                        break subLoop
                    }
                }
                
                straightOrFlashCards.removeAll()
            }
            
            if straightOrFlashCards.count == 5 {
                
                handRank = .StraightFlush
                return
                
            } else {
                straightOrFlashCards.removeAll()
                for index in 0 ..< 5 {
                    straightOrFlashCards.append(suitedCards[index])
                }
                
                handRank = .Flush
                return
            }
            
        } else {
            var lastStraightCard: Card! = nil
            mainLoop: for index in 0 ... cards.count - 4 {
                subLoop: for subIndex in index ..< cards.count {
                    let straightCard = cards[subIndex]
                    
                    if straightOrFlashCards.count == 0 {
                        straightOrFlashCards.append(straightCard)
                        lastStraightCard = straightCard
                        
                    } else if lastStraightCard.rank.rawValue == straightCard.rank.rawValue + 1 {
                        straightOrFlashCards.append(straightCard)
                        lastStraightCard = straightCard
                        
                        if straightOrFlashCards.count == 4 && lastStraightCard.rank == .Two && cards.first!.rank == .Ace {
                            // Wheel Straight.
                            straightOrFlashCards.append(cards.first!)
                            break mainLoop
                            
                        } else if straightOrFlashCards.count == 5 {
                            break mainLoop
                        }
                        
                    } else if lastStraightCard.rank.rawValue > straightCard.rank.rawValue + 1 {
                        straightOrFlashCards.removeAll()
                        break subLoop
                    }
                }
                
                straightOrFlashCards.removeAll()
            }
            
            guard straightOrFlashCards.count != 5 else {
                
                handRank = .Straight
                return
            }
            
            guard threeOfKindCard == nil else {
                
                handRank = .ThreeOfKind
                return
            }
            
            if highPairCard != nil {
                if lowPairCard != nil {
                    
                    handRank = .TwoPairs
                    return
                    
                } else {
                    
                    handRank = .Pair
                    return
                }
                
            } else {
                
                handRank = .HighCard
                return
            }
        }
    }
}

func == (lhs: HandRankCalculator, rhs: HandRankCalculator) -> Bool {
    guard lhs.handRank == rhs.handRank else { return false }
    
    switch lhs.handRank! {
        
    case .HighCard:
        for index in 0 ..< 5 {
            if lhs.cards[index].rank != rhs.cards[index].rank {
                return false
            }
        }
        
        return true
        
    case .Pair:
        guard lhs.highPairCard.rank == rhs.highPairCard.rank else { return false }
        
        var numberOfSignificantCards = 0
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.highPairCard.rank {
                if card.rank != rhs.cards[index].rank {
                    return false
                }
                
                numberOfSignificantCards += 1
                if numberOfSignificantCards == 3 {
                    return true
                }
            }
        }
        
    case .TwoPairs:
        guard lhs.highPairCard.rank == rhs.highPairCard.rank &&
            lhs.lowPairCard.rank == rhs.lowPairCard.rank else { return false }
        
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.highPairCard.rank && card.rank != lhs.lowPairCard.rank {
                if card.rank != rhs.cards[index].rank {
                    return false
                } else {
                    return true
                }
            }
        }
        
    case .ThreeOfKind:
        guard lhs.threeOfKindCard.rank == rhs.threeOfKindCard.rank else { return false }
        
        var numberOfSignificantCards = 0
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.threeOfKindCard.rank {
                if card.rank != rhs.cards[index].rank {
                    return false
                }
                
                numberOfSignificantCards += 1
                if numberOfSignificantCards == 2 {
                    return true
                }
            }
        }
        
    case .Straight:
        return lhs.straightOrFlashCards.first!.rank == rhs.straightOrFlashCards.first!.rank
        
    case .Flush:
        for index in 0 ..< 5 {
            if lhs.straightOrFlashCards[index].rank != rhs.straightOrFlashCards[index].rank {
                return false
            }
        }
        
        return true
        
    case .FullHouse:
        return lhs.threeOfKindCard.rank == rhs.threeOfKindCard.rank &&
            lhs.highPairCard.rank == rhs.highPairCard.rank
        
    case .FourOfKind:
        guard lhs.fourOfKindCard.rank == rhs.fourOfKindCard.rank else { return false }

        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.fourOfKindCard.rank {
                if card.rank != rhs.cards[index].rank {
                    return false
                } else {
                    return true
                }
            }
        }
        
    case .StraightFlush:
        return lhs.straightOrFlashCards.first!.rank == rhs.straightOrFlashCards.first!.rank
    }
    
    return true
}

func < (lhs: HandRankCalculator, rhs: HandRankCalculator) -> Bool {
    guard lhs.handRank == rhs.handRank else {
        return lhs.handRank < rhs.handRank
    }
    
    switch lhs.handRank! {
        
    case .HighCard:
        for index in 0 ..< 5 {
            if lhs.cards[index].rank < rhs.cards[index].rank {
                return true
            } else if lhs.cards[index].rank > rhs.cards[index].rank {
                return false
            }
        }
        
        return false
        
    case .Pair:
        guard lhs.highPairCard.rank == rhs.highPairCard.rank else {
            return lhs.highPairCard.rank < rhs.highPairCard.rank
        }
        
        var numberOfSignificantCards = 0
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.highPairCard.rank {
                if card.rank < rhs.cards[index].rank {
                    return true
                } else if card.rank > rhs.cards[index].rank {
                    return false
                }
                
                numberOfSignificantCards += 1
                if numberOfSignificantCards == 3 {
                    return false
                }
            }
        }
        
    case .TwoPairs:
        guard lhs.highPairCard.rank == rhs.highPairCard.rank &&
            lhs.lowPairCard.rank == rhs.lowPairCard.rank else {
                if lhs.highPairCard.rank < rhs.highPairCard.rank {
                    return true
                } else if lhs.highPairCard.rank > rhs.highPairCard.rank {
                    return false
                } else if lhs.lowPairCard.rank < rhs.lowPairCard.rank {
                    return true
                } else {
                    return false
                }
        }
        
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.highPairCard.rank && card.rank != lhs.lowPairCard.rank {
                if card.rank < rhs.cards[index].rank {
                    return true
                } else {
                    return false
                }
            }
        }
        
    case .ThreeOfKind:
        guard lhs.threeOfKindCard.rank == rhs.threeOfKindCard.rank else {
            return lhs.threeOfKindCard.rank < rhs.threeOfKindCard.rank
        }
        
        var numberOfSignificantCards = 0
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.threeOfKindCard.rank {
                if card.rank < rhs.cards[index].rank {
                    return true
                } else if card.rank > rhs.cards[index].rank {
                    return false
                }
                
                numberOfSignificantCards += 1
                if numberOfSignificantCards == 2 {
                    return false
                }
            }
        }
        
    case .Straight:
        return lhs.straightOrFlashCards.first!.rank < rhs.straightOrFlashCards.first!.rank
        
    case .Flush:
        for index in 0 ..< 5 {
            if lhs.straightOrFlashCards[index].rank < rhs.straightOrFlashCards[index].rank {
                return true
            } else if lhs.straightOrFlashCards[index].rank > rhs.straightOrFlashCards[index].rank {
                return false
            }
        }
        
        return false
        
    case .FullHouse:
        guard lhs.threeOfKindCard.rank == rhs.threeOfKindCard.rank &&
            lhs.highPairCard.rank == rhs.highPairCard.rank else {
                if lhs.threeOfKindCard.rank < rhs.threeOfKindCard.rank {
                    return true
                } else if lhs.threeOfKindCard.rank > rhs.threeOfKindCard.rank {
                    return false
                } else if lhs.highPairCard.rank < rhs.highPairCard.rank {
                    return true
                } else {
                    return false
                }
        }
        
        return false
        
    case .FourOfKind:
        guard lhs.fourOfKindCard.rank == rhs.fourOfKindCard.rank else {
            return lhs.fourOfKindCard.rank < rhs.fourOfKindCard.rank
        }
        
        for index in 0 ..< lhs.cards.count {
            let card = lhs.cards[index]
            if card.rank != lhs.fourOfKindCard.rank {
                if card.rank < rhs.cards[index].rank {
                    return true
                } else {
                    return false
                }
            }
        }
        
    case .StraightFlush:
        return lhs.straightOrFlashCards.first!.rank < rhs.straightOrFlashCards.first!.rank
    }
    
    return false
}

// swiftlint:enable cyclomatic_complexity
