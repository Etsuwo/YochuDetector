//
//  TrimmingView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/25.
//

import SwiftUI

struct TrimmingView: View {
    
    private let viewModel = TrimmingViewModel()
    @ObservedObject private var viewState: TrimmingViewModel.ViewState
    
    init() {
        viewState = viewModel.viewState
    }
    
    var body: some View {
        Image(nsImage: NSImage.withOptionalURL(url: viewState.url))
    }
}

struct TrimmingView_Previews: PreviewProvider {
    static var previews: some View {
        TrimmingView()
    }
}
