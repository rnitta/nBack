//
//  GameRecordHeader.swift
//  nBack
//
//  Created by PT2051 on 2018/12/31.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit

class GameRecordHeader: UITableViewHeaderFooterView {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var missLabel: UILabel!
    override func draw(_ rect: CGRect) {
        dateLabel.text = NSLocalizedString("records_tableHeaderDate", comment: "")
        levelLabel.text = NSLocalizedString("records_tableHeaderLevel", comment: "")
        timeLabel.text = NSLocalizedString("records_tableHeaderTime", comment: "")
        missLabel.text = NSLocalizedString("records_tableHeaderMiss", comment: "")
    }
}
