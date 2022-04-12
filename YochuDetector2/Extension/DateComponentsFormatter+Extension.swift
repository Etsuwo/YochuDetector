//
//  DateComponentsFormatter.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/03/28.
//

import Foundation

extension DateComponentsFormatter {
    static func headerString(from time: Double) -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .abbreviated
        dateFormatter.allowedUnits = [.day, .hour, .minute]
        return dateFormatter.string(from: time)!
    }
}
