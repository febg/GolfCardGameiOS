//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//let card1 = Card(type: .ace, suit: .spades, faceUp: false, visibleToOwner: false)
let jcard1 = "{\"Suit\": \"hearts\",\"FaceUp\": false,\"VisibleToOwner\": false}"
print(jcard1)
let jData: Data = jcard1.data(using: .utf8)!

//print(jData)
//let jsonEncoder = JSONEncoder()
//let jsonData = try jsonEncoder.encode(card1)

let jsonDecoder = JSONDecoder()

do {
let data = try jsonDecoder.decode(Card.self, from: jData)
print(data)
} catch let error {
  print(error)
}
