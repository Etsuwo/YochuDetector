//
//  TrimmingView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/25.
//

import SwiftUI

struct TrimmingView: View {
    
    private let viewModel = TrimmingViewModel()
    private var image: NSImage {
        NSImage.withOptionalURL(url: viewState.url)
    }
    private var cropView: CropView {
        CropView(image: image)
    }
    @ObservedObject private var viewState: TrimmingViewModel.ViewState
    
    init() {
        viewState = viewModel.viewState
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    cropView
                        .frame(maxWidth: .infinity)
                        .onPreferenceChange(EditableRectangleFrameKey.self, perform: {
                            viewModel.updateCropArea(rect: $0)
                        })
                        .onPreferenceChange(EditableRectangleViewSizeKey.self, perform: {
                            viewModel.updateCropViewSize(size: $0)
                        })
                        .isHidden(viewState.cropViewIsHidden)
                    Image(nsImage: viewState.croppedImage)
                        .resizable()
                        .scaledToFit()
                        .isHidden(viewState.croppedViewIsHidden)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    viewModel.onTapTrimButton(image: image)
                }, label: {
                    Text("切り取る")
                })
                    .isHidden(viewState.cropViewIsHidden)
                Button(action: {
                    viewModel.onTapReturnButton()
                }, label: {
                    Text("戻す")
                })
                    .isHidden(viewState.croppedViewIsHidden)
                Spacer()
                Button(action: {
                    viewModel.onTapGoButton()
                }, label: {
                    Text("GO!!!!!")
                })
                Spacer()
                    .frame(width: 24)
            }
            .padding()
        }
        
    }
}

struct TrimmingView_Previews: PreviewProvider {
    static var previews: some View {
        TrimmingView()
    }
}
