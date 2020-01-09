//
//  UIAlbumsView.swift
//  Cropper
//
//  Created by Egor Kuznetsov on 08.01.2020.
//  Copyright © 2020 Hugo Polsinelli. All rights reserved.
//

import UIKit
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
    label.text = "pictures"
    label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
    label.textColor = UIColor.gray
    return label
  }()
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = .none
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
    button_cancel.translatesAutoresizingMaskIntoConstraints = false
    button_cancel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16).isActive = true
    button_cancel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
    button_cancel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
    button_cancel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    self.addSubview(view_albums)
    view_albums.translatesAutoresizingMaskIntoConstraints = false
    view_albums.heightAnchor.constraint(equalToConstant: 340).isActive = true
    view_albums.bottomAnchor.constraint(equalTo: button_cancel.topAnchor).isActive = true
    view_albums.leftAnchor.constraint(equalTo: button_cancel.leftAnchor).isActive = true
    view_albums.rightAnchor.constraint(equalTo: button_cancel.rightAnchor).isActive = true
    
    view_albums.addSubview(label_section)
    label_section.translatesAutoresizingMaskIntoConstraints = false
    label_section.topAnchor.constraint(equalTo: view_albums.topAnchor, constant: 14).isActive = true
    label_section.leftAnchor.constraint(equalTo: view_albums.leftAnchor, constant: 16).isActive = true
    
    view_albums.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: label_section.bottomAnchor, constant: 8).isActive = true
    tableView.leftAnchor.constraint(equalTo: view_albums.leftAnchor).isActive = true
    tableView.rightAnchor.constraint(equalTo: view_albums.rightAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view_albums.bottomAnchor).isActive = true
    
    tableView.register(AlbumCell.self,
                       forCellReuseIdentifier: "cell_album")
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
