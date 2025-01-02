//
//  SCImageLoader.swift
//  SmartCity
//
//  Created by Michael on 30.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

enum SCImageLoaderError: Error {
    case CallFailed
    case noDataAvailable
    case CorruptedData
}

extension SCImageLoaderError: LocalizedError {
    
    
    public var errorDescription: String? {
        switch self {
        case .CallFailed:
            return NSLocalizedString("Image couldn't be loaded.", comment: "Error")
            
        case .noDataAvailable:
            return NSLocalizedString("No data for image available.", comment: "Error")
            
        case .CorruptedData:
            return NSLocalizedString("Image data not valid.", comment: "Error")
        }
    }
}

typealias imageLoadercompletionHandler = (_ image: UIImage?, _ error:SCImageLoaderError?) -> Void

class SCImageLoader {
    

    static let sharedInstance = SCImageLoader()
    
    var session : URLSession = URLSession()
    
    private let loaderQueue = SCImageLoaderQueue()

    private let maxRequests = 4
    private var requestsInProgress = 0
    
    private init() {
        setupSession()
    }

    private func setupSession() {
        let config = URLSessionConfiguration.ephemeral
        config.httpMaximumConnectionsPerHost = 8
        self.session = URLSession(configuration: config)
        self.session.configuration.httpMaximumConnectionsPerHost = 8
    }
    // Cancel all downloads
    func cancel() {
        self.session.invalidateAndCancel()
        setupSession()
        self.requestsInProgress = 0
        self.loaderQueue.flush()
    }

    // Prefetch an Image and save it to the cache
    func prefetchImage(imageURL: SCImageURL) {
//        loaderQueue.addImageRequest(with: imageURL, priority: .low, completion: nil)
//        SCUtilities.delay(withTime: 0.0, callback: {self.processQueuedTasks()})
    }
    func getImage(with imageURL: SCImageURL, completion: imageLoadercompletionHandler?) {
        print(imageURL.absoluteUrlString())
        completion?(UIImage(named: imageURL.absoluteUrlString()), nil)
//        loaderQueue.addImageRequest(with: imageURL, priority: .high, completion: completion)
//        SCUtilities.delay(withTime: 1.0, callback: {self.processQueuedTasks()})
    }
    
    func cancelImageRequest(for imageURL: SCImageURL) {
//        loaderQueue.removeRequest(url: imageURL)
//        SCUtilities.delay(withTime: 1.0, callback: {self.processQueuedTasks()})
    }

    func processQueuedTasks() {
       // debugPrint("inside processQueuedTasks")
        if requestsInProgress < maxRequests{
            if let url = self.loaderQueue.getNextRequest() {
                downloadImage(with: url)
                requestsInProgress += 1
            } else {
                requestsInProgress = 0
            }
        }
    }
    
    // Load an Image
    private func downloadImage(with url: SCImageURL) {
        //debugPrint("downloadImage for \(url.absoluteUrl())")
        let imageDataTask = session.dataTask(with: url.absoluteUrl(), completionHandler: { [weak self] (data, response, error) in
            //usleep(1000000)
            DispatchQueue.main.async {
                
                let completionHandlers =  self?.loaderQueue.getCompletionHandlers(for: url) ?? []
                self?.loaderQueue.removeRequest(url: url)
                self?.requestsInProgress -= 1


                if response != nil {
                    let httpResponse:HTTPURLResponse = response as! HTTPURLResponse
                    
                    if httpResponse.statusCode != 200 {
                        debugPrint("LazyImage status code : \(httpResponse.statusCode)")
                        
                        //Completion block
                        //Call did not succeed
                        let error: SCImageLoaderError = SCImageLoaderError.CallFailed
                        for handler in completionHandlers {
                            handler(nil, error)
                        }
                        return
                    }
                }
                
                if data == nil {
                    if error != nil {
                    }
                    debugPrint("LazyImage: No image data available")
                    
                    //No data available
                    let error: SCImageLoaderError = SCImageLoaderError.noDataAvailable
                    for handler in completionHandlers {
                        handler(nil, error)
                    }
                    return
                }
                
                
                if let image = UIImage(data:data!, scale: 3.0) {
                    
                     //Image path
                    let imagePath:String? = url.storagePathforImage()

                    // save Image in cache, but not more than with 400*400 points
                    SCImageCache.saveImage(image: image.resizedImageWithinRect(rectSize: CGSize(width: 400.0, height: 400.0), withScale: true), imagePath: imagePath!, lazyWriting: url.canBeStoredLazy())
                    
                    for handler in completionHandlers {
                        handler(image, nil)
                    }

                    SCUtilities.delay(withTime: 1.0, callback: {self?.processQueuedTasks()})

                } else {
                    let error: SCImageLoaderError = SCImageLoaderError.CorruptedData
                    for handler in completionHandlers {
                        handler(nil, error)
                    }
                }
                
                return
                
            }
        })
        
        imageDataTask.resume()

    }
    
}
