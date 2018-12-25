//
//  TotalExp.swift
//  nBack
//
//  Created by PT2051 on 2018/12/25.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import Foundation

public func increaseTotalExp(level: Int, miss: Int) {
    if miss < level {
        let userDefault = UserDefaults.standard
        let prevTotalExp: Int = userDefault.integer(forKey: "totalExp")
        userDefault.set(prevTotalExp + level - miss, forKey: "totalExp")
    }
}
