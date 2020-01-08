//
//  UIAlbumsView.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 08.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import UIKit
import SnapKit
import Photos

class UIAlbumsView: UIView {
  
  typealias CompleteClosure = (String) -> ()
  var onDidChosenAlbum: CompleteClosure?
  
  typealias CancelClosure = () -> ()
  var onDidTappedCancel: CancelClosure?
  
  var albums = PHFetchResult<PHAssetCollection>()
  
  private let button_cancel: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.backgroundColor = UIColor.white
    button.setTitle("Cancel", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    button.setTitleColor(UIColor.black, for: .normal)
    return button
  }()
  
  private let view_albums: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
    return view
  }()

  private let label_section: UILabel = {
    let label = UILabel()
    label.text = "Albums"
    label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
    label.textColor = UIColor.gray
    return label
  }()
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    return tableView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func setup() {
    self.addSubview(button_cancel)
    button_cancel.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.snp.bottom).offset(-16)
      make.left.equalTo(self.snp.left).offset(16)
      make.right.equalTo(self.snp.right).offset(-16)
      make.height.equalTo(50)
    }
    
    self.addSubview(view_albums)
    view_albums.snp.makeConstraints { (make) in
      make.height.equalTo(340)
      make.bottom.equalTo(button_cancel.snp.bottom)
      make.left.equalTo(button_cancel.snp.left)
      make.right.equalTo(button_cancel.snp.right)
    }
    
    view_albums.addSubview(label_section)
    label_section.snp.makeConstraints { (make) in
      make.top.equalTo(view_albums.snp.top).offset(14)
      make.left.equalTo(view_albums.snp.left).offset(16)
    }
    
    view_albums.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.register(AlbumCell.self,
                       forCellReuseIdentifier: "cell_album")
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(label_section.snp.bottom).offset(8)
      make.left.equalTo(view_albums.snp.left)
      make.right.equalTo(view_albums.snp.right)
      make.bottom.equalTo(view_albums.snp.bottom)
    }
  }
  
  @objc func button_cancel_tapped() {
    onDidTappedCancel?()
  }
  
}

extension UIAlbumsView: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return albums.count
  }
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "cell_album",
      for: indexPath
    ) as! AlbumCell
    let album = albums[indexPath.row]
    cell.configure(with: album)
    return cell
  }
}

extension UIAlbumsView: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    print("TAPPED")
    let album = albums[indexPath.row]
    onDidChosenAlbum?(album.localizedTitle ?? "Album")
  }
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62
  }
}
