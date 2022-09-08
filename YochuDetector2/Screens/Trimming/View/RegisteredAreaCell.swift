//
//  RegisteredAreaView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/30.
//

import SwiftUI

struct RegisteredAreaCell: View {
    
    @State private var isHover = false
    
    let numOfTarget: Int
    let startAt: Int
    let image: NSImage
    let onTappedbutton: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: 2)
                .fill(Color.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                VStack {
                    Text("試験管: \(numOfTarget)")
                    Text("スタート: \(startAt)分")
                }
                if isHover {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.gray)
                        .onTapGesture {
                            onTappedbutton()
                        }
                }
                Spacer()
                
            }
        }
        .frame(height: 50)
        .onHover(perform: { isHovered in
            isHover = isHovered
        })
    }
}

//struct RegisteredAreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisteredAreaCell(numOfTarget: 5, image: NSImage(), onTappedbutton: {})
//    }
//}
