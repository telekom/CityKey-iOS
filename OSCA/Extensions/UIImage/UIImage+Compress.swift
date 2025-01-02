//
//  UIImage+Compress.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 19/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func compressImageBelow(kb: Double, completion:(UIImage?, Data?) -> Void) {
        
        if let imageData = self.jpegData(compressionQuality: 0.5){
            
          var resizingImage = self
          var imageSizeKB = Double(imageData.count) / 1000.0
          var imgFinalData: Data = imageData
          while imageSizeKB > kb {
                if let resizedImage = resizingImage.resized(withPercentage: 0.9),
                    let imageData = resizedImage.jpegData(compressionQuality: 0.5) {
                    resizingImage = resizedImage
                    imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
                    imgFinalData = imageData
                    print("There were \(imageData.count) bytes")
                    let bcf = ByteCountFormatter()
                    bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                    bcf.countStyle = .file
                    let string = bcf.string(fromByteCount: Int64(imageData.count))
                    print("formatted result: \(string)")
                }
            }
            completion(self, imgFinalData);
        }
        completion(nil, nil);
    }

    func compressImage() -> UIImage{
        var ratioSquare: Double
        let bitmapHeight: Int = Int(self.size.height)
        let bitmapWidth: Int = Int(self.size.width)
        ratioSquare = Double(bitmapHeight * bitmapWidth / 1440000)
        if (ratioSquare <= 1) {
            return self
        }
        let ratio = sqrt(ratioSquare)
        let requiredHeight = round(Double(bitmapHeight) / ratio)
        let requiredWidth = round(Double(bitmapWidth) / ratio)
        let scaledImageSize = CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
        return UIGraphicsImageRenderer(size: scaledImageSize).image {
            _ in draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
    }
    
}
