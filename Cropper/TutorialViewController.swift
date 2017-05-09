//
//  TutorialViewController.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 09/05/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Onboard
import Foundation

func generateWalkThrough(rect: CGRect) -> OnboardingViewController {
    let page1 = CustomOBContentViewController(title: "", body: "Take a picture or choose\none for your library",
                                              image: #imageLiteral(resourceName: "icon-p1"), buttonText: "", action: nil)
    let page2 = CustomOBContentViewController(title: "", body: "Choose in how many pieces\nyou want to split\nthe picture",
                                                image: #imageLiteral(resourceName: "icon-p2"), buttonText: "", action: nil)
    let page3 = CustomOBContentViewController(title: "", body: "Adjust the cropping\nwindow... And you're done",
                                                image: #imageLiteral(resourceName: "icon-p3"), buttonText: "", action: nil)
    
    page1.topPadding = 135
    page1.frame = CGSize(width: 120, height: 91)
    
    page2.topPadding = 135
    page2.frame = CGSize(width: 215, height: 75)
    
    page3.topPadding = 135
    page3.frame = CGSize(width: 110, height: 110)
    
    let obvc = CustomOBViewController(backgroundImage: imageWithalpha(img: #imageLiteral(resourceName: "trees"), alpha: 0.0),
                                      contents: [page1, page2, page3])
    obvc?.shouldMaskBackground = false
    obvc?.allowSkipping = true
    return obvc!
}

func imageWithalpha(img: UIImage, alpha: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(img.size, false, 0.0)
    
    let ctx: CGContext  = UIGraphicsGetCurrentContext()!
    let area: CGRect = CGRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height)
    
    ctx.scaleBy(x: 1, y: -1)
    ctx.translateBy(x: 0, y: -area.size.height)
    ctx.setBlendMode(.multiply)
    
    ctx.setAlpha(alpha)
    ctx.draw(img.cgImage!, in: area)
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    return newImage;
}

class CustomOBViewController: OnboardingViewController {
    
    let startColor = UIColor(red: 54/255, green: 209/255, blue: 220/255, alpha: 1).cgColor
    
    let endColor = UIColor(red: 91/255, green: 134/255, blue: 229/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [startColor, endColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }
}

class CustomOBContentViewController: OnboardingContentViewController {
    
    var frame: CGSize = CGSize() {
        didSet {
            self.iconWidth = frame.width
            self.iconHeight = frame.height
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        bodyLabel.numberOfLines = 2
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
    }
}





