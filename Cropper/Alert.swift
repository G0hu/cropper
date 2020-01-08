//
//  Alert.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 07.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import Foundation
import UIKit

class Alert {
  
  static func show(title: String? = nil, message: String? = nil, actions: [UIAlertAction]? = nil, preferredStyle: UIAlertController.Style) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    if actions == nil {
      let action = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
      alert.addAction(action)
    } else {
      for action in actions! {
        alert.addAction(action)
      }
    }
    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
  }
  
}

extension UIApplication {
  static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
      return topViewController(base: selected)
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}
