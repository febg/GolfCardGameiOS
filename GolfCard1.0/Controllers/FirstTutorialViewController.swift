//
//  FirstTutorialViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-23.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

class FirstTutorialViewController: UIViewController {
  
  @IBOutlet private var playerCards: [UIButton]!
  @IBOutlet private var oponentCards: [UIButton]!
  @IBOutlet private var deckButton: UIButton!
  @IBOutlet private var pileCard: UIButton!
  @IBOutlet private var infoButton: UIButton!
  @IBOutlet private var oponentScore: UILabel!
  @IBOutlet private var playerScore: UILabel!
  @IBOutlet private var infoLabel: UILabel!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtittleLabel: UILabel!
  @IBOutlet private var deckLabel: UILabel!
  @IBOutlet private var pileLabel: UILabel!
  @IBOutlet private var scoreLabel: UILabel!
  @IBOutlet private var upperRightLabel: UILabel!
  @IBOutlet private var upperLeftLabel: UILabel!
  @IBOutlet private var lowerRightLabel: UILabel!
  @IBOutlet private var lowerLeftLabel: UILabel!
  
  @IBAction private func cardAction(_ sender: UIButton){
    print("you touched card \(sender.tag)")
  }
  
  @IBAction func pileAction(_ sender: Any) {
  }
  
  @IBAction func deckAction(_ sender: Any) {
  }
  
  @IBAction func infoAction(_ sender: Any) {
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
