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
  func didChangedTurn(playerId: String)
  func didSwapCard(playerId: String, at index: Int, from type: String)
  func didFinishRound()
}

class GolfGame {
  
  public weak var delegate: GolfGameDelegate?
  public var players = [Player]()
  public let cardsPerPlayer: Int = 6
  public let visibleCards: Int = 3
  public var gameState: GameStates = .loading
  public var turn = 1
  public var round = 1
  public var isPIC = false
  private var botManager = BotManager()
  private var playersLeft: Int = 0
  private var currentDeck: Deck = Deck(empty: true)
  private var pileDeck: Deck = Deck(empty: true)
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
    case (1,"1"),(1,"2"),(1,"3"):
      handleBotMove()
    case (2,"1"),(2,"2"),(2,"3"):
      handleBotMove()
    case (15,_) :
      handleTimeout()
      
    default:
      self.turnTime += 1
    }
  }
  
  init(playerCount: Int){
    playersLeft = playerCount
    initializePlayers()
    startGame()
  }
  
  private func initializePlayers(){
    for i in 0..<playersLeft {
      players.append(Player(playerId: String(i)))
    }
  }
  
  public func startGame(){
    round = 1
    turn = 1
    cleanGame()
    //Mark: Logic handled by client
    gameState = .loading
    currentDeck = Deck(empty: false)
    pileDeck = Deck(empty: true)
    dealCards()
    initializePileDeck()
    setInitialPlayerInControl()
    startRound()
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
  
  public func clearCardAction(playerId: String) {
    
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
        self.delegate?.didSwapCard(playerId: playerId, at: cardTag, from: "DECK")
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
             self.delegate?.didSwapCard(playerId: playerId, at: cardTag, from: "PILE")
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
      let move = botManager.makeFirstMove(playerHand: player.hand, topPileCard: pileDeck.getTopCardCopy())
      handleBotResponse(move: move)
      break
    case .playerMoveDeck:
      let move = botManager.makeSecondMove(playerHand: player.hand, newCard: player.newCard)
      handleBotResponse(move: move!)
      break
    case .playerMovePile:
      let move = botManager.makeSecondMove(playerHand: player.hand, card: player.newCard)
      handleBotResponse(move: move!)
      break
    default:
      break
    }
  }
  
  public func getPlayersPoints() -> [String:String]{
    var playerPointsMap = [String:String]()
    for (i, p) in players.enumerated() {
      let points = p.computeHandValue()
      playerPointsMap["P\(i)"] = String(points)
    }
    return playerPointsMap
  }

  
  public func getPlayerPoints(playerId: String) -> String {
    for p in players {
      if p.playerId == playerId {
      let points = p.computeHandValue()
        return String(points)
      }
    }
    return "0"
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
  
  public func cleanGame() {
    // TODO clear timer
    for p in 0..<players.count {
      players[p].clearHand()
    }
  }
  
  private func getRandomSlot(playerId: String) -> Int {
    guard let player = self.getPlayer(playerId: playerId) else { return 0 }
    var availableSlots = [Int]()
    for c in 0..<player.hand.count {
      if !player.hand[c].faceUp { availableSlots.append(c) }
    }
    let randNumber = Int(arc4random_uniform(UInt32(availableSlots.count)))
    return availableSlots[randNumber]
  }
  
  //TODO: Refactor
  private func nextTurn() {
    if isEndOfGame() { return }
    beginNextTurn()
    setPlayerInControl()
    self.delegate?.didChangedTurn(playerId: playerInControl)
  }
  
  private func setPlayerInControl() {
    playerInControl = getNextPlayerId(currentPlayerId: playerInControl)!
    if playerInControl == "0" { isPIC = true }
    else {isPIC = false}
  }
  
  private func setInitialPlayerInControl() {
      playerInControl = players[0].playerId
      isPIC = true
  }
  
  private func beginNextTurn() {
    self.turnTime = 0
    turn += 1
  }
  
  private func isEndOfGame() -> Bool {
    if turn == playersLeft * cardsPerPlayer {
     finishRound()
      return true
    }
    return false
  }
  
  private func finishRound() {
    round += 1
    delegate?.didFinishRound()
    stopGame()
  }
  
  func startRound() {
    gameState = .playerWait
    turnTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
  }
  public func stopGame() {
    if turnTimer.isValid { turnTimer.invalidate () }
  }
}
