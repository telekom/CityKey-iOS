//
//  NSString+Base64.swift
//  SmartCity
//
//  Created by Michael on 04.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

extension String {
    
    
    // returns an Image from a base64 String
    func imageFromBase64() -> UIImage? {
        guard let data = Data(base64Encoded: self) else { return nil }
        
        return UIImage(data: data)
    }
}
