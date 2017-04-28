//
//  WQCachingImageManager.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/6.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import Photos

public class WQCachingImageManager: PHCachingImageManager {
   
    public override class func `default`() -> WQCachingImageManager {
        return super.default() as! WQCachingImageManager
    }
    
    // 获取缩略图
    public func requestThumbnailImage(for asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
//        option.resizeMode = .fast
        let targetSize = self.getThumbnailSize(originSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
        return self.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option) { (image: UIImage?, dictionry: Dictionary?) in
            resultHandler(image, dictionry)
        }
    }
    
    // 获取预览图
    public func requestPreviewImage(for asset: PHAsset, progressHandler: Photos.PHAssetImageProgressHandler?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let option = PHImageRequestOptions()
//        option.version = .current
        option.resizeMode = .exact
//        option.deliveryMode = .fastFormat
        option.isNetworkAccessAllowed = true
        option.progressHandler = progressHandler
        
        let targetSize = self.getPriviewSize(originSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))

        return self.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: option) { (image: UIImage?, dictionry: Dictionary?) in
            resultHandler(image, dictionry)
        }
    }
    
    public func getThumbnailAndPreviewImage(originImage: UIImage) -> (thumbnailImage: UIImage?, previewImage: UIImage?) {

        let targetSize = self.getPriviewSize(originSize: originImage.size)
        
        UIGraphicsBeginImageContext(targetSize)
        originImage.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let previewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        let thumbnailSize = self.getThumbnailSize(originSize: originImage.size)
        UIGraphicsBeginImageContext(thumbnailSize)
        originImage.draw(in: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return (thumbnailImage: thumbnailImage, previewImage: previewImage)
    }
    
    private func getThumbnailSize(originSize: CGSize) -> CGSize {
        let thumbnailWidth: CGFloat = (WQScreenWidth - 5 * 5) / 4 * UIScreen.main.scale
        let pixelScale = CGFloat(originSize.width)/CGFloat(originSize.height)
        let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailWidth/pixelScale)
        
        return thumbnailSize
    }
    
    private func getPriviewSize(originSize: CGSize) -> CGSize {
        let width = originSize.width
        let height = originSize.height
        let pixelScale = CGFloat(width)/CGFloat(height)
        var targetSize = CGSize()
        if width <= 1280 && height <= 1280 {
            //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
            targetSize.width = CGFloat(width)
            targetSize.height = CGFloat(height)
        } else if width > 1280 && height > 1280 {
            //宽以及高均大于1280，但是图片宽高比例大于(小于)2时，则宽或者高取小(大)的等比压缩至1280
            if pixelScale > 2 {
                targetSize.width = 1280*pixelScale
                targetSize.height = 1280
            } else if pixelScale < 0.5 {
                targetSize.width = 1280
                targetSize.height = 1280/pixelScale
            } else if pixelScale > 1 {
                targetSize.width = 1280
                targetSize.height = 1280/pixelScale
            } else {
                targetSize.width = 1280*pixelScale
                targetSize.height = 1280
            }
        } else {
            //b,宽或者高大于1280，但是图片宽度高度比例小于或等于2，则将图片宽或者高取大的等比压缩至1280
            if pixelScale <= 2 && pixelScale > 1 {
                targetSize.width = 1280
                targetSize.height = 1280/pixelScale
            } else if pixelScale > 0.5 && pixelScale <= 1 {
                targetSize.width = 1280*pixelScale
                targetSize.height = 1280
            } else {
                targetSize.width = CGFloat(width)
                targetSize.height = CGFloat(height)
            }
        }
        return targetSize
    }
    
    // UIImageView Cache
    class func readCacheFromUrl(url: String) -> Data? {
        var data: Data?
        let path: String = WQCachingImageManager.getFullCachePathFromUrl(url: url)
        if FileManager.default.fileExists(atPath: path) {
            do { data = try Data(contentsOf: URL(fileURLWithPath: path)) }
            catch { print("读取缓存图片失败！") }
        }
        return data
    }
    
    class func writeCacheToUrl(url: String, data: Data) {
        let path: String = WQCachingImageManager.getFullCachePathFromUrl(url: url)
        do { try data.write(to: URL(fileURLWithPath: path), options: .atomic) }
        catch { print("写入缓存图片失败！") }
    }
    //设置缓存路径
    class func getFullCachePathFromUrl(url: String) -> String {
        var chchePath = NSHomeDirectory().appending("/Library/Caches/MyCache")
        let fileManager: FileManager = FileManager.default
        fileManager.fileExists(atPath: chchePath)
        if !(fileManager.fileExists(atPath: chchePath)) {
            do { try fileManager.createDirectory(atPath: chchePath, withIntermediateDirectories: true, attributes: nil) }
            catch { print("创建目录失败！") }
        }
        //进行字符串处理
        var newURL: String
        newURL = WQCachingImageManager.stringToString(str: url)
        chchePath = chchePath.appending("/\(newURL)")
        return chchePath
    }
    //删除缓存
    class func removeAllCache(){
        let chchePath = NSHomeDirectory().appending("/Library/Caches/MyCache")
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: chchePath) {
            do { try fileManager.removeItem(atPath: chchePath) }
            catch { print("清楚缓存失败！") }
        }
        
    }
    class func stringToString(str: String) -> String {
        var newStr: String = String()
        for i in 0 ..< str.characters.count {
            let c = str.cString(using: .utf8)![i]
            if (c>=48&&c<=57)||(c>=65&&c<=90)||(c>=97&&c<=122){
                newStr.append("\(c)")
            }
        }
        return newStr
        
    }
}
