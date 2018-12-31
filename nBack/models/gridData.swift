//
//  gridData.swift
//  nBack
//
//  Created by PT2051 on 2018/12/24.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import Foundation
import RealmSwift

class gridData: Object {
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

extension Results where Element == gridData {
    func toHeatmapJson() -> [String: Int] {
        return self.reduce(into: [String: Int]()) { $0[String(format: "%d", Int($1.timeStamp.timeIntervalSince1970))] = 1 }
    }    
}

extension Results {
    func perfect() -> Results<Element> {
        return self.filter("miss == %d", 0)
    }
}
