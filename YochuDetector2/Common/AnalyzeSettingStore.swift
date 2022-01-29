//
//  AnalyzeSettingStore.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import Foundation

final class AnalyzeSettingStore {
    static let shared = AnalyzeSettingStore()
    private init() {}
    
    var inputUrl: URL?
    var outputUrl: URL?
}