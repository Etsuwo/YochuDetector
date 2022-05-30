//
//  CGRect+Extension.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/05/26.
//

import Foundation

extension CGRect {
    func isSameCenter(at rect: CGRect, buffer: CGFloat) -> Bool {
        let xRange = rect.midX - buffer ... rect.midX + buffer
        let yRange = rect.midY - buffer ... rect.midY + buffer
        
        return xRange.contains(self.midX) && yRange.contains(self.midY)
    }
}
