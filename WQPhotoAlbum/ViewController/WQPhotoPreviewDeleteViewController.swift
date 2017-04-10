//
//  WQPhotoPreviewDeleteViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 2017/4/10.
//  Copyright © 2017年 qian.com. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

class WQPhotoPreviewDeleteViewController: WQPhotoBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var currentIndex = 0
    //  浏览数据源
    var previewPhotoArray: [WQPhotoModel] = []
    //  删除闭包
    var deleteClicked: ((_ photos: [WQPhotoModel]) -> Void)?
        
    private let cellIdentifier = "PreviewCollectionCell"
    
    private var scrollDistance: CGFloat = 0
    
    private lazy var photoCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: WQScreenWidth+10, height: WQScreenHeight)
        flowLayout.scrollDirection = .horizontal
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: WQScreenWidth+10, height: WQScreenHeight), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        collectionView.register(WQPreviewCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        return collectionView
    }()
    
    deinit {
        print("=====================\(self)未内存泄露")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.photoCollectionView)
        self.initNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photoCollectionView.selectItem(at: IndexPath(item: self.currentIndex, section: 0), animated: false, scrollPosition: .left)
        self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            
        }
    }
    
    //  MARK:- private method
    private func initNavigation() {
        self.setBackNav()
        self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
        self.setRightImageButton(normalImageName: "album_photo_delete.png", selectedImageName: "album_photo_delete.png", isSelected: false)
        self.view.bringSubview(toFront: self.naviView)
    }
    
    // handle events
    override func rightButtonClick(button: UIButton) {
            let deleteAlert = UIAlertController(title: nil, message: "确定要删除此照片吗？", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancleAction)
            let deleteAction = UIAlertAction(title: "删除", style: .default, handler: { [unowned self] (alertAction) in
                self.previewPhotoArray.remove(at: self.currentIndex)
                self.photoCollectionView.deleteItems(at: [IndexPath(item: self.currentIndex, section: 0)])
                if self.deleteClicked != nil {
                    self.deleteClicked!(self.previewPhotoArray)
                }
                if self.previewPhotoArray.count == 0 {
                    self.navigationController!.popViewController(animated: true)
                }
            })
            deleteAlert.addAction(deleteAction)
            self.navigationController?.present(deleteAlert, animated: true, completion: nil)
    }
    
    // MARK:- delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.previewPhotoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WQPreviewCollectionViewCell
        let photoTuple: WQPhotoModel = self.previewPhotoArray[indexPath.row]
        if let originImage = photoTuple.originImage {
            cell.photoImage = originImage
        } else if let imageURL = photoTuple.imageURL {
            var pixelScale:CGFloat = 1
            if let thumbnailImage = photoTuple.thumbnailImage {
                pixelScale = CGFloat(thumbnailImage.size.width)/CGFloat(thumbnailImage.size.height)
            }
            cell.photoImageView.kf.setImage(with: URL(string: imageURL), placeholder: photoTuple.thumbnailImage, options: .none, progressBlock: { (downloadSize, totalSize) in
                let progressView = WQProgressView.showWQProgressView(in: cell.contentView, frame: CGRect(x: cell.frame.width-20-12, y: cell.frame.midY+(cell.frame.width/pixelScale-20)/2-12, width: 20, height: 20))
                progressView.progress = Double(downloadSize/totalSize)
            }, completionHandler: { (image, error, cacheType, imageURL) in
                
            })
        } else {
            cell.photoImage = photoTuple.thumbnailImage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! WQPreviewCollectionViewCell).defaultScale = 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDistance = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndex = Int(round(scrollView.contentOffset.x/scrollView.bounds.width))
        if self.currentIndex >= self.previewPhotoArray.count {
            self.currentIndex = self.previewPhotoArray.count-1
        } else if self.currentIndex < 0 {
            self.currentIndex = 0
        }
        self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
    }
}
