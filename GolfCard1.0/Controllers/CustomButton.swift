//
//  CustomButton.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-06.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
  

}

//MARK: Exposed Properties
extension UIView {
  // [  Corner Radious  ]
  @IBInspectable var CornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
}
