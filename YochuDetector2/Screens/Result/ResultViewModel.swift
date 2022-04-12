//
//  ResultViewModel.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/02/24.
//

import Foundation

final class ResultViewModel: ObservableObject {
    func onTapBackTrimming() {
        NotificationCenter.default.post(name: .transitionTrimming, object: nil)
    }
}
