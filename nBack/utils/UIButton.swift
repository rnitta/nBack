//
//  UIButton.swift
//  nBack
//
//  Created by PT2051 on 2018/12/15.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit

extension UIButton {
    func dropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.3
    }
}
