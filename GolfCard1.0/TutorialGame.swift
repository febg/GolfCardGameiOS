//
//  TutorialGame.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-25.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

class TutorialGame {

  let playerCardRanks: [Card.Rank] = [.ten, .five, .two, .six, .four, .king]
  let playerCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .hearts, .dimonds]
  
  var mainPlayer: Player
  var tutorialPlayer: Player
  
  init() {
    mainPlayer = Player(playerId: "P1")
    tutorialPlayer = Player(playerId: "P2")
  }
  
	enum gameState {
		case playerMove_0
		case playerMove_1
		case playerMove_2
		case playerMove_3
		case playerMove_4
		case playerMove_5
		case playerMove_6
		case tutorialMove_0
		case tutorialMove_1
		case tutorialMove_2
		case tutorialMove_3
		case tutorialMove_4
		case tutorialMove_5
		case tutorialMove_6
	}

}

//MARK: Player Cards
extension TutorialGame {
  
  func initializePlayerCards(ranks: [Card.Rank], suits: [Card.Suit]) -> [Card]? {
    if ranks.count != suits.count { return nil }
    var cards = [Card]()
    var visibleToOwner = true
    for (i, _) in ranks.enumerated(){
      if i == 3 { visibleToOwner = false }
      let card = Card(rank: ranks[i], suit: suits[i], faceUp: false, visibleToOwner: visibleToOwner)
      cards.append(cards)
    }
    return cards
  }
  
}
