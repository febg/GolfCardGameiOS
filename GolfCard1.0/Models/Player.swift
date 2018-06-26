//
//  Player.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-08.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

struct Player: Codable {
  var playerId: String
  var hand: [Card]
  var handValue: Int
  var newCard: Card
  var startGame: Bool
  var actionCard: Card
  
  
  private enum CodingKeys: String, CodingKey {
    case playerId = "playerId"
    case hand = "hand"
    case handValue = "handValue"
    case newCard = "newCard"
    case startGame = "startGame"
    case actionCard = "actionCard"
  }
  
  init(playerId: String) {
    self.playerId = playerId
    hand = [Card]()
    handValue = 0
    newCard = Card()
    startGame = false
    actionCard = Card()
  }
  
  init(playerId: String, hand: [Card]){
    self.playerId = playerId
    self.hand = hand
    handValue = 0
    newCard = Card()
    startGame = false
    actionCard = Card()
  }
  
  mutating func addToHand(card: Card) {
    hand.append(card)
  }
  
  mutating func clearHand(){
    hand = [Card]()
  }
  
  public func getCardIndex(card: Card) -> Int? {
    for i in 0..<hand.count {
      if hand[i].rank == card.rank && hand[i].suit == card.suit {
        return i
      }
    }
    return nil
  }
  
  public func computeHandValue() -> Int {
    var sum = 0
    let cardMap = getCardCount()
    for c in hand {
      switch(c.faceUp,c.rank?.description){
      case (false, _):
        break
      case (true, "0"),(true, "J"),(true, "K"):
        break
      case (true, "2"):
        sum -= 2
      case (true,_):
        var cardCount = cardMap[(c.rank?.description)!]
        if cardCount! % 2 == 0 { break }
        if cardCount! % 2 == 1 { cardCount = cardCount! - 1 }
        sum += (c.rank?.value)!
      }
    }
    return sum
    
  }
  
  private func getCardCount() -> [String:Int] {
    var cardMap = [String:Int]()
    for c in hand {
      if c.faceUp {
        var count = cardMap[(c.rank?.description)!] ?? 0
        count += 1
        cardMap[(c.rank?.description)!] = count
      }
    }
    return cardMap
  }

}
