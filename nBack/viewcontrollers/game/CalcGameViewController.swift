//
//  CalcGameViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/15.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import LTMorphingLabel
import IBAnimatable

enum GameStatus {
    case pending
    case memorize
    case answer
    case trail
    case end
}

class CalcGameViewController: UIViewController {
    var levelN: Int?
    var subjects: [[Int]] = [] // 問題
    let numbers: [[Int?]] = [[1,2,3],[4,5,6],[7,8,9],[nil,0,nil]]
    @IBOutlet var countDownView: UIView!
    @IBOutlet var countDownLabel: LTMorphingLabel!
    @IBOutlet var numPad: NumPad!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var subjectLabel: LTMorphingLabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        numPad.dataSource = self
        numPad.delegate = self
        numPad.backgroundColor = UIColor.Border.ultraLightGray
        
        if let initN = levelN { levelLabel.text = "\(initN) Back" }
        
        self.view.addSubview(countDownView)
        setupCountDownTimer()
        createSubjects()
    }
    
    private func setupCountDownTimer() {
        countDownView.frame = self.view.frame
        countDownView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        countDownLabel.morphingEffect = .pixelate
        for i in 1...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.countDownLabel.text = "\(3 - i)"
                if i == 3 {
                    self.countDownView.removeFromSuperview()
                }
            }
        }
    }
    
    private func createSubjects() {
        guard let initN = levelN else { return }
        var prevNums: [Int] = [0, 0]
        
        // 問題の配列生成
        for _ in 1...(10 + initN) {
            var nums = [Int.random(in: 1...9), Int.random(in: 1...9)]
            // 同じ数字が出力されると答えた感が無いので同じ数字を避けるためのロジック
            if prevNums[0] == nums[0] && prevNums[1] == nums[1] {
                nums = [10 - prevNums[0], 10 - prevNums[1]]
                if nums[0] == 5 && nums[1] == 5 {
                    nums = [6,6]
                }
            }

            prevNums = nums
            subjects += [nums]
        }
    }
    
    
    @IBAction func dis(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CalcGameViewController: NumPadDelegate, NumPadDataSource {
    
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {
        let prog: Float = 1.0 / Float(numbers[position.row][position.column] ?? 1)
        progressBar.setProgress(prog, animated: true)
        
        subjectLabel.morphingEffect = .evaporate
        if let sl = numbers[position.row][position.column] {
            subjectLabel.text = "\(subjects[sl][0]) + \(subjects[sl][1]) = ?"
        }
    }

    func numPad(_ numPad: NumPad, itemAtPosition position: Position) -> Item {
        var item: Item!
        if let num = numbers[position.row][position.column] {
            item = Item(title: "\(num)")
            item.selectedBackgroundColor = UIColor.lightGray
            item.titleColor = UIColor.darkGray
            item.backgroundColor = UIColor.Set.lightBase
            item.font = UIFont(name: "HiraginoSans-W6", size: 20)
        } else {
            item = Item()
            item.selectedBackgroundColor = UIColor.white
            
        }
        return item
    }
    
    func numPad(_ numPad: NumPad, numberOfColumnsInRow row: Row) -> Int {
        return 3
    }
    
    func numberOfRowsInNumPad(_ numPad: NumPad) -> Int {
        return 4
    }
}
