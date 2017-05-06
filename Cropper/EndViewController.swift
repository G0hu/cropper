//
//  EndViewController.swift
//  Cropper
//
//  Created by Hugo Polsinelli on 06/05/2017.
//  Copyright © 2017 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Foundation

class ResizableButton: UIButton {
    override var intrinsicContentSize: CGSize {
        get {
            let labelSize = titleLabel?.sizeThatFits(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? CGSize.zero
            let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right + 20, height: 60)
            
            return desiredButtonSize
        }
    }
}

class EndViewController: UIViewController {
    
    let startColor = UIColor(red: 91/255, green: 134/255, blue: 229/255, alpha: 1).cgColor
    
    let endColor = UIColor(red: 54/255, green: 209/255, blue: 220/255, alpha: 1).cgColor
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let button: ResizableButton = {
        let b: ResizableButton = ResizableButton()
        b.backgroundColor = UIColor.white
        
        b.setTitleColor(UIColor.gray, for: .normal)
        b.setTitle("Unsquare again", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: b.intrinsicContentSize)
        
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        return b
    }()
    
    let icon: UIImageView = {
        let img: UIImageView = UIImageView(image: #imageLiteral(resourceName: "end-screen-tick"))
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()
    
    let imgSavedLabel: UILabel = {
        let l: UILabel = UILabel()
        l.text = "Your pictures have been saved\n to your library"
        l.font = UIFont.boldSystemFont(ofSize: 18)
        l.textColor = UIColor.white
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        button.frame = self.view.frame
        button.addTarget(self, action: #selector(onTouchButton), for: .touchUpInside)
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [startColor, endColor]
        
        self.view.addSubview(icon)
        self.view.addSubview(button)
        self.view.addSubview(imgSavedLabel)
        self.view.layer.insertSublayer(gradient, at: 0)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 150)
        icon.heightAnchor.constraint(equalToConstant: 100)
        icon.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -150).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -150).isActive = true
        
        imgSavedLabel.translatesAutoresizingMaskIntoConstraints = false
        imgSavedLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        imgSavedLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -30).isActive = true
        imgSavedLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width - 60).isActive = true
    }
    
    func onTouchButton() {
        self.dismiss(animated: true, completion: nil)
    }
}