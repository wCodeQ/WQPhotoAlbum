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
    lazy var rightButton: UIButton = {
        let rightButton = UIButton()
        rightButton.frame = CGRect(x: WQScreenWidth-50, y: 20, width: 50, height: 44)
        rightButton.backgroundColor = UIColor.clear
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightButton.addTarget(self, action: #selector(rightButtonClick(button:)), for: .touchUpInside)
        return rightButton
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: WQScreenWidth/2-50, y: 20, width: 100, height: 44))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 17)
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
    }
    
    func setBackNav() {
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
    
    func setRightTextButton(text: String, color: UIColor) {
        rightButton.setTitle(text, for: .normal)
        rightButton.setTitleColor(color, for: .normal)
        naviView.addSubview(rightButton)
    }

    func setRightImageButton(normalImageName: String, selectedImageName: String?, isSelected: Bool) {
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)
        rightButton.setImage(UIImage.init(named: normalImageName), for: .normal)
        if selectedImageName != nil {
            rightButton.setImage(UIImage.init(named: selectedImageName!), for: .selected)
        }
        rightButton.isSelected = isSelected
        naviView.addSubview(rightButton)
    }
    
    func backClick(button: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func rightButtonClick(button: UIButton) {
        
    }
    
}
