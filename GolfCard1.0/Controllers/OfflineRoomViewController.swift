//
//  OfflineRoomViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-09.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit


extension OfflineRoomViewController: GolfGameDelegate, MenuViewControllerDelagate {
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
    showPlayerCard(playerId: playerId, index: index)
    clearDeck()
    updatePileCard()
  }
  
  func didFlipDeck() {
    //TODO: change image guard
    showDeck()
  }
  func didSwapCard(playerId: String, at index: Int, from type: String){
    let player = game.getPlayer(playerId: playerId)!
    let playerCards = playerPositions[playerId]
    let cardButton = playerCards![index]
    let playerCard = player.hand[index % 6]
    let cardImage = UIImage(named: playerCard.getDescription()!)
    if (playerCard.faceUp) {
      UIView.transition(with: cardButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        cardButton.setBackgroundImage(cardImage, for: .disabled)
        cardButton.isEnabled = false
      }, completion: nil)
    }
    switch (type) {
    case "DECK":
      clearDeck()
    case "PILE":
      updatePileCard()
    default:
      return
    }
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
  var playerPositions = [String: [UIButton]]()
  
  
  //MARK: [  Outlets  ]
  @IBOutlet weak var picLabel: UILabel!
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
      game.selectSelfAction(playerId: "0")
      break
    case (false, .playerMoveSelf, lastCardTag):
      game.confirmSelfAction(playerId: "0", cardTag: sender.tag)
    case (false, .playerMoveDeck,_):
      game.replaceDeckCard(playerId: "0", cardTag: sender.tag)
      break
    case (false, .playerMovePile,_):
      game.replacePileCard(playerId: "0", cardTag: sender.tag)
      break
    default:
      break
    }
    lastCardTag = sender.tag
  }
  
  @IBAction func deckAction(_ sender: Any) {
    if !game.isPIC { return }
    switch (game.gameState){
    case (.playerWait), (.playerMovePile), (.playerSecondWait):
      game.selectDeckAction(playerId: "0")
    case (.playerMoveDeck):
      game.clearDeckAction(playerId: "0")
    default:
      break
    }
  }
  
  @IBAction func pileAction(_ sender: Any) {
    if !game.isPIC { return }
    switch (game.gameState){
    case (.playerWait):
      game.selectPileAction(playerId: "0")
    case (.playerMovePile):
      game.clearPileAction(playerId: "0")
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
    game.delegate = self
    initilizeLobby()
    startDealer()
    
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
    setPlayerPositions()
    hideAllCards()
    //TODO: Set player positions
    //TODO: Hide all  cards
    //TODO: Deal all cards, show player visible cards
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
    guard let backCard = UIImage(named: "back")
    else{
      return
    }
      self.deckButton.setBackgroundImage(backCard, for: .normal)

  }
  
  private func showDeck() {
    let deckCard = game.getCurrentDeckTopCard()
    let cardImage = UIImage(named: deckCard.getDescription()!)
    if (deckCard.faceUp) {
      UIView.transition(with: deckButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        self.deckButton.setBackgroundImage(cardImage, for: .normal)
      }, completion: nil)
    }
  }
}

//MARK: Pile Logic
extension OfflineRoomViewController {
  private func updatePileCard() {
    guard let description = game.getPileDeckTopCard().getDescription(),
      let cardImage = UIImage(named: description)
      else{
        return
    }
    UIView.transition(with: pileButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
      self.pileButton.setBackgroundImage(cardImage, for: .normal)
    }, completion: nil)
  }
}

//MARK: Cards Logic
extension OfflineRoomViewController {
  private func showPlayerCard(playerId: String, index: Int) {
    let player = game.getPlayer(playerId: playerId)!
    let playerCard = player.hand[index % 6]
    let playerCards = playerPositions[playerId]
    let cardButton = playerCards![index]
    let cardImage = UIImage(named: playerCard.getDescription()!)
    if (playerCard.faceUp) {
      UIView.transition(with: cardButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        cardButton.setBackgroundImage(cardImage, for: .disabled)
        cardButton.isEnabled = false
      }, completion: nil)
    }
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
}
