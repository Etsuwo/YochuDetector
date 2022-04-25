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
            UserDefaults.KeyString.shootingInterval.rawValue: 2,
            UserDefaults.KeyString.wandaringMinute.rawValue: 20,
            UserDefaults.KeyString.stopMinute.rawValue: 30,
            UserDefaults.KeyString.stopRectBuffer.rawValue: 10,
            UserDefaults.KeyString.confidenceThreshold.rawValue: 50
        ]
        userDefaults.register(defaults: defaults)
    }
    
    func getValue(key: UserDefaults.KeyString) -> Int {
        userDefaults.integer(forKey: key.rawValue)
    }
    
    func setValue(value: Int ,key: UserDefaults.KeyString) {
        userDefaults.set(value, forKey: key.rawValue)
    }
}


extension UserDefaults {
    enum KeyString: String, CaseIterable {
        case shootingInterval
        case wandaringMinute
        case stopMinute
        case stopRectBuffer
        case confidenceThreshold
    }
}
