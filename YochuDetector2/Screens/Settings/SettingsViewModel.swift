//
//  SettingsViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/25.
//

import Foundation

final class SettingsViewModel {
    final class ViewState: ObservableObject {
        @Published var analyzeScoreThreshold = "0"
        @Published var stopThreshold = "0"
        @Published var stopAllowableError = "0"
        @Published var shootInterval = "0"
        @Published var wandaringThreshold = "0"
    }
    
    private(set) var viewState = ViewState()
    
    func onTapBack() {
        
    }
    
    func onTapGo() {
        
    }
}
