//
//  TutorialGame.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-25.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation


//MARK: [PROTOCOL]
protocol TutorialGameDelegate: class {
  func showWelcomeMessage(message: String)
  func showTapToContinue(message: String, count: Int)
}

class TutorialGame {

  public weak var delegate: TutorialGameDelegate?
  private let playerCardRanks: [Card.Rank] = [.ten, .five, .two, .six, .four, .king]
  private let playerCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .hearts, .dimonds]
  private let tutorialCardRanks: [Card.Rank] = [.ace, .ace, .king, .three, .eight, .two]
  private let tutorialCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .clubs, .dimonds]
  private let deckCardRanks: [Card.Rank] = [.four, .king, .eight, .five, .ten, .nine, .seven, .three, .nine]
  private let deckCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .hearts, .dimonds, .clubs, .hearts, .spades]
  
  private var mainPlayer = Player(playerId: "P0")
  private var tutorialPlayer = Player(playerId: "P1")
  private var deck = [Card]()
  private var pile = Card(rank: .six, suit: .hearts, faceUp: true, visibleToOwner: false)
  private var timer: Timer!
  private var time = 0.0
  private var gameState: GameState
  
  init() {
    gameState = .started
    guard
      let mainPlayerHand = initializeCards(ranks: playerCardRanks, suits: playerCardSuits),
      let tutorialPlayerHand = initializeCards(ranks: tutorialCardRanks, suits: tutorialCardSuits),
      let deckCards = initializeCards(ranks: deckCardRanks, suits: deckCardSuits)
      else{
        return
    }
    mainPlayer.hand = mainPlayerHand
    tutorialPlayer.hand = tutorialPlayerHand
    deck = deckCards
    startTimer()
  }
  
	enum GameState {
    case started
    case welcome_0
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

//MARK: Welcome logic

extension TutorialGame {
  private func showWelcomeMessage() {
    delegate?.showWelcomeMessage(message: "Welcome to Harvest Season Tutorial")
  }
  private func showTapToContinue() {
    delegate?.showTapToContinue(message: "tap to continue", count: 100)
  }
}

//MARK: Timmers
extension TutorialGame {
  private func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeUpdate), userInfo: nil, repeats: true)
  }
  
  @objc private func timeUpdate() {
    time += 0.5
    switch (time, gameState) {
    case (0.5,.started)  :
      showWelcomeMessage()
    case (2.0, .started):
      showTapToContinue()
    default:
     break
    }
  }
}

//MARK: Player Cards
extension TutorialGame {
  
  func initializeCards(ranks: [Card.Rank], suits: [Card.Suit]) -> [Card]? {
    if ranks.count != suits.count { return nil }
    var cards = [Card]()
    var visibleToOwner = true
    for (i, _) in ranks.enumerated(){
      if i == 3 { visibleToOwner = false }
      let card = Card(rank: ranks[i], suit: suits[i], faceUp: false, visibleToOwner: visibleToOwner)
      cards.append(card)
    }
    return cards
  }
  
}
