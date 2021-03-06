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
    
    var images: Array<UIImage> = []
    let background: UIImage = #imageLiteral(resourceName: "trees")
    let newBackground = resizeImage(source: background, width: rect.width * 3)
    
    for i in 0...2 {
        let r = CGRect(x: rect.width * CGFloat(i), y: 0.0, width: rect.width, height: newBackground.size.height)
        let img: UIImage = newBackground.croppedImage(withFrame: r, angle: 0, circularClip: false)
        images.append(img)
    }
    
    let page1 = CustomOBContentViewController(body: "Take a picture or choose\none from your library...",
                                              image: #imageLiteral(resourceName: "icon-p1"), background: images[0])
    let page2 = CustomOBContentViewController(body: "Choose in how many pieces\nyou want to split...",
                                              image: #imageLiteral(resourceName: "icon-p2"), background: images[1])
    let page3 = CustomOBContentViewController(body: "Adjust the cropping\nwindow... And you're done!",
                                              image: #imageLiteral(resourceName: "icon-p3"), background: images[2])
    
    page1.icon_frame = CGSize(width: 120, height: 91)
    page2.icon_frame = CGSize(width: 215, height: 75)
    page3.icon_frame = CGSize(width: 110, height: 110)
    
    let obvc = CustomOBViewController(backgroundImage: UIImage(), contents: [page1, page2, page3])
    obvc?.shouldMaskBackground = false
    obvc?.allowSkipping = true
    obvc?.skipHandler = { obvc?.selfDismiss() }
    return obvc!
}

fileprivate func resizeImage(source: UIImage, width: CGFloat) -> UIImage {
    let oldWidth: CGFloat = source.size.width
    let scaleFactor: CGFloat = width / oldWidth
    let newHeight: CGFloat = source.size.height * scaleFactor
    
    let newWidth: CGFloat = oldWidth * scaleFactor
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight));
    source.draw(in: CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))
    
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}

class CustomOBViewController: OnboardingViewController {
    
    let startColor = UIColor(red: 138/255, green: 50/255, blue: 190/255, alpha: 1).cgColor
    
    let endColor = UIColor(red: 190/255, green: 90/255, blue: 90/255, alpha: 1).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [startColor, endColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    func selfDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

class CustomOBContentViewController: OnboardingContentViewController {
    
    var backgrnd: UIImageView?
    
    var icon_frame: CGSize = CGSize() {
        didSet {
            self.iconWidth = icon_frame.width
            self.iconHeight = icon_frame.height
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(title: String?, body: String?, image: UIImage?, buttonText: String?, action: (() -> Void)? = nil) {
        super.init(title: title, body: body, image: image, buttonText: buttonText, action: action)
    }
    
    override init(title: String?, body: String?, image: UIImage?, buttonText: String?, actionBlock: action_callback? = nil) {
        super.init(title: title, body: body, image: image, buttonText: buttonText, actionBlock: actionBlock)
    }
    
    override init(title: String?, body: String?, videoURL: URL?, buttonText: String?, action: (() -> Void)? = nil) {
        super.init(title: title, body: body, videoURL: videoURL, buttonText: buttonText, action: nil)
    }
    
    override init(title: String?, body: String?, image: UIImage?, videoURL: URL?, buttonText: String?,
                  actionBlock: action_callback? = nil) {
        super.init(title: title, body: body, image: image, videoURL: videoURL,
                   buttonText: buttonText, actionBlock: actionBlock)
    }
    
    init(body: String?, image: UIImage?, background: UIImage?) {
        super.init(title: "", body: body, image: image, buttonText: "", action: nil)
        backgrnd = UIImageView(image: background!)
        
        backgrnd?.alpha = 0.25
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        bodyLabel.numberOfLines = 2
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        
        view.insertSubview(backgrnd!, at: 0)
        backgrnd?.translatesAutoresizingMaskIntoConstraints = false
        backgrnd?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        backgrnd?.widthAnchor.constraint(equalToConstant: ((backgrnd?.image?.size.width)! * (backgrnd?.image?.scale)!))
            .isActive = true
        backgrnd?.heightAnchor.constraint(equalToConstant: ((backgrnd?.image?.size.height)! * (backgrnd?.image?.scale)!))
            .isActive = true
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: iconWidth).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: (backgrnd?.topAnchor)!, constant: -55).isActive = true
    }
}
