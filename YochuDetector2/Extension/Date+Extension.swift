//
//  Date+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/03/27.
//

import Foundation

extension Date {
    static func nowString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        formatter.locale = Locale(identifier: "ja_JP")
        let now = Date()
        return formatter.string(from: now)
    }
}
