//
//  UnInteractiveLoadingView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/14.
//

import SwiftUI

protocol UnInteractiveLoadingViewState: ObservableObject {
    var isHiddenProgressView: Bool { get }
    var currentProgressValue: Double { get }
    var totalProgressValue: Double { get }
}

struct UnInteractiveLoadingView<T: UnInteractiveLoadingViewState>: View {
    
    @ObservedObject var viewState: T
    
    var body: some View {
        ZStack {
            Color(CGColor.init(gray: 0.5, alpha: 0.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ProgressView("Analyzing...", value: viewState.currentProgressValue, total: viewState.totalProgressValue)
                .frame(maxWidth: .infinity)
                .padding()
                .padding()
        }
        .isHidden(viewState.isHiddenProgressView)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

