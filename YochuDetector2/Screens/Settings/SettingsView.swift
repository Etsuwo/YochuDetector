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
//            SettingField(
//                title: "検出スコアの閾値",
//                placeholder: "Input Value between 1 to 100, default is 50",
//                value: $viewState.analyzeScoreThreshold
//            )
            
            SettingField(
                title: "幼虫の停止判定時間(分)",
                placeholder: "Input Value more than 1, default is 30",
                value: $viewState.stopThreshold
            )
            .padding(.top)
            
            SettingField(
                title: "停止判定で許容する座標の誤差",
                placeholder: "Input Value more than 0, default is 10",
                value: $viewState.stopAllowableError
            )
            .padding(.top)
            
            SettingField(
                title: "ワンダリング行動の判定時間(分)",
                placeholder: "Input Value more than 1, default is 20",
                value: $viewState.wandaringThreshold
            )
            .padding(.top)
            
            SettingField(
                title: "撮影画像の間隔(分)",
                placeholder: "Input Value more than 1, default is 2",
                value: $viewState.shootInterval
            )
            .padding(.top)
            
            SettingField(
                title: "エサ領域切り分け用の閾値",
                placeholder: "Input Value between 1 to 100, default is 30",
                value: $viewState.binaryThreshold
            )
            .padding(.top)
            
            Picker(
                "停止判定の方法",
                selection: $viewState.stopAnalyzeMethod,
                content: {
                    ForEach(StopAnalyzeMethod.allCases) { method in
                        Text(method.rawValue)
                    }
                }
            )
            .padding(.top)
            .frame(width: 300)
            
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
                .alert(isPresented: $viewState.showAlert, content: {
                    Alert(title: Text("無効な入力があります"), dismissButton: .default(Text("OK"), action: {
                        viewModel.onTapAlertButton()
                    }))
                    
                })
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
