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

    var is_editing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!is_editing) {
            view.backgroundColor = UIColor.white
            showCameraRoll()
        } else {
            view.backgroundColor = UIColor.black
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        is_editing = false
        let horizontal = (cropRect.width / cropRect.height) > 1 ? true : false
        let pieces: CGFloat = round(horizontal ? (cropRect.width / cropRect.height) : (cropRect.height / cropRect.width))
        print("Scale: %d", image.scale)
        
        if (horizontal) {
            for i in 1...Int(pieces) {
                
                guard let cgImage = image.cgImage?.copy()
                else { return }
                
                let cpy: UIImage = UIImage(cgImage: cgImage,
                                       scale: image.scale,
                                       orientation: image.imageOrientation)
                
                let x: CGFloat = CGFloat(i - 1) * (image.size.width / pieces)
                let rect = CGRect(x: x, y: 0, width: image.size.width / pieces, height: image.size.height)
                let slice: UIImage = cpy.croppedImage(withFrame: rect, angle: angle, circularClip: false)
                
                UIImageWriteToSavedPhotosAlbum(slice, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } else {
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print(error.localizedDescription)
        } else {
            print("Your altered image has been saved to your photos.")
        }
    }
}

