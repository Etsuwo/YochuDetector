//
//  Double+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/26.
//

import Foundation

extension Double {
    // 小数点第二位で四捨五入
    var minuteToHour: Double {
        let decimalPlace: Double = 100
        return (self / 60 * decimalPlace).rounded() / 100
    }
}
