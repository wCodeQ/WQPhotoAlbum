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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func buttonClick(_ sender: UIButton) {
        let photoAlbumVC = WQPhotoNavigationViewController(photoAlbumDelegate: self)
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    
    func photoAlbum(selectPhotos: [UIImage]) {
        print(selectPhotos.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

