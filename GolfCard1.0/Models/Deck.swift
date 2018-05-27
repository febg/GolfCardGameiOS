//
//  Deck.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-09.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

struct Deck: Codable {
  private (set) var cards = [Card]()
  
  init(empty: Bool){
    if (!empty){
      for suit in Card.Suit.all{
        for rank in Card.Rank.all{
          cards.append(Card(rank: rank, suit: suit, faceUp: false, visibleToOwner: false) )
        }
      }
      shuffleDeck()
    }
  }
  
  mutating func getTopCard() -> Card? {
    //TODO: Handle end of deck
    return cards.isEmpty ? nil : self.cards.remove(at: cards.count-1)
  }
  
  mutating func getTopCardCopy() -> Card {
    return cards.isEmpty ? Card() : self.cards[cards.count-1] 
  }
  
  mutating func flipTopCard() {
//    if var card = self.getTopCard() {
//      card.flipCard()
//      return card
//    }else{
//      return nil
//    }
    cards[cards.count-1].flipCard()
  }
  
  mutating func flipTopCardUp() {
   if (!cards[cards.count-1].faceUp) { cards[cards.count-1].flipCard() }
  }
  
  mutating func add(card: Card){
    cards.append(card)
  }
  
  //TODO: test deck comletness
  mutating func shuffleDeck(){
    var newDeck = [Card]()
    for i in 0..<self.cards.count {
      let random = Int(arc4random_uniform(UInt32(self.cards.count)))
      newDeck.append( cards.remove(at: random))
    }
    cards = newDeck
  }
  
  
}
