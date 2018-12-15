//
//  UIImage.swift
//  nBack
//
//  Created by PT2051 on 2018/12/15.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit

extension UIImage {
    func tint(color: UIColor, resize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(resize, false, 0)
        color.setFill()
        let drawRect = CGRect(x: 0, y: 0, width: resize.width, height: resize.height)
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage ?? UIImage()
    }
}
