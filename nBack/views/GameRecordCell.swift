//
//  GameRecordCell.swift
//  nBack
//
//  Created by PT2051 on 2018/12/27.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import UIKit

class GameRecordCell: UITableViewCell {


    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var levelScrimView: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var missCountLabel: UILabel!
    @IBOutlet weak var perfectIndicatorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initiallize
        
        levelScrimView.layer.cornerRadius = levelScrimView.frame.width / 2.0
        levelScrimView.layer.borderColor = UIColor.Set.lightBase.cgColor
        levelScrimView.layer.borderWidth = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
