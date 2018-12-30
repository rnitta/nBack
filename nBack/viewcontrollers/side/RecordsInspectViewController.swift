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
    let realm = try! Realm()
    var calcRecords:Results<calcData>!
    var gridRecords:Results<gridData>!
    let disposeBag:DisposeBag = DisposeBag()
    var segmentIndex:Int = 0
    @IBOutlet var segmentView: BetterSegmentedControl!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var recordListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calcRecords = realm.objects(calcData.self).sorted(byKeyPath: "timeStamp", ascending: false)
        gridRecords = realm.objects(gridData.self).sorted(byKeyPath: "timeStamp", ascending: false)
        recordListTableView.delegate = self
        recordListTableView.dataSource = self
        recordListTableView.register(UINib(nibName: "GameRecordCell", bundle: nil), forCellReuseIdentifier: "GameRecordCell")
        recordListTableView.register(UINib(nibName: "GameRecordHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "GameRecordHeader")
        recordListTableView.tableFooterView = UIView(frame: .zero)
        
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
        segmentIndex = Int(sender.index)
        recordListTableView.reloadData()
    }
}

// テーブル系切り出す
extension RecordsInspectViewController: UITableViewDelegate, UITableViewDataSource {
     //ヘッダの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
     //ヘッダ設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GameRecordHeader") {
            return headerView
        }
        return nil
    }
    
     //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentIndex == 0 {
            return calcRecords.count
        } else {
            return gridRecords.count
        }
    }
    
    // 各セルのテキスト
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameRecordCell")! as! GameRecordCell
        let dateFormat = "MM/dd HH:mm"
        if segmentIndex == 0 {
            let record = calcRecords[indexPath.item]
            cell.dateLabel.text = record.timeStamp.toString(dateFormat)
            cell.levelLabel.text = String(format: "%d", record.level)
            cell.elapsedTimeLabel.text = String(format: "%.1fs", record.elapsedTime)
            cell.missCountLabel.text = String(format: "%d", record.miss)
            if record.miss == 0 {
                cell.perfectIndicatorImageView.isHidden = false
                if let svg = SVGKImage(named: "check_icon.svg") {
                    svg.size = CGSize(width: 20, height: 20)
                    cell.perfectIndicatorImageView.image = svg.uiImage
                }
            } else {
                cell.perfectIndicatorImageView.isHidden = true
            }
            
        } else {
            let record = gridRecords[indexPath.item]
            cell.dateLabel.text = record.timeStamp.toString(dateFormat)
            cell.levelLabel.text = String(format: "%d", record.level)
            cell.elapsedTimeLabel.text = String(format: "%.1fs", record.elapsedTime)
            cell.missCountLabel.text = String(format: "%d", record.miss)
            if record.miss == 0 {
                cell.perfectIndicatorImageView.isHidden = false
                if let svg = SVGKImage(named: "check_icon.svg") {
                    svg.size = CGSize(width: 20, height: 20)
                    cell.perfectIndicatorImageView.image = svg.uiImage
                }
            } else {
                cell.perfectIndicatorImageView.isHidden = true
            }
            
        }
        return cell as GameRecordCell
    }
}
