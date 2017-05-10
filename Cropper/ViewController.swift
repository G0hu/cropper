//
//  ViewController.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 07/03/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Photos

import TOCropViewController
import ALCameraViewController

class ViewController: UIViewController, TOCropViewControllerDelegate {

    let endViewController: EndViewController = EndViewController()
    let imageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "1-2 kopya"))
    var forceWalkthrough: Bool = true
    var is_editing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        imageView.frame = view.frame
        view.addSubview(imageView)
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
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "first_launch")
            
            self.present(generateWalkThrough(rect: view.frame), animated: false, completion: nil)
        } else if (!is_editing) {
            showCameraRoll()
        }
    }
    
    @objc private func showCameraRoll() {
        let cameraViewController = CameraViewController(croppingEnabled: false) { [weak self] image, asset in
            if let img = image {
                self?.is_editing = true
                self?.dismiss(animated: false, completion: { self?.presentCropViewController(image: img) })
            } else {
                self?.dismiss(animated: false, completion: { self?.showCameraRoll() })
            }
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    private func presentCropViewController(image: UIImage) {
        let cropViewController: TOCropViewController = TOCropViewController(image: image)
        cropViewController.cropView.aspectRatioLockEnabled = true
        cropViewController.delegate = self
        
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController,
                            didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        let horizontal = (cropRect.width / cropRect.height) > 1 ? true : false
        let pieces: CGFloat = round(horizontal ? (cropRect.width / cropRect.height) : (cropRect.height / cropRect.width))
        
        for i in 1...Int(pieces) {
            let (x, y) = horizontal ? (CGFloat(i - 1) * (image.size.width / pieces), 0) :
                (0 , CGFloat(i - 1) * (image.size.height / pieces))
            let (w, h) = horizontal ? (image.size.width / pieces, image.size.height) :
                (image.size.width, image.size.height / pieces)

            let rect = CGRect(x: x, y: y, width: w, height: h)
            let slice: UIImage = image.croppedImage(withFrame: rect, angle: angle, circularClip: false)
            
            let rotated = horizontal ? slice : slice.rotated(by: Measurement(value: 270, unit: .degrees))
            UIImageWriteToSavedPhotosAlbum(rotated!, self,
                                           #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        self.dismiss(animated: true, completion: {
            self.present(self.endViewController, animated: true, completion: nil)
            self.is_editing = false
        })
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        is_editing = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Your altered image has been saved to your photos.")
        }
    }
}

extension UIImage {
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}

