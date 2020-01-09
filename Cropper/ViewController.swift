//
//  ViewController.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 07/03/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Photos
import StoreKit
import RealmSwift
import SVProgressHUD

import GoogleMobileAds
import TOCropViewController
import ALCameraViewController

class ViewController: UIViewController, TOCropViewControllerDelegate, GADRewardBasedVideoAdDelegate {
  
  let endViewController: EndViewController = EndViewController()
  let imageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "1-2 kopya"))
  var cropView: TOCropViewController? = nil
  var forceWalkthrough: Bool = false
  var is_editing: Bool = false
  var banner: GADBannerView
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.banner = GADBannerView()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(with banner: GADBannerView) {
    self.banner = banner
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setNeedsStatusBarAppearanceUpdate()
    
    imageView.contentMode = UIView.ContentMode.scaleAspectFill
    imageView.frame = view.frame
    view.addSubview(imageView)
    view.addSubview(banner)
    
    self.banner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    self.banner.topAnchor.constraint(equalTo: view.topAnchor,
                                     constant: UIApplication.shared.statusBarFrame.height).isActive = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if (is_editing) {
      imageView.isHidden = true
      view.backgroundColor = UIColor.black
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    let launchedBefore = UserDefaults.standard.bool(forKey: "first_launch")
    if !launchedBefore || forceWalkthrough {
      forceWalkthrough = false
      UserDefaults.standard.set(true, forKey: "first_launch")
      
      let walkThrough = generateWalkThrough(rect: view.frame)
      walkThrough.modalPresentationStyle = .fullScreen
      self.present(walkThrough, animated: false, completion: {
        walkThrough.view.addSubview(self.banner)
        self.banner.centerXAnchor.constraint(equalTo: walkThrough.view.centerXAnchor).isActive = true
        self.banner.topAnchor.constraint(equalTo: walkThrough.view.topAnchor,
                                         constant: UIApplication.shared.statusBarFrame.height).isActive = true
      })
    } else if (!is_editing) {
      showCameraRoll()
    }
  }
  
  @objc private func showCameraRoll() {
    cameraRollAppearance()
  }
  
  func cameraRollAppearance(for album: String? = nil) {
    let cameraViewController = CameraViewController(album: album, croppingEnabled: false) { [weak self] image, asset in
      if let img = image {
        self?.is_editing = true
        self?.dismiss(animated: false, completion: { self?.presentCropViewController(image: img) })
      } else {
        self?.dismiss(animated: false, completion: { self?.showCameraRoll() })
      }
    }
    
    cameraViewController.modalPresentationStyle = .fullScreen
    present(cameraViewController, animated: true, completion: {
      cameraViewController.view.addSubview(self.banner)
      
      
      self.banner.centerXAnchor.constraint(equalTo: cameraViewController.view.centerXAnchor).isActive = true
      self.banner.topAnchor.constraint(equalTo: cameraViewController.view.topAnchor,
                                       constant: UIApplication.shared.statusBarFrame.height).isActive = true
    })
  }
  
  private func presentCropViewController(image: UIImage) {
    let cropViewController: TOCropViewController = TOCropViewController(image: image)
    cropViewController.cropView.aspectRatioLockEnabled = true
    cropViewController.delegate = self
    self.cropView = cropViewController
    cropViewController.cropView.gridOverlayView.removeStamp(Subscription.hasSubscription, removeButton: true)
    
    cropViewController.modalPresentationStyle = .fullScreen
    self.present(cropViewController, animated: true, completion: {
      cropViewController.view.addSubview(self.banner)
      cropViewController.cropView.gridOverlayView.removeStamp(Subscription.hasSubscription, removeButton: true)
      self.banner.centerXAnchor.constraint(equalTo: cropViewController.view.centerXAnchor).isActive = true
      self.banner.topAnchor.constraint(equalTo: cropViewController.view.topAnchor,
                                       constant: UIApplication.shared.statusBarFrame.height).isActive = true
      
      GADRewardBasedVideoAd.sharedInstance().delegate = self
      GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: AppDelegate.videosUnitId)
    })
  }
  
  func cropViewController(_ cropViewController: TOCropViewController,
                          didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
    let horizontal = (cropRect.width / cropRect.height) > 1 ? true : false
    let pieces: CGFloat = round(horizontal ? (cropRect.width / cropRect.height) : (cropRect.height / cropRect.width))
    
    for i in (1...Int(pieces)).reversed() {
      let (x, y) = horizontal ? (CGFloat(i - 1) * (image.size.width / pieces), 0) :
        (0 , CGFloat(i - 1) * (image.size.height / pieces))
      let (w, h) = horizontal ? (image.size.width / pieces, image.size.height) :
        (image.size.width, image.size.height / pieces)
      
      let rect = CGRect(x: x, y: y, width: w, height: h)
      let slice: UIImage = image.croppedImage(withFrame: rect, angle: angle, circularClip: false)
      
      let rotated = horizontal ? slice : slice.rotate(with: 270)
      var final = i == Int(pieces) && cropViewController.cropView.gridOverlayView.stampIsDisplayed()
      ? rotated.addWatermark(with: #imageLiteral(resourceName: "stamp")) : rotated
      
      if Subscription.hasSubscription {
        final = rotated
      }
      
      UIImageWriteToSavedPhotosAlbum(final, self,
                                     #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    self.dismiss(animated: true, completion: {
      self.endViewController.modalPresentationStyle = .fullScreen
      self.present(self.endViewController, animated: true, completion: {
        self.endViewController.view.addSubview(self.banner)
        self.banner.centerXAnchor.constraint(equalTo: self.endViewController.view.centerXAnchor).isActive = true
        self.banner.topAnchor.constraint(equalTo: self.endViewController.view.topAnchor,
                                         constant: UIApplication.shared.statusBarFrame.height).isActive = true
      })
      self.is_editing = false
    })
  }
  
  func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
    is_editing = false
    self.dismiss(animated: true, completion: nil)
  }
  
  func willRemoveStamp(_ cropViewController: TOCropViewController, withBaseImage image: UIImage) {
    let action_ad = UIAlertAction(title: "Watch Ad", style: .default) { (ACTION) in
      if GADRewardBasedVideoAd.sharedInstance().isReady {
        GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: cropViewController)
      }
    }
    let action_inApp = UIAlertAction(title: "Remove watermarks forever for $2.99", style: .default) { (ACTION) in
      self.purchase(product: .removeWatermark)
    }
    let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    Alert.show(
      title: "How would you like to remove the watermark?",
      actions: [action_ad, action_inApp, action_cancel],
      preferredStyle: .actionSheet
    )
  }
  
  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
    if let c = self.cropView {
      c.cropView.gridOverlayView.removeStamp(true, removeButton: true)
    }
  }
  
  func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    if let c = self.cropView {
      if c.cropView.gridOverlayView.stampIsDisplayed() {
        c.cropView.gridOverlayView.removeStamp(false, removeButton: false)
      }
    }
  }
  
  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
    if let c = self.cropView {
      if c.cropView.gridOverlayView.stampIsDisplayed() {
        c.cropView.gridOverlayView.removeStamp(false, removeButton: true)
      }
    }
  }
  
  func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: AppDelegate.videosUnitId)
  }
  
  @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      print(error.localizedDescription)
    } else {
      
      print("Your altered image has been saved to your photos.")
      
    }
  }
  
  //In-App purchases functions
  func purchase(product: PurchasesService.Purchase) {
    SVProgressHUD.show()
    
    PurchasesService.shared.purchase(product: product) { error in
      SVProgressHUD.dismiss()
      if let error = error {
        Alert.show(message: error,
                   preferredStyle: .alert)
        return
      }
      
      switch product {
      case .removeWatermark:
        Analytics.shared.logEvent(name: "Purchase Watermark Removal", with: ["product": "watermark"])
        
        let subscription = Subscription()
        subscription.expirationDate = Date().addingTimeInterval(86400*86400)
        let realm = try! Realm()
        try! realm.write {
          realm.add(subscription)
        }
        
        if let c = self.cropView {
          c.cropView.gridOverlayView.removeStamp(true, removeButton: true)
        }
      }
    }
  }
  
  func purchasesRestored() {
    SVProgressHUD.dismiss()
    
    PurchasesService.shared.restorePurchases { status in
      switch status {
      case .notPurchased?:
        Analytics.shared.logEvent(name: "purchases_not_restored")
        Alert.show(message: "You don't have any purchases",
                   preferredStyle: .alert)
      default:
        Analytics.shared.logEvent(name: "purchases_restored")
        Alert.show(message: "You've successfully restored purchases",
                   preferredStyle: .alert)
      }
    }
  }
}

extension UIImage {
  func rotate(with angle: CGFloat) -> UIImage {
    let rotated: UIView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.size))
    let t: CGAffineTransform = CGAffineTransform(rotationAngle: angle * CGFloat.pi / 180.0)
    rotated.transform = t
    let rotatedSize: CGSize = rotated.frame.size
    
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    bitmap.rotate(by: angle * CGFloat.pi / 180.0)
    bitmap.scaleBy(x: 1.0, y: -1.0);
    
    bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                                          width: self.size.width, height: self.size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }
  
  func addWatermark(with watermark: UIImage) -> UIImage {
    let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
    UIGraphicsBeginImageContextWithOptions(self.size, true, 0)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(UIColor.white.cgColor)
    context?.fill(rect)
    
    self.draw(in: rect, blendMode: .normal, alpha: 1)
    let watermarkSize = CGSize(width: self.size.width * 19 / 100,
                               height: (self.size.width * 19 / 100) * (watermark.size.height / watermark.size.width))
    let watermarkOrigin = CGPoint(x: self.size.width - watermarkSize.width - 7,
                                  y: self.size.height - watermarkSize.height - 7)
    watermark.draw(in: CGRect(origin: watermarkOrigin, size: watermarkSize), blendMode: .normal, alpha: 1)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
}
