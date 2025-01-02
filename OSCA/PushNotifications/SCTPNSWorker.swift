//
//  SCTPNSWorker.swift
//  OSCA
//
//  Created by A118572539 on 27/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol TPNSWorking {
    // API call to register a device for Push Notification
    func registerForPush(with additionalParameters: [String: String], registrationID: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void))
    
    func unRegisterForPush(completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void))
}

class SCTPNSWorker {
    
    let client: SCTPNSClient
    
    init(client: SCTPNSClient) {
        self.client = client
    }
}

extension SCTPNSWorker: TPNSWorking {
    
    func registerForPush(with additionalParameters: [String : String],
                         registrationID: String,
                         completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void)) {
        client.registerForPush(with: additionalParameters, registrationID: registrationID) { successful, error in
            // handle result and do mapping if required
        }
    }
    
    func unRegisterForPush(completion: @escaping ((Bool, SCWorkerError?) -> Void)) {
        client.unRegisterForPush { successful, error in
            // // handle result and do mapping if required
        }
    }
}
