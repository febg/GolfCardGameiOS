//
//  BotManager.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-14.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

class BotManager {
  var dificulty: Int = 0
  
  struct Move {
    var type: MoveType
    var setAt: Int?
    
    init(moveType: MoveType) {
      type = moveType
    }
    
    init(moveType: MoveType, at: Int) {
      type = moveType
      setAt = at
    }
  }
  
  enum Source {
    case pile
    case deck
  }
  
  enum MoveType {
    case getDeck
    case getPile
    case getSelf
    case setSelf
    case swap
  }
  
  enum CardHierarchy {
    case negative
    case neutral
    case low
    case high
    case avoided
  }
  
  public func getHierarchies(cardList: [Card]) -> [CardHierarchy] {
    var cardHierarchies = [CardHierarchy]()
    for c in 0..<cardList.count {
      cardHierarchies.append(getHierarchy(cardRank: cardList[c].rank!))
    }
    return cardHierarchies
  }
  
  //makeFirstMove either getsPileCard, flip selfCard or getsDeckCard
  public func makeFirstMove(playerHand: [Card], topPileCard: Card) -> Move {
    let pileHierchary = getHierarchy(cardRank: topPileCard.rank!)
    let cardsHierarchies = getHierarchies(cardList: playerHand)
    if (isNewCardValid(newCard: topPileCard, newCardHierarchy: pileHierchary, cards: playerHand)) {
      return Move(moveType: .getPile)
    }
    if let flipCardAt = flipOwnCard(cards: playerHand, cardsHierarchies: cardsHierarchies) {
      return Move(moveType: .setSelf, at: flipCardAt)
    } else {
      return Move(moveType: .getDeck)
    }
  }
  
  public func makeSecondMove(playerHand: [Card], newCard: Card) -> Move? {
    let cardHierchary = getHierarchy(cardRank: newCard.rank!)
    let cardsHierarchies = getHierarchies(cardList: playerHand)
    if (isNewCardValid(newCard: newCard, newCardHierarchy: cardHierchary, cards: playerHand)) {
      let move = makeSecondMove(playerHand: playerHand, card: newCard)
      return move
    }
    if let flipCardAt = flipOwnCard(cards: playerHand, cardsHierarchies: cardsHierarchies) {
      return Move(moveType: .setSelf, at: flipCardAt)
    } else {
      let randomIndex = getRandomUnseenCard(cards: playerHand)
      return Move(moveType: .setSelf, at: randomIndex)
    }
  }
  
  public func makeSecondMove(playerHand: [Card], card: Card) -> Move? {
    let cardHierarchy = getHierarchy(cardRank: card.rank!)
    switch cardHierarchy {
    case .negative:
      let index = placeNegative(card: card, cards: playerHand)
      return Move(moveType: .swap, at: index)
    case .neutral:
      let index = placeNeutral(card: card, cards: playerHand)
      return Move(moveType: .swap, at: index)
    case .low:
      let index = placeLow(card: card, cards: playerHand)
      return Move(moveType: .swap, at: index)
    case .high:
      let index = placeHigh(card: card, cards: playerHand)
      return Move(moveType: .swap, at: index)
    case .avoided:
      break
    }
    return nil
  }
  
  private func getHierarchy(cardRank: Card.Rank) -> CardHierarchy {
    switch cardRank {
    case .two: return .negative
    case .king, .jack: return .neutral
    case .ace, .three, .four, .five: return .low
    case .six, .seven, .eight, .nine, .ten: return .high
    case .queen: return .avoided
    }
  }
  
  private func isNewCardValid(newCard: Card, newCardHierarchy: CardHierarchy, cards: [Card]) -> Bool {
    switch newCardHierarchy {
    case .negative:
      return true
    case .neutral:
      return true
    case .low:
      if let singleEqualCard = findSingleEqualCard(card: newCard, cards: cards) {
        return singleEqualCard
      } else if let sigleHighestCard = findHighestSingleCard(card: newCard, inCards: cards) {
        return sigleHighestCard
      } else {
        return false
      }
    case .high:
      if let singleEqualCard = findSingleEqualCard(card: newCard, cards: cards) {
        return singleEqualCard
      } else {
        return false
      }
    case .avoided:
      if let doubleEqualCard = findTwoEqualCards(card: newCard, inCards: cards) {
        return doubleEqualCard
      }
      return false
    }
  }
  
  private func flipOwnCard(cards: [Card], cardsHierarchies: [CardHierarchy]) -> Int? {
    if let doubleCard = checkDoubleCards(cards: cards) {
      return doubleCard
    } else {
      for c in 0..<cards.count {
        switch(cards[c].faceUp, cardsHierarchies[c]) {
        case (false, .negative):
          return c
        case (false, .neutral):
          return c
        default:
          break
        }
      }
      return nil
    }
  }
  
  private func checkDoubleCards(cards: [Card]) -> Int? {
    let cardCount = getCardCount(cards: cards)
    for c in 0..<cards.count {
      if cardCount[cards[c].rank!.value] == 2 {
        if !cards[c].faceUp { return c }
      }
    }
    return nil
  }
  
  private func placeNegative(card: Card, cards: [Card] ) -> Int {
    if let highestSingleCard = getHigherSingleCard(card: card, inCards: cards) {
      return highestSingleCard
    } else {
      let randomUnseenCard = getRandomUnseenCard(cards: cards)
      return randomUnseenCard
    }
  }
  
  private func placeNeutral(card: Card, cards: [Card]) -> Int {
    if let highestSingleCard = getHigherSingleCard(card: card, inCards: cards) {
      return highestSingleCard
    } else {
      let randomUnseenCard = getRandomUnseenCard(cards: cards)
      return randomUnseenCard
    }
  }
  
  private func placeLow(card: Card, cards: [Card]) -> Int {
    if let replaceForEqual = getHighNotEqualSingleCard(card: card, inCards: cards) {
      return replaceForEqual
    } else {
      let randomUnseenCard = getRandomUnseenCard(cards: cards)
      return randomUnseenCard
    }
  }
  
  private func placeHigh(card: Card, cards: [Card]) -> Int {
    if let replaceForEqual = getHighNotEqualSingleCard(card: card, inCards: cards) {
      return replaceForEqual
    } else {
      let randomUnseenCard = getRandomUnseenCard(cards: cards)
      return randomUnseenCard
    }
  }
  
  private func placeAvoided(card: Card, cards: [Card]) -> Int {
    if let doubleEqualCard = getDoubleCard(card: card, inCards: cards) {
      return doubleEqualCard
    }
    return 1
  }
  
  private func findHighestSingleCard(card: Card, inCards cards: [Card]) -> Bool? {
    let cardValue = card.rank!.value
    var higherValues = [Int: Int]()
    for c in 0..<cards.count {
      switch(dificulty, cards[c].faceUp, cards[c].visibleToOwner) {
      //TODO: Handle case when two neutral
      case (0, true, _), (0, false, true):
        if cards[c].rank!.value > cardValue {
          if let count = higherValues[cards[c].rank!.value] {
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      default:
        break
      }
    }
    for (_, count) in higherValues {
      if count == 1 { return true }
    }
    return nil
  }
  
  private func findSingleEqualCard(card: Card, cards: [Card]) -> Bool? {
    var count = 0
    for c in 0..<cards.count {
      switch(dificulty, cards[c].faceUp, cards[c].visibleToOwner) {
      case (0, false, true), (0, true, _):
        count = cards[c].rank! == card.rank! ? count + 1 : count
      default:
        break
      }
    }
    return (count == 1) ? true : nil
  }
  
  private func getCardCount(cards: [Card]) -> [Int: Int] {
    var cardCount = [Int: Int]()
    for c in 0..<cards.count {
      if cardCount[cards[c].rank!.value] != nil {
        cardCount[cards[c].rank!.value] = cardCount[cards[c].rank!.value]! + 1
      } else {
        cardCount[cards[c].rank!.value] = 1
      }
    }
    return cardCount
  }
  
  private func getRandomUnseenCard(cards: [Card]) -> Int {
    var cardIndexMap = [Int: Int]()
    //TODO: unseenCards int?
    var unSeenCards = Array<Card>()
    for c in 0..<cards.count {
      if (!cards[c].faceUp) {
        cardIndexMap[unSeenCards.count] = c
        unSeenCards.append(cards[c])
      }
    }
    let randomIndex = arc4random_uniform(UInt32(unSeenCards.count - 1))
    return cardIndexMap[Int(randomIndex)]!
  }
  
  private func findTwoEqualCards(card: Card, inCards cards: [Card]) -> Bool? {
    var count = 0
    for c in 0..<cards.count {
      if (cards[c].rank! == card.rank!) { count = count + 1 }
    }
    return (count == 2) ? true : nil
  }
  private func getHigherSingleCard(card: Card, inCards cards: [Card]) -> Int? {
    let cardValue = card.rank!.value
    var cardMap = [Int: Int]()
    var higherValues = [Int: Int]()
    var maxValue = cardValue
    for c in 0..<cards.count {
      switch(dificulty, cards[c].faceUp, cards[c].visibleToOwner) {
      //TODO: Handle case when two neutral
      case (0, true, _):
        if cards[c].rank!.value > cardValue {
          if let count = higherValues[cards[c].rank!.value] {
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      case (0, false, true):
        if cards[c].rank!.value > cardValue {
          cardMap[cards[c].rank!.value] = c
          if let count = higherValues[cards[c].rank!.value] {
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      default:
        break
      }
    }
    for (value, count) in higherValues {
      if value > maxValue && count == 1 { maxValue = value }
    }
    return maxValue > cardValue ? cardMap[maxValue] : nil
  }
  
  //TODO fix function to be not equal...kind of confusing
  private func getHighNotEqualSingleCard(card: Card, inCards cards: [Card]) -> Int? {
    let cardValue = card.rank!.value
    var cardMap = [Int: Int]()
    var higherValues = [Int: Int]()
    var maxValue = -2
    for c in 0..<cards.count {
      switch(dificulty, cards[c].faceUp, cards[c].visibleToOwner) {
      //TODO: Handle case when two neutral
      case (0, true, _):
        if (cards[c].rank!.value > maxValue && cards[c].rank!.value != cardValue) {
          if let count = higherValues[cards[c].rank!.value] {
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      case (0, false, true):
        cardMap[cards[c].rank!.value] = c
        if cards[c].rank!.value > cardValue && cards[c].rank!.value != cardValue {
          if let count = higherValues[cards[c].rank!.value] {
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      default:
        break
      }
    }
    for (value, count) in higherValues {
      if value > maxValue && count == 1 { maxValue = value }
      else if value <= 0 && value > maxValue { maxValue = value }
    }
    return maxValue > cardValue ? cardMap[maxValue] : nil
  }
  
  private func getDoubleCard(card: Card, inCards cards: [Card]) -> Int? {
    let cardValue = card.rank!.value
    var cardMap = [Int: Int]()
    var higherValues = [Int: Int]()
    var maxValue = -2
    for c in 0..<cards.count {
      switch(dificulty, cards[c].faceUp, cards[c].visibleToOwner) {
      //TODO: Handle case when two neutral
      case (0, true, _):
        if cards[c].rank!.value > maxValue && cards[c].rank!.value != cardValue {
          if let count = higherValues[cards[c].rank!.value]{
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      case (0, false, true):
        cardMap[cards[c].rank!.value] = c
        if cards[c].rank!.value > cardValue && cards[c].rank!.value != cardValue {
          if let count = higherValues[cards[c].rank!.value] {
            higherValues[cards[c].rank!.value] = count + 1
          } else {
            higherValues[cards[c].rank!.value] = 1
          }
        }
      default:
        break
      }
    }
    for (value, count) in higherValues {
      if value > maxValue && count == 1 { maxValue = value }
      else if value <= 0 && value > maxValue { maxValue = value }
    }
    return maxValue > cardValue ? cardMap[maxValue] : nil
  }
  
  private func getHighestCard(cards: [Card]) -> Int {
    var maxValue = -3
    for c in 0..<cards.count {
      switch(dificulty, cards[c].faceUp, cards[c].visibleToOwner) {
      //TODO: Handle case when two neutral
      case (0, true, true):
        maxValue = cards[c].rank!.value > maxValue ? cards[c].rank!.value : maxValue
      default:
        //TODO Add dificulties
        break
      }
    }
    return maxValue
  }
  
}
