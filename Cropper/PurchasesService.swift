//
//  PurchasesService.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 07.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import RealmSwift

typealias CompletionBlock = (Bool) -> Void

class PurchasesService {
  enum Purchase: String {
    case removeWatermark = "egehugo.unsqrd.removewatermark"
    
    static var allProducts: [Purchase] = [.removeWatermark]
  }
  
  static var shared: PurchasesService = PurchasesService()
  private var products: [String: SKProduct] = [:]
  
  func fetchAllProducts() {
    let allProducts = Purchase.allProducts.map({ $0.rawValue })
    var allProductsSet = Set<String>()
    allProducts.forEach({ allProductsSet.insert($0) })
    
    print("PRODUCTS ARE", allProductsSet)
    
    SwiftyStoreKit.retrieveProductsInfo(allProductsSet) { (result) in
      self.products = [:]
      for product in result.retrievedProducts {
        self.products[product.productIdentifier] = product
      }
    }
  }
  
  func getProduct(product: Purchase,
                  completion: @escaping (SKProduct?) -> Void) {
    if let value = self.products[product.rawValue] {
      completion(value)
      return
    }
    SwiftyStoreKit.retrieveProductsInfo(Set<String>(arrayLiteral: product.rawValue)) { (result) in
      if let value = result.retrievedProducts.first {
        completion(value)
        self.fetchAllProducts()
      } else {
        completion(nil)
      }
    }
  }
  
  func getProducts(products: [Purchase],
                   earlyAccessBlock: (([Purchase: SKProduct]) -> Void)?,
                   completion: @escaping ([Purchase: SKProduct]) -> Void) {
    var productsDictionary: [Purchase: SKProduct] = [:]
    for productTypes in products {
      if let product = self.products[productTypes.rawValue] {
        productsDictionary[productTypes] = product
      }
    }
    
    if productsDictionary.count != products.count {
      if productsDictionary.count > 0 {
        earlyAccessBlock?(productsDictionary)
      }
    } else {
      completion(productsDictionary)
      return
    }
    
    let identifiers = products.map({ $0.rawValue })
    SwiftyStoreKit.retrieveProductsInfo(Set<String>(identifiers)) { (result) in
      if result.retrievedProducts.count == identifiers.count {
        var productsDictionary: [Purchase: SKProduct] = [:]
        for product in result.retrievedProducts {
          if let identifier = Purchase(rawValue: product.productIdentifier) {
            productsDictionary[identifier] = product
          } else {
            assertionFailure("No such identifier")
          }
        }
        completion(productsDictionary)
        self.fetchAllProducts()
      } else {
        completion([:])
      }
    }
  }
  
  func purchaseSubscription(with product: SKProduct,
                            completion: @escaping CompletionBlock) {
    var type = "unknown"
    let inAppPurchase = Purchase(rawValue: product.productIdentifier)
    
    if let inAppPurchase = inAppPurchase {
      switch inAppPurchase {
      case .removeWatermark:
        type = "removeWatermark"
      }
    }
    
    SwiftyStoreKit.purchaseProduct(product) { (result) in
      switch result {
      case .success(let purchase):
        if purchase.transaction.transactionState == .purchased {
          Analytics.shared.logRevenue(productId: purchase.product.productIdentifier,
                                      quantity: purchase.quantity,
                                      price: purchase.product.price as NSNumber,
                                      revenueType: type,
                                      receipt: SwiftyStoreKit.localReceiptData)
        }
        
        if let inAppPurchase = inAppPurchase {
          self.verifySubscription(inAppPurchase, completion: { (result) in
            if let result = result {
              self.purchased(inAppPurchase, status: result)
              completion(true)
            } else {
              completion(false)
            }
          })
        } else {
          completion(true)
        }
      case .error(let error):
        switch error.code {
        case .paymentCancelled:
          break
        case .storeProductNotAvailable:
          print("not available")
        case .clientInvalid:
          print("invalid")
        case .paymentNotAllowed:
          print("not allowed")
        default:
          print("Another error", error.code.rawValue)
        }
        completion(false)
      }
    }
  }
  
  enum PuchaseStatus {
    case puchased
    case expired
    case notPurcahsed
  }
  
  func verifyPurchase(_ inAppPurchase: Purchase, completion: @escaping (VerifyPurchaseResult?) -> Void) {
    #if DEBUG
    let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: "fb8f2541ec78413bab09230dd35f9255")
    #else
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "fb8f2541ec78413bab09230dd35f9255")
    #endif
    
    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
      switch result {
      case .success(let receipt):
        let productId = inAppPurchase.rawValue
        
        let purchaseResult = SwiftyStoreKit.verifyPurchase(
          productId: productId,
          inReceipt: receipt
        )

        completion(purchaseResult)
      case .error(let error):
        print("Receipt verification failed: \(error)")
        completion(nil)
      }
    }
  }
  
  func purchase(product: Purchase, completionHandler: @escaping(_ error: String?) -> ()) {
    SwiftyStoreKit.purchaseProduct(product.rawValue) { (result) in
      switch result {
      case .success(let purchase):
        if purchase.transaction.transactionState == .purchased {
          
          var type = "unknown"
          
          switch product {
          case .removeWatermark:
            type = "removeWatermark"
          default:
            break;
          }
          
          self.verifyPurchase(product) { (result) in
            if let _ = result {
              Analytics.shared.logRevenue(productId: purchase.product.productIdentifier,
                                                 quantity: purchase.quantity,
                                                 price: purchase.product.price as NSNumber,
                                                 revenueType: type,
                                                 receipt: SwiftyStoreKit.localReceiptData
              )
              completionHandler(nil)
            } else {
              completionHandler("The device is not allowed to make the payment")
            }
          }
        }
      case .error(let error):
        switch error.code {
        case .unknown: completionHandler("Unknown error. Please contact support")
        case .clientInvalid: completionHandler("Not allowed to make the payment")
        case .paymentCancelled: completionHandler("The purchase was declined")
        case .paymentInvalid: completionHandler("The purchase identifier was invalid")
        case .paymentNotAllowed: completionHandler("The device is not allowed to make the payment")
        case .storeProductNotAvailable: completionHandler("The product is not available in the current storefront")
        case .cloudServicePermissionDenied: completionHandler("Access to cloud service information is not allowed")
        case .cloudServiceNetworkConnectionFailed: completionHandler("Could not connect to the network")
        case .cloudServiceRevoked: completionHandler("User has revoked permission to use this cloud service")
        default: completionHandler((error as NSError).localizedDescription)
        }
      }
    }
  }
  
  func purchased(_ inAppPurchase: Purchase,
                 status: VerifySubscriptionResult) {
    let realm = try! Realm()
    let subscription = Subscription.subscription(by: inAppPurchase.rawValue)
    
    switch status {
    case .purchased(let expiryDate, _):
      try? realm.write {
        subscription.expirationDate = expiryDate
      }
    case .expired(let expiryDate, _):
      try? realm.write {
        subscription.expirationDate = expiryDate
      }
    case .notPurchased:
      try? realm.write {
        subscription.expirationDate = nil
      }
    }
  }
  
  func updateSubscriptionPurchases() {
    let realm = try! Realm()
    let subscriptions = realm.objects(Subscription.self)
    
    for subscription in subscriptions {
      if let purchase = Purchase(rawValue: subscription.identifier) {
        self.verifySubscription(purchase) { (result) in
          if let result = result {
            self.purchased(purchase, status: result)
          }
        }
      }
    }
  }
  
  func verifySubscription(_ inAppPurcahse: Purchase, completion: @escaping (VerifySubscriptionResult?) -> Void) {
    #if DEBUG
    let appleValidator = AppleReceiptValidator(service: .sandbox,
                                               sharedSecret: "5b226d384c2541c6b30cc5ab5060a0ab")
    #else
    let appleValidator = AppleReceiptValidator(service: .production,
                                               sharedSecret: "5b226d384c2541c6b30cc5ab5060a0ab")
    #endif
    
    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
      switch result {
      case .success(let receipt):
        let productId = inAppPurcahse.rawValue
        
        let purchaseResult = SwiftyStoreKit.verifySubscription(
          ofType: .autoRenewable,
          productId: productId,
          inReceipt: receipt)
        completion(purchaseResult)
      case .error(let error):
        print("Receipt verification failed: \(error)")
        completion(nil)
      }
    }
  }
  
  func restorePurchases(completion: ((_ result: VerifySubscriptionResult?) -> Void)? = nil) {
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
      for purchase in results.restoredPurchases {
        print(purchase)
        if let inAppPurcahse = Purchase(rawValue: purchase.productId) {
          print(inAppPurcahse)
          self.verifySubscription(inAppPurcahse, completion: { (result) in
            if let result = result {
              print(result)
              self.purchased(inAppPurcahse, status: result)
            }
          })
        }
      }
      if results.restoredPurchases.count == 0 {
        completion?(.notPurchased)
      } else {
        completion?(nil)
      }
    }
  }
}

extension SKProduct {
  var productLocalizedPrice: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = priceLocale
    return formatter.string(from: price) ?? ""
  }
}



