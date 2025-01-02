//
//  SCNetworkCallsExecutor.swift
//  OSCA
//
//  Created by A118572539 on 27/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCNetworkCallsExecutor {
    
    init() {}
    
    public func executeRequest(with request: URLRequest,
                               configuration: URLSessionConfiguration = .default,
                               maxAttempts: UInt? = 0,
                               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession(configuration: configuration).dataTask(with: request) { [weak self] (data, response, error)  in
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandler(data, response, error)
                return
            }
            
            switch httpStatusCode {
            // Handling all server related errors with retry mechanism
            case 500...599:
                SCUtilities.delay(withTime: 60.0) {
                    if let retryCount = maxAttempts, retryCount > 0 {
                        self?.executeRequest(with: request,
                                             configuration: configuration,
                                             maxAttempts: retryCount - 1,
                                             completionHandler: completionHandler)
                    }
                }
            default:
                completionHandler(data, response, error)
            }
        }.resume()
    }
}
