//
//  AnalyzerSetting.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/23.
//

import Foundation

struct AnalyzerSetting {
    var interval: Int = 2
    var wandaringMinute: Int = 20
    var stopMinute: Int = 30
    var stopRectBuffer: Int = 10
    var confidenceThreshold: Int = 50
    
    var oneHour: Int {
        60 / interval
    }
    var wandaringThreshold: Int {
        wandaringMinute / interval
    }
    var stopThreshold: Int {
        stopMinute / interval
    }
}
