# WQPhotoAlbum
* 语言：Swift3.0
* 系统：iOS 8及以上
* 依赖库：Photos.framework

![Platform](https://img.shields.io/badge/platforms-iOS-orange.svg)
![Languages](https://img.shields.io/badge/languages-Swift-orange.svg)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-59C939.svg?style=flat)](https://github.com/Carthage/Carthage)
### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) 是管理第三方framework动态库的工具.

安装方法： [Homebrew](http://brew.sh/) 打开终端输入以下命令：

```bash
$ brew update
$ brew install carthage
```

在工程主目录下创建`Cartfile`文件，然后输入：

```ogdl
github "wCodeQ/WQPhotoAlbum"
```

终端运行 `carthage` 编译出 `WQPhotoAlbumKit.framework` 导入到你的工程中。

## 功能说明
* 默认跳转所有相册列表，选择图片和预览。
* 返回列表为相册列表，点击取消dismiss
* 单独公开预览界面，支持删除
* 支持裁剪功能
## 接入说明
* 全局变量设置
```Swift
//主要按钮和选择图主色调，默认#0093FF色
WQPhotoAlbumSkinColor = UIColor.red
//导航条高度（不包含状态栏高度）默认44
WQNavigationHeight = 44
//是否打开调试打印信息，默认false
WQPhotoAlbumEnableDebugOn = true
```

* 直接跳转所有照片,默认是选择图片
```Swift
let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .selectPhoto)   //初始化需要设置代理对象
photoAlbumVC.maxSelectCount = 10    //最大可选择张数
self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)

//跳转裁剪图片选择列表
let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .clipPhoto)
photoAlbumVC.clipBounds = CGSize(width: self.view.frame.width, height: 400)     //裁剪框大小，不设置默认为屏幕宽度正方形
self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)

//跳转图片列表类型
public enum WQPhotoAlbumType {
    case selectPhoto, clipPhoto
}

//实现WQPhotoAlbumProtocol协议获取选择图片资源
@objc public protocol WQPhotoAlbumProtocol: NSObjectProtocol {
    //返回图片原资源，需要用PHCachingImageManager或者我封装的WQCachingImageManager进行解析处理
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotoAssets: [PHAsset]) -> Void

    //返回WQPhotoModel数组，其中包含选择的缩略图和预览图
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotos: [WQPhotoModel]) -> Void

    //返回裁剪后图片
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(clipPhoto: UIImage?) -> Void
}
```
* 直接预览跳转，支持删除
```Swift
//基于WQPhotoModel中的资源，如果有原图直接展示，否者先展示缩略图然后加载网络图，完成后再展示原图，已做掉缓存
let wqPhotoPreviewVC = WQPhotoPreviewDeleteViewController()
wqPhotoPreviewVC.previewPhotoArray = self.selectIamgeArr        //传入预览源，为WQPhotoModel数组，支持缩略图，原图和网络图
wqPhotoPreviewVC.currentIndex = currentIndex                    //当前展示第几张   
wqPhotoPreviewVC.isAllowDelete = true                           //设置是否支持删除，默认不支持，当设置了deleteClicked闭包时默认支持删除
wqPhotoPreviewVC.deleteClicked = { [unowned self] (photos: [WQPhotoModel], deleteModel: WQPhotoModel) in
    self.selectIamgeArr = photos
}
self.navigationController?.pushViewController(wqPhotoPreviewVC, animated: true)
```
* 可以根据PHAsset或者UIImage获取相应缩略图和预览图
```Swift
// WQCachingImageManager实例方法
// 获取缩略图
public func requestThumbnailImage(for asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID
// 获取预览图
public func requestPreviewImage(for asset: PHAsset, progressHandler: Photos.PHAssetImageProgressHandler?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID
// 根据原图获取缩略图和预览图
public func getThumbnailAndPreviewImage(originImage: UIImage) -> (thumbnailImage: UIImage?, previewImage: UIImage?)
```
