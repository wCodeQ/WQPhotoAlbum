//
//  WQPhotoPreviewViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/2.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import Photos

class WQPhotoPreviewViewController: WQPhotoBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var currentIndex = 0
    //  数据源(预览选择时用)
    var photoData = WQPhotoData()
    //  浏览数据源
    var previewPhotoArray = [PHAsset]()
    //  完成闭包
    var sureClicked: ((_ view: UIView, _ selectPhotos: [PHAsset]) -> Void)?
    //  是否支持选择
    var isSelectPhoto = false
    //  删除闭包
    var deleteClicked: ((_ selectPhotos: [PHAsset]) -> Void)?
    
    private let cellIdentifier = "PreviewCollectionCell"
    
    private var scrollDistance: CGFloat = 0
    private var willDisplayCellAndIndex: (cell: WQPreviewCollectionViewCell, indexPath: IndexPath)?
    private var isFirstCell = true
    private var isDeleteCell = false
    
    private var requestIDs = [PHImageRequestID]()

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
    
    private lazy var bottomView = WQAlbumBottomView(type: .noPreview)

    deinit {
        print("=====================\(self)未内存泄露")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.photoData.assetArray.count != 0 {
            self.isSelectPhoto = true
        }
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.photoCollectionView)
        self.initNavigation()
        if self.isSelectPhoto {
            self.setBottomView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photoCollectionView.selectItem(at: IndexPath(item: self.currentIndex, section: 0), animated: false, scrollPosition: .left)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            for id in self.requestIDs {
                WQCachingImageManager.default().cancelImageRequest(id)
            }
        }
    }
    
    //  MARK:- private method
    private func initNavigation() {
        self.setBackNav()
        if self.isSelectPhoto {
            if let index = self.photoData.assetArray.index(of: self.previewPhotoArray[currentIndex]) {
                self.setRightImageButton(normalImageName: "album_select_gray.png", selectedImageName: "album_select_blue.png", isSelected: self.photoData.divideArray[index])
            }
        } else {
            self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
            self.setRightImageButton(normalImageName: "album_photo_delete.png", selectedImageName: "album_photo_delete.png", isSelected: false)
        }
        self.view.bringSubview(toFront: self.naviView)
    }
    
    private func setBottomView() {
//        self.bottomView.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        self.bottomView.sureClicked = { [unowned self] in
            if self.sureClicked != nil {
                self.sureClicked!(self.view, self.photoData.seletedAssetArray)
            }
        }
        self.view.addSubview(self.bottomView)
        self.completedButtonShow()
    }
    
    private func completedButtonShow() {
        if self.photoData.seletedAssetArray.count > 0 {
            self.bottomView.sureButtonTitle = "(\(self.photoData.seletedAssetArray.count))完成"
            self.bottomView.buttonIsEnabled = true
        } else {
            self.bottomView.sureButtonTitle = "完成"
            self.bottomView.buttonIsEnabled = false
        }
    }
    
    private func setPreviewImage(cell: WQPreviewCollectionViewCell, asset: PHAsset) {
        let pixelScale = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        let id = WQCachingImageManager.default().requestPreviewImage(for: asset, progressHandler: { (progress: Double, error: Error?, pointer: UnsafeMutablePointer<ObjCBool>, dictionry: Dictionary?) in
            //下载进度
            DispatchQueue.main.async {
                let progressView = WQProgressView.showWQProgressView(in: cell.contentView, frame: CGRect(x: cell.frame.width-20-12, y: cell.frame.midY+(cell.frame.width/pixelScale-20)/2-12, width: 20, height: 20))
                progressView.progress = progress
            }
        }, resultHandler: { (image: UIImage?, dictionry: Dictionary?) in
            var downloadFinined = true
            if let cancelled = dictionry![PHImageCancelledKey] as? Bool {
                downloadFinined = !cancelled
            }
            if downloadFinined, let error = dictionry![PHImageErrorKey] as? Bool {
                downloadFinined = !error
            }
            if downloadFinined, let resultIsDegraded = dictionry![PHImageResultIsDegradedKey] as? Bool {
                downloadFinined = !resultIsDegraded
            }
            if downloadFinined, let photoImage = image {
                cell.photoImage = photoImage
            }
        })
        self.requestIDs.append(id)
    }
    
    // handle events
    override func rightButtonClick(button: UIButton) {
        if self.isSelectPhoto {
            if let index = self.photoData.assetArray.index(of: self.previewPhotoArray[currentIndex]) {
                button.isSelected = !button.isSelected
                self.photoData.divideArray[index] = !self.photoData.divideArray[index]
                if self.photoData.divideArray[index] {
                    self.photoData.seletedAssetArray.append(self.previewPhotoArray[currentIndex])
                } else {
                    self.photoData.seletedAssetArray.remove(at: self.photoData.seletedAssetArray.index(of: self.previewPhotoArray[currentIndex])!)
                }
                self.completedButtonShow()
            }
        } else {
            let deleteAlert = UIAlertController(title: nil, message: "确定要删除此照片吗？", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancleAction)
            let deleteAction = UIAlertAction(title: "删除", style: .default, handler: { [unowned self] (alertAction) in
                self.isDeleteCell = true
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
    }
    
    // MARK:- delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.previewPhotoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WQPreviewCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let asset = self.previewPhotoArray[indexPath.row]
        
        let id = WQCachingImageManager.default().requestThumbnailImage(for: asset) { (image: UIImage?, dictionry: Dictionary?) in
            (cell as! WQPreviewCollectionViewCell).photoImage = image ?? UIImage()
        }
        self.requestIDs.append(id)
        
        self.willDisplayCellAndIndex = (cell as! WQPreviewCollectionViewCell, indexPath)
        if indexPath.row == self.currentIndex && self.isFirstCell {
            self.isFirstCell = false
            self.setPreviewImage(cell: cell as! WQPreviewCollectionViewCell, asset: asset)
        } else if self.isDeleteCell {
            self.isDeleteCell = false
            if self.currentIndex > self.previewPhotoArray.count-1 {
                self.currentIndex = self.previewPhotoArray.count-1
            }
            let asset = self.previewPhotoArray[self.currentIndex]
            self.setPreviewImage(cell: cell as! WQPreviewCollectionViewCell, asset: asset)
            self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
        }
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
        if self.isSelectPhoto {
            if let index = self.photoData.assetArray.index(of: self.previewPhotoArray[self.currentIndex]) {
                self.rightButton.isSelected = self.photoData.divideArray[index]
            }
        } else {
            self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != self.scrollDistance {
            let currentCell = self.photoCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! WQPreviewCollectionViewCell
            let asset = self.previewPhotoArray[self.currentIndex]
            self.setPreviewImage(cell: currentCell, asset: asset)
        }
    }

}
