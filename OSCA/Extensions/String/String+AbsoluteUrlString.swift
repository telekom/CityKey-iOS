//
//  String+AbsoluteUrlString.swift
//  SmartCity
//
//  Created by Michael on 16.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 *
 * Extension store weak objects like delegates in an array
 *
 */
extension String {

    
    func isAbsoluteUrlString() -> Bool
    {
        guard let urlstring = self.encodeUrl() else {
            debugPrint("no valid url found")
            return false
        }
        
        if urlstring.hasPrefix("http://") || urlstring.hasPrefix("https://"){
            return true
        }
        
        return false
    }
    
    func absoluteUrl() -> URL {
        guard let urlString = self.encodeUrl() else {
            debugPrint("no valid url found")
            return URL(string: "https://\(GlobalConstants.kSOL_Image_Domain)")!
        }
        if urlString.isAbsoluteUrlString() {
            return URL(string: urlString)!
        } else {
            return GlobalConstants.appendURLPathToSOLImageUrl(path: urlString, parameter: nil)
        }
    }

}
