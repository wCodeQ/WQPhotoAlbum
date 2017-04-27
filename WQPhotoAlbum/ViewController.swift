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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func clipClick(_ sender: UIButton) {
        let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .clipPhoto)    //初始化需要设置代理对象
        photoAlbumVC.clipBounds = CGSize(width: self.view.frame.width, height: 400)
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    @IBAction func buttonClick(_ sender: UIButton) {
        let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .selectPhoto)    //初始化需要设置代理对象
        photoAlbumVC.maxSelectCount = 10    //最大可选择张数
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    
    func photoAlbum(selectPhotos: [UIImage]) {
        print(selectPhotos.count)
    }
    
    func photoAlbum(clipPhoto: UIImage?) {
        clipImage.image = clipPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

