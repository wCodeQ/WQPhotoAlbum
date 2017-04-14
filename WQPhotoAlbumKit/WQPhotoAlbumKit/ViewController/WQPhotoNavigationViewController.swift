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
    //返回图片原资源，需要用PHCachingImageManager或者我封装的WQCachingImageManager进行解析处理
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotoAssets: [PHAsset]) -> Void
    
    // 返回WQPhotoModel数组，其中包含选择的缩略图和预览图
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotos: [WQPhotoModel]) -> Void
}

public class WQPhotoNavigationViewController: UINavigationController {
    
    // 最大选择张数
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
