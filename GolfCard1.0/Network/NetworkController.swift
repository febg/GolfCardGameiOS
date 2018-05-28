//
//  NetworkController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-04.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation
import Alamofire
import Starscream

protocol NetworkControllerDelegate: class {
 // func didLoadRooms(rooms: RoomList)
  func didUpdateGame(room: Room)
  func didUpdatePlayerState(playerState: Bool)
  func didJoinRoom(room: Room)
  func didConectToWebSocket()
}


extension NetworkController: WebSocketDelegate {
  func websocketDidConnect(socket: WebSocketClient) {
    print("Connected")
    delegate?.didConectToWebSocket()
    //TODO passdown Room id where socket was connected
  }
  
  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    print("Disconnected")
  }
  
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    print("Recieve Message")
  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    do {
      let serverResponse = try self.jsonDecoder.decode(Room.self, from: data)
      delegate?.didUpdateGame(room: serverResponse)
    }catch let error {
      print(error)
    }
  }
  
  func sendAction(playerAction: PlayerAction){
    print("send Action \(playerAction)")
    do {
    let data = try JSONEncoder().encode(playerAction)
    socket.write(data: data)
    }catch let error {
      print(error)
    }
    }
}

class NetworkController {
  
  private var socket: WebSocket!
  private let baseURL = "http://localhost"
  private let jsonDecoder = JSONDecoder()
  private let jsonEncoder = JSONEncoder()
  public weak var delegate: NetworkControllerDelegate?
  public var hasWSConnection: Bool {
    get{
      return (socket != nil) ? socket.isConnected : false
    }
  }
  
  private func webSocketConnection(roomId: String, playerId: String){
    socket = WebSocket(url: URL(string: "ws://localhost/ws/\(roomId)/\(playerId)")!)
    socket.delegate = self
    socket.connect()
  }
  public func getRooms(){
    let getRoomsPath = "/rooms/"
    print("getting rooms")
    Alamofire.request(baseURL+getRoomsPath).responseJSON { response in
//      if let json = response.data, let rooms = try? self.jsonDecoder.decode(RoomList.self, from: json) {
//        self.delegate?.didLoadRooms(rooms: rooms)
//      } else {
//        print(response.error)
//      }
    }
  }
  
  public func setReadyState(roomId: String, playerId: String){
    let setReadyStatePath = "/readyState/"
    let parameters: [String: Any] = [
      "room_id" : roomId,
      "player_id" : playerId
    ]
 
    Alamofire.request(baseURL+setReadyStatePath, method: .post, parameters: parameters).responseJSON {
      response in
      self.delegate?.didUpdatePlayerState(playerState: true)
    }
  }
  
  public func updateAndJoinRoom() {
    
  }
  
  public func joinAvailableRoom(playerId: String) {
    let setReadyStatePath = "/join-room/"
    let parameters: [String: Any] = [
      "user_id" : playerId
    ]
    
    Alamofire.request(baseURL+setReadyStatePath, method: .post, parameters: parameters).responseJSON {
      response in

      if let json = response.data, let room = try? self.jsonDecoder.decode(Room.self, from: json) {
        self.delegate?.didJoinRoom(room: room)
      } else {
        print(response.error)
      }
    }
  }
  
  public func joinRoomSocket(roomId: String, userId: String){
    webSocketConnection(roomId: roomId, playerId: userId)
  }
}

