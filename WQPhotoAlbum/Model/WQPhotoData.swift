//
//  WQPhotoData.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/6.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import Photos

class WQPhotoData: NSObject {
    // 判断数据是否发生变化
    var dataChanged = false
    // 存储每个cell选择标记（false：未选中，true：选中)
    var divideArray = [Bool]() {
        didSet {
            self.dataChanged = true
        }
    }
    //  相册所有图片数据源
    var assetArray = [PHAsset]()
    //  已选图片数组，数据类型是 PHAsset
    var seletedAssetArray = [PHAsset]()
}
