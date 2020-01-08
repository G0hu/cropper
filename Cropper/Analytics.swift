//
//  Analytics.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 07.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import Foundation
import Amplitude_iOS

class Analytics {
  
  static var shared = Analytics()
  
  func setUserProperties(properties: [AnyHashable: Any]) {
    Amplitude.instance().setUserProperties(properties)
  }
  
  func logEvent(name: String, with parameters: [AnyHashable: Any]? = nil) {
    if let parameters = parameters {
      Amplitude.instance().logEvent(name,
                                    withEventProperties: parameters)
    } else {
      Amplitude.instance().logEvent(name)
    }
  }
  
  func logRevenue(productId: String,
                  quantity: Int,
                  price: NSNumber,
                  revenueType: String,
                  receipt: Data?,
                  properties: [AnyHashable: Any]? = nil) {
    var revenue = AMPRevenue().setProductIdentifier(productId).setQuantity(quantity).setPrice(price).setRevenueType(revenueType)
    if let receipt = receipt {
      revenue = revenue?.setReceipt(receipt)
    }
    if let properties = properties {
      revenue = revenue?.setEventProperties(properties)
    }
    Amplitude.instance().logRevenueV2(revenue)
  }
  
  public func formatDateForAnalytics(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar.current
    dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
    return dateFormatter.string(from: date)
  }
  
}



