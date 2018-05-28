//
//  GolfGameClient.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-05.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

extension GolfGameClient {
  
  public func joinRoomSocket(roomId: String) {
    networkController.joinRoomSocket(roomId: roomId, userId: localPlayerId)
  }
  public func joinAvailableRoom() {
    connectionDelegate?.didTryingToJoinRoom()
    networkController.joinAvailableRoom(playerId: localPlayerId)
  }
}

extension GolfGameClient: NetworkControllerDelegate {
  func didJoinRoom(room: Room) {
    roomId = room.roomId
    connectionDelegate?.didConectToRoom()
    joinRoomSocket(roomId: roomId)
    updateFromServer(data: room.data)
    //Connect to websocket
  }
  
  func didUpdatePlayerState(playerState: Bool) {
    gameDelegate?.didUpdateLobby(newPlayer: false)
  }
  
  func didConectToWebSocket() {
    print("didConnecttoWebSocket")
    connectionDelegate?.didReadyToStart()
    // Set room Id where websocket connection was stablished
  }
  
  //  func didLoadRooms(rooms roomList: RoomList) {
  //    print("cliebt didLoadRooms")
  //    self.roomList = roomList
  //    roomDelagate?.didGotRooms(roomList: roomList.rooms)
  //  }
  
  func didUpdateGame(room: Room) {
    setPlayerInControl(pic: room.playerInControl)
    updateFromServer(data: room.data)
    routeResponse(room: room)
  }
}

protocol GolfGameRoomDelegate: class {
  func didGotRooms(roomList: [RoomData])
}

protocol GolfGameClientDelegate: class {
  func didFlipCard(player: String, at index: Int, descriptions: [String:String])
  func didStartRound(turnTime: Int, descriptions: [String:String])
  func didUpdateTime(turnTime: Int)
  func didPlayerReadyUp(playerId: String)
  func didFlipDeck(description: String)
  func didSwapCard(playerId: String, at index: Int, from type:String, descriptions: [String:String])
  func didFinishRound()
  func didUpdateLobby(newPlayer: Bool)
}

protocol GolfGameConnectionDelegate: class {
  func didTryingtoConnect()
  func didGotRoomsUpdate()
  func didTryingToJoinRoom()
  func didConectToRoom()
  func didReadyToStart()
  
}

class GolfGameClient {
  public weak var roomDelagate: GolfGameRoomDelegate?
  public weak var gameDelegate: GolfGameClientDelegate?
  public weak var connectionDelegate: GolfGameConnectionDelegate?
  let networkController = NetworkController()
  var localPlayerId = ""
  // var roomList: RoomList? = nil
  var cardsPerPlayer = 6
  var roomId: String = ""
  var playerInControl = ""
  var players: [Player] = [Player]()
  var numberOfPlayers = 0
  var didGameStarted = false
  var roomState: String = ""
  var isPic = false
  var gameState: String = ""
  var deckTopCard = Card()
  var pileTopCard = Card()
  var turnTime = 0
  var round: Int = 0
  var roundTime: String = ""
  
  init(){
    networkController.delegate = self
  }
  
  func updateFromServer(data: GameData){
    players = sortPlayers(players: data.players)
    numberOfPlayers = data.playerLeft
    gameState = data.gameState
    deckTopCard =  data.currentDeck
    pileTopCard =  data.pileDeck
    turnTime = data.turnTime
    round = data.round
    roundTime = data.roundTime
    updateRoomState(serverRoomSate: data.roomState)
  }
  enum ClientState: String {
    case initializing = "STARTING"
    case lobby = "LOBBY"
    case game = "GAME"
  }
  
  private func handleRoomStateChange(newRoomState: String) {
    switch (roomState, newRoomState) {
    case ("GAME", "LOBBY"):
      gameDelegate?.didFinishRound()
      didGameStarted = false
      break
    case ("STARTING", "LOBBY"):
      break
    case ("LOBBY", "GAME"):
      startRound()
    default:
      break
    }
  }
  
  private func routeResponse(room: Room){
    switch (room.data.roomState, room.responseType){
    case ("LOBBY", "PLAYER"):
      //Add  Player on lobby screen
      break
    case ("GAME", "ACTION"):
      //Route Player Action Type
      print("Got aactione \(room)")
      handlePlayerAction(playerAction: room.playerAction)
      
      //TODO PlayerAction
      //TODO Periodic Update (Round time, etc)
      break
    case ("LOBBY", "TIME"):
      gameDelegate?.didUpdateLobby(newPlayer: false)
      //TODO refresh Lobby screen
      break
    case ("GAME", "TIME"):
      gameDelegate?.didUpdateTime(turnTime: turnTime)
      //TODO Add Player
      //TODO Periodic Update
      break
    case ("STARTING", "TIME"):
      break
    default:
      break
    }
  }
  
  public func updateRoomState(serverRoomSate: String) {
    if roomState == serverRoomSate { return }
    handleRoomStateChange(newRoomState: serverRoomSate)
    roomState = serverRoomSate
  }
  
  public func setPlayerStatus() {
    networkController.setReadyState(roomId: roomId, playerId: localPlayerId)
  }
  
  private func  setPlayerInControl(pic: String) {
    if localPlayerId == pic { isPic = true }
    else { isPic = false }
    playerInControl = pic
  }
  
  private func checkNewTurn() {
    
  }
  
  private func startRound() {
    //TODO round start countdown
    var descriptions = getVisibleCards(playerId: localPlayerId)
    descriptions["PILE"] = pileTopCard.getDescription()
    gameDelegate?.didStartRound(turnTime: turnTime, descriptions: descriptions)
    didGameStarted = true
  }
  
  private func getVisibleCards(playerId: String) -> [String:String] {
    var descriptions = [String:String]()
    for p in players {
      if p.playerId == playerId {
        for (i, c) in p.hand.enumerated() {
          if c.visibleToOwner { descriptions["C"+String(i)] = c.getDescription() }
        }
      }
    }
    return descriptions
  }
  
  private func sortPlayers(players: [Player]) -> [Player] {
    var temp = [Player]()
    var new = [Player]()
    var set = false
    for p in 0..<players.count {
      if players[p].playerId == localPlayerId {
        new.append(players[p])
        set = true
        continue
      }
      if set {
        new.append(players[p])
        continue
      }
      temp.append(players[p])
    }
    new += temp
    return new
  }
  
  private func getCardIndex(playerId: String, card: Card) -> Int? {
    for p in players {
      if p.playerId == playerId {
        guard let c = p.getCardIndex(card: card) else { break }
        return c
      }
    }
    return  nil
  }
  
  private func getCardAt(index: Int) -> Card {
    for p in players {
      if p.playerId == localPlayerId { return p.hand[index] }
    }
    return Card()
  }
  
  private func getPlayerIndex(playerId: String) -> String? {
    var index: Int = -1
    for (i, p) in players.enumerated() {
      if p.playerId ==  playerId {
        index = i
      }
    }
    switch (index){
    case 0:
      return "MP"
    case 1:
      return "P1"
    case 2:
      return "P2"
    case 3:
      return "P3"
    default:
      return nil
    }
  }
  
  
  private func handlePlayerAction(playerAction: PlayerAction) {
    switch (playerAction.actionType) {
    case "flip":
      guard
        let c = getCardIndex(playerId: playerAction.playerId, card: playerAction.flipCard),
        let p = getPlayerIndex(playerId: playerAction.playerId),
        let description = playerAction.flipCard.getDescription()
        else { break }
      flipCard(player: p, at: c, description: description)
      break
    case "flipDeck":
      guard
        let description = deckTopCard.getDescription()
        else { break }
      gameDelegate?.didFlipDeck(description: description)
      break
    case "replacePile":
      guard
        let c = getCardIndex(playerId: playerAction.playerId, card: playerAction.flipCard),
        let p = getPlayerIndex(playerId: playerAction.playerId),
        let description = playerAction.flipCard.getDescription()
        else { break }
      replacePile(player: p, at: c, description: description)
      break
    case "replaceDeck":
      guard
        let c = getCardIndex(playerId: playerAction.playerId, card: playerAction.flipCard),
        let p = getPlayerIndex(playerId: playerAction.playerId),
        let description = playerAction.flipCard.getDescription()
        else { break }
      replaceDeck(player: p, at: c, description: description)
      break
    default:
      break
    }
  }
  
  private func flipCard(player: String, at index: Int, description: String) {
    var descriptions = [String:String]()
    descriptions["C"] = description
    descriptions["PILE"] = pileTopCard.getDescription()
    gameDelegate?.didFlipCard(player: player, at: index, descriptions: descriptions)
  }
  
  private func replacePile(player: String, at index: Int, description: String) {
    var descriptions = [String:String]()
    descriptions["C"] = description
    descriptions["PILE"] = pileTopCard.getDescription()
    gameDelegate?.didSwapCard(playerId: player, at: index, from: "PILE", descriptions: descriptions)
  }
  
  private func replaceDeck(player: String, at index: Int, description: String) {
    var descriptions = [String:String]()
    descriptions["C"] = description
    descriptions["PILE"] = pileTopCard.getDescription()
    gameDelegate?.didSwapCard(playerId: player, at: index, from: "DECK", descriptions: descriptions)
  }
  
  public func flipDeckAction() {
    let playerAction = PlayerAction(action: "flipDeck", byPlayer: self.localPlayerId, onRoom: self.roomId, card: Card())
    networkController.sendAction(playerAction: playerAction)
  }
  
  public func flipCardAction(index: Int) {
    let flipedCard = getCardAt(index: index)
    let playerAction = PlayerAction(action: "flip", byPlayer: self.localPlayerId, onRoom: self.roomId, card: flipedCard)
    networkController.sendAction(playerAction: playerAction)
  }
  
  public func replacePileAction(index: Int) {
    let replacedCard = getCardAt(index: index)
    let playerAction = PlayerAction(action: "replacePile", byPlayer: self.localPlayerId, onRoom: self.roomId, card: replacedCard)
    networkController.sendAction(playerAction: playerAction)
  }
  
  public func replaceDeckAction(index: Int) {
    let replacedCard = getCardAt(index: index)
    let playerAction = PlayerAction(action: "replaceDeck", byPlayer: self.localPlayerId, onRoom: self.roomId, card: replacedCard)
    networkController.sendAction(playerAction: playerAction)
  }
  
  public func isCardFaceUp(index: Int) -> Bool {
    for p in players {
      if p.playerId ==  localPlayerId { return p.hand[index].faceUp}
    }
    return false
  }
  
}

