//
//  SCImageLoaderQueue.swift
//  SmartCity
//
//  Created by Michael on 15.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
