//
//  MainViewController.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 10/05/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

class MainViewController: UIViewController, GADBannerViewDelegate {
  
  var banner: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
  
  override func viewDidLoad() {
    let unsqdViewController: ViewController = ViewController(with: banner)
    addChild(unsqdViewController)
    
    banner.delegate = self
    banner.adUnitID = AppDelegate.bannerUnitId
    banner.rootViewController = self
    banner.load(GADRequest())
    
    view.addSubview(unsqdViewController.view)
    unsqdViewController.didMove(toParent: self)
    
    let unsqd: UIView = unsqdViewController.view
    unsqd.translatesAutoresizingMaskIntoConstraints = false
    unsqd.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    unsqd.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    
    banner.translatesAutoresizingMaskIntoConstraints = false
    banner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    banner.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 30)
      .isActive = true
    
    
    view.addSubview(banner)
  }
}
