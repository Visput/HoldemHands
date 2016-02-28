//
//  HandRankCalculator.swift
//  PokerHand
//
//  Created by Uladzimir Papko on 2/20/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import Foundation

private var cardsArray = QuickArray<QuickArray<Card>>()

struct HandRankCalculator: Equatable, Comparable {
    
    private var handRank: HandRank!
    
    private var straightOrFlashCards = QuickArray<Card>()
    private var fourOfKindCard: Card!
    private var threeOfKindCard: Card!
    private var highPairCard: Card!
    private var lowPairCard: Card!
    private var cards: QuickArray<Card>!
    
    init() {
        if cardsArray.count == 0 {
            cardsArray.append(QuickArray<Card>())
            cardsArray.append(QuickArray<Card>())
            cardsArray.append(QuickArray<Card>())
            cardsArray.append(QuickArray<Card>())
        }
    }
    
    mutating func calculateRankForCards(inout orderedCards: OrderedCards) {        
        // Reset data.
        for index in 0 ..< cardsArray.count {
            cardsArray[index].removeAll()
        }
        straightOrFlashCards.removeAll()
        fourOfKindCard = nil
        threeOfKindCard = nil
        highPairCard = nil
        lowPairCard = nil
        
        cards = orderedCards.cards
        
        // Calculate rank.
        for index in 0 ..< cards.count {
            let card1 = cards[index]
            let suitIndex = card1.suit.rawValue
            cardsArray[suitIndex].append(card1)
            
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
        
        var suitedCards = cardsArray.first!
        for index in 1 ..< cardsArray.count {
            if cardsArray[index].count > suitedCards.count {
                suitedCards = cardsArray[index]
            }
        }
        
        if suitedCards.count >= 5 {
            mainLoop: for index in 0 ... suitedCards.count - 4 {
                subLoop: for subIndex in index ..< suitedCards.count {
                    if straightOrFlashCards.count == 0 {
                        straightOrFlashCards.append(suitedCards[subIndex])
                        
                    } else if straightOrFlashCards.last!.rank.rawValue == suitedCards[subIndex].rank.rawValue + 1 {
                        straightOrFlashCards.append(suitedCards[subIndex])
                        
                        if straightOrFlashCards.count == 4 && straightOrFlashCards.last!.rank == .Two && suitedCards.first!.rank == .Ace {
                            // Steel Wheel.
                            straightOrFlashCards.append(suitedCards.first!)
                            break mainLoop
                            
                        } else if straightOrFlashCards.count == 5 {
                            break mainLoop
                        }
                        
                    } else if straightOrFlashCards.last!.rank.rawValue > suitedCards[subIndex].rank.rawValue + 1  {
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
                straightOrFlashCards = suitedCards
                straightOrFlashCards.removeLast(straightOrFlashCards.count - 5)
                
                handRank = .Flush
                return
            }
            
        } else {
            mainLoop: for index in 0 ... cards.count - 4 {
                subLoop: for subIndex in index ..< cards.count {
                    if straightOrFlashCards.count == 0 {
                        straightOrFlashCards.append(cards[subIndex])
                        
                    } else if straightOrFlashCards.last!.rank.rawValue == cards[subIndex].rank.rawValue + 1 {
                        straightOrFlashCards.append(cards[subIndex])
                        
                        if straightOrFlashCards.count == 4 && straightOrFlashCards.last!.rank == .Two && cards.first!.rank == .Ace {
                            // Wheel Straight.
                            straightOrFlashCards.append(cards.first!)
                            break mainLoop
                            
                        } else if straightOrFlashCards.count == 5 {
                            break mainLoop
                        }
                        
                    } else if straightOrFlashCards.last!.rank.rawValue > cards[subIndex].rank.rawValue + 1  {
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

func ==(lhs: HandRankCalculator, rhs: HandRankCalculator) -> Bool {
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

func <(lhs: HandRankCalculator, rhs: HandRankCalculator) -> Bool {
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
                } else  {
                    return false
                }
            }
        }
        
    case .StraightFlush:
        return lhs.straightOrFlashCards.first!.rank < rhs.straightOrFlashCards.first!.rank
    }
    
    return false
}
