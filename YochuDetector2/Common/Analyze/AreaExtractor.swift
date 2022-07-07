//
//  AreaExtractor.swift
//  YochuDetector2
//
//  Created by Etsushi Otani on 2022/04/14.
//

import Foundation
import AppKit
import opencv2

final class AreaExtractor {
    func extractFeed(from image: NSImage, binaryThreshold: Double = 20) -> NSImage {
        let mat = Mat(nsImage: image)
        let resultMat = Mat(nsImage: image)
        var channels: [Mat] = []
        let areaThreshold = image.size.height * image.size.width * 0.05
        
        Imgproc.rectangle(img: resultMat, pt1: Point2i(x: 0, y: 0), pt2: Point2i(x: resultMat.size().width, y: resultMat.size().height / 2), color: Scalar(0, 0, 0), thickness: -1)
        Imgproc.cvtColor(src: resultMat, dst: resultMat, code: .COLOR_BGR2HSV)
        Imgproc.GaussianBlur(src: resultMat, dst: resultMat, ksize: Size2i(width: 9, height: 9), sigmaX: 0)
        Core.split(m: resultMat, mv: &channels)
        Imgproc.threshold(src: channels[1], dst: resultMat, thresh: binaryThreshold, maxval: 255, type: ThresholdTypes.THRESH_BINARY)
        var contours: [[Point2i]] = []
        let hierarchy = Mat()
        Imgproc.findContours(image: resultMat, contours: &contours, hierarchy: hierarchy, mode: RetrievalModes.RETR_LIST, method: ContourApproximationModes.CHAIN_APPROX_NONE)
        contours.forEach { contour in
            let contourMat = MatOfPoint(array: contour)
            if Imgproc.contourArea(contour: contourMat) > areaThreshold {
                Imgproc.fillPoly(img: mat, pts: [contour], color: Scalar(0))
            }
        }

        // 直接MatからtoNSImage()使うとメモリリークする
        let cgImage = mat.toCGImage()
        let nsImage = NSImage(cgImage: cgImage, size: image.size)
        return nsImage
    }
}
