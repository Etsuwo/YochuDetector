//
//  EditableRectangleView.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/01/29.
//

import SwiftUI

struct EditableRectangleView: View {
    @State var topSpacerHeight: CGFloat = 50
    @State var bottomSpacerHeight: CGFloat = 50
    @State var leadingSpacerWidth: CGFloat = 50
    @State var trailingSpacerWidth: CGFloat = 50
    private let frame: CGFloat = 20
    private let spacing: CGFloat = 0
    let minFrame: CGFloat = 100
    
    func tapTopLeading(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateLeadingSpace(rectangleSize: viewSize, transitionX: value.translation.width)
                updateTopSpace(rectangleSize: viewSize, transitionY: value.translation.height)
            }
    }
    
    func tapTopCenter(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateTopSpace(rectangleSize: viewSize, transitionY: value.translation.height)
            }
    }
    
    func tapTopTrailing(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateTopSpace(rectangleSize: viewSize, transitionY: value.translation.height)
                updateTrailingSpace(rectangleSize: viewSize, transitionX: value.translation.width)
            }
    }
    
    func tapCenterLeading(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateLeadingSpace(rectangleSize: viewSize, transitionX: value.translation.width)
            }
    }
    
    func tapCenterCenter(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let transitionX = value.translation.width
                let transitionY = value.translation.height
                if topSpacerHeight + transitionY > 0 && bottomSpacerHeight - transitionY > 0 {
                    topSpacerHeight += transitionY
                    bottomSpacerHeight -= transitionY
                }
                if leadingSpacerWidth + transitionX > 0 && trailingSpacerWidth - transitionX > 0 {
                    leadingSpacerWidth += transitionX
                    trailingSpacerWidth -= transitionX
                }
            }
    }
    
    func tapCenterTrailing(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateTrailingSpace(rectangleSize: viewSize, transitionX: value.translation.width)
            }
    }
    
    func tapBottomLeading(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateLeadingSpace(rectangleSize: viewSize, transitionX: value.translation.width)
                updateBottomSpace(rectangleSize: viewSize, transitionY: value.translation.height)
            }
    }
    
    func tapBottomCenter(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateBottomSpace(rectangleSize: viewSize, transitionY: value.translation.height)
            }
    }
    
    func tapBottomTrailing(viewSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                updateTrailingSpace(rectangleSize: viewSize, transitionX: value.translation.width)
                updateBottomSpace(rectangleSize: viewSize, transitionY: value.translation.height)
            }
    }
    
    func updateLeadingSpace(rectangleSize: CGSize, transitionX: CGFloat) {
        if rectangleSize.width - transitionX > minFrame,
           leadingSpacerWidth + transitionX > 0 {
            leadingSpacerWidth += transitionX
        }
    }
    
    func updateBottomSpace(rectangleSize: CGSize, transitionY: CGFloat) {
        if rectangleSize.height + transitionY > minFrame,
           bottomSpacerHeight - transitionY > 0 {
            bottomSpacerHeight -= transitionY
        }
    }
    
    func updateTrailingSpace(rectangleSize: CGSize, transitionX: CGFloat) {
        if rectangleSize.width + transitionX > minFrame,
           trailingSpacerWidth - transitionX > 0 {
            trailingSpacerWidth -= transitionX
        }
    }
    
    func updateTopSpace(rectangleSize: CGSize, transitionY: CGFloat) {
        if rectangleSize.height - transitionY > minFrame,
           topSpacerHeight + transitionY > 0 {
            topSpacerHeight += transitionY
        }
    }
    
    var body: some View {
            VStack {
                Spacer()
                    .frame(height: topSpacerHeight)
                HStack {
                    Spacer()
                        .frame(width: leadingSpacerWidth)
                    GeometryReader { geometry in
                        ZStack {
                            Rectangle()
                                .stroke(lineWidth: 2)
                                .fill(Color.red)
                            VStack(spacing: spacing) {
                                HStack(spacing: spacing) {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: frame)
                                        .contentShape(Rectangle())
                                        .gesture(tapTopLeading(viewSize: geometry.size))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(tapTopCenter(viewSize: geometry.size))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: frame)
                                        .contentShape(Rectangle())
                                        .gesture(tapTopTrailing(viewSize: geometry.size))
                                }
                                .frame(height: frame)
                                HStack(spacing: spacing) {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: frame)
                                        .contentShape(Rectangle())
                                        .gesture(tapCenterLeading(viewSize: geometry.size))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(tapCenterCenter(viewSize: geometry.size))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: frame)
                                        .contentShape(Rectangle())
                                        .gesture(tapCenterTrailing(viewSize: geometry.size))
                                }
                                HStack(spacing: spacing) {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: frame)
                                        .contentShape(Rectangle())
                                        .gesture(tapBottomLeading(viewSize: geometry.size))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(tapBottomCenter(viewSize: geometry.size))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: frame)
                                        .contentShape(Rectangle())
                                        .gesture(tapBottomTrailing(viewSize: geometry.size))
                                }
                                .frame(height: frame)
                            }
                        }
                    }
                    Spacer()
                        .frame(width: trailingSpacerWidth)
                    }
                Spacer()
                    .frame(height: bottomSpacerHeight)
            }
    }
}

struct EditableRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        EditableRectangleView()
    }
}
