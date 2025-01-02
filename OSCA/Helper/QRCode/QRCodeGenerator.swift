//
//  QRCodeGenerator.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 28/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class QRCodeGenerator {

    static func getQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)

            if let outputImage = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: outputImage)
            }
        }
        
        return nil
    }
}
