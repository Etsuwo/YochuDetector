//
//  SettingsView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/25.
//

import SwiftUI

struct SettingsView: View {
    
    private let viewModel = SettingsViewModel()
    @ObservedObject private var viewState: SettingsViewModel.ViewState
    
    init() {
        viewState = viewModel.viewState
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
