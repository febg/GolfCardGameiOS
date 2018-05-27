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
  
  func flip (){
    
  }
}
