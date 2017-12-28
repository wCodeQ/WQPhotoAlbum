//
//  WQPhotoNavigationViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 2017/4/7.
//  Copyright © 2017年 qian.com. All rights reserved.
//

import UIKit
import Photos

/// 是否开启print信息打印
public var WQPhotoAlbumEnableDebugOn = false

/// 导航条高度（不包含状态栏高度）默认44
public var WQNavigationHeight: CGFloat = 44

/// 主题色
public var WQPhotoAlbumSkinColor = UIColor(red: 0, green: 147/255.0, blue: 1, alpha: 1) {
    didSet {
        WQSelectSkinImage = UIImage.wqCreateImageWithView(view: WQPhotoNavigationViewController.wqGetSelectView())!
    }
}
var WQSelectSkinImage: UIImage = UIImage.wqCreateImageWithView(view: WQPhotoNavigationViewController.wqGetSelectView())!

@objc public protocol WQPhotoAlbumProtocol: NSObjectProtocol {
    //返回图片原资源，需要用PHCachingImageManager或者我封装的WQCachingImageManager进行解析处理
    @available(iOS 8.0, *)
    /// 选择照片完成代理方法
    ///
    /// - Parameter selectPhotoAssets: 选择照片源
    /// - Returns: Void
    @objc optional func photoAlbum(selectPhotoAssets: [PHAsset]) -> Void
    
    //返回WQPhotoModel数组，其中包含选择的缩略图和预览图
    @available(iOS 8.0, *)
    /// 选择照片完成代理方法
    ///
    /// - Parameter selectPhotoAssets: 选择照片Model
    /// - Returns: Void
    @objc optional func photoAlbum(selectPhotos: [WQPhotoModel]) -> Void
    
    // 返回裁剪后图片
    @available(iOS 8.0, *)
    /// 裁剪照片回调代理方法
    ///
    /// - Parameter clipPhoto: 裁剪图
    /// - Returns: Void
    @objc optional func photoAlbum(clipPhoto: UIImage?) -> Void
}


/// 相册SDK类型枚举
///
/// - selectPhoto: 选择照片
/// - clipPhoto: 裁剪照片
public enum WQPhotoAlbumType {
    case selectPhoto, clipPhoto
}

public class WQPhotoNavigationViewController: UINavigationController {

    /// 最大选择张数
    public var maxSelectCount = 0 {
        didSet {
            self.photoAlbumVC.maxSelectCount = maxSelectCount
        }
    }

    /// 裁剪大小
    public var clipBounds: CGSize = CGSize(width: WQScreenWidth, height: WQScreenWidth) {
        didSet {
            self.photoAlbumVC.clipBounds = clipBounds
        }
    }
    
    private let photoAlbumVC = WQPhotoAlbumViewController()
    
    private convenience init() {
        self.init(photoAlbumDelegate: nil, photoAlbumType: .selectPhoto)
    }

    /// 接入SDK照片列表构造方法
    ///
    /// - Parameters:
    ///   - photoAlbumDelegate: 代理回调方法
    ///   - photoAlbumType: 相册类型
    public init(photoAlbumDelegate: WQPhotoAlbumProtocol?, photoAlbumType: WQPhotoAlbumType) {
        let photoAlbumListVC = WQPhotoAlbumListViewController()
        photoAlbumListVC.photoAlbumDelegate = photoAlbumDelegate
        photoAlbumListVC.type = photoAlbumType
        super.init(rootViewController: photoAlbumListVC)
        self.isNavigationBarHidden = true
        photoAlbumVC.photoAlbumDelegate = photoAlbumDelegate
        photoAlbumVC.type = photoAlbumType
        self.pushViewController(photoAlbumVC, animated: false)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if WQPhotoAlbumEnableDebugOn {
            print("=====================\(self)未内存泄露")
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    class func wqGetSelectView() -> UIView {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        view.backgroundColor = WQPhotoAlbumSkinColor
        view.image = UIImage.wqImageFromeBundle(named: "album_select_blue.png")
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        return view
    }
}
