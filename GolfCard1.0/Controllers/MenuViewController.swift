//
//  MenuViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-25.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit


protocol MenuViewControllerDelagate: class {
  func didContinue()
  func didQuit()
}

class MenuViewController: UIViewController {
  public var game: GolfGame!
  public var delegate: MenuViewControllerDelagate?
  private var newGame = false
  
  @IBOutlet weak var PlayerLabel_1: UILabel!
  @IBOutlet weak var PlayerLabel_2: UILabel!
  @IBOutlet weak var PlayerLabel_3: UILabel!
  @IBOutlet weak var PlayerLabel_4: UILabel!
  @IBOutlet weak var PointLabel_1: UILabel!
  @IBOutlet weak var PointLabel_2: UILabel!
  @IBOutlet weak var PointLabel_3: UILabel!
  @IBOutlet weak var PointLabel_4: UILabel!
  
  
  
  @IBAction func ContinueButton(_ sender: Any) {
    print("clik c")
    newGame = true
    delegate?.didContinue()
  }
  
  @IBAction func HideButton(_ sender: Any) {
  }
  
  @IBAction func QuitButton(_ sender: Any) {
    print("clik q")
    
    delegate?.didQuit()
  }
  override func viewDidLoad() {
    newGame = false
        super.viewDidLoad()
    displayScore()
        // Do any additional setup after loading the view.
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? OfflineRoomViewController {
      destination.newGame = newGame
      destination.game = game
    }
  }
  
  func displayScore() {
    let points = game.getPlayersPoints()
    PlayerLabel_1.text = "Player 1"
    PlayerLabel_2.text = "Player 2"
    PlayerLabel_3.text = "Player 3"
    PlayerLabel_4.text = "Player 4"
    
    PointLabel_1.text = points["P0"]
    PointLabel_2.text = points["P1"]
    PointLabel_3.text = points["P2"]
    PointLabel_4.text = points["P3"]
  }
  
}
