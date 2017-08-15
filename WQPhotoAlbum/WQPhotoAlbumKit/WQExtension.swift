//
//  WQExtension.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/6.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import Security

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, handle:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        handle()
    }
}

extension UIImage {
    class func wqImageFromeBundle(named: String) -> UIImage? {
        let pathName = "/Frameworks/WQPhotoAlbumKit.framework/\(named)"
        if let fullImagePath = Bundle.main.resourcePath?.appending(pathName) {
            return UIImage(contentsOfFile: fullImagePath)
        }
        return nil
    }

    class func wqCreateImageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    class func wqCreateImageWithView(view: UIView) -> UIImage? {
        let size = view.bounds.size;
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数。
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImageView {
    /**
     *设置web图片
     *url:图片路径
     *defaultImage:默认缺省图片
     *isCache：是否进行缓存的读取
     */
    func setWebImage(url:String?, defaultImage:UIImage?, isCache:Bool, downloadSuccess: ((_ image: UIImage?) -> Void)?) {
        var wqImage:UIImage?
        guard url != nil else {return}
        //设置默认图片
        if defaultImage != nil {
            self.image = defaultImage
        }
        
        if isCache {
            var data: Data? = WQCachingImageManager.default().readCacheFromUrl(url: url!)
            if data != nil {
                wqImage = UIImage(data: data!)
                self.image = wqImage
                if downloadSuccess != nil {
                    downloadSuccess!(wqImage)
                }
            }else{
                let dispath = DispatchQueue.global(qos: .utility)
                dispath.async(execute: { () -> Void in
                    do {
                        guard let imageURL = URL(string: url!) else {return}
                        data = try Data(contentsOf: imageURL)
                        if data != nil {
                            wqImage = UIImage(data: data!)
                            //写缓存
                            WQCachingImageManager.default().writeCacheToUrl(url: url!, data: data!)
                            DispatchQueue.main.async(execute: { () -> Void in
                                //刷新主UI
                                self.image = wqImage
                                if downloadSuccess != nil {
                                    downloadSuccess!(wqImage)
                                }
                            })
                        }
                    }
                    catch { print("下载图片失败")}
                })
            }
        }else{
            let dispath = DispatchQueue.global(qos: .utility)
            dispath.async(execute: { () -> Void in
                do {
                    guard let imageURL = URL(string: url!) else {return}
                    let data = try Data(contentsOf: imageURL)
                    wqImage = UIImage(data: data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        //刷新主UI
                        self.image = wqImage
                        if downloadSuccess != nil {
                            downloadSuccess!(wqImage)
                        }
                    })
                }
                catch {print("下载图片失败")}
            })
        }
    }
}
