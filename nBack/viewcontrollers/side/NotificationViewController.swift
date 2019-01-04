//
//  NotificationViewController.swift
//  nBack
//
//  Created by PT2051 on 2019/01/02.
//  Copyright © 2019 amagrammer. All rights reserved.
//

import UIKit
import SVGKit
import RxSwift
import RxCocoa
import BetterSegmentedControl
import UserNotifications
import CDAlertView

class NotificationViewController: UIViewController, UNUserNotificationCenterDelegate {

    let userDefault = UserDefaults()
    let udnotificationKey: String = "isDailyLocalNotificationEnabled"
    let disposeBag = DisposeBag()
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var describeLabel: UILabel!
    @IBOutlet var onOffToggle: BetterSegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupToggle()
        setupCloseButton()
        setupLabel()
    }
    
    private func setupLabel() {
        describeLabel.text = NSLocalizedString("notification_describeLabel", comment: "")
    }
    
    private func setupCloseButton() {
        closeButton.backgroundColor = UIColor.clear
        
        if let svg = SVGKImage(named: "closeX_icon.svg") {
            closeButton.setImage(svg.uiImage, for: .normal)
            closeButton.tintColor = UIColor.gray
        }
        
        closeButton.rx.tap.subscribe {[unowned self] _ in
            self.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    private func setupToggle() {
        // ちゃんとやるならenumで
        let selectedIndex: UInt = userDefault.bool(forKey: udnotificationKey) ? 0 : 1
        onOffToggle.setIndex(selectedIndex)
        
        onOffToggle.segments = LabelSegment.segments(withTitles: ["On", "Off"],
                                                        normalFont: UIFont(name: "HiraginoSans-W3", size: 20)!,
                                                        selectedFont: UIFont(name: "HiraginoSans-W6", size: 20)!)
    }
    
    @IBAction func toggleValueChanged(_ sender: BetterSegmentedControl) {
        if onOffToggle.index == 0 {
            // on
            userDefault.set(true, forKey: udnotificationKey)
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if error != nil { return }
                if granted {
                    center.delegate = self //いる？
                } else {
                    let alert: UIAlertController = UIAlertController(title: NSLocalizedString("notification_pushAlertTitle", comment: ""), message: NSLocalizedString("notification_pushAlertMessage", comment: ""), preferredStyle:  UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK🤔", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) -> Void in
                        self.userDefault.set(false, forKey: self.udnotificationKey)
                        self.onOffToggle.setIndex(1)
                        DispatchQueue.main.async {
                            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        
        } else {
            // off
            userDefault.set(false, forKey: udnotificationKey)
        }
    }
}
