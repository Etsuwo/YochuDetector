//
//  AnalyzeSettingStore.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation
import AppKit

final class AnalyzeSettingStore {
    static let shared = AnalyzeSettingStore()
    private init() {}
    
    var inputUrl: URL?
    var outputUrl: URL?
    var experimentStartAt: Int = 0 // 実験開始時間、アプリ落としたら消える
    var analyzerSetting: AnalyzerSetting = AnalyzerSetting()
}
