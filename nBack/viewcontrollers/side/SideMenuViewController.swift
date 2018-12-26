//
//  SideMenuViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/27.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import Lottie

class SideMenuViewController: UIViewController {

    
    
    @IBOutlet var vainAnimationView: LOTAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVainAnimation()
    }
    
    private func setupVainAnimation() {
        vainAnimationView.backgroundColor = UIColor.clear
        vainAnimationView.setAnimation(named: "kujira.json")
        vainAnimationView.loopAnimation = true
        vainAnimationView.animationSpeed = 1
        vainAnimationView.play()
    }


}
