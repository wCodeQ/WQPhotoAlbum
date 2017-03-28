# WQPhotoAlbum
* 语言：Swift3.0
* 系统：iOS 8及以上
* 依赖库：Photos.framework
## 接入说明
```objective-c
//直接跳转所有照片
let photoAlbumVC = WQPhotoAlbumViewController()
self.navigationController?.pushViewController(photoAlbumVC, animated: true)
//直接预览跳转，支持删除
let previewVC = WQPhotoPreviewViewController()
previewVC.currentIndex = currentIndex       //当前展示第几张
previewVC.previewPhotoArray = previewArray  //需要预览照片数组
previewVC.deleteClicked = { [unowned self] (selectPhotos: [PHAsset]) in
    //删除图片操作后闭包
}
self.navigationController?.pushViewController(previewVC, animated: true)
```
