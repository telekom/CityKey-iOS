//
//  UIImage+Base64.swift
//  SmartCity
//
//  Created by Michael on 04.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

extension UIImage {
    
    // Returns as JPEG Base64 String from an UIImage
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.7) else { return nil }
        return imageData.base64EncodedString()
    }
    
}
