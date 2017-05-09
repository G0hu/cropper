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
    var is_editing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
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
        if (!is_editing) {
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
        
        present(cameraViewController, animated: false, completion: nil)
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
            UIImageWriteToSavedPhotosAlbum(slice, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
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

