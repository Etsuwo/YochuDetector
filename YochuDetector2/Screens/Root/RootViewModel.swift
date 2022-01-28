//
//  RootViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/27.
//

import Foundation
import Combine

final class RootViewModel {
    final class ViewState: ObservableObject {
        @Published var displayView: ViewType = .selectSource
    }
    
    private(set) var viewState = ViewState()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        registerNotification()
    }
    
    private func registerNotification() {
        NotificationCenter.Publisher(center: .default, name: .transitionTrimming, object: nil)
            .sink(receiveValue: {[weak self] _ in
                self?.viewState.displayView = .trimming
            })
            .store(in: &cancellables)
    }
}

enum ViewType {
    case selectSource
    case trimming
}
