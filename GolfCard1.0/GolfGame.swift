//
//  GolfGame.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-09.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

protocol GolfGameDelegate: class {
  func didFlipCard(with playerId: String, at index: Int)
  func didFlipDeck()
  func didSwapCard(playerId: String, at index: Int, from type: String)
  func didFinishRound()
}

class GolfGame {
  
  public weak var delegate: GolfGameDelegate?
  
  public static let localShared = {
    return GolfGame(isLocal: true, playerCount: 4)
  }()
  
  public static let remoteShared = {
    return GolfGame(isLocal: false, playerCount: 4)
  }()
  
  private init() {
    fatalError("You can't touch this shit with signleton")
  }
  
  
  public var players = [Player]()
  public let cardsPerPlayer: Int = 6
  public let visibleCards: Int = 3
  public var gameState: GameStates
  public var turn = 1
  public var round = 1
  private var local: Bool
  private var botManager: BotManager?
  private var playersLeft: Int = 0
  private var currentDeck: Deck
  private var pileDeck: Deck
  private var playerInControl: String = ""
  private var turnTime = 0
  private var gameTime = 0
  private var turnTimer: Timer!
  private var gameTimer: Timer!
  
  
  enum GameStates {
    case loading
    case playerWait
    case playerSecondWait
    case playerMoveDeck
    case playerMovePile
    case playerMoveSelf
    case playerConfirm
  }
  
  
  @objc public func updateTime(){
    switch (self.turnTime, playerInControl){
    case (2,"1"),(1,"2"),(1,"3"):
      handleBotMove()
    case (3,"1"),(2,"2"),(2,"3"):
      handleBotMove()
    case (4,_) :
      handleTimeout()
  
    default:
      self.turnTime += 1
    }
  }
  
  
  
  init(isLocal: Bool, playerCount: Int){
    local = isLocal
    playersLeft = playerCount
    switch local{
    case true:
      //Mark: Logic handled by client
      gameState = .loading
      currentDeck = Deck(empty: false)
      pileDeck = Deck(empty: true)
      initializePlayers()
      dealCards()
      initializePileDeck()
      playerInControl = players[0].playerId
      botManager = BotManager()
      startGame()
    case false:
      //TODO: Initialize current deck from server JSON
      gameState = .loading
      currentDeck = Deck(empty: true)
      pileDeck = Deck(empty: true)
      botManager = nil
    }
  }
  private func initializePlayers(){
    for i in 0..<playersLeft {
      players.append(Player(playerId: String(i)))
    }
  }
  
  public func startRound(){
    round = 1
    turn = 1
    cleanGame(quit: false)
    switch local{
    case true:
      //Mark: Logic handled by client
      gameState = .loading
      currentDeck = Deck(empty: false)
      pileDeck = Deck(empty: true)
      dealCards()
      initializePileDeck()
      playerInControl = players[0].playerId
      botManager = BotManager()
      startGame()
    case false:
      //TODO: Initialize current deck from server JSON
      gameState = .loading
      currentDeck = Deck(empty: true)
      pileDeck = Deck(empty: true)
      botManager = nil
    }
  }
  
  public func confirmSelfAction(playerId: String, cardTag: Int){
    for p in 0..<players.count{
      switch (playerId, playerId) {
      case (players[p].playerId, playerInControl):
        moveDeckToPile()
        flipCard(playerId: playerId, cardTag: cardTag)
        self.delegate?.didFlipCard(with: playerId, at: cardTag)
        gameState = .playerWait
        nextTurn()

      default:
        break
      }
    }
  }
  
  public func moveDeckToPile(){
    var card = currentDeck.getTopCard()!
    if !card.faceUp { card.flipCard() }
    pileDeck.add(card: card)
  }
  
  public func getCardFace(cardTag: Int, playerId: String) -> Bool {
    for p in 0..<players.count {
      if players[p].playerId == playerId { return players[p].hand[cardTag % 6].faceUp }
    }
    return false
  }
  
  public func selectDeckAction(playerId: String){
    for p in 0..<players.count{
      switch (playerId, playerId){
      case (players[p].playerId, playerInControl):
        currentDeck.flipTopCardUp()
        delegate?.didFlipDeck()
        players[p].newCard = currentDeck.getTopCardCopy()
        gameState = .playerMoveDeck
      default:
        break
      }
    }
  }
  
  public func selectPileAction(playerId: String){
    for p in 0..<players.count{
      switch (playerId, playerId){
      case (players[p].playerId, playerInControl):
        players[p].newCard = pileDeck.getTopCardCopy()
        gameState = .playerMovePile
      default:
        break
      }
    }
  }
  
  public func clearPileAction(playerId: String){
    for p in 0..<players.count{
      switch (playerId, playerId){
      case (players[p].playerId, playerInControl):
        players[p].newCard = Card()
        gameState = .playerWait
      default:
        break
      }
    }
  }
  
  public func clearDeckAction(playerId: String){
    for p in 0..<players.count{
      switch (playerId, playerId){
      case (players[p].playerId, playerInControl):
        players[p].newCard = Card()
        gameState = .playerSecondWait
      default:
        break
      }
    }
  }
  
  public func selectSelfAction(playerId: String){
    self.gameState = .playerMoveSelf
  }
  
  public func getNewCard(playerId: String){
    var player = getPlayer(playerId: playerId)!
    player.newCard = currentDeck.getTopCard()!
    print(player.newCard)
  }
  
  private func initializePileDeck(){
    var card = currentDeck.getTopCard()!
    card.flipCard()
    pileDeck.add(card: card)
  }
  
  public func getPlayerInControl() -> String{
    return self.playerInControl
  }
  
  
  public func flipCard(playerId: String, cardTag: Int){
    for p in 0..<players.count{
      if players[p].playerId == playerId && players[p].playerId == playerInControl { players[p].hand[cardTag % 6].flipCard() }
    }
  }
  
  
  public func replaceDeckCard(playerId: String, cardTag: Int){
    for p in 0..<players.count{
      switch(playerId, playerId){
      case (players[p].playerId, playerInControl):
        var newPileCard = players[p].hand[cardTag]
        newPileCard.flipCard()
        pileDeck.add(card: newPileCard)
        players[p].hand[cardTag] = currentDeck.getTopCard()!
        players[p].newCard = Card()
        gameState = .playerWait
        self.delegate?.didFlipCard(with: playerId, at: cardTag)
        nextTurn()

      default:
        break
      }
    }
  }
  
  public func replacePileCard(playerId: String, cardTag: Int){
    for p in 0..<players.count{
      switch(playerId, playerId){
      case (players[p].playerId, playerInControl):
        var newPileCard = players[p].hand[cardTag]
        newPileCard.flipCard()
        players[p].hand[cardTag] = pileDeck.getTopCard()!
        players[p].newCard = Card()
        pileDeck.add(card: newPileCard)
        gameState = .playerWait
        self.delegate?.didFlipCard(with: playerId, at: cardTag)
        nextTurn()

      default:
        break
      }
    }
  }
  
  private func dealCards() {
    for c in 0..<cardsPerPlayer{
      for i in 0..<self.players.count{
        switch (c){
        case (0...2):
          var card = currentDeck.getTopCard()!
          card.visibleToOwner = true
          self.players[i].addToHand(card: card)
        default:
          self.players[i].addToHand(card: currentDeck.getTopCard()!)
          
        }
      }
    }
  }
  
  private func getNextPlayerId(currentPlayerId: String) -> String? {
    for i in 0..<self.players.count{
      switch(players[i].playerId, i){
      case (currentPlayerId, self.players.count-1):
        return players[0].playerId
      case (currentPlayerId,_):
        return players[i+1].playerId
      default: break
      }
    }
    return nil
  }
  
  public func getPlayer(playerId: String) -> Player?{
    for i in 0..<players.count{
      switch(players[i].playerId){
      case playerId:
        return players[i]
      default: break
      }
    }
    return nil
  }
  
  public func getPileDeckTopCard() -> Card{
    return pileDeck.cards.isEmpty ? Card() : pileDeck.cards[pileDeck.cards.count - 1]
  }
  
  public func getCurrentDeckTopCard() -> Card{
    return currentDeck.cards[currentDeck.cards.count - 1]
  }
  
  private func handleTimeout(){
    let cardReplaced = getRandomSlot(playerId: playerInControl)
    switch(gameState){
    case .playerMovePile:
      replacePileCard(playerId: playerInControl, cardTag: cardReplaced)
      break
    case  .playerMoveDeck:
      replaceDeckCard(playerId: playerInControl, cardTag: cardReplaced)
    case .playerWait, .playerMoveSelf:
      selectDeckAction(playerId: playerInControl)
      replaceDeckCard(playerId: playerInControl, cardTag: cardReplaced)
    default:
      break
    }
  }
  
  private func handleBotMove(){
    let player = getPlayer(playerId: playerInControl)!
    switch(gameState){
    case .playerWait:
      let move = botManager?.makeFirstMove(playerHand: player.hand, topPileCard: pileDeck.getTopCardCopy())
      handleBotResponse(move: move!)
      break
    case .playerMoveDeck:
      let move = botManager?.makeSecondMove(playerHand: player.hand, newCard: player.newCard)
      handleBotResponse(move: move!)
      break
    case .playerMovePile:
      let move = botManager?.makeSecondMove(playerHand: player.hand, card: player.newCard)
      handleBotResponse(move: move!)
      break
    default:
      break
    }
  }
  
  private func handleBotResponse(move: BotManager.Move){
    switch(move.type, gameState){
    case (.getPile, .playerWait):
      selectPileAction(playerId: playerInControl)
    case (.getDeck, .playerWait):
      selectDeckAction(playerId: playerInControl)
    case (.setSelf, _):
      confirmSelfAction(playerId: playerInControl, cardTag: move.setAt!)
    case (.swap, .playerMovePile):
      replacePileCard(playerId: playerInControl, cardTag: move.setAt!)
    case (.swap, .playerMoveDeck):
      replaceDeckCard(playerId: playerInControl, cardTag: move.setAt!)
    default:
      break
    }
  }
  
  public func cleanGame(quit: Bool) {
    // TODO clear timers
    for p in 0..<players.count {
      players[p].clearHand()
    }
  }
  
  private func getRandomSlot(playerId: String) -> Int{
    guard let player = self.getPlayer(playerId: playerId) else { return 0 }
    var availableSlots = [Int]()
    for c in 0..<player.hand.count {
      if !player.hand[c].faceUp { availableSlots.append(c) }
    }
    let randNumber = Int(arc4random_uniform(UInt32(availableSlots.count)))
    return availableSlots[randNumber]
  }
  
  private func nextTurn(){
    print(turn)
    print(playersLeft * cardsPerPlayer)
    if turn == playersLeft * cardsPerPlayer {
      round += 1
      delegate?.didFinishRound()
      stopGame()
    }
    playerInControl = getNextPlayerId(currentPlayerId: playerInControl)!
    self.turnTime = 0
    turn += 1
  }
  
  func startGame(){
    gameState = .playerWait
    turnTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
  }
  public func stopGame(){
    if turnTimer.isValid{
      turnTimer.invalidate()
    }
  }
}
