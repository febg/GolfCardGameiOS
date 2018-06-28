//
//  FirstTutorialViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-23.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

extension FirstTutorialViewController: TutorialGameDelegate {
  func showTapToContinue(message: String, count: Int) {
    pulseSubtitle(count: count, text: message)
  }
  
  func showWelcomeMessage(message: String) {
    showTitleLabel(text: message, animated: true)
  }
  
  
}

class FirstTutorialViewController: UIViewController {
  
  private var tutorialGame = TutorialGame()
  private let nubmerOfPlayers = 2
  private let cardsPerPlayer = 6
  
  @IBOutlet private var playerPositions: [UIView]!
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
  
  enum LabelPosition {
    case upperRight
    case lowerRight
    case upperLeft
    case lowerLeft
    case title
    case subtitle
    case score
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tutorialGame.delegate = self
    prepareTutorialView()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected (_:)))
    self.view.addGestureRecognizer(tapGesture)

    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
  @objc func tapDetected (_ sender: UITapGestureRecognizer) {
    showPlayer(playerId: "P0", animated: true)
  }
  
}

//Control logic
extension FirstTutorialViewController {
  private func prepareTutorialView(){
    cleanAll()
  }

  private func cleanAll() {
    hideDeck()
    hidePile()
    hideAllLabels()
    hideAllPlayers()
    hideInfoLabel()
  }
}


//MARK: Cards logic
extension FirstTutorialViewController {
  func hideCards() {
    for i in 0..<cardsPerPlayer {
      playerCards[i].isHidden = true
      oponentCards[i].isHidden = true
    }
  }
}


//MARK: Deck logic
extension FirstTutorialViewController {
  private func hideDeck() {
    deckButton.isHidden = true
  }
  private func hideDeckLabel() {
    deckLabel.isHidden = true
  }
}

//MARK: Pile logic
extension FirstTutorialViewController {
  private func hidePile() {
    pileCard.isHidden = true
  }
  private func hidePileLabel() {
    pileLabel.isHidden = true
  }
}

//MARK: Navigation logic
extension FirstTutorialViewController {
  private func hideInfoButton() {
    infoButton.isHidden = true
  }
  
  private func hideInfoLabel() {
    infoLabel.isHidden = true
  }
}

//MARK: Players logic
extension FirstTutorialViewController {
  private func hidePlayer(playerId: String) {
    if playerId == "P0" { playerPositions[0].isHidden = true }
    else { playerPositions[1].isHidden = true }
  }
  private func hideAllPlayers() {
    for i in 0..<nubmerOfPlayers {
      playerPositions[i].isHidden = true
    }
  }
  private func showPlayer(playerId: String) {
    if playerId == "P0" { playerPositions[0].isHidden = false }
    else { playerPositions[1].isHidden = false }
  }
  private func showPlayer(playerId: String, animated: Bool) {
    if playerId == "P0" {
      playerPositions[0].isHidden = false
      playerPositions[0].alpha = 0.0
      playerPositions[0].fadeIn()
    }
    else {
      playerPositions[1].isHidden = false
      playerPositions[0].alpha = 0.0
      playerPositions[0].fadeIn()
    }
  }
  private func showAllPlayers() {
    for i in 0..<nubmerOfPlayers {
      playerPositions[i].isHidden = false
    }
  }
}

extension FirstTutorialViewController {
  private func hideLabel(position: LabelPosition) {
    switch(position) {
    case .upperLeft:
      upperLeftLabel.isHidden = true
    case .lowerLeft:
      lowerLeftLabel.isHidden = true
    case .upperRight:
      upperRightLabel.isHidden = true
    case .lowerRight:
      lowerRightLabel.isHidden = true
    case .title:
      titleLabel.isHidden = true
    case .subtitle:
      subtittleLabel.isHidden = true
    case .score:
      scoreLabel.isHidden = true
    }
  }
  
  private func hideAllLabels() {
    upperRightLabel.isHidden = true
    lowerRightLabel.isHidden = true
    upperLeftLabel.isHidden = true
    lowerLeftLabel.isHidden = true
    titleLabel.isHidden = true
    subtittleLabel.isHidden = true
    scoreLabel.isHidden = true
    hideDeckLabel()
    hidePileLabel()
  }
  
  private func showTitleLabel(text: String, animated: Bool) {
    titleLabel.text = text
    titleLabel.alpha = 0.0
    titleLabel.isHidden = false
    titleLabel.fadeIn(duration: 2.0, delay: 0.0)
  }
  
  private func pulseSubtitle(count : Int, text: String) {
    subtittleLabel.text = text
    subtittleLabel.alpha = 0.0
    subtittleLabel.isHidden = false
    subtittleLabel.pulse(count: count)
  }

  
}
