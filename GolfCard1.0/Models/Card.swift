//
//  Card.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-08.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation


struct Card: Codable{
  var rank: Rank?
  var suit: Suit?
  var faceUp: Bool = false
  var visibleToOwner: Bool = false
  
  
  
  mutating public func flipCard(){
    switch faceUp {
    case true:
      faceUp = false
    case false:
      faceUp = true
    }
  }
  
  enum Suit: String, Codable {
    case spades = "Spade"
    case hearts  = "Heart"
    case clubs = "Club"
    case dimonds = "Dimond"
    
    var desription: String {
      switch self {
      case .spades: return "spades"
      case .hearts: return "hearts"
      case .clubs: return "clubs"
      case .dimonds: return "dimonds"
      }
    }
    
    static var all = [Suit.clubs, .hearts, .spades, .dimonds]
  }
  
  enum Rank: String, Codable {
    case ace = "ace"
    case two = "two"
    case three = "three"
    case four = "four"
    case five = "five"
    case six = "six"
    case seven = "seven"
    case eight = "eight"
    case nine = "nine"
    case ten = "ten"
    case jack = "jack"
    case queen = "queen"
    case king = "king"
    
    var pointValue: Int {
      switch self {
      case .ace: return 1
      case .two: return -2
      case .three: return 3
      case .four: return 4
      case .five: return 5
      case .six: return 6
      case .seven: return 7
      case .eight: return 8
      case .nine: return 9
      case .ten, .queen: return 10
      case .jack, .king: return 0
      }
    }
    
    var value: Int {
      switch self {
      case .ace: return 1
      case .two: return -2
      case .three: return 3
      case .four: return 4
      case .five: return 5
      case .six: return 6
      case .seven: return 7
      case .eight: return 8
      case .nine: return 9
      case .ten: return 10
      case .queen: return 11
      case .jack, .king: return 0
      }
    }
    
    var description: String {
      switch self {
      case .ace: return "A"
      case .two: return "2"
      case .three: return "3"
      case .four: return "4"
      case .five: return "5"
      case .six: return "6"
      case .seven: return "7"
      case .eight: return "8"
      case .nine: return "9"
      case .ten: return "10"
      case .jack: return "J"
      case .queen: return "Q"
      case .king: return "K"
      }
    }
    
    static let all: [Rank] = [.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king]
  }
  
  public func getDescription() -> String? {
    guard let rank = self.rank, let suit = self.suit else { return nil }
    return rank.description + suit.desription
  }
  
  public func getImageKeys() -> (String,String) {
    guard let rank = self.rank?.description, let suit = self.suit?.rawValue else { return ("","") }
    switch (self.faceUp, self.visibleToOwner) {
    case (true, _):
      return ("Front"+suit, rank)
    //FACEUP
    case (_, true):
      //BackVisible
      return ("BackVisible"+suit, rank)
    default:
      //back
      return ("Back-1", "")
    }
  }
}

