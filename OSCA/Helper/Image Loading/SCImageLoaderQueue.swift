/*
Created by Michael on 15.11.18.
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

class SCImageLoaderQueue: NSObject {

    enum SCImageLoaderQueuePriority{
        case high
        case low
    }

    enum SCImageLoaderQueueStatus{
        case queued
        case inProgress
    }
    

    private var tasks = [SCImageURL: [imageLoadercompletionHandler]]()
    private var tasksPriority = [SCImageURL: SCImageLoaderQueuePriority]()
    private var tasksStatus = [SCImageURL: SCImageLoaderQueueStatus]()
    private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)

    // Load an Image or get it from the Cache via cempletion handler
    func addImageRequest(with imageURL: SCImageURL, priority: SCImageLoaderQueuePriority, completion: imageLoadercompletionHandler?) {
        // Check if the URL was already cached ?
        var containsURL = false
        
        if let cachedImageString = SCImageCache.checkIfImageExists(with: imageURL) {
            
            // If there is no completion Handler then we should return, because we don't need to get a cached image
            if let completionhandler = completion {
                SCImageCache.readImage(imagePath: cachedImageString) {
                    
                    (image:UIImage?) in
                    
                    if let image = image {
                        //Image read successfully
                        completionhandler (image, nil)
                    } else {
                        completionhandler(nil,.CorruptedData)
                    }
                }
            }
            return
        }
        
        // if we need to load the image, because it is not cached, we need to add it in the tasks
        
        self.accessQueue.sync {
            containsURL = tasks.keys.contains(imageURL)
            
            if containsURL {
                if let completionhandler = completion {

                    self.tasks[imageURL]?.append(completionhandler)
                    // if the priority is higher than the priority from the existing entry, then we should update the value in the dict
                    if self.tasksPriority[imageURL] == .low && priority == .high{
                        self.tasksPriority[imageURL] = .high
                        //debugPrint("CHANGED PRIO TO HIGH")

                    }

                }
            } else {

                if let completionhandler = completion {
                    self.tasks[imageURL] = [completionhandler]
                } else {
                    let emptyCompletion : imageLoadercompletionHandler = {_,_ in}
                    self.tasks[imageURL] = [emptyCompletion]
                }
                self.tasksPriority[imageURL] = priority
                self.tasksStatus[imageURL] = .queued
            }

        }

    }
    
    func getNextRequest() -> SCImageURL?{
        var highPrioURL : SCImageURL?

        self.accessQueue.sync {
            for (key, _) in tasks{
                if tasksStatus[key] == .queued {
                    highPrioURL = key

                    self.tasksStatus[highPrioURL!] = .inProgress
                    break
                }
            }
        }

        return highPrioURL
    }

    func getCompletionHandlers(for url: SCImageURL) -> [imageLoadercompletionHandler]{
        var handlers = [imageLoadercompletionHandler]()
        
        self.accessQueue.sync {
            if let th = tasks[url] {
                handlers = th
            }
        }

        return handlers
    }

    func removeRequest(url: SCImageURL){
        self.accessQueue.async(flags:.barrier) {
            self.tasks.removeValue(forKey: url)
            self.tasksPriority.removeValue(forKey: url)
            self.tasksStatus.removeValue(forKey: url)
        }

    }

    func flush(){
        self.accessQueue.async(flags:.barrier) {
            self.tasks = [SCImageURL: [imageLoadercompletionHandler]]()
            self.tasksPriority = [SCImageURL: SCImageLoaderQueuePriority]()
            self.tasksStatus = [SCImageURL: SCImageLoaderQueueStatus]()
        }
        
    }

    
}
