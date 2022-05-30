//
//  croppedView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/26.
//

import SwiftUI

struct CroppedView: View {
    
    @Binding var separatedCount: Int
    let croppedImage: NSImage
    
    var body: some View {
        ZStack {
            Image(nsImage: croppedImage)
                .resizable()
                .scaledToFit()
            SeparateHelperView(separateCount: $separatedCount)
                .frame(idealWidth: .zero)
        }
        .aspectRatio(croppedImage.size.width / croppedImage.size.height, contentMode: .fit)
    }
}
