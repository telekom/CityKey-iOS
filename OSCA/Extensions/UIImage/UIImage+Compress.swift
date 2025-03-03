/*
Created by Harshada Deshmukh on 19/05/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/


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
