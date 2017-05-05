//
//  WQExtension.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/6.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit

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
    class func imageFromeWQBundle(named: String) -> UIImage? {
        let pathName = "/Frameworks/WQPhotoAlbumKit.framework/\(named)"
        if let fullImagePath = Bundle.main.resourcePath?.appending(pathName) {
            return UIImage(contentsOfFile: fullImagePath)
        }
        return nil
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
        if url == nil {
            return
        }
        //设置默认图片
        if defaultImage != nil {
            self.image = defaultImage
        }
        
        if isCache {
            var data: Data? = WQCachingImageManager.readCacheFromUrl(url: url!)
            if data != nil {
                wqImage = UIImage(data: data!)
                self.image = wqImage
                if downloadSuccess != nil {
                    downloadSuccess!(wqImage)
                }
            }else{
                let dispath=DispatchQueue.global(qos: .utility)
                dispath.async(execute: { () -> Void in
                    do {
                        guard let imageURL = URL(string: url!) else {return}
                        data = try Data(contentsOf: imageURL)
                        if data != nil {
                            wqImage = UIImage(data: data!)
                            //写缓存
                            WQCachingImageManager.writeCacheToUrl(url: url!, data: data!)
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
            let dispath=DispatchQueue.global(qos: .utility)
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
