//
//  WQPhotoNavigationViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 2017/4/7.
//  Copyright © 2017年 qian.com. All rights reserved.
//

import UIKit
import Photos

@objc public protocol WQPhotoAlbumProtocol: NSObjectProtocol {
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotoAssets: [PHAsset]) -> Void
    
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotos: [WQPhotoModel]) -> Void
}

public class WQPhotoNavigationViewController: UINavigationController {
    
    public var maxSelectCount = 0 {
        didSet {
            self.photoAlbumVC.maxSelectCount = maxSelectCount
        }
    }
    
    private let photoAlbumVC = WQPhotoAlbumViewController()
    
    convenience init() {
        self.init(photoAlbumDelegate: nil)
    }
    
    public init(photoAlbumDelegate: WQPhotoAlbumProtocol?) {
        super.init(rootViewController: WQPhotoAlbumListViewController())
        self.isNavigationBarHidden = true
        photoAlbumVC.photoAlbumDelegate = photoAlbumDelegate
        self.pushViewController(photoAlbumVC, animated: false)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("=====================\(self)未内存泄露")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
