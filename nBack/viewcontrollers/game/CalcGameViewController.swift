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
import NumPad

enum GameStatus {
    case pending
    case memorize
    case answer
    case trail
    case end
    
    func text() -> String {
        return ""
    }
}

class CalcGameViewController: UIViewController {
    var levelN: Int?
    private var subjects: [[Int]] = [] // 問題
    private let numbers: [[Int?]] = [[1,2,3],[4,5,6],[7,8,9],[nil,0,nil]]
    private var turnCount: Int? {
        didSet {
            updateTurn()
            updateSubjectLabel()
        }
    }
    private var missCount: Int? {
        didSet {
            updateMissCountLabel()
        }
    }
    var status: GameStatus = .pending
    @IBOutlet var countDownView: UIView!
    @IBOutlet var countDownLabel: LTMorphingLabel!
    @IBOutlet var countDownAnimationView: LOTAnimationView!
    @IBOutlet var indicatorAnimationView: LOTAnimationView!
    @IBOutlet var numPad: NumPad!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var subjectLabel: LTMorphingLabel!
    @IBOutlet var memorizeLabel: UILabel!
    @IBOutlet var missCountLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        numPad.dataSource = self
        numPad.delegate = self
        numPad.backgroundColor = UIColor.Border.ultraLightGray
        numPad.isHidden = true
        
        if let initN = levelN { levelLabel.text = "\(initN) Back" }
        
        self.view.addSubview(countDownView)
        setupCountDownTimer()
        createSubjects()
        initView()
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

//MARK: - カウントダウン関連
extension CalcGameViewController {
    private func setupCountDownTimer() {
        // アニメーション
        countDownAnimationView.setAnimation(named: "materialCountDown.json")
        countDownAnimationView.loopAnimation = false
        countDownAnimationView.animationSpeed = 1
        countDownAnimationView.play(fromProgress: 0, toProgress: 0.75, withCompletion: nil) // 4周あるので
        
        // カウントダウンラベル
        countDownView.frame = self.view.frame
        countDownView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        countDownLabel.morphingEffect = .pixelate
        for i in 1...3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.countDownLabel.text = "\(3 - i)"
                if i == 3 {
                    self.countDownAnimationView.pause()
                    self.countDownView.removeFromSuperview()
                    self.startMemorizeTurn()
                }
            }
        }
    }
}

//MARK: - ゲーム関連
extension CalcGameViewController {
    private func initView() {
        turnCount = 1
        missCount = 0
        memorizeLabel.text = NSLocalizedString("game_memorize", comment: "")
        missCountLabel.text = String(format: NSLocalizedString("game_missCount", comment: ""), 0)
        subjectLabel.morphingEffect = .evaporate
        updateSubjectLabel()
    }
    
    private func updateTurn() {
        if let level = levelN, let turn = turnCount {
            let prog: Float = Float(turn) / Float(level * 2 + 9)
            progressBar.setProgress(prog, animated: true)
            switch true {
            case turn <= level:
                status = .memorize
            case level < turn && turn <= level + 9:
                status = .answer
            case level + 9 < turn && turn <= level * 2 + 9:
                status = .trail
            case level * 2 + 9 <= turn:
                status = .end
            default:
                status = .pending
            }
        }
    }
    
    private func updateSubjectLabel() {
        if let turn = turnCount, status == .memorize || status == .answer  {
            subjectLabel.text = "\(subjects[turn - 1][0]) + \(subjects[turn - 1][1]) = ?"
        }
    }
    
    private func updateMissCountLabel() {
        let missN: Int = missCount ?? 0
        missCountLabel.text = String(format: NSLocalizedString("game_missCount", comment: ""), missN)
    }
    
    private func startMemorizeTurn() {
        indicatorAnimationView.setAnimation(named: "dottedLoading.json")
        indicatorAnimationView.loopAnimation = false
        indicatorAnimationView.animationSpeed = 0.33333
        indicatorAnimationView.play(completion: { (_: Bool) in
            self.nextTurn()
        })
    }
    
    private func nextTurn() {
        turnCount! += 1
        switch self.status {
        case .memorize:
            startMemorizeTurn()
        case .answer:
            numPad.isHidden = false
            indicatorAnimationView.isHidden = true
        case .trail:
            subjectLabel.text = "?"
            memorizeLabel.text = String(format: NSLocalizedString("game_answerNBack", comment: ""), levelN!)
        default:
            numPad.isHidden = false
        }
    }
}

extension CalcGameViewController: NumPadDelegate, NumPadDataSource {
    
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {
        if status == .answer || status == .trail {
            guard let number = numbers[position.row][position.column] else { return }
            let answerDigit:Int = (subjects[turnCount! - levelN! - 1][0] + subjects[turnCount! - levelN! - 1][1]) % 10
            print(answerDigit)
            if number == answerDigit {
                //正解
                indicatorAnimationView.setAnimation(named: "correct.json")
                indicatorAnimationView.loopAnimation = false
                indicatorAnimationView.animationSpeed = 4
                indicatorAnimationView.isHidden = false
                indicatorAnimationView.play(completion: { (_: Bool) in
                    self.indicatorAnimationView.isHidden = true
                    self.nextTurn()
                })
            } else {
                //不正解
                indicatorAnimationView.setAnimation(named: "wrong.json")
                indicatorAnimationView.loopAnimation = false
                indicatorAnimationView.animationSpeed = 6
                indicatorAnimationView.isHidden = false
                indicatorAnimationView.play(completion: { (_: Bool) in
                    self.indicatorAnimationView.isHidden = true
                    self.missCount! += 1
                })
            }
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
