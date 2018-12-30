//
//  Date.swift
//  nBack
//
//  Created by PT2051 on 2018/12/27.
//  Copyright © 2018 amagrammer. All rights reserved.
//

import Foundation
extension Date {
    func toYMDHM() -> String {
        let dateFormater = DateFormatter()
        dateFormater.timeZone = TimeZone.current
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormater.string(from: self)
    }
    func toString(_ dateFormat: String) -> String {
        let dateFormater = DateFormatter()
        dateFormater.timeZone = TimeZone.current
        dateFormater.locale = Locale.current
        dateFormater.dateFormat = dateFormat
        return dateFormater.string(from: self)
    }
}
