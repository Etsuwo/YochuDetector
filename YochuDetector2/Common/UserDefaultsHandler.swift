//
//  UserDefaultsHandler.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/25.
//

import Foundation

final class UserDefaultsHandler {
    private let userDefaults = UserDefaults.standard
    
    init() {
        let defaults: [String: Any] = [
            UserDefaults.IntKeyString.shootingInterval.rawValue: 2,
            UserDefaults.IntKeyString.wandaringMinute.rawValue: 20,
            UserDefaults.IntKeyString.stopMinute.rawValue: 30,
            UserDefaults.IntKeyString.stopRectBuffer.rawValue: 10,
            UserDefaults.IntKeyString.confidenceThreshold.rawValue: 50,
            UserDefaults.IntKeyString.binaryThreshold.rawValue: 30,
            UserDefaults.StringKeyString.stopAnalyzeMethod.rawValue: StopAnalyzeMethod.forward.rawValue
        ]
        userDefaults.register(defaults: defaults)
    }
    
    func getValue(key: UserDefaults.IntKeyString) -> Int {
        userDefaults.integer(forKey: key.rawValue)
    }
    
    func getValue(key: UserDefaults.StringKeyString) -> String {
        userDefaults.string(forKey: key.rawValue) ?? ""
    }
    
    func setValue(value: Int ,key: UserDefaults.IntKeyString) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func setValue(value: String, key: UserDefaults.StringKeyString) {
        userDefaults.set(value, forKey: key.rawValue)
    }
}


extension UserDefaults {
    enum IntKeyString: String, CaseIterable {
        case shootingInterval
        case wandaringMinute
        case stopMinute
        case stopRectBuffer
        case confidenceThreshold
        case binaryThreshold
    }
    
    enum StringKeyString: String, CaseIterable {
        case stopAnalyzeMethod
    }
}
