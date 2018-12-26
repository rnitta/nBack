//
//  calcData.swift
//  nBack
//
//  Created by PT2051 on 2018/12/24.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import Foundation
import RealmSwift

// なんで頭小文字にしたんだろう
class calcData: Object {
    @objc dynamic var id:String = UUID().uuidString
    @objc dynamic var miss:Int = 0 // ミス数
    @objc dynamic var elapsedTime:Double = 0 // 経過時間
    @objc dynamic var level:Int = 1 // レベル
    @objc dynamic var timeStamp = Date() // 計測日時
    
    override static func primaryKey() -> String? {
        return "id"
    }
    override static func indexedProperties() -> [String] {
        return ["timeStamp"]
    }
}
