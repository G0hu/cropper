//
//  HEX.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 08.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
  var themeRedColor: UIColor {
    return UIColor.init(hex: "F51B23")
  }
  
  convenience init(hex: String) {
    let scanner = Scanner(string: hex)
    scanner.scanLocation = 0
    
    var rgbValue: UInt64 = 0
    
    scanner.scanHexInt64(&rgbValue)
    
    let r = (rgbValue & 0xff0000) >> 16
    let g = (rgbValue & 0xff00) >> 8
    let b = rgbValue & 0xff
    
    self.init(
      red: CGFloat(r) / 0xff,
      green: CGFloat(g) / 0xff,
      blue: CGFloat(b) / 0xff, alpha: 1
    )
  }
}
