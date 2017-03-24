//
//  WQPhotoAlbumViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/11/29.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit
import Photos

class WQPhotoAlbumViewController: WQPhotoBaseViewController, PHPhotoLibraryChangeObserver, UICollectionViewDelegate, UICollectionViewDataSource {

    // 完成闭包
    var sureClicked: ((_ selectPhotos: [PHAsset]) -> Void)?
    
    private let cellIdentifier = "PhotoCollectionCell"
    private lazy var photoCollectionView: UICollectionView = {
        // 竖屏时每行显示4张图片
        let shape: CGFloat = 5
        let cellWidth: CGFloat = (WQScreenWidth - 5 * shape) / 4
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(64, shape, 0, shape)
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = shape
        flowLayout.minimumInteritemSpacing = shape
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: WQScreenWidth, height: WQScreenHeight - 44), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
//        collectionView.clipsToBounds = false
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        collectionView.register(WQPhotoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        return collectionView
    }()
    
    private var bottomView = WQAlbumBottomView()
    
    //  数据源
    private var photoData = WQPhotoData()
    
    deinit {
        print("=====================\(self)未内存泄露")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.photoCollectionView)
        self.initNavigation()
        self.setBottomView()
        self.getAllPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        if self.photoData.dataChanged {
            self.photoCollectionView.reloadData()
            self.completedButtonShow()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.photoData.dataChanged = false
    }
    
    //  MARK:- private method
    private func initNavigation() {
        self.setNavTitle(title: "所有图片")
        self.view.bringSubview(toFront: self.naviView)
    }
    
    private func setBottomView() {
        self.bottomView.previewClicked = { [unowned self] in
            self.gotoPreviewViewController(previewArray: self.photoData.seletedAssetArray, currentIndex: 0)
        }
        self.bottomView.sureClicked = { [unowned self] in
            if self.sureClicked != nil {
                self.sureClicked!(self.photoData.seletedAssetArray)
            }
            self.navigationController!.popViewController(animated: true)
        }
        self.view.addSubview(self.bottomView)
    }
    
    private func getAllPhotos() {
        //  注意点！！-这里必须注册通知，不然第一次运行程序时获取不到图片，以后运行会正常显示。体验方式：每次运行项目时修改一下 Bundle Identifier，就可以看到效果。
        PHPhotoLibrary.shared().register(self)
        //  获取所有系统图片信息集合体
        let allOptions = PHFetchOptions()
        //  对内部元素排序，按照时间由远到近排序
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        //  将元素集合拆解开，此时 allResults 内部是一个个的PHAsset单元
        let fetchAssets = PHAsset.fetchAssets(with: allOptions)
        self.photoData.assetArray = fetchAssets.objects(at: IndexSet.init(integersIn: 0..<fetchAssets.count))
        
        self.photoData.divideArray = Array(repeating: false, count: self.photoData.assetArray.count)
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
    
    // MARK:- handle events
    private func gotoPreviewViewController(previewArray: [PHAsset], currentIndex: Int) {
        let previewVC = WQPhotoPreviewViewController()
        previewVC.currentIndex = currentIndex
        previewVC.photoData = self.photoData
        previewVC.previewPhotoArray = previewArray
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    // MARK:- delegate
    //  PHPhotoLibraryChangeObserver  第一次获取相册信息，这个方法只会进入一次
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        getAllPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoData.assetArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WQPhotoCollectionViewCell
        let asset = self.photoData.assetArray[indexPath.row]
        _ = WQCachingImageManager.default().requestThumbnailImage(for: asset) { (image: UIImage?, dictionry: Dictionary?) in
            cell.photoImage = image ?? UIImage()
        }
        cell.isChoose = self.photoData.divideArray[indexPath.row]
        cell.selectPhotoCompleted = { [unowned self] in
            self.photoData.divideArray[indexPath.row] = !self.photoData.divideArray[indexPath.row]
            if self.photoData.divideArray[indexPath.row] {
                self.photoData.seletedAssetArray.append(self.photoData.assetArray[indexPath.row])
            } else {
                self.photoData.seletedAssetArray.remove(at: self.photoData.seletedAssetArray.index(of: self.photoData.assetArray[indexPath.row])!)
            }
            self.completedButtonShow()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.gotoPreviewViewController(previewArray: self.photoData.assetArray, currentIndex: indexPath.row)
    }
}

// 相册底部view
class WQAlbumBottomView: UIView {
    
    private lazy var previewButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 12, y: 12, width: 60, height: 20))
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .left
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.setTitleColor(UIColor.green, for: .normal)
        button.addTarget(self, action: #selector(previewClick(button:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var sureButton: UIButton = {
        let button = UIButton(frame: CGRect(x: WQScreenWidth-12-80, y: 12, width: 80, height: 20))
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .right
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.setTitleColor(UIColor.green, for: .normal)
        button.addTarget(self, action: #selector(sureClick(button:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    var previewButtonTitle: String? {
        didSet {
            self.previewButton.setTitle(previewButtonTitle, for: .normal)
        }
    }
    
    var sureButtonTitle: String? {
        didSet {
            self.sureButton.setTitle(sureButtonTitle, for: .normal)
        }
    }
    
    var buttonIsEnabled = false {
        didSet {
            self.previewButton.isEnabled = buttonIsEnabled
            self.sureButton.isEnabled = buttonIsEnabled
        }
    }
    
    // 预览闭包
    var previewClicked: ((Void) -> Void)?
    
    // 完成闭包
    var sureClicked: ((Void) -> Void)?
    
    enum WQAlbumBottomViewType {
        case normal, noPreview
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: WQScreenHeight-44, width: WQScreenWidth, height: 44), type: .normal)
    }
    
    convenience init(type: WQAlbumBottomViewType) {
        self.init(frame: CGRect(x: 0, y: WQScreenHeight-44, width: WQScreenWidth, height: 44), type: type)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, type: .normal)
    }
    
    init(frame: CGRect, type: WQAlbumBottomViewType) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        if type == .normal {
            self.addSubview(self.previewButton)
        }
        
        self.addSubview(self.sureButton)
        let cutLine = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5))
        cutLine.backgroundColor = UIColor.black
        self.addSubview(cutLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: handle events
    func previewClick(button: UIButton) {
        if previewClicked != nil {
            previewClicked!()
        }
    }
    
    func sureClick(button: UIButton) {
        if sureClicked != nil {
            sureClicked!()
        }
    }
}
