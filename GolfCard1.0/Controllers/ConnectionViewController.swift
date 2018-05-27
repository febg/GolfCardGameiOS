//
//  ConnectionViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-06.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

extension ConnectionViewController: GolfGameConnectionDelegate {
  func didTryingtoConnect() {
    //NOT USED
    print("ConnectionView: trying to connect")
  }
  
  func didGotRoomsUpdate() {
    print("Connection View: got rooms")
    connectionLabel.text = "trying to join"

  }
  
  func didTryingToJoinRoom() {
    //TODO called when user clicks on Join Room button
    print("Connection View: trying to join room")
    connectionLabel.text = "trying to join"

  }
  
  func didConectToRoom() {
    //TODO called when HTTP request to join a room was asserted
    print("Connection View: Connected to Room")
    connectionLabel.text = "connected"

  }
  
  func didReadyToStart() {
    //TODO called when web socket stacblished connection
    connectionLabel.text = "readyTostart"
    showGame()
  }
  
}

class ConnectionViewController: UIViewController {
    var golfGameClient: GolfGameClient!
  
  
  @IBOutlet weak var connectionLabel: UILabel!
  var connected = false
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  override func viewWillAppear(_ animated: Bool) {
    print("viewdidAppear")
    super.viewWillAppear(animated)
    golfGameClient.connectionDelegate = self
    
    
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
  private func showGame(){
    if !connected {
      self.performSegue(withIdentifier: "GameRoom", sender: self)
      connected = true
    }

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let onlineRoom = segue.destination as? OnlineRoomViewController {
      onlineRoom.gameClient = golfGameClient
    }
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
