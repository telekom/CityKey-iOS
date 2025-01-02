//
//  SCImageCache.swift
//  SmartCity
//
//  Created by Michael on 30.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import func AVFoundation.AVMakeRect
class SCImageCache {
    
    static func saveImage(image:UIImage, imagePath:String, lazyWriting: Bool) {
        
        //Store image to the temporary folder for later use
        var error: NSError?

        let pngImage = image.pngData()!

        let saveImage = {
            do {
                try pngImage.write(to: URL(fileURLWithPath: imagePath), options: [.noFileProtection, .atomicWrite])
            } catch let error1 as NSError {
                error = error1
                if let actualError = error {
                    debugPrint("Image not saved. \(actualError)")
                }
            } catch {
                debugPrint("Error: Couldn't write Cache!")
            }
        }
        
        if lazyWriting {
            DispatchQueue.global(qos: .background).async {
                saveImage()
            }
        } else {
            saveImage()
        }

    }
    
    
    static func readImage(imagePath:String, completion: @escaping (_ error:UIImage?) -> Void) -> Void {
        var image:UIImage?
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                //Image exists
                let dat:Data = imageData
                
                image = UIImage(data:dat, scale: 2.0)
            }
        completion(image)
    }
    
    
    //MARK: - Clear cache for non  persitent files
    static func clearCache() {
        var removed: Int = 0
        do {
            
            // Delete all files from the temporary directory
            let tmpDirURL = URL(string: SCImageURL.cachesDir())!
            let tmpFiles = try FileManager.default.contentsOfDirectory(at: tmpDirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            debugPrint("\(tmpFiles.count) temporary files found")
            for url in tmpFiles {
                removed += 1
                try FileManager.default.removeItem(at: url)
            }
            debugPrint("\(removed) temporary files removed")
        } catch {
            debugPrint("\(removed) temporary files removed")
        }    }
    
    //MARK - Check image existence
    
    
    /// Checks if image exists in storage
    ///
    /// - Parameter url: The image URL
    /// - Returns: returns the image path or nil if image does not exists
    static func checkIfImageExists(with url:SCImageURL) -> String? {
        
        //Image path
        var imagePath:String? = url.storagePathforImage()
        
        //Check if image exists
        let imageExists:Bool = FileManager.default.fileExists(atPath: imagePath!)
        
        if !imageExists {
            imagePath = nil
        }
        
        return imagePath
    }
    
}
