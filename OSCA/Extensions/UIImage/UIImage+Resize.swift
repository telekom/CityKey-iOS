//
//  UIImage+Resize.swift
//  SmartCity
//
//  Created by Michael on 04.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize, withScale: Bool) -> UIImage {
        
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        if withScale {
            UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale);
        } else {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        }

        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize, withScale: Bool) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if heightFactor > widthFactor{
            resizeFactor = heightFactor
        }
        
        // if image doesn't needs to resized becasue it smaller thena the frame and it is in landscape
        if resizeFactor < 1.0  && widthFactor < heightFactor{
            return self
        }
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize, withScale: withScale)
        return resized
    }
}
