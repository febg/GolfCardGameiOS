//
//  ViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-08.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  

  @IBAction func playOnlineButton(_ sender: Any) {
    showPlayOnline()
  }
  override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

  
  func showPlayOnline(){
    self.performSegue(withIdentifier: "OnlineMenu", sender: self)
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let onlineMenu = segue.destination as? OnlineMenuViewController {
      let golfGameClient = GolfGameClient()
      onlineMenu.golfGameClient = golfGameClient
    }
  }
}

