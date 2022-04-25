//
//  NotificationName.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/27.
//

import Foundation
enum NotificationName: String {
    case transitionTrimming
    case transitionResult
    case transitionSelectSource
    case transitionSettings
}

extension Notification.Name {
    static let transitionTrimming = NotificationName.transitionTrimming.name
    static let transitionResult = NotificationName.transitionResult.name
    static let transitionSelectSource = NotificationName.transitionSelectSource.name
    static let transitionSettings = NotificationName.transitionSettings.name
}

extension NotificationName {
    var name: Notification.Name {
        let name = "\(NotificationCenter.default).\(rawValue)"
        return Notification.Name(rawValue: name)
    }
}
