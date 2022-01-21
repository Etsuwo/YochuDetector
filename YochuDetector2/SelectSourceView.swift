//
//  ContentView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/22.
//

import SwiftUI

struct SelectSourceView: View {
    @State var text: String = ""
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Input Source")
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                TextField("hogehgoe", text: $text)
                Button(action: {
                    // TODO: 入力フォルダ選択
                }, label: {
                    Text("select")
                })
            }
            Spacer()
                .frame(height: 24)
            HStack {
                Text("Input Source")
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                TextField("hogehgeo", text: $text)
                Button(action: {
                    // TODO: 出力フォルダ選択
                }, label: {
                    Text("select")
                })
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // TODO: 画面遷移
                }, label: {
                    Text("Next")
                })
            }
            Spacer()
                .frame(height: 24)
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSourceView()
    }
}
