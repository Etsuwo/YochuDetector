//
//  SeparateHelperView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/26.
//

import SwiftUI

struct SeparateHelperView: View {
    
    @Binding var separateCount: Int
    
    init(separateCount: Binding<Int>) {
        _separateCount = separateCount
    }
    
    var body: some View {
        makeBlocks()
    }
    
    func makeBlocks() -> some View {
        HStack {
            if 1 < separateCount, separateCount < 20 {
                ForEach(Array(1..<separateCount), id: \.self) { _ in
                    Spacer()
                        
                    Rectangle()
                        .fill(Color.red)
                        .frame(maxWidth: 1)
                }
            }
            Spacer()
        }
    }
}
