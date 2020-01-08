//
//  Subscription.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 07.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import Foundation
import RealmSwift

class Subscription: Object {
  
  @objc dynamic var identifier = ""
  @objc dynamic var expirationDate: Date?
  
  static var hasSubscription: Bool {
    let realm = try! Realm()
    let subscriptions = realm.objects(Subscription.self)
    var hasSubscription = false
    
    for subscription in subscriptions {
      if let expiration = subscription.expirationDate {
        if expiration.timeIntervalSinceNow >= 0 {
          hasSubscription = true
          break
        }
      }
    }
    return hasSubscription
  }
  
  static func subscription(by id: String) -> Subscription {
    let realm = try! Realm()
    let subscription = realm.objects(Subscription.self).filter("identifier == '\(id)'").first
    if let subscription = subscription {
      return subscription
    }
    
    let newSubscription = Subscription()
    newSubscription.identifier = id
    newSubscription.expirationDate = nil
    try! realm.write {
      realm.add(newSubscription)
    }
    return newSubscription
  }
  
}
