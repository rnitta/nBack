//
//  RecordsInspectViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/27.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import SVGKit
import RxSwift
import RxCocoa
import RealmSwift

class RecordsInspectViewController: UIViewController {

    let disposeBag:DisposeBag = DisposeBag()
    @IBOutlet var segmentView: BetterSegmentedControl!
    @IBOutlet var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentView()
        setupCloseButton()
        
    }
    
    private func setupCloseButton() {
        closeButton.backgroundColor = UIColor.clear
        
        // SVGKImage?.uiImageで事足りるかも
        if let svg = SVGKImage(named: "closeX_icon.svg") {
            closeButton.setImage(svg.uiImage, for: .normal)
            closeButton.tintColor = UIColor.gray
        }
    
        closeButton.rx.tap.subscribe {[unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }

    
    private func setupSegmentView() {
        segmentView.segments = LabelSegment.segments(withTitles: ["Calc", "Grid"],
                              normalFont: UIFont(name: "HiraginoSans-W3", size: 20)!,
                              selectedFont: UIFont(name: "HiraginoSans-W6", size: 20)!)
    }
    // セグメントの切り替えハンドラ
    @IBAction func segmentValueChanged(_ sender: BetterSegmentedControl) {
        print(sender.index)
    }

}
