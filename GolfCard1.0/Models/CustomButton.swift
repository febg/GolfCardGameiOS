//
//  CustomButton.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-06.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit


@IBDesignable
class CustomButton: UIButton {
 
}

extension UILabel {
  @IBInspectable
  var rotation: Int {
    get {
      return 0
    } set {
      let radians = CGFloat(CGFloat(Double.pi) * CGFloat(newValue) / CGFloat(180.0))
      self.transform = CGAffineTransform(rotationAngle: radians)
    }
  }
}


//MARK: Exposed Properties
extension UIView {
  
  
  
@IBInspectable var CornerRadius: CGFloat {
  get {
    return layer.cornerRadius
  }
  set {
    layer.cornerRadius = newValue
    layer.masksToBounds = newValue > 0
  }
}

@IBInspectable
var shadowRadius: CGFloat {
  get {
    return layer.shadowRadius
  }
  set {
    layer.shadowRadius = newValue
  }
}

@IBInspectable
var shadowOpacity: Float {
  get {
    return layer.shadowOpacity
  }
  set {
    layer.shadowOpacity = newValue
  }
}

@IBInspectable
var shadowOffset: CGSize {
  get {
    return layer.shadowOffset
  }
  set {
    layer.shadowOffset = newValue
  }
}

@IBInspectable
var shadowColor: UIColor? {
  get {
    if let color = layer.shadowColor {
      return UIColor(cgColor: color)
    }
    return nil
  }
  set {
    if let color = newValue {
      layer.shadowColor = color.cgColor
    } else {
      layer.shadowColor = nil
    }
  }
}
  
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
}
