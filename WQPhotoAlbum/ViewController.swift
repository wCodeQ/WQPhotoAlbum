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
        var imageUrl = ["http://site.test.tf56.com/fastdfsWeb/dfs/group1/M00/03/F8/CgcN7Vj26fWAbmh8AAW9Qr9M7wI360.jpg",
            "http://site.test.tf56.com/fastdfsWeb/dfs/group1/M00/03/FA/CgcN7Fj26fSAWD7YAABjcoM6lB4696.jpg",
            "http://site.test.tf56.com/fastdfsWeb/dfs/group1/M00/04/13/CgcN7VkL6AeAfuhcABWqhv3Pwzc782.jpg"]
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
        WQPhotoAlbumSkinColor = UIColor.red
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

