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
    updatePlayerCardsTitles()
    refreshTimer.invalidate()
    self.performSegue (withIdentifier: "Menu", sender: self)
    print("Finished")
  }
  
  func didContinue() {
    //TODO Remove testing only
    game.stopGame()
    game.startRound()
    print("Player Continue")
  }
  
  func didQuit() {
    print("Player quited")
  }
  
  
  func didFlipCard(with playerId: String, at index: Int) {
    let player = game.getPlayer(playerId: playerId)!
    let playerCardMap = playersCards[playerId]
    let cardButton = getButton(buttonTag: playerCardMap![index])!
    let playerCard = player.hand[index % 6]
    if (playerCard.faceUp) {
      UIView.transition(with: cardButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        cardButton.backgroundColor = UIColor(displayP3Red: 241/255, green: 239/255, blue: 232/255, alpha: 1)

      }, completion: nil)
    }
  }
  
  func didFlipDeck() {
    let deckCard = game.getCurrentDeckTopCard()
    if (deckCard.faceUp) {
      UIView.transition(with: deckButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        self.deckButton.backgroundColor = UIColor(displayP3Red: 241/255, green: 239/255, blue: 232/255, alpha: 1)
      }, completion: nil)
    }
  }
  func didSwapCard(playerId: String, at index: Int, from type: String){
    let player = game.getPlayer(playerId: playerId)!
    let sourceCard = type == "DECK" ? deckButton : pileButton
    let playerCardMap = playersCards[playerId]
    let cardButton = getButton(buttonTag: playerCardMap![index])!
    let playerCard = player.hand[index % 6]
    if (playerCard.faceUp) {
      UIView.transition(with: cardButton, duration: 0.4, options: .transitionFlipFromLeft, animations: {
        cardButton.backgroundColor = UIColor(displayP3Red: 241/255, green: 239/255, blue: 232/255, alpha: 1)
      }, completion: { _ in
        UIView.animate(withDuration: 1.0, animations: {
          let sourceFrame = sourceCard?.frame
          sourceCard?.frame = cardButton.frame
          cardButton.frame = sourceFrame!
          })
      })
    }
  }
}



class OfflineRoomViewController: UIViewController {
  
  let game = GolfGame.localShared
  
  var cardsDelt = 0
  var turnTime = 0
  var pic = ""
  var lastCardTag = 0
  var playersCards = [String:[Int]]()
  @IBOutlet weak var picLabel: UILabel!
  @IBOutlet private var cardsButtons:  [UIButton]!
  @IBOutlet private var deckButton: UIButton!
  @IBOutlet private var pileButton: UIButton!
  @IBAction private func cardAction(_ sender: UIButton){
    let cardFace = game.getCardFace(cardTag: sender.tag, playerId: "0")
    switch (pic, cardFace, game.gameState, sender.tag){
    case ("0", false, .playerWait,_), ("0", false, .playerSecondWait,_):
      game.selectSelfAction(playerId: "0")
      break
    case ("0", false, .playerMoveSelf, lastCardTag):
      game.confirmSelfAction(playerId: "0", cardTag: sender.tag)
    case ("0", false, .playerMoveDeck,_):
      game.replaceDeckCard(playerId: "0", cardTag: sender.tag)
      break
    case ("0", false, .playerMovePile,_):
      game.replacePileCard(playerId: "0", cardTag: sender.tag)
      break
    default:
      break
    }
    lastCardTag = sender.tag
  }
  
  @IBAction func deckAction(_ sender: Any) {
    switch (pic, game.gameState){
    case ("0", .playerWait), ("0", .playerMovePile), ("0", .playerSecondWait):
      game.selectDeckAction(playerId: "0")
    case (pic, .playerMoveDeck):
      game.clearDeckAction(playerId: "0")
    default:
      break
    }
  }
  
  @IBAction func pileAction(_ sender: Any) {
    switch (pic, game.gameState){
    case ("0", .playerWait):
      game.selectPileAction(playerId: "0")
    case (pic, .playerMovePile):
      game.clearPileAction(playerId: "0")
    default:
      break
    }
  }
  
  @IBAction func showMenuButton(_ sender: Any) {
    self.performSegue (withIdentifier: "Menu", sender: self)
    print("Finished")
  }
  
  
  var dealer: Timer!
  var refreshTimer: Timer!
  
  @objc public func updateTime(){
    updateDecks()
    updatePlayerCards()
    pic = game.getPlayerInControl()
    picLabel.text = pic
  }
  
  @objc public func test(){
    switch(self.cardsDelt){
    case 0...23:
      let card = getButton(buttonTag: cardsDelt)!
      card.fadeIn()
      self.cardsDelt = cardsDelt + 1
    default:
      self.dealer.invalidate()
    }
  }
  func startDealer(){
    self.cardsDelt = 0
    dealer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(test), userInfo: nil, repeats: true)
  }
  
  func getGame(){
    refreshTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    startDealer()
  }
  
  func updatePlayerCards(){
    updatePlayerCardsTitles()
    updatePlayerCardsColors()
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? MenuViewController {
      destination.delegate = self
    }
  }
  
  func updatePlayerCardsTitles(){
    var count = 0
    for p in 0..<game.players.count{
      for i in 0..<game.cardsPerPlayer{
        let card = getButton(buttonTag: count)!
        let faceUp = game.players[p].hand[i].faceUp
        let visibleToOwner = game.players[p].hand[i].visibleToOwner
        switch(faceUp, visibleToOwner, p){
        case (false, true, 0):
          let description =  game.players[p].hand[i].getDescription()
          card.setTitle(description, for: UIControlState.normal)
//          card.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.1) , for: UIControlState.normal)
        case (true, _, _):
          let description =  game.players[p].hand[i].getDescription()
          card.setTitleColor(UIColor(red: 55/255, green: 149/255, blue: 250/255, alpha: 1) , for: UIControlState.normal)
          card.setTitle(description, for: UIControlState.normal)
        case (false, false, _):
          card.setTitle("", for: UIControlState.normal)
        default: break
        }
        count += 1
      }
    }
  }
  
  func updateDecks() {
    let pileTopCard = game.getPileDeckTopCard()
    let deckTopCard = game.getCurrentDeckTopCard()
    updateDecksTittle(pileTopCard: pileTopCard, deckTopCard: deckTopCard)
    updateDecksColors(pileTopCard: pileTopCard, deckTopCard: deckTopCard)
  }
  
  func updateDecksTittle(pileTopCard: Card, deckTopCard: Card){
    var cardLabel = pileTopCard.faceUp ? pileTopCard.getDescription() : ""
    pileButton.setTitle(cardLabel, for: UIControlState.normal)
    cardLabel = deckTopCard.faceUp ? deckTopCard.getDescription() : ""
    deckButton.setTitle(cardLabel, for: UIControlState.normal)
  }
  
  func updatePlayerCardsColors(){
    var count = 0
    for p in 0..<game.players.count{
      for i in 0..<game.cardsPerPlayer{
        let card = getButton(buttonTag: count)!
        switch (p, self.pic, self.game.players[p].hand[i].faceUp, self.game.gameState){
        case (_, _,true, _):
          card.backgroundColor = UIColor(displayP3Red: 241/255, green: 239/255, blue: 232/255, alpha: 1)
        case (0, "0", false, .playerWait), (0, "0", false, .playerSecondWait):
          card.backgroundColor = UIColor(displayP3Red: 0.86, green: 0.97, blue: 0.78, alpha: 1)
        case (0, "0", false, .playerMoveDeck), (0, "0", false, .playerMovePile):
          card.backgroundColor = UIColor(displayP3Red: 0.98, green: 0.84, blue: 0.22, alpha: 1)
        case (0, "0", false, .playerMoveSelf):
          card.backgroundColor = UIColor(displayP3Red: 0.98, green: 0.84, blue: 0.22, alpha: 1)
        default:
          card.backgroundColor = UIColor(displayP3Red: 1.00, green: 0.64, blue: 0.76, alpha: 1)
        }
        count += 1
      }
    }
  }
  
  func updateDecksColors(pileTopCard: Card, deckTopCard: Card){
    switch (game.gameState, pic){
    case (.playerWait, "0"), (.playerMoveSelf, "0"):
      pileButton.backgroundColor = UIColor(displayP3Red: 0.86, green: 0.97, blue: 0.78, alpha: 1)
      deckButton.backgroundColor = UIColor(displayP3Red: 0.86, green: 0.97, blue: 0.78, alpha: 1)
      break
    case (.playerMoveDeck, "0"):
      pileButton.backgroundColor = UIColor(displayP3Red: 1.00, green: 0.64, blue: 0.76, alpha: 1)
      deckButton.backgroundColor = UIColor(displayP3Red: 0.98, green: 0.84, blue: 0.22, alpha: 1)
      break
    case (.playerMovePile, "0"):
      pileButton.backgroundColor = UIColor(displayP3Red: 0.98, green: 0.84, blue: 0.22, alpha: 1)
      deckButton.backgroundColor = UIColor(displayP3Red: 0.98, green: 0.84, blue: 0.22, alpha: 1)
      break
    case (.playerSecondWait, "0"):
      pileButton.backgroundColor = UIColor(displayP3Red: 1.00, green: 0.64, blue: 0.76, alpha: 1)
      deckButton.backgroundColor = UIColor(displayP3Red: 0.86, green: 0.97, blue: 0.78, alpha: 1)
      break
    default:
      pileButton.backgroundColor = UIColor(displayP3Red: 1.00, green: 0.64, blue: 0.76, alpha: 1)
      deckButton.backgroundColor = UIColor(displayP3Red: 1.00, green: 0.64, blue: 0.76, alpha: 1)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    GolfGame.localShared.delegate = self
    print(game)
    var count = 0
    for p in 0..<game.players.count{
      for i in 0..<game.cardsPerPlayer{
        //TODO fix error after quit game
        let card = getButton(buttonTag: count)!
        let faceUp = game.players[p].hand[i].faceUp
        switch(faceUp){
        case true:
          let rank = String(describing: game.players[p].hand[i].rank!.rawValue)
          let suit = String(describing: game.players[p].hand[i].suit!.rawValue)
          card.setTitle(rank+suit, for: UIControlState.normal)
          count += 1
          continue
        case false:
          card.setTitle(nil, for: UIControlState.normal)
        }
        count += 1
        card.alpha = 0.0
      }
      playersCards[game.players[p].playerId] = Array(p*6...(p*6)+5)
    }
    getGame()
  }
  
  public func getButton(buttonTag tag: Int) -> UIButton? {
    for (button) in cardsButtons {
      if (button.tag == tag){
        return button
      }
    }
    return nil
  }
  
  
  //  public func dealCards(){
  //    self.timer = Repeater.once(after: .seconds(5)) { timer in
  ////       do something
  //    }
  // }
}
