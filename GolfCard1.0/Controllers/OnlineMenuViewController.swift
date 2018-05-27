//
//  OnlineMenuViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-05.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

extension OnlineMenuViewController: GolfGameRoomDelegate {
  func didGotRooms(roomList: [RoomData]) {
    print("Display UI available rooms")
    print(roomList)
  }
}

class OnlineMenuViewController: UIViewController {
  
  var golfGameClient: GolfGameClient!
  var roomsAvailable: Int = 0
  
  @IBOutlet weak var userNameTextField: UITextField!
  
  @IBAction func joinRoomButton(_ sender: Any) {
    if userNameTextField.text == "" { return }
    golfGameClient.localPlayerId = userNameTextField.text!
    golfGameClient.joinAvailableRoom()
    showConnection()
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      print("viewDidLoad")
    }
  
  override func viewWillAppear(_ animated: Bool) {
    print("viewdidAppear")
    super.viewWillAppear(animated)
    golfGameClient.roomDelagate = self
  }
  
  func showConnection(){
    self.performSegue(withIdentifier: "ConnectionRoom", sender: self)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let onlineRoom = segue.destination as? ConnectionViewController {
      onlineRoom.golfGameClient = golfGameClient
    }
  }
}
