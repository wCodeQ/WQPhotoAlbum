//
//  ViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/11/29.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import WQPhotoAlbumKit

class ViewController: UIViewController, WQPhotoAlbumProtocol {

    @IBOutlet weak var clipImage: UIImageView!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.gray
    }
    
    @IBAction func clipClick(_ sender: UIButton) {
        let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .clipPhoto)    //初始化需要设置代理对象
//        photoAlbumVC.clipBounds = CGSize(width: self.view.frame.width, height: 400)
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    
    @IBAction func previewNetworkImage(_ sender: UIButton) {
        var imageModels = [WQPhotoModel]()
        var imageUrl = ["http://pic.ruiwen.com/allimg/1708/598c667c4a7e337671.jpg",
            "http://img.juimg.com/tuku/yulantu/120926/219049-12092612154377.jpg",
            "http://pic1.win4000.com/mobile/0/53718339417a9.jpg"]
        for i in 0 ..< 3 {
            let model = WQPhotoModel(thumbnailImage: nil, originImage: nil, imageURL: imageUrl[i])
            imageModels.append(model)
        }
        let wqPhotoPreviewVC = WQPhotoPreviewDeleteViewController()
        wqPhotoPreviewVC.previewPhotoArray = imageModels
        wqPhotoPreviewVC.currentIndex = 0
        self.navigationController?.pushViewController(wqPhotoPreviewVC, animated: true)
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
//        WQPhotoAlbumSkinColor = UIColor.red   //修改主题色
        let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .selectPhoto)    //初始化需要设置代理对象
        photoAlbumVC.maxSelectCount = 3    //最大可选择张数
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    
    func photoAlbum(selectPhotos: [WQPhotoModel]) {
        switch selectPhotos.count {
        case 1:
            imageOne.image = selectPhotos[0].thumbnailImage
        case 2:
            imageOne.image = selectPhotos[0].thumbnailImage
            imageTwo.image = selectPhotos[1].thumbnailImage
        case 3:
            imageOne.image = selectPhotos[0].thumbnailImage
            imageTwo.image = selectPhotos[1].thumbnailImage
            imageThree.image = selectPhotos[2].thumbnailImage
        default:
            break
        }
    }
    
    func photoAlbum(clipPhoto: UIImage?) {
        clipImage.image = clipPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

