//
//  closeButtonProtocol.swift
//  nBack
//
//  Created by PT2051 on 2018/12/31.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVGKit

//protocol CloseButtonProtocol {
//    var disposeBag: DisposeBag {get}
//    var closeButton: UIButton {get set}
//    func setupCloseButton()
//}
//
//extension CloseButtonProtocol{
//    func setupCloseButton() {
//        closeButton.backgroundColor = UIColor.clear
//        
//        // SVGKImage?.uiImageで事足りるかも
//        if let svg = SVGKImage(named: "closeX_icon.svg") {
//            closeButton.setImage(svg.uiImage, for: .normal)
//            closeButton.tintColor = UIColor.gray
//        }
//        
//        closeButton.rx.tap.subscribe {[unowned self] _ in
//            self.dismiss(animated: true, completion: nil)
//            }.disposed(by: disposeBag)
//    }
//}
