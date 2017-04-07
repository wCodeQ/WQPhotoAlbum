//
//  WQCachingImageManager.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/6.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import Photos

class WQCachingImageManager: PHCachingImageManager {
   
    open override class func `default`() -> WQCachingImageManager {
        return super.default() as! WQCachingImageManager
    }
    
    open func requestThumbnailImage(for asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
//        option.resizeMode = .fast
        let cellWidth: CGFloat = (WQScreenWidth - 5 * 5) / 4 * UIScreen.main.scale
        let pixelScale = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        return self.requestImage(for: asset, targetSize: CGSize(width: cellWidth, height: cellWidth/pixelScale), contentMode: .aspectFit, options: option) { (image: UIImage?, dictionry: Dictionary?) in
            resultHandler(image, dictionry)
        }
    }
    
    open func requestPreviewImage(for asset: PHAsset, progressHandler: Photos.PHAssetImageProgressHandler?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
//        option.version = .current
//        option.resizeMode = .exact
//        option.deliveryMode = .fastFormat
        option.isNetworkAccessAllowed = true
        option.progressHandler = progressHandler
        let screenRect = UIScreen.main.bounds
        let scaleScreen = UIScreen.main.scale
        let pixelScale = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        var targetSize = CGSize(width: screenRect.width*scaleScreen, height: screenRect.height*scaleScreen)
        let minWidth = targetSize.width > CGFloat(asset.pixelWidth) ? CGFloat(asset.pixelWidth) : targetSize.width
        let minHeight = targetSize.height > CGFloat(asset.pixelHeight) ? CGFloat(asset.pixelHeight) : targetSize.height
        if minWidth > minHeight {
            targetSize.width = minHeight*pixelScale*2
            targetSize.height = minHeight*2
        } else {
            targetSize.width = minWidth*2
            targetSize.height = minWidth/pixelScale*2
        }
        return self.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option) { (image: UIImage?, dictionry: Dictionary?) in
            resultHandler(image, dictionry)
        }
    }
}
