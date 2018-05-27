//
//  RoomResponse.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-08.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

struct RoomResponse: Codable{
    var rooms: [RoomData]
}

struct RoomData: Codable {
    var roomId : String
    var players: Int
}
