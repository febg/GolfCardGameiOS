//
//  Room.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-09.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

struct Room: Codable{
  var roomId: String
  var playerInControl: String
  var responseType: String
  var playerAction: PlayerAction
  var data: GameData
  
  private enum CodingKeys: String, CodingKey {
    case roomId = "roomId"
    case playerInControl = "playerInControl"
    case responseType = "responseType"
    case playerAction = "playerAction"
    case data = "data"
  }
  
}

struct GameData: Codable {
  var players: [Player]
  var playerLeft: Int
  var gameState: String
  var roomState: String
  var currentDeck: Card
  var pileDeck: Card
  var readyToBegin: Bool
  var turnTime: Int
  var round: Int
  var roundTime: String
  
  private enum CodingKeys: String, CodingKey {
    case players = "players"
    case playerLeft = "playersLeft"
    case gameState = "gameState"
    case roomState = "roomState"
    case currentDeck = "currentDeck"
    case pileDeck = "pileDeck"
    case readyToBegin = "readyToBegin"
    case turnTime = "turnTime"
    case round = "round"
    case roundTime = "roundTime"
  }
}
