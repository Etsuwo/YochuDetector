//
//  SettingsViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/25.
//

import Foundation

final class SettingsViewModel {
    final class ViewState: ObservableObject {
        @Published var analyzeScoreThreshold: String
        @Published var stopThreshold: String
        @Published var stopAllowableError: String
        @Published var shootInterval: String
        @Published var wandaringThreshold: String
        @Published var binaryThreshold: String
        @Published var showAlert: Bool = false
        
        init() {
            let setting = AnalyzeSettingStore.shared.analyzerSetting
            analyzeScoreThreshold = "\(setting.confidenceThreshold)"
            stopThreshold = "\(setting.stopMinute)"
            stopAllowableError = "\(setting.stopRectBuffer)"
            shootInterval = "\(setting.interval)"
            wandaringThreshold = "\(setting.wandaringMinute)"
            binaryThreshold = "\(setting.binaryThreshold)"
        }
    }
    
    private(set) var viewState = ViewState()
    
    func onTapBack() {
        NotificationCenter.default.post(name: .transitionTrimming, object: nil)
    }
    
    func onTapGo() {
        do {
            try register()
            NotificationCenter.default.post(name: .transitionTrimming, object: nil)
            
        } catch {
            viewState.showAlert = true
        }
    }
    
    func onTapAlertButton() {
        viewState.showAlert = false
    }
    
    private func register() throws { 
        guard let analyzeScoreThreshold = Int(viewState.analyzeScoreThreshold),
              (1...100).contains(analyzeScoreThreshold),
              let stopThreshold = Int(viewState.stopThreshold),
              stopThreshold >= 1,
              let stopAllowableError = Int(viewState.stopAllowableError),
              stopAllowableError >= 0,
              let shootInterval = Int(viewState.shootInterval),
              shootInterval >= 1,
              let wandaringThreshold = Int(viewState.wandaringThreshold),
              wandaringThreshold >= 1,
              let binaryThreshold = Int(viewState.binaryThreshold),
              (1...100).contains(binaryThreshold) else {
            throw NSError()
        }
        AnalyzeSettingStore.shared.analyzerSetting.update(interval: shootInterval, wandaringMinute: wandaringThreshold, stopMinute: stopThreshold, stopRectBuffer: stopAllowableError, confidenceThreshold: analyzeScoreThreshold, binaryThreshold: binaryThreshold)
    }
}
