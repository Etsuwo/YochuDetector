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
        VStack {
            Spacer()
            SettingField(
                title: "Analyze Socre Threshold",
                placeholder: "Input Value between 1 to 100, default is 50",
                value: $viewState.analyzeScoreThreshold
            )
            
            SettingField(
                title: "Stop Threshold",
                placeholder: "Input Value more than 1, default is 30",
                value: $viewState.stopThreshold
            )
            .padding(.top)
            
            SettingField(
                title: "Stop Allowable Error",
                placeholder: "Input Value more than 0, default is 10",
                value: $viewState.stopAllowableError
            )
            .padding(.top)
            
            SettingField(
                title: "Wandaring Threshold",
                placeholder: "Input Value more than 1, default is 20",
                value: $viewState.wandaringThreshold
            )
            .padding(.top)
            
            SettingField(
                title: "Shooting Interval",
                placeholder: "Input Value more than 1, default is 2",
                value: $viewState.shootInterval
            )
            .padding(.top)
            
            HStack {
                Spacer()
                Button(action: {
                    viewModel.onTapBack()
                }, label: {
                    Text("戻る")
                })
                Button(action: {
                    viewModel.onTapGo()
                }, label: {
                    Text("決定")
                })
                .padding(.horizontal)
            }
            .padding(.top)
            Spacer()
            
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
