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
  func didFlipCard(playerId: String, card: Int)
  func showDeck(animated: Bool)
  func showDeckLabel(message: String)
  func showLowerLeft(message: String)
  func showPileDeck(animated: Bool)
  func showPileLabel(message:String)
  func showPlayer(playerId: String, animated: Bool)
  func showSubtitle(message: String)
  func showTapToContinue(message: String, count: Int)
  func showTitle(message: String)
  func showUpperRight(message: String)
  func showWelcomeMessage(message: String)
  func hideAll()
  func hideLowerLeft()
  func hidePlayer(playerId: String)
  func hideSubtitle()
  func hideTitle()
  func hideUpperRight()
}

class TutorialGame {

  public weak var delegate: TutorialGameDelegate?
  private let playerCardRanks: [Card.Rank] = [.ten, .five, .two, .six, .four, .king]
  private let playerCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .hearts, .dimonds]
  private let tutorialCardRanks: [Card.Rank] = [.ace, .ace, .king, .three, .eight, .two]
  private let tutorialCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .clubs, .dimonds]
  private let deckCardRanks: [Card.Rank] = [.four, .king, .eight, .five, .ten, .nine, .seven, .three, .nine]
  private let deckCardSuits: [Card.Suit] = [.clubs, .spades, .hearts, .dimonds, .hearts, .dimonds, .clubs, .hearts, .spades]
  private let mainPlayerId: String = "P0"
  private let tutorialPlayerId: String = "P1"
  private var mainPlayer = Player()
  private var tutorialPlayer = Player()
  private var deck = [Card]()
  private var pile = Card(rank: .six, suit: .hearts, faceUp: true, visibleToOwner: false)
  private var timer: Timer!
  private var time = 0.0
  private(set) var gameState: GameState
  
  init() {
    gameState = .started
    guard
      let mainPlayerHand = initializeCards(ranks: playerCardRanks, suits: playerCardSuits),
      let tutorialPlayerHand = initializeCards(ranks: tutorialCardRanks, suits: tutorialCardSuits),
      let deckCards = initializeCards(ranks: deckCardRanks, suits: deckCardSuits)
      else{
        return
    }
    mainPlayer.playerId = mainPlayerId
    tutorialPlayer.playerId = tutorialPlayerId
    mainPlayer.hand = mainPlayerHand
    tutorialPlayer.hand = tutorialPlayerHand
    deck = deckCards
    startTimer()
  }
  
	enum GameState {
    case started
    case welcome_0
    case welcome_1
    case welcome_2
    case welcome_3
    case welcome_4
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

//MARK: States logic

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
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    time = 0.0
  }
  
  @objc private func updateTime() {
    time += 0.5
    switch (time, gameState) {
    case (0.5,.started)  :
      showWelcomeMessage()
    case (2.0, .started):
      showTapToContinue()
      gameState = .welcome_0
      stopTimer()
    case (0.5, .welcome_1):
      delegate?.showPlayer(playerId: mainPlayerId, animated: true)
      delegate?.showTitle(message: "you start with 6 cards facing down")
    case (2.0, .welcome_1):
      delegate?.showLowerLeft(message: "visible to you  ->")
    case (2.5, .welcome_1):
      delegate?.showUpperRight(message: "<-  not visible")
    case (3.0, .welcome_1):
      gameState = .welcome_2
    case (3.5, .welcome_2):
      showTapToContinue()
      stopTimer()
    case (0.5, .welcome_3):
      delegate?.showDeck(animated: true)
    case (1.0, .welcome_3):
      delegate?.showTitle(message: "this are the game deck and pile")
      delegate?.showDeckLabel(message: "deck ->")
    case (1.5, .welcome_3):
      delegate?.showPileDeck(animated: true)
      delegate?.hideLowerLeft()
      delegate?.hideUpperRight()
    case (2.5, .welcome_3):
      delegate?.showPileLabel(message: "<- pile")
    case (0.5, .playerMove_0):
      delegate?.hideUpperRight()
      delegate?.hideLowerLeft()
      delegate?.showTitle(message: "double tap a card to flip it")
    case (1.0, .playerMove_0):
      delegate?.showLowerLeft(message: "double tap this card ->")
      stopTimer()
    default:
     break
    }
  }

  private func stopTimer() {
    if timer.isValid { timer.invalidate() }
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

//MARK: Control logic

extension TutorialGame {
  public func handleTapToContinue() {
    switch (gameState) {
    case .welcome_0:
      gameState = .welcome_1
      startTimer()
    case .welcome_2:
      gameState = .welcome_3
      startTimer()
      break
    case .welcome_4:
      gameState = .playerMove_0
      startTimer()
    default:
      break
    }
    delegate?.hideSubtitle()
  }
  
  public func handleCardAction(card: Int) {
    switch(card, gameState) {
    case (2, .playerMove_0):
      mainPlayer.hand[card].flipCard()
      delegate?.didFlipCard(playerId: "P0", card: card)
      break
    default:
      break
    }
  }
  public func getPlayer(playerId: String) -> Player {
    return playerId == "P0" ? mainPlayer : tutorialPlayer
  }
  
  public func getCurrentDeckTopCard() ->  Card {
    return deck[deck.count - 1]
  }
  
  public func getCurrentPileCard() -> Card {
    return pile
  }
}
