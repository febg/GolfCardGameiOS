//
//  OnlineMenuViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-05.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

extension OnlineMenuViewController {
  func textFieldShouldReturn(_ userNameTextField: UITextField) -> Bool {
    self.view.endEditing(true)
    return true;
  }
}

extension OnlineMenuViewController: GolfGameRoomDelegate {
  func didGotRooms(roomList: [RoomData]) {
    print("Display UI available rooms")
    print(roomList)
  }
}

class OnlineMenuViewController: UIViewController, UITextFieldDelegate {
  
  var golfGameClient: GolfGameClient!
  var roomsAvailable: Int = 0
  
  @IBOutlet var userNameTextField: UITextField!
  
  @IBAction func joinRoomButton(_ sender: Any) {
    if userNameTextField.text == "" { return }
    golfGameClient.localPlayerId = userNameTextField.text!
    golfGameClient.joinAvailableRoom()
    showConnection()
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
      self.view.addGestureRecognizer(tapGesture)
      userNameTextField.delegate = self
    }
  
  override func viewWillAppear(_ animated: Bool) {
    print("viewdidAppear")
    super.viewWillAppear(animated)
    golfGameClient.roomDelagate = self as? GolfGameRoomDelegate
  }
  
  func showConnection(){
    self.performSegue(withIdentifier: "ConnectionRoom", sender: self)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
    userNameTextField.resignFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let onlineRoom = segue.destination as? ConnectionViewController {
      onlineRoom.golfGameClient = golfGameClient
    }
  }
}
