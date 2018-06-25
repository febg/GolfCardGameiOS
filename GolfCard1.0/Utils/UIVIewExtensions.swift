//
//  UIVIewExtensions.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-04-11.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func fadeIn(duration : TimeInterval = 1.0, delay: TimeInterval = 0.0) {
    UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
      self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
    }, completion: nil)
  }
  
  func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0) {
    UIView.animate(
      withDuration: duration,
      delay: delay,
      options: .curveEaseOut,
      animations: { self.alpha = 0.0 },
      completion: nil
    )
  }
  
  func grow() {
    let time: TimeInterval = 0.5
    UIView.animate(
      withDuration: time,
      delay: 0.0,
      animations: {
        for c in self.constraints {
        switch (c.firstAttribute) {
        case .width:
          c.constant = 140

        case .height:
          c.constant = 160
        default:
          break
        }
        }
        self.layoutIfNeeded()
    },
      completion: nil
    )
    self.borderWidth = 1.0
    
  }
  
  func shrink() {
    let time: TimeInterval = 0.5
    UIView.animate(
      withDuration: time,
      delay: 0.0,
      animations: {
        for c in self.constraints {
          switch (c.firstAttribute) {
          case .width:
            c.constant = 126
          case .height:
            c.constant = 146
          default:
            break
          }
        }
        self.layoutIfNeeded()
    },
      completion: nil
    )
     self.borderWidth = 0.0
  }
  
  func flip (){
    
  }
  
}
