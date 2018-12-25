//
//  TutorialViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/14.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import paper_onboarding

// FIXME: 一度表示したら二度と出ないようにする app delegateで?
class TutorialViewController: UIViewController {

    let userDefault = UserDefaults.standard
    @IBOutlet var skipButton: UIButton!
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        userDefault.set(true, forKey: "isTutorialSkipped")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.isHidden = true
        setupPaperOnboardingView()
        
        // ボタンを前に持ってくる
        view.bringSubviewToFront(skipButton)
    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
}

extension TutorialViewController: PaperOnboardingDataSource {
    func onboardingItemsCount() -> Int {
        return 3
    }

    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage(),
                               title: NSLocalizedString("tutorial_0title", comment: ""),
                               description: NSLocalizedString("tutorial_0desc", comment: ""),
                               pageIcon: UIImage(),
                               color: UIColor.Tutorial.background0,
                               titleColor: UIColor.Tutorial.title,
                               descriptionColor: UIColor.Tutorial.desc,
                               titleFont: UIFont(name: "HiraginoSans-W6", size: CGFloat(20))!,
                               descriptionFont: UIFont(name: "HiraginoSans-W3", size: CGFloat(14))!),
            OnboardingItemInfo(informationImage: UIImage(),
                               title: NSLocalizedString("tutorial_1title", comment: ""),
                               description: NSLocalizedString("tutorial_1desc", comment: ""),
                               pageIcon: UIImage(),
                               color: UIColor.Tutorial.background1,
                               titleColor: UIColor.Tutorial.title,
                               descriptionColor: UIColor.Tutorial.desc,
                               titleFont: UIFont(name: "HiraginoSans-W6", size: CGFloat(20))!,
                               descriptionFont: UIFont(name: "HiraginoSans-W3", size: CGFloat(14))!),
            OnboardingItemInfo(informationImage: UIImage(),
                               title: NSLocalizedString("tutorial_2title", comment: ""),
                               description: NSLocalizedString("tutorial_2desc", comment: ""),
                               pageIcon: UIImage(),
                               color: UIColor.Tutorial.background2,
                               titleColor: UIColor.Tutorial.title,
                               descriptionColor: UIColor.Tutorial.desc,
                               titleFont: UIFont(name: "HiraginoSans-W6", size: CGFloat(20))!,
                               descriptionFont: UIFont(name: "HiraginoSans-W3", size: CGFloat(14))!)
            ][index]
    }
}

extension TutorialViewController: PaperOnboardingDelegate {
    // ページ切り替え毎に実行
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.skipButton.isHidden = false
            }
        } else {
            skipButton.isHidden = true
        }
    }
    
    func onboardingDidTransitonToIndex(_: Int) {
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        //item.titleLabel?.backgroundColor = .redColor()
        //item.descriptionLabel?.backgroundColor = .redColor()
        //item.imageView = ...
    }
}
