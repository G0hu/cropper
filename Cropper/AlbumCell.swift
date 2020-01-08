//
//  AlbumCell.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 08.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import UIKit
import Photos

class AlbumCell: UITableViewCell {
  
  private let imageView_thumbnail: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = UIColor(hex: "FFEBEB")
    return imageView
  }()
  
  private let label_title: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
    return label
  }()
  
  private let label_count: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textColor = UIColor.gray
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func configure(with album: PHAssetCollection) {
    label_title.text = album.localizedTitle
    label_count.text = "\(album.estimatedAssetCount) albums"
    
    retrieveThumbnail(for: album)
  }
  
  func setup() {
    self.addSubview(imageView_thumbnail)
    imageView_thumbnail.snp.makeConstraints { (make) in
      make.top.equalTo(self.snp.top).offset(6)
      make.left.equalTo(self.snp.left).offset(16)
      make.width.equalTo(50)
      make.height.equalTo(50)
    }

    let stackView = UIStackView(arrangedSubviews: [label_title, label_count])
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.alignment = .leading
    stackView.distribution = .equalSpacing
    self.addSubview(stackView)
    
    stackView.snp.makeConstraints { (make) in
      make.centerY.equalTo(imageView_thumbnail.snp.centerY)
      make.left.equalTo(imageView_thumbnail.snp.right).offset(10)
    }
  }
  
  func retrieveThumbnail(for album: PHAssetCollection) {
    let fetchOptions = PHFetchOptions()
    let descriptor = NSSortDescriptor(key: "creationDate", ascending: true)
    fetchOptions.sortDescriptors = [descriptor]
    
    let fetchResult = PHAsset.fetchKeyAssets(in: album, options: fetchOptions)
    
    guard let asset = fetchResult?.firstObject else {
      return
    }
    
    let options = PHImageRequestOptions()
    options.resizeMode = .exact
    
    let scale = UIScreen.main.scale
    let dimension = CGFloat(78.0)
    let size = CGSize(width: dimension * scale, height: dimension * scale)
    
    
    PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, info) in
      DispatchQueue.main.async {
        self.imageView_thumbnail.image = image
      }
    }
  }
  
}
