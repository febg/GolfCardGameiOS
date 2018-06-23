//
//  OnlineRoomViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-15.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

//<---------------------------- Extensions ---------------------------->

//MARK: GolfGameClient Protocol

extension OnlineRoomViewController: GolfGameClientDelegate{
  func updatePlayerInControl(position: String, playerInControl: String) {
     showPlayerInControl(position: position, playerId: playerInControl)
  }
  
  func didSwapCard(playerId: String, at index: Int, from type: String, descriptions: [String : String]) {
    swapCard(playerId: playerId, at: index, from: type, descriptions: descriptions)
    clearDeck()
  }
  
  func didFlipCard(player: String, at index: Int, descriptions: [String:String]) {
    showPlayerCard(position: player, card: index, with: descriptions["C"]!)
    clearDeck()
    updatePileCard(description: descriptions["PILE"]!)
  }
  
  func didStartRound(turnTime: Int, descriptions: [String:String]) {
    prepareForGame(turnTime: turnTime)
    updatePileCard(description: descriptions["PILE"]!)
    showVisibleCards(descriptions: descriptions)
    clearDeck()
  }
  
  func didUpdateTime(turnTime: Int) {
    updateStatusLabel(turnTime: turnTime)
  }
  
  func didFlipDeck(description: String) {
    showDeck(description: description)
  }
  
  func didFinishRound() {
    let descriptions = gameClient.getAllDescriptions()
    updateAllCards(descriptions: descriptions)
    updateLobby()
  }
  
  func didUpdateLobby(newPlayer: Bool) {
    updateLobby()
  }
}

//<---------------------------- Main Class ---------------------------->

class OnlineRoomViewController: UIViewController {
  
  //MARK: [  Properties  ]
  var gameClient: GolfGameClient!
  private var selectedCard = -1
  private var playerPostitions = [String:[UIButton]]()
  private var playerLabelPositions = [String:UILabel]()
  private var playerStatusPositions = [String:UILabel]()
  private var visiblePlayers = 1 //Default to 1 -> local player
  
  //MARK: [  Outlets  ]
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var bottomPlayerLabel: UILabel!
  @IBOutlet weak var leftPlayerLabel: UILabel!
  @IBOutlet weak var topPlayerLabel: UILabel!
  @IBOutlet weak var rightPlayerLabel: UILabel!
  @IBOutlet weak var leftStatusLabel: UILabel!
  @IBOutlet weak var rightStatusLabel: UILabel!
  @IBOutlet weak var topStatusLabel: UILabel!
  @IBOutlet weak var pileCard: UIButton!
  @IBOutlet weak var deckCard: UIButton!
  @IBOutlet weak var bottomStatusButton: UIButton!
  @IBOutlet private var bottomCards:  [UIButton]!
  @IBOutlet private var leftCards:  [UIButton]!
  @IBOutlet private var topCards:  [UIButton]!
  @IBOutlet private var rightCards:  [UIButton]!
  
  //MARK: [ ActionOutlets  ]
  
  @IBAction private func cardAction(_ sender: UIButton){
    print("toest01: Activate \(sender.tag)")
    if !gameClient.isPic { return }
    if gameClient.isCardFaceUp(index: sender.tag) { return }
    switch (gameClient.gameState, sender.tag) {
    case ("waitingPlayerMove", selectedCard), ("playerMoveDeck", selectedCard):
      gameClient.flipCardAction(index: sender.tag)
      print("test01: Select Card")
      break
    case ("waitingPlayerMove", _), ("playerMoveDeck", _):
      selectedCard = sender.tag
      print("toest01: Activate card \(selectedCard)")
    default:
      selectedCard = -1
    }
  }
  
  @IBAction func pileAction(_ sender: UIButton) {    
    if !gameClient.isPic { return }
    switch (gameClient.gameState, selectedCard){
    case ("waitingPlayerMove", (0...5)):
      gameClient.replacePileAction(index: selectedCard)
      break
    default:
      break
    }
  }
  
  @IBAction func deckAction(_ sender: UIButton) {
    if !gameClient.isPic { return }
    switch (gameClient.gameState, selectedCard){
    case ("playerMoveDeck", (0...5)):
      gameClient.replaceDeckAction(index: selectedCard)
      break;
    case ("waitingPlayerMove", (0...5)):
      selectedCard = -1
    case ("waitingPlayerMove", -1):
      gameClient.flipDeckAction()
    default:
      break;
    }
    // Update colors?
  }
  
  @IBAction func statusButton(_ sender: Any) {
    gameClient.setPlayerStatus()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gameClient.gameDelegate = self
    initializeLobby()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  private func initializeLobby() {
    hideAllPlayerCards()
    updateLobby()
    updateStatusLabel(message: "Waiting for Players...")
  }
}

//MARK: Control logic
extension OnlineRoomViewController {
  private func prepareForGame(turnTime: Int) {
    clearAllCards()
    updateLobby()
    hideStatus()
    updateStatusLabel(turnTime: turnTime)
  }
  
  private func updateLobby() {
    if (gameClient.roomState != "LOBBY") { return }
    setPlayerPositions(playerCount: gameClient.numberOfPlayers)
    updateLobbyBoard()
  }
  
  private func updateLobbyBoard() {
    for (i,p) in gameClient.players.enumerated() {
      switch (i) {
      case 0:
        showPlayerCards(position: "P0")
        if bottomStatusButton.isHidden { bottomStatusButton.isHidden = false }
        bottomStatusButton.setTitle(p.startGame.description, for: .normal)
        bottomPlayerLabel.text = p.playerId
        break
      case 1:
        showPlayerCards(position: "P1")
        showPlayerInfo(position: "P1", playerId: p.playerId, playerStatus: p.startGame)
        break
      case 2:
        showPlayerCards(position: "P2")
        showPlayerInfo(position: "P2", playerId: p.playerId, playerStatus: p.startGame)
        break
      case 3:
        showPlayerCards(position: "P3")
        showPlayerInfo(position: "P3", playerId: p.playerId, playerStatus: p.startGame)
        break
      default:
        break
      }
    }
  }
}

//MARK: Pile Logic
extension OnlineRoomViewController {
  private func updatePileCard(description: String) {
    guard
      let cardImage = UIImage(named: description)
      else {
        return
    }
    pileCard.setBackgroundImage(cardImage, for: .normal)
    pileCard.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
  }
}
//MARK: Deck logic
extension OnlineRoomViewController {
  private func clearDeck() {
    guard
      let backCardImage = UIImage(named: "back")
      else {
        return
    }
    deckCard.setBackgroundImage(backCardImage, for: .normal)
    selectedCard = -1
  }
  
  private func showDeck(description: String) {
    guard
      let deckImage = UIImage(named: description)
      else {
        return
    }
    deckCard.setBackgroundImage(deckImage, for: .normal)
    deckCard.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
  }
}

//MARK: Cards logic
extension OnlineRoomViewController {
  private func setPlayerPositions(playerCount: Int) {
    var positionMap = [String:[UIButton]]()
    var labelMap = [String:UILabel]()
    var statusMap = [String:UILabel]()
    positionMap["P0"] = bottomCards
    labelMap["P0"] = bottomPlayerLabel
    switch (playerCount){
    case 4:
      positionMap["P1"] = leftCards
      labelMap["P1"] = leftPlayerLabel
      statusMap["P1"] = leftStatusLabel
      positionMap["P2"] = topCards
      labelMap["P2"] = topPlayerLabel
      statusMap["P2"] = topStatusLabel
      positionMap["P3"] = rightCards
      labelMap["P3"] = rightPlayerLabel
      statusMap["P3"] = rightStatusLabel
      //Normal behaviour
    case 3:
      positionMap["P1"] = leftCards
      labelMap["P1"] = leftPlayerLabel
      statusMap["P1"] = leftStatusLabel
      positionMap["P2"] = rightCards
      labelMap["P2"] = rightPlayerLabel
      statusMap["P2"] = rightStatusLabel
      // T-shape layout
    case 2:
      positionMap["P1"] = topCards
      labelMap["P1"] = topPlayerLabel
      statusMap["P1"] = topStatusLabel
      // Face-to-face layout
    default:
      //only main player on lobby
      break
    }
    if playerCount != visiblePlayers {
      hideOponentsCards()
      hideOponentLabels()
      hideOponentStatus()
      visiblePlayers = playerCount
    }
    playerPostitions = positionMap
    playerLabelPositions = labelMap
    playerStatusPositions = statusMap
  }
  private func hideAllPlayerCards(){
    for c in 0..<gameClient.cardsPerPlayer {
      bottomCards[c].isHidden = true
      leftCards[c].isHidden = true
      topCards[c].isHidden = true
      rightCards[c].isHidden = true
    }
  }
  
  private func showPlayerCards(position: String) {
    let cards = playerPostitions[position]
    for c in cards! {
      c.isHidden = false
    }
  }
  
  
  private func hideOponentsCards() {
    for c in 0..<gameClient.cardsPerPlayer {
      leftCards[c].isHidden = true
      topCards[c].isHidden = true
      rightCards[c].isHidden = true
    }
  }
  
  private func clearAllCards() {
    clearDeck()
    clearPlayerCards()
  }
  
  private func clearPlayerCards() {
    guard let backImage = UIImage(named: "back")
      else {
        return
    }
    for c in 0..<gameClient.cardsPerPlayer {
      bottomCards[c].setBackgroundImage(backImage, for: .normal)
      leftCards[c].setBackgroundImage(backImage, for: .normal)
      topCards[c].setBackgroundImage(backImage, for: .normal)
      rightCards[c].setBackgroundImage(backImage, for: .normal)
    }
  }
  private func swapCard(playerId: String, at index: Int, from type: String, descriptions: [String:String]) {
    switch (type) {
    case "DECK":
      //TODO animation from deck to hand from hand to pile
      break
    case "PILE":
      //TODO animation from pile to hand from hand to pile
      break
    default:
      break
    }
    //TODO safely unwarp values
    showPlayerCard(position: playerId, card: index, with: descriptions["C"]!)
    updatePileCard(description: descriptions["PILE"]!)
    
  }
  private func updateAllCards(descriptions: [String:[String:String]]) {
    for (p, cards) in descriptions {
      guard
        //TODO ask xinyi about unwarpping dependency optionals
        let cardImage0 = UIImage(named: cards["C0"]!),
        let cardImage1 = UIImage(named: cards["C1"]!),
        let cardImage2 = UIImage(named: cards["C2"]!),
        let cardImage3 = UIImage(named: cards["C3"]!),
        let cardImage4 = UIImage(named: cards["C4"]!),
        let cardImage5 = UIImage(named: cards["C5"]!)
        
        else {
          return
      }
      let cardButtons = playerPostitions[p]
      cardButtons![0].setBackgroundImage(cardImage0, for: .disabled)
      cardButtons![1].setBackgroundImage(cardImage1, for: .disabled)
      cardButtons![2].setBackgroundImage(cardImage2, for: .disabled)
      cardButtons![3].setBackgroundImage(cardImage3, for: .disabled)
      cardButtons![4].setBackgroundImage(cardImage4, for: .disabled)
      cardButtons![5].setBackgroundImage(cardImage5, for: .disabled)
    }
  }
  
  private func showVisibleCards(descriptions: [String : String]) {
    bottomCards[0].setTitle(descriptions["C0"], for: .normal)
    bottomCards[1].setTitle(descriptions["C1"], for: .normal)
    bottomCards[2].setTitle(descriptions["C2"], for: .normal)
  }
  
  private func showPlayerCard(position: String, card index: Int, with description: String) {
    //TODO guard
    guard
      let cards = playerPostitions[position],
      let cardImage = UIImage(named: description)
      else{
        return
    }
    let card = cards[index]
    UIView.transition(with: card, duration: 0.4, options: .transitionFlipFromLeft, animations: {
      card.setBackgroundImage(cardImage, for: .disabled)
      card.setTitle("", for: .normal)
      card.isEnabled = false
    }, completion: nil)
    
  }
}
//MARK: Board Info Logic
extension OnlineRoomViewController {
  private func showPlayerInControl(position: String, playerId: String) {
    for (key, label) in playerLabelPositions {
      if key == position {
        label.textColor = UIColor(displayP3Red: 9/255, green: 125/255, blue: 235/255, alpha: 1.0)
        continue
      }
      label.textColor = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
    }
  }
  
  private func showPlayerInfo(position: String, playerId: String, playerStatus: Bool) {
    //TODO guard
    let label = playerLabelPositions[position]
    let status = playerStatusPositions[position]
    label?.text = playerId
    status?.text = playerStatus.description
  }
  
  private func hideLabels() {
    bottomPlayerLabel.text = ""
    leftPlayerLabel.text = ""
    topPlayerLabel.text = ""
    rightPlayerLabel.text = ""
  }
  
  private func hideOponentLabels() {
    leftPlayerLabel.text = ""
    topPlayerLabel.text = ""
    rightPlayerLabel.text = ""
  }
  
  private func hideStatus() {
    bottomStatusButton.isHidden = true
    leftStatusLabel.text = ""
    topStatusLabel.text = ""
    rightStatusLabel.text = ""
  }
  
  private func hideOponentStatus() {
    leftStatusLabel.text = ""
    topStatusLabel.text = ""
    rightStatusLabel.text = ""
  }
  
  private func updateStatusLabel(turnTime: Int) {
    statusLabel.text = String(turnTime)
  }
  
  private func updateStatusLabel(message: String) {
    statusLabel.text = message
  }
}
