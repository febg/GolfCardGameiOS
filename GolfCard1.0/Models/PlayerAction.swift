//
//  PlayerAction.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-06.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

struct PlayerAction: Codable {
  var actionType: String
  var roomId: String
  var playerId: String
  var flipCard: Card
  
  init(action actionType: String, byPlayer playerId: String, onRoom roomId: String,  card flipCard: Card){
    self.actionType = actionType
    self.roomId = roomId
    self.playerId = playerId
    self.flipCard = flipCard
  }

}

