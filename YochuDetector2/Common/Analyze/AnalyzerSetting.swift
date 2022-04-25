//
//  AnalyzerSetting.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/23.
//

import Foundation

final class AnalyzerSetting {
    
    private let userDefaultsHandler = UserDefaultsHandler()
    
    var interval: Int {
        userDefaultsHandler.getValue(key: .shootingInterval)
    }
    var wandaringMinute: Int {
        userDefaultsHandler.getValue(key: .wandaringMinute)
    }
    var stopMinute: Int {
        userDefaultsHandler.getValue(key: .stopMinute)
    }
    var stopRectBuffer: Int {
        userDefaultsHandler.getValue(key: .stopRectBuffer)
    }
    var confidenceThreshold: Int {
        userDefaultsHandler.getValue(key: .confidenceThreshold)
    }
    
    var oneHour: Int {
        60 / interval
    }
    
    var wandaringThreshold: Int {
        wandaringMinute / interval
    }
    
    var stopThreshold: Int {
        stopMinute / interval
    }
    
    func update(interval: Int, wandaringMinute: Int, stopMinute: Int, stopRectBuffer: Int, confidenceThreshold: Int) {
        let values = [interval, wandaringMinute, stopMinute, stopRectBuffer, confidenceThreshold]
        for (index, key) in UserDefaults.KeyString.allCases.enumerated() {
            userDefaultsHandler.setValue(value: values[index], key: key)
        }
    }
}
