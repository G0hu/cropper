//
//  ViewController.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 07/03/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import EasyImagy
import TOCropViewController
import ALCameraViewController

class ViewController: UIViewController, TOCropViewControllerDelegate {

    var b: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        b = UIButton(frame: self.view.frame)
        b?.backgroundColor = UIColor.clear
        b?.addTarget(self, action: #selector(showCameraRoll), for: .touchUpInside)
        
        view.addSubview(b!)
        view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func showCameraRoll() {
        let cameraViewController = CameraViewController(croppingEnabled: false) { [weak self] image, asset in
            if let img = image {
                self?.dismiss(animated: true, completion: { self?.presentCropViewController(image: img) })
            } else {
                self?.dismiss(animated: true, completion: nil)
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
        print("image cropped")
        self.dismiss(animated: true, completion: nil)
    }
}

