//
//  CropView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/30.
//

import SwiftUI

struct CropView: View {
    
    let image: NSImage
    let editableRectangleView = EditableRectangleView()
    var cropPreviewImage: Image {
        Image(nsImage: self.image)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                cropPreviewImage
                    .resizable()
                editableRectangleView
            }
            .aspectRatio(image.size.width / image.size.height, contentMode: .fit)
        }
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropView(image: NSImage())
    }
}
