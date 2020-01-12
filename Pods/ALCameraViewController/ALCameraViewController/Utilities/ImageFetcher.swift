//
//  ALImageFetchingInteractor.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public typealias ImageFetcherSuccess = (PHFetchResult<PHAsset>) -> ()
public typealias ImageFetcherFailure = (NSError) -> ()

//extension PHFetchResult: Sequence {
//    public func makeIterator() -> NSFastEnumerationIterator {
//        return NSFastEnumerationIterator(self)
//    }
//}

public class ImageFetcher {
  
  private var success: ImageFetcherSuccess?
  private var failure: ImageFetcherFailure?
  
  private var album: String?
  
  private var authRequested = false
  private let errorDomain = "com.zero.imageFetcher"
  
  let libraryQueue = DispatchQueue(label: "com.zero.ALCameraViewController.LibraryQueue");
  
  public init(album: String?) {
    self.album = album
  }
  
  public func onSuccess(_ success: @escaping ImageFetcherSuccess) -> Self {
    self.success = success
    return self
  }
  
  public func onFailure(_ failure: @escaping ImageFetcherFailure) -> Self {
    self.failure = failure
    return self
  }
  
  public func fetch() -> Self {
    _ = PhotoLibraryAuthorizer { error in
      if error == nil {
        self.onAuthorized()
      } else {
        self.failure?(error!)
      }
    }
    return self
  }
  
  private func onAuthorized() {
    let options = PHFetchOptions()
    
    print("STARTED FETCHING", Date())
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    libraryQueue.async {
      print("JOINED ASYNC", Date())
      if let album = self.album {
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        for k in 0 ..< collection.count {
          print("LOOKING FOR ALBUM", Date())
          let obj:AnyObject! = collection.object(at: k)
          if obj.title == album {
            print("FOUND ALBUM", Date())
            if let assCollection = obj as? PHAssetCollection {
              print("RETURNED COLLECTION", Date())
              let results = PHAsset.fetchAssets(in: assCollection, options: options)
              self.success?(results)
              return
            }
          }
        }
      }
      
      let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
      DispatchQueue.main.async {
        self.success?(assets)
      }
    }
  }
}
