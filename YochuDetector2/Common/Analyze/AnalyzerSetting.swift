//
//  AnalyzerSetting.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/23.
//

import Foundation

struct AnalyzerSetting {
    var interval: Int = 2
    var numberOfTarget: Int = 0
    var oneHour: Int {
        60 / interval
    }
    var wandaringThreshold: Int {
        20 / interval
    }
    var stopThreshold: Int {
        30 / interval
    }
    private(set) var stopRectBuffer: Int = 20
}
