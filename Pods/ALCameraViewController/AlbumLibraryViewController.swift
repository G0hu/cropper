//
//  AlbumLibraryViewController.swift
//  ALCameraViewController
//
//  Created by Egor Kuznetsov on 12.01.2020.
//

import UIKit
import Photos

class AlbumLibraryViewController: UIViewController {
  
  var croppingEnabled: Bool = false
  var completion: CameraViewCompletion!
  
  public var onSelectionComplete: PhotoLibraryViewSelectionComplete?
  
  var albums = [PHAssetCollection]()
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView.register(AlbumCell.self,
                       forCellReuseIdentifier: "cell_album")
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _ = PhotoLibraryAuthorizer { error in
      if error == nil {
        let fetchOptions = PHFetchOptions()
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions)
        cameraRoll.enumerateObjects { (collection, _, _) in
          if collection.photosCount > 0 {
            self.albums = [collection]
          }
        }
        
        let results = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        results.enumerateObjects { (collection, _, _) in
          if collection.photosCount > 0 {
            self.albums.append(collection)
          }
        }
        
        self.tableView.reloadData()
      } else {
        print("error is", error?.localizedDescription)
//        self.failure?(error!)
      }
    }
    
    setup()
    
    let buttonImage = UIImage(named: "libraryCancel", in: CameraGlobals.shared.bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: buttonImage,
                                                       style: UIBarButtonItem.Style.plain,
                                                       target: self,
                                                       action: #selector(dismissLibrary))
  }
  
  func setup() {
    self.view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
  }
  
  @objc func dismissLibrary() {
    onSelectionComplete?(nil)
  }
  
}

extension AlbumLibraryViewController: UITableViewDataSource {
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
    let collection = albums[indexPath.row]
    cell.configure(with: collection)
    return cell
  }
}

extension AlbumLibraryViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let imagePicker = PhotoLibraryViewController()
    imagePicker.onSelectionComplete = { [weak imagePicker] asset in
      if let asset = asset {
        self.onSelectionComplete?(asset)
      } else {
        self.onSelectionComplete?(nil)
      }
    }
    let album = albums[indexPath.row]
    imagePicker.chosenAlbum = album.localizedTitle
    self.navigationController?.pushViewController(imagePicker, animated: true)
  }
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}
