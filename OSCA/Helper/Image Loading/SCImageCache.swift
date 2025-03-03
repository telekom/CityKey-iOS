/*
Created by Michael on 30.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
