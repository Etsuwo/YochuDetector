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
    
    
    var body: some View {
        ZStack {
            Image(nsImage: image)
            editableRectangleView
        }
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropView(image: NSImage())
    }
}
