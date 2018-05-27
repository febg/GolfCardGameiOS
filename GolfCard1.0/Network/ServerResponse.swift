//
//  ServerResponse.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-05-08.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation

struct ServerError: Codable {
  //TODO handle error codes, for know just strings
  var error: String
}
