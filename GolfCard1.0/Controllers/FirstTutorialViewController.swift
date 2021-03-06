//
//  FirstTutorialViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-23.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

extension FirstTutorialViewController: TutorialGameDelegate {
  func showInfoView() {
    self.performSegue(withIdentifier: "InfoView", sender: self)
  }
  
  func showInfoTitle(message: String) {
    showInfoLabel(text: message)
  }
  
  func hideScoreTitle() {
    hideScoreLabel()
  }
  
  func showScoreTitle(message: String) {
    showScoreLabel(text: message)
  }
  
  func hideDeckTitle() {
    hideDeckLabel()
  }
  
  func hidePileTitle() {
    hidePileLabel()
  }
  
  func showPileTitle(message: String) {
    showPileLabel(text: message)
  }
  
  func showDeckTitle(message: String) {
    showDeckLabel(text: message)
  }
  
  func showPileDeck(animated: Bool) {
    showPileButton(animated: animated)
  }
  
  func showDeck(animated: Bool) {
    showDeckButton(animated: animated)
  }
  
  func didFlipCard(playerId: String, card: Int) {
    showPlayerCard(playerId: playerId, index: card, animated: true)
  }
  
  func showLowerLeft(message: String) {
    showLowerLeftLabel(text: message)
  }
  
  func hideLowerLeft() {
    hideLowerLeftLabel()
  }
  
  func showUpperRight(message: String) {
    showUpperRightLabel(text: message)
  }
  
  func hideUpperRight() {
    hideUpperRightLabel()
  }
  
  func showSubtitle(message: String) {
    showSubtitleLabel(text: message)
  }
  
  func showTitle(message: String) {
    showTitleLabel(text: message, animated: false)
  }
  
  func showPlayer(playerId: String, animated: Bool) {
    showPlayerView(playerId: playerId, animated: true)
  }
  
  func hideTitle() {
    hideTitleLabel()
  }
  
  func hideSubtitle() {
    hideSubtitleLabel()
  }
  
  func hidePlayer(playerId: String) {
    hidePlayer(playerId: playerId)
  }
  
  func hideAll() {
    cleanAll()
  }
  
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
  private var timer: Timer! = nil
  private var time = 0.0
  private var lastTouchedCard = -1
  
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
  @IBOutlet private var subtitleLabel: UILabel!
  @IBOutlet private var deckLabel: UILabel!
  @IBOutlet private var pileLabel: UILabel!
  @IBOutlet private var scoreLabel: UILabel!
  @IBOutlet private var playerLabel: UILabel!
  @IBOutlet private weak var oponentLabel: UILabel!
  @IBOutlet private var upperRightLabel: UILabel!
  @IBOutlet private var upperLeftLabel: UILabel!
  @IBOutlet private var lowerRightLabel: UILabel!
  @IBOutlet private var lowerLeftLabel: UILabel!
  
  @IBAction private func cardAction(_ sender: UIButton){
    
    switch (sender.tag, tutorialGame.gameState, lastTouchedCard) {
    case (2, .playerMove_0, -1):
      selectCard(at: sender.tag)
      lastTouchedCard = sender.tag
    case (2, .playerMove_0, sender.tag):
      tutorialGame.handleCardAction(card: sender.tag)
      lastTouchedCard = -1
    default:
      break
    }
    
//    if sender.tag == lastTouchedCard {
//      //TODO: Flip Card?
//      deselectCard(at: sender.tag)
//      lastTouchedCard = -1
//      showPlayerCard(playerId: "P0", index: sender.tag, animated: true)
//      //TODO: lastTouchedCard = -1
//      return
//    }
//    if lastTouchedCard != -1 { deselectCard(at: lastTouchedCard) }
//    selectCard(at: sender.tag)
//    lastTouchedCard = sender.tag
  }
  
  @IBAction func pileAction(_ sender: Any) {
  }
  
  @IBAction func deckAction(_ sender: Any) {
  }
  
  @IBAction func infoAction(_ sender: Any) {
    tutorialGame.handleTapInfo()
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
    tutorialGame.handleTapToContinue()
  }
}

//MARK: Timers
extension FirstTutorialViewController {
  private func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    time = 0.0
  }
  
  @objc private func updateTime() {
    time += 0.3
    switch (tutorialGame.gameState) {
    case (.welcome_1):
      fadeCardsIn(playerId: "P0")
      break
    default:
      break
    }
  }
  
  private func stopTimer() {
    if timer.isValid { timer.invalidate() }
  }
}


//MARK: Control logic
extension FirstTutorialViewController {
  private func prepareTutorialView(){
    cleanAll()
    showVisibleCards()
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
  private func hideCards() {
    for i in 0..<cardsPerPlayer {
      playerCards[i].isHidden = true
      oponentCards[i].isHidden = true
    }
  }
  
  private func setCardsAlpha(playerId: String, alpha: Double) {
    let cards = playerId == "P0" ? playerCards : oponentCards
    for c in cards! {
      c.alpha = CGFloat(alpha)
    }
  }
  
  private func showPlayerCards(playerId: String, animated: Bool) {
    if animated { startTimer() }
  }
  
  private func fadeCardsIn(playerId: String) {
    let cards = playerId == "P0" ? playerCards : oponentCards
    switch (time) {
    case 0.3:
      cards![0].fadeIn(duration: 0.5, delay: 0.0)
    case 0.6:
      cards![1].fadeIn(duration: 0.5, delay: 0.0)
    case (0.8...0.9):
      cards![2].fadeIn(duration: 0.5, delay: 0.0)
    case 1.2:
      cards![3].fadeIn(duration: 0.5, delay: 0.0)
    case 1.5:
      cards![4].fadeIn(duration: 0.5, delay: 0.0)
    case 1.8:
      cards![5].fadeIn(duration: 0.5, delay: 0.0)
    case 2.1:
      showPlayerLabel(playerId: playerId)
      showPlayerScore(playerId: playerId, text: "0")
      stopTimer()
    default:
      break
    }
  }
  
  private func showVisibleCards() {
    for i in 0..<3 {
      showVisibleCard(playerId: "P0", index: i)
    }
  }
  
  private func showVisibleCard(playerId: String, index: Int) {
    guard
    let playerCards = playerId == "P0" ? self.playerCards : oponentCards
      else{
        return
    }
    let player = tutorialGame.getPlayer(playerId: playerId)
    let playerCard = player.hand[index % 6]
    let (imageName, text) = playerCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    let cardButton = playerCards[index]
    if (playerCard.visibleToOwner) {
      UIView.transition(with: cardButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        cardButton.setBackgroundImage(cardImage, for: .normal)
        cardButton.setTitle(text, for: .normal)
        let textColor = UIColor(displayP3Red: 245/255, green: 240/255, blue: 237/255, alpha: 1)
        cardButton.setTitleColor(textColor, for: .normal)
        cardButton.isEnabled = true
      }, completion: nil)
    }
  }
  
  private func showPlayerCard(playerId: String, index: Int, animated: Bool) {
    guard
    let playerCards = playerId == "P0" ? self.playerCards : oponentCards
      else{
        return
    }
    let player = tutorialGame.getPlayer(playerId: playerId)
    let playerCard = player.hand[index % 6]
    let (imageName, text) = playerCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    let cardButton = playerCards[index]
    if (animated) {
      UIView.transition(with: cardButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        cardButton.setBackgroundImage(cardImage, for: .disabled)
        cardButton.setTitle(text, for: .disabled)
        let textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
        cardButton.setTitleColor(textColor, for: .disabled)
        cardButton.isEnabled = false
      }, completion: nil)
    }
  }
  
  private func selectCard(at index: Int) {
    guard
    let playerCards = self.playerCards
      else {
        return
    }
    let player = tutorialGame.getPlayer(playerId: "P0")
    let playerCard = player.hand[index % 6]
    let (imageName, text) = playerCard.getImageKeys()
    let cardImage = UIImage(named: "Selected"+imageName)
    let cardButton = playerCards[index]
    var textColor: UIColor
    cardButton.setBackgroundImage(cardImage, for: .normal)
    cardButton.setTitle(text, for: .normal)
    if playerCard.faceUp {
      textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    }
    else {
      textColor = UIColor(displayP3Red: 245/255, green: 240/255, blue: 237/255, alpha: 1)
    }
    cardButton.setTitleColor(textColor, for: .normal)
  }
  
  private func deselectCard(at index: Int) {
    guard
      let playerCards = self.playerCards
      else{
        return
    }
    let player = tutorialGame.getPlayer(playerId: "P0")
    let playerCard = player.hand[index % 6]
    let (imageName, text) = playerCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    let cardButton = playerCards[index]
    var textColor: UIColor
    cardButton.setBackgroundImage(cardImage, for: .normal)
    cardButton.setTitle(text, for: .normal)
    if playerCard.faceUp {
      textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    }
    else {
      textColor = UIColor(displayP3Red: 245/255, green: 240/255, blue: 237/255, alpha: 1)
    }
    cardButton.setTitleColor(textColor, for: .normal)
  }
  
  private func updatePlayerCard(playerId: String, index: Int) {
    guard
    let playerCards = playerId == "P0" ? self.playerCards : oponentCards
      else{
        return
    }
    let player = tutorialGame.getPlayer(playerId: playerId)
    let playerCard = player.hand[index % 6]
    let (imageName, text) = playerCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    let cardButton = playerCards[index]
    var textColor = UIColor()
    if playerCard.faceUp {
      cardButton.isEnabled = false
      textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
      cardButton.setBackgroundImage(cardImage, for: .disabled)
      cardButton.setTitle(text, for: .disabled)
      cardButton.setTitleColor(textColor, for: .disabled)
      return
    }
    if playerCard.visibleToOwner && playerId != "0" {
      return
    }
    textColor = UIColor(displayP3Red: 245/255, green: 240/255, blue: 237/255, alpha: 1)
    cardButton.setBackgroundImage(cardImage, for: .normal)
    cardButton.setTitle(text, for: .normal)
    cardButton.setTitleColor(textColor, for: .normal)
  }
  
}


//MARK: Deck logic
extension FirstTutorialViewController {
  private func hideDeck() {
    deckButton.alpha = 0.0
  }
  private func hideDeckLabel() {
    deckLabel.isHidden = true
  }
  
  private func showDeckButton(animated: Bool) {
    if animated {
      deckButton.fadeIn()
    }
    deckButton.alpha = 1.0
  }
  
  private func showDeckLabel(text: String) {
    deckLabel.text = text
    deckLabel.isHidden = false
  }
  
  private func clearDeck() {
    guard let backCard = UIImage(named: "Back")
      else{
        return
    }
    self.deckButton.setBackgroundImage(backCard, for: .normal)
    self.deckButton.setTitle("", for: .normal)
  }
  
  private func selectDeck() {
    let deckCard = tutorialGame.getCurrentDeckTopCard()
    let (imageName, text) = deckCard.getImageKeys()
    let cardImage = UIImage(named: "Selected"+imageName)
    var textColor: UIColor
    deckButton.setBackgroundImage(cardImage, for: .normal)
    deckButton.setTitle(text, for: .normal)
    textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    deckButton.setTitleColor(textColor, for: .normal)
    
  }
  
  private func deselectDeck() {
    let deckCard = tutorialGame.getCurrentDeckTopCard()
    let (imageName, text) = deckCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    var textColor: UIColor
    deckButton.setBackgroundImage(cardImage, for: .normal)
    deckButton.setTitle(text, for: .normal)
    textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    deckButton.setTitleColor(textColor, for: .normal)
    
  }
  
  private func flipDeckButton() {
    let deckCard = tutorialGame.getCurrentDeckTopCard()
    let (imageName, cardText) = deckCard.getImageKeys()
    guard let cardImage = UIImage(named: imageName)
      else{
        return
    }
    if (deckCard.faceUp) {
      UIView.transition(with: deckButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        self.deckButton.setBackgroundImage(cardImage, for: .normal)
        self.deckButton.setTitle(cardText, for: .normal)
      }, completion: nil)
    }
  }
}

//MARK: Pile logic
extension FirstTutorialViewController {
  private func hidePile() {
    pileCard.alpha = 0.0
  }
  
  private func hidePileLabel() {
    pileLabel.isHidden = true
  }
  
  private func showPileButton(animated: Bool) {
    if animated { pileCard.fadeIn() }
    pileCard.alpha = 1.0
  }
  
  private func showPileLabel(text: String) {
    pileLabel.text = text
    pileLabel.isHidden = false
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
  private func hidePlayerView(playerId: String) {
    if playerId == "P0" { playerPositions[0].isHidden = true }
    else { playerPositions[1].isHidden = true }
  }
  private func hideAllPlayers() {
    for i in 0..<nubmerOfPlayers {
      playerPositions[i].isHidden = true
    }
  }
  
  private func showPlayerView(playerId: String, animated: Bool) {
    if animated { prepareToShowPlayer(playerId: playerId) }
    if playerId == "P0" { playerPositions[0].isHidden = false }
    else { playerPositions[1].isHidden = false }
  }
  
  private func fadePlayerViewIn(playerId: String, animated: Bool) {
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
  
  private func prepareToShowPlayer(playerId: String) {
    setCardsAlpha(playerId: playerId, alpha: 0.0)
    hidePlayerLabel(playerId: playerId)
    hidePlayerScore(playerId: playerId)
    showPlayerCards(playerId: playerId, animated: true)
  }
  
  private func showAllPlayers() {
    for i in 0..<nubmerOfPlayers {
      playerPositions[i].isHidden = false
    }
  }
}

//MARK: Labels logic
extension FirstTutorialViewController {
  //TODO, refactor to hanlde label text, and refactor show labels as well
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
      subtitleLabel.isHidden = true
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
    subtitleLabel.isHidden = true
    scoreLabel.isHidden = true
    hideDeckLabel()
    hidePileLabel()
  }
  
  private func hideSubtitleLabel() {
    subtitleLabel.text = ""
    subtitleLabel.isHidden = true
  }
  
  private func hideTitleLabel() {
    titleLabel.text = ""
    titleLabel.isHidden = true
  }
  
  private func hidePlayerLabel(playerId: String) {
    let label = playerId == "P0" ? playerLabel : oponentLabel
    label?.isHidden = true
  }
  
  private func showPlayerLabel(playerId: String) {
    let label = playerId == "P0" ? playerLabel : oponentLabel
    label?.isHidden = false
  }
  
  private func hidePlayerScore(playerId: String) {
    let label = playerId == "P0" ? playerScore : oponentScore
    label?.isHidden = true
  }
  
  private func showPlayerScore(playerId: String, text: String) {
    let label = playerId == "P0" ? playerScore : oponentScore
    label?.text = text
    label?.isHidden = false
  }
  
  private func showLowerLeftLabel(text: String) {
    lowerLeftLabel.text = text
    lowerLeftLabel.isHidden = false
  }
  
  private func hideLowerLeftLabel() {
    lowerLeftLabel.text = ""
    lowerLeftLabel.isHidden = true
  }
  
  private func showScoreLabel(text: String) {
    scoreLabel.text = text
    scoreLabel.isHidden = false
  }
  
  private func showUpperRightLabel(text: String) {
    upperRightLabel.text = text
    upperRightLabel.isHidden = false
  }
  
  private func showInfoLabel(text: String) {
    infoLabel.text = text
    infoLabel.isHidden = false
  }
  
  private func hideUpperRightLabel() {
    upperRightLabel.text = ""
    upperRightLabel.isHidden = true
  }

  private func hideScoreLabel() {
    scoreLabel.text = ""
    scoreLabel.isHidden = true
  }
  
  private func showTitleLabel(text: String, animated: Bool) {
    titleLabel.text = text
    titleLabel.isHidden = false
    if animated {
      titleLabel.alpha = 0.0
      titleLabel.fadeIn(duration: 2.0, delay: 0.0)
      return
    }
    titleLabel.alpha = 1.0
  }
  
  private func pulseSubtitle(count : Int, text: String) {
    subtitleLabel.text = text
    subtitleLabel.alpha = 0.0
    subtitleLabel.isHidden = false
    subtitleLabel.pulse(count: count)
  }
  
  private func showSubtitleLabel(text: String) {
    subtitleLabel.isHidden = false
    subtitleLabel.text = text
  }
  
}
