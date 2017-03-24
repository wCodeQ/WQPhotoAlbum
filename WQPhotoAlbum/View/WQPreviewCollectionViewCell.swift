//
//  WQPreviewCollectionViewCell.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/12/5.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit

class WQPreviewCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        var frame = self.contentView.bounds
        frame.size.width -= 10
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap(doubleTapGestureRecognizer:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
        return imageView
    }()
    
    private lazy var photoImageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        var frame = self.contentView.bounds
        frame.size.width -= 10
        scrollView.frame = frame
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        scrollView.maximumZoomScale = self._maxScale
        scrollView.minimumZoomScale = self._minScale
//        scrollView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleHeight]
        return scrollView
    }()
    
    private var currentScale: CGFloat = 1
    private let _maxScale: CGFloat = 2
    private let _minScale: CGFloat = 1
    
    // 图片设置
    var photoImage: UIImage? {
        didSet {
            self.photoImageView.image = photoImage
        }
    }
    
    // 初始缩放大小
    var defaultScale: CGFloat = 1 {
        didSet {
            self.photoImageScrollView.setZoomScale(defaultScale, animated: false)
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.init())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.photoImageScrollView.addSubview(self.photoImageView)
        self.contentView.addSubview(self.photoImageScrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 双击手势
    func doubleTap(doubleTapGestureRecognizer: UITapGestureRecognizer) {
        //当前倍数等于最大放大倍数
        //双击默认为缩小到原图
        let aveScale = _minScale + (_maxScale - _minScale) / 2.0 //中间倍数
        if currentScale >= aveScale {
            currentScale = _minScale
            self.photoImageScrollView.setZoomScale(currentScale, animated: true)
        } else if currentScale < aveScale {
            currentScale = _maxScale
            let touchPoint = doubleTapGestureRecognizer.location(in: self)
            self.photoImageScrollView.zoom(to: CGRect(x: touchPoint.x ,y:touchPoint.y ,width: 10 ,height:10), animated: true)
        }
        
    }
    
    //MARK: -UIScrollView delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.currentScale = scale
    }
}
