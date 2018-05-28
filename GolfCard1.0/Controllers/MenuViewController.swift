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
  
  public var delegate: MenuViewControllerDelagate?
  
  @IBAction func ContinueButton(_ sender: Any) {
    print("clik c")
    delegate?.didContinue()
  }
  
  @IBAction func HideButton(_ sender: Any) {
  }
  
  @IBAction func QuitButton(_ sender: Any) {
    print("clik q")

    delegate?.didQuit()
  }
  override func viewDidLoad() {
        super.viewDidLoad()

      
        // Do any additional setup after loading the view.
    }
}
