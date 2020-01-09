//
//  AppDelegate.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 07/03/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Firebase
import Amplitude_iOS
import SwiftyStoreKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  static let bannerUnitId = "ca-app-pub-7859617379555812/4710575486"
  static let videosUnitId = "ca-app-pub-7859617379555812/5125607482"
  //static let bannerUnitId = "ca-app-pub-7859617379555812/4710575486"
  //static let videosUnitId = "ca-app-pub-7859617379555812/5125607482"
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    Amplitude.instance().initializeApiKey("7a92b7d7891e9a46d94fefb5eedab314")
    FirebaseApp.configure()
    
    print("DID FINISH")
    
    setUpInApps()
    self.window = UIWindow(frame: UIScreen.main.bounds)
    
    if let window = self.window {
      window.rootViewController = MainViewController()
      window.backgroundColor = UIColor.white
      window.makeKeyAndVisible()
    }
    
    return true
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    var orientation: UIInterfaceOrientationMask = .portrait
    DispatchQueue.main.async {
      let root = window?.rootViewController
      
      if (root?.presentedViewController) is EndViewController {
        orientation = .portrait
      } else if (root?.presentedViewController) is CustomOBViewController {
        orientation = .portrait
      } else {
        orientation = .all
      }
    }
    
    return orientation
  }
  
  func setUpInApps() {
    print("setup inapps")
    SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
      print("restoring")
      for purchase in purchases {
        switch purchase.transaction.transactionState {
        case .purchased, .restored:
          if purchase.needsFinishTransaction {
            SwiftyStoreKit.finishTransaction(purchase.transaction)
          }
        case .failed, .purchasing, .deferred:
          break
        default:
          break;
        }
      }
      self.verifyReciepts()
    }
  }

  func verifyReciepts() {
    PurchasesService.shared.fetchAllProducts()
    PurchasesService.shared.updateSubscriptionPurchases()
  }
  
}
