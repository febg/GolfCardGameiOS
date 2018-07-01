//
//  OfflineRoomViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-09.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit


extension OfflineRoomViewController: GolfGameDelegate, MenuViewControllerDelagate {
  func didChangedTurn(playerId: String) {
    resizePlayers(playerId: playerId)
    updatePlayersPoints()
  }
  
  func didFinishRound() {
    self.performSegue (withIdentifier: "Menu", sender: self)
    print("Finished")
  }
  
  func didContinue() {
    //TODO Remove testing only
    game.stopGame()
    game.startGame()
    print("Player Continue")
  }
  
  func didQuit() {
    print("Player quited")
  }
  
  
  func didFlipCard(with playerId: String, at index: Int) {
    //TODO: Update pile
    showPlayerCard(playerId: playerId, index: index, animated: true)
    clearDeck()
    updatePileCard()
  }
  
  func didFlipDeck() {
    //TODO: change image guard
    showDeck()
  }
  func didSwapCard(playerId: String, at index: Int, from type: String){
    showPlayerCard(playerId: playerId, index: index, animated: true)
    if (type == "DECK") { clearDeck() }
    updatePileCard()
  }
}


//MARK: Main Class
class OfflineRoomViewController: UIViewController {
  
  //MARK: [  Properties  ]
  var game: GolfGame!
  var cardsDelt = 0
  var turnTime = 0
  var pic = ""
  var lastCardTag = 0
  var playersCards = [String:[Int]]()
  var dealer: Timer!
  var newGame: Bool!
  var playerPositions = [String: [UIButton]]()
  
  
  
  
  
  //MARK: [  Outlets  ]
   @IBOutlet private var pointsLabels:  [UILabel]!
  
  @IBOutlet private var playersViews:  [UIView]!
  @IBOutlet private var cardsButtons:  [UIButton]!
  @IBOutlet private var bottomCards: [UIButton]!
  @IBOutlet private var leftCards: [UIButton]!
  @IBOutlet private var topCards: [UIButton]!
  @IBOutlet private var rightCards: [UIButton]!
  @IBOutlet private var deckButton: UIButton!
  @IBOutlet private var pileButton: UIButton!
  
  //MARK: [  ActionOutlets  ]
  @IBAction private func cardAction(_ sender: UIButton){

    if !game.isPIC { return }
    let cardFace = game.getCardFace(cardTag: sender.tag, playerId: "0")
    switch (cardFace, game.gameState, sender.tag){
    case (false, .playerWait,_), (false, .playerSecondWait,_):
      lastCardTag = sender.tag
      game.selectSelfAction(playerId: "0")
      selectCard(at: sender.tag)
      break
    case (false, .playerMoveSelf, lastCardTag):
      game.confirmSelfAction(playerId: "0", cardTag: sender.tag)
      deselectCard(at: lastCardTag)
    case (false, .playerMoveDeck,_):
      game.replaceDeckCard(playerId: "0", cardTag: sender.tag)
      deselectCard(at: lastCardTag)
      break
    case (false, .playerMovePile,_):
      game.replacePileCard(playerId: "0", cardTag: sender.tag)
      deselectCard(at: lastCardTag)
      break
    default:
      break
    }
  }
  
  
  @IBAction func deckAction(_ sender: UIButton) {
    if !game.isPIC { return }
    switch (game.gameState){
    case (.playerWait), (.playerSecondWait):
      game.selectDeckAction(playerId: "0")
      selectDeck()
    case (.playerMoveDeck):
      game.clearDeckAction(playerId: "0")
      deselectDeck()
    default:
      break
    }
  }
  
  @IBAction func pileAction(_ sender: UIButton) {
    if !game.isPIC { return }
    switch (game.gameState){
    case (.playerWait):
      game.selectPileAction(playerId: "0")
      selectPile()
    case (.playerMovePile):
      game.clearPileAction(playerId: "0")
      deselectPile()
    default:
      break
    }
  }
  
  @IBAction func showMenuButton(_ sender: Any) {
    self.performSegue (withIdentifier: "Menu", sender: self)
    print("Finished")
  }
  
  //TODO: delete
  @objc public func test(){
    switch(self.cardsDelt){
    case 0...23:
      let card = getButton(buttonTag: cardsDelt)!
      card.fadeIn()
    case 24:
      updatePileCard()
    default:
      self.dealer.invalidate()
    }
    self.cardsDelt = cardsDelt + 1
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setPlayerPositions()
    if newGame {
      initilizeLobby()
      startDealer()
    }
    else{
      updatePileCard()
      updateAllCards()
      updatePlayersPoints()
    }
    game.delegate = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? MenuViewController {
      destination.game = game
      destination.delegate = self
    }
  }
}


//MARK: New functions
extension OfflineRoomViewController {
  private func initilizeLobby() {
   // hideAllCards()
    showVisibleCards()
    playersViews[0].grow()
  }
  
  private func showVisibleCards() {
    for i in 0..<3 {
      showVisibleCard(playerId: "0", index: i)
    }
  }
  
  private func showVisibleCard(playerId: String, index: Int) {
    guard let player = game.getPlayer(playerId: playerId),
      let playerCards = playerPositions[playerId]
      else{
        return
    }
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
  
  private func updateAllCards() {
    for (i,p) in game.players.enumerated() {
      for (j, _) in p.hand.enumerated() {
        updatePlayerCard(playerId: "\(i)", index: j)
      }
    }
  }
  
  private func setPlayerPositions() {
    playerPositions["0"] = bottomCards
    playerPositions["1"] = leftCards
    playerPositions["2"] = topCards
    playerPositions["3"] = rightCards
  }
  
  private func hideAllCards() {
    for c in 0..<game.cardsPerPlayer {
      bottomCards[c].alpha = 0.0
      leftCards[c].alpha = 0.0
      topCards[c].alpha = 0.0
      rightCards[c].alpha = 0.0
    }
  }
  
  private func clearPlayerCards() {
    guard let backImage = UIImage(named: "back")
      else {
        return
    }
    for c in 0..<game.cardsPerPlayer {
      bottomCards[c].setBackgroundImage(backImage, for: .normal)
      leftCards[c].setBackgroundImage(backImage, for: .normal)
      topCards[c].setBackgroundImage(backImage, for: .normal)
      rightCards[c].setBackgroundImage(backImage, for: .normal)
    }
  }
}

//MARK: Deck Logic
extension OfflineRoomViewController {
  private func clearDeck() {
    guard let backCard = UIImage(named: "Back")
      else{
        return
    }
    self.deckButton.setBackgroundImage(backCard, for: .normal)
    self.deckButton.setTitle("", for: .normal)
  }
  
  private func selectDeck() {
    let deckCard = game.getCurrentDeckTopCard()
    let (imageName, text) = deckCard.getImageKeys()
    let cardImage = UIImage(named: "Selected"+imageName)
    var textColor: UIColor
    deckButton.setBackgroundImage(cardImage, for: .normal)
    deckButton.setTitle(text, for: .normal)
    textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    deckButton.setTitleColor(textColor, for: .normal)

  }
  
  private func deselectDeck() {
    let deckCard = game.getCurrentDeckTopCard()
    let (imageName, text) = deckCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    var textColor: UIColor
    deckButton.setBackgroundImage(cardImage, for: .normal)
    deckButton.setTitle(text, for: .normal)
    textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    deckButton.setTitleColor(textColor, for: .normal)

  }
  
  private func showDeck() {
    let deckCard = game.getCurrentDeckTopCard()
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

//MARK: Pile Logic
extension OfflineRoomViewController {
  private func updatePileCard() {
    let (imageName, text) = game.getPileDeckTopCard().getImageKeys()
    guard let cardImage = UIImage(named: imageName)
      else{
        return
    }
    UIView.transition(with: pileButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
      self.pileButton.setBackgroundImage(cardImage, for: .normal)
      self.pileButton.setTitle(text, for: .normal)
    }, completion: nil)
  }
  
  private func selectPile() {
    let deckCard = game.getPileDeckTopCard()
    let (imageName, text) = deckCard.getImageKeys()
    let cardImage = UIImage(named: "Selected"+imageName)
    var textColor: UIColor
    pileButton.setBackgroundImage(cardImage, for: .normal)
    pileButton.setTitle(text, for: .normal)
    textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    
  }
  
  private func deselectPile() {
    let deckCard = game.getPileDeckTopCard()
    let (imageName, text) = deckCard.getImageKeys()
    let cardImage = UIImage(named: imageName)
    var textColor: UIColor
    pileButton.setBackgroundImage(cardImage, for: .normal)
    pileButton.setTitle(text, for: .normal)
    textColor = UIColor(displayP3Red: 207/255, green: 67/255, blue: 87/255, alpha: 1)
    
  }
}

//MARK: Cards Logic
extension OfflineRoomViewController {
  private func showPlayerCard(playerId: String, index: Int, animated: Bool) {
    guard let player = game.getPlayer(playerId: playerId),
      let playerCards = playerPositions[playerId]
      else{
        return
    }
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
    guard let player = game.getPlayer(playerId: "0"),
      let playerCards = playerPositions["0"]
      else{
        return
    }
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
    guard let player = game.getPlayer(playerId: "0"),
      let playerCards = playerPositions["0"]
      else{
        return
    }
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
    guard let player = game.getPlayer(playerId: playerId),
      let playerCards = playerPositions[playerId]
      else{
        return
    }
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


//MARK: Control Logic
extension OfflineRoomViewController {
  func startDealer(){
    self.cardsDelt = 0
    dealer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(test), userInfo: nil, repeats: true)
  }
  
  public func getButton(buttonTag tag: Int) -> UIButton? {
    for (button) in cardsButtons {
      if (button.tag == tag){
        return button
      }
    }
    return nil
  }
  
  private func resizePlayers(playerId: String) {
    switch (playerId) {
    case "0":
      playersViews[0].grow()
      playersViews[1].shrink()
      playersViews[2].shrink()
      playersViews[3].shrink()
    case "1":
      playersViews[1].grow()
      playersViews[0].shrink()
      playersViews[2].shrink()
      playersViews[3].shrink()
    case "2":
      playersViews[2].grow()
      playersViews[0].shrink()
      playersViews[1].shrink()
      playersViews[3].shrink()
    case "3":
      playersViews[3].grow()
      playersViews[0].shrink()
      playersViews[1].shrink()
      playersViews[2].shrink()
    default: break
    }
  }
  
  private func updatePlayersPoints() {
    pointsLabels[0].text = game.getPlayerPoints(playerId: "0")
    pointsLabels[1].text = game.getPlayerPoints(playerId: "1")
    pointsLabels[2].text = game.getPlayerPoints(playerId: "2")
    pointsLabels[3].text = game.getPlayerPoints(playerId: "3")
  }
  
}
