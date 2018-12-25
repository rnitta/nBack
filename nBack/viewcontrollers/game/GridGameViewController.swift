//
//  GridGameViewController.swift
//  nBack
//
//  Created by PT2051 on 2018/12/15.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit
import LTMorphingLabel
import IBAnimatable
import NumPad
import Material
import SVGKit
import RealmSwift

class GridGameViewController: UIViewController {
    var levelN: Int!
    private var status: GameStatus = .pending
    private var gameStartTime: Date!
    private var gameEndTime: Date!
    private var subjectGrids: [UICollectionViewCell?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    private var turnCount: Int? {
        didSet {
            updateTurn()
            updateSubjectGrid()
        }
    }
    private var missCount: Int? {
        didSet {
            updateMissCountLabel()
        }
    }
    private var subjects: [[Int]] = [] // 問題
    
    @IBOutlet var countDownView: UIView!
    @IBOutlet var countDownLabel: LTMorphingLabel!
    @IBOutlet var countDownAnimationView: LOTAnimationView!

    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var subjectCollectionView: UICollectionView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var missCountLabel: UILabel!
    @IBOutlet var indicatorAnimationView: LOTAnimationView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var gridPad: NumPad!
    
    @IBOutlet var completionView: UIView!
    @IBOutlet var completionAnimationView: LOTAnimationView!
    @IBOutlet var completionCongratLabel: UILabel!
    @IBOutlet var completionLevelLabel: UILabel!
    @IBOutlet var completionMissCountLabel: UILabel!
    @IBOutlet var completionTimeElapsedLabel: UILabel!
    @IBOutlet var completionCloseButton: FlatButton!
    @IBAction func completionCloseButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubject()
        initView()
        
        gridPad.dataSource = self
        gridPad.delegate = self
        gridPad.backgroundColor = UIColor.Border.ultraLightGray
        //gridPad.isHidden = true
        
        self.view.addSubview(countDownView)
        setupCountDownTimer()
        
    }
    
    // 幅確定させたいので仕方なく
    override func viewDidLayoutSubviews() {
        setCollectionSizes()
        updateSubjectGrid() // 1回目のため仕方なく
    }
    
    private func initView() {
        turnCount = 1
        missCount = 0
        levelLabel.text = String(format: "%d Back", levelN)
        instructionLabel.text = NSLocalizedString("game_memorizeGrid", comment: "")
        missCountLabel.text = String(format: NSLocalizedString("game_missCount", comment: ""), 0)
        indicatorAnimationView.backgroundColor = UIColor.clear
        
        closeButton.backgroundColor = UIColor.clear
        closeButton.tintColor = UIColor.darkGray
        if let closeButtonSVG = SVGKImage(named: "closeX_icon.svg") {
            closeButtonSVG.size = CGSize(width: closeButton.bounds.width * 0.8, height: closeButton.bounds.height * 0.8)
            closeButton.setImage(closeButtonSVG.uiImage, for: .normal)
        }
    }
}

//MARK: - ゲーム関連
extension GridGameViewController {
    private func updateTurn() {
        if let turn = turnCount {
            let prog: Float = Float(turn) / Float(levelN * 2 + 10)
            progressBar.setProgress(prog, animated: true)
            switch true {
            case turn <= levelN:
                status = .memorize
            case levelN < turn && turn <= levelN + 9:
                status = .answer
            case levelN + 9 < turn && turn <= levelN * 2 + 9:
                status = .trail
            case levelN * 2 + 9 <= turn:
                status = .end
            default:
                status = .pending
            }
        }
    }
    private func updateMissCountLabel() {
        let missN: Int = missCount ?? 0
        missCountLabel.text = String(format: NSLocalizedString("game_missCount", comment: ""), missN)
    }
    
    private func updateSubjectGrid() {
        for grid in subjectGrids {
            grid?.backgroundColor = UIColor.GridGame.regularGrid
        }
        if let turn = turnCount, status == .memorize || status == .answer  {
            let targetGrid = subjectGrids[subjects[turn - 1][0] * 4 + subjects[turn - 1][1]]
            targetGrid?.backgroundColor = UIColor.GridGame.hightlitedGrid
        }
    }
    
    private func startMemorizeTurn() {
        indicatorAnimationView.setAnimation(named: "dottedLoading.json")
        indicatorAnimationView.loopAnimation = false
        indicatorAnimationView.animationSpeed = 0.5
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
            gridPad.isHidden = false
            indicatorAnimationView.isHidden = true
        case .trail:
            instructionLabel.text = String(format: NSLocalizedString("game_answerNBackGrid", comment: ""), levelN)
        case .end:
            showCompletionView()
        default:
            gridPad.isHidden = false
        }
    }
    
}

//MARK: - 完了
extension GridGameViewController {
    private func showCompletionView() {
        // 結果ラベル
        gameEndTime = Date()
        let span:Double = self.gameEndTime.timeIntervalSince(self.gameStartTime)
        let congratKeyStr: String = missCount! == 0 ? "game_completion_congratPerfect" : "game_completion_congratDone"
        completionCongratLabel.text = NSLocalizedString(congratKeyStr, comment: "")
        completionLevelLabel.text = String(format: NSLocalizedString("game_completion_level", comment: ""), levelN)
        completionTimeElapsedLabel.text = String(format: NSLocalizedString("game_completion_timeElapsed", comment: ""), span)
        completionMissCountLabel.text = String(format: NSLocalizedString("game_completion_missCount", comment: ""), missCount!)
        completionLevelLabel.isHidden = true
        completionTimeElapsedLabel.isHidden = true
        completionMissCountLabel.isHidden = true
        completionCloseButton.isHidden = true
        
        // 結果保存　↑時間計測終了よりあとにする
        saveResult()
        
        // アニメーション
        completionView.frame = self.view.frame
        completionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(completionView)
        if missCount! == 0 {
            completionAnimationView.setAnimation(named: "clap.json")
        } else {
            completionAnimationView.setAnimation(named: "fabulousLike.json")
        }
        completionAnimationView.animationSpeed = 1
        completionAnimationView.loopAnimation = false
        completionAnimationView.play(completion: { (_: Bool) in
            self.completionLevelLabel.isHidden = false
            self.completionTimeElapsedLabel.isHidden = false
            self.completionMissCountLabel.isHidden = false
            self.completionCloseButton.isHidden = false
            
        })
        
    }
}

//MARK: - カウントダウン関連
extension GridGameViewController {
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
                    self.gameStartTime = Date() //時間計測開始
                }
            }
        }
    }
}

//MARK: - 保存
extension GridGameViewController {
    private func saveResult() {
        let realm = try! Realm()
        let data = gridData()
        data.level = levelN
        data.elapsedTime = gameEndTime.timeIntervalSince(gameStartTime)
        data.miss = missCount!
        data.timeStamp = Date()
        
        try! realm.write() {
            realm.add(data)
        }
        
        if missCount! == 0 {
            let userDefaults = UserDefaults.standard
            let prevMaxLevel: Int = userDefaults.integer(forKey: "gridMaxLevel") // 初期値0
            if prevMaxLevel < levelN! {
                userDefaults.set(levelN!, forKey: "gridMaxLevel")
                userDefaults.set(true, forKey: "isGridMaxLevelUpdated")
            }
        }
        
        increaseTotalExp(level: levelN, miss: missCount!)
    }
}

//MARK: - 問題関連
extension GridGameViewController: CollectionViewDelegate, CollectionViewDataSource {
    // 問題関連の初期化
    private func initSubject() {
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.backgroundColor = UIColor.clear
        //問題作成
        guard let initN = levelN else { return }
        var prevNums: [Int] = [0, 0]
        for _ in 1...(10 + initN) {
            var nums = [Int.random(in: 0...2), Int.random(in: 0...3)]
            // 同じマスを避けるためのロジック
            if prevNums[0] == nums[0] && prevNums[1] == nums[1] {
                nums = [Int.random(in: 0...2), 3 - prevNums[1]]
            }
            prevNums = nums
            subjects += [nums]
        }
        print(subjects)
    }
    private func setCollectionSizes() {
        let width = floor((subjectCollectionView.frame.width - 8) / 4)
        let height = floor((subjectCollectionView.frame.height - 6) / 3)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        subjectCollectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    //不要
    var dataSourceItems: [DataSourceItem] {
        return [DataSourceItem()]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = subjectCollectionView.dequeueReusableCell(withReuseIdentifier: "subjectItemCell", for: indexPath)
        cell.layer.cornerRadius = 10 // 適当
        //cell.backgroundColor = UIColor.GridGame.regularGrid
        subjectGrids[indexPath.row] = cell
        return cell
    }
}

//MARK: - 回答ぱっど
extension GridGameViewController: NumPadDelegate, NumPadDataSource {
    
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {
        if status == .answer || status == .trail {
            let answerGrid:[Int] = [subjects[turnCount! - levelN! - 1][0], subjects[turnCount! - levelN! - 1][1]]
            if position.row == answerGrid[0] && position.column == answerGrid[1] {
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
        item = Item()
        item.backgroundColor = UIColor.GridGame.regularGrid
        item.selectedBackgroundColor = UIColor.darkGray
        return item
    }
    
    func numPad(_ numPad: NumPad, numberOfColumnsInRow row: Row) -> Int {
        return 4
    }
    
    func numberOfRowsInNumPad(_ numPad: NumPad) -> Int {
        return 3
    }
}
