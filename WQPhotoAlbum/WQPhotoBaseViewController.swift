//
//  WQPhotoBaseViewController.swift
//  WQPhotoAlbum
//
//  Created by 王前 on 16/11/29.
//  Copyright © 2016年 qian.com. All rights reserved.
//

import UIKit

public let WQScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let WQScreenHeight: CGFloat = UIScreen.main.bounds.size.height

class WQPhotoBaseViewController: UIViewController {

    let naviView = UIView(frame: CGRect(x: 0, y: 0, width: WQScreenWidth, height: 64))
    let rightImageButton = UIButton()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: WQScreenWidth/2-50, y: 20, width: 100, height: 44))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        self.setNavigationView()
    }
    
    fileprivate func setNavigationView() {
        naviView.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        self.view.addSubview(naviView)
        let backImage = UIImage(named: "icon_back_white.png")
        let backButton = UIButton(frame: CGRect(x: 0, y: 20, width: 50, height: 44))
        backButton.backgroundColor = UIColor.clear
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(backClick(button:)), for: .touchUpInside)
        naviView.addSubview(backButton)
    }
    
    func setNavTitle(title: String) {
        titleLabel.text = title
        if !titleLabel.isDescendant(of: naviView) {
            naviView.addSubview(titleLabel)
        }
    }

    func setRightImageButton(normalImageName: String, selectedImageName: String?, isSelected: Bool) {
        rightImageButton.frame = CGRect(x: WQScreenWidth-50, y: 20, width: 50, height: 44)
        rightImageButton.backgroundColor = UIColor.clear
        rightImageButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)
        rightImageButton.setImage(UIImage.init(named: normalImageName), for: .normal)
        if selectedImageName != nil {
            rightImageButton.setImage(UIImage.init(named: selectedImageName!), for: .selected)
        }
        rightImageButton.addTarget(self, action: #selector(rightButtonClick(button:)), for: .touchUpInside)
        rightImageButton.isSelected = isSelected
        naviView.addSubview(rightImageButton)
    }
    
    func backClick(button: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func rightButtonClick(button: UIButton) {
        
    }
    
}
