//
//  SCBackgroundTaskManager.swift
//  OSCA
//
//  Created by Bharat Jagtap on 20/08/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCBackgroundTaskManager {
    
    private var tasks = [String: UIBackgroundTaskIdentifier]()
    public static let shared = SCBackgroundTaskManager()
    
    func startBackgroundTask(identifier : String) {
        
        if !tasks.keys.contains(identifier) {
            
            let taskIdentifier = UIApplication.shared.beginBackgroundTask(withName: identifier) {
                SCFileLogger.shared.write("Inside Expiration Handler : Ending Background Task \(identifier)", withTag: .logout)
                SCBackgroundTaskManager.shared.endBackgroundTask(identifier: identifier)
            }
            tasks[identifier] = taskIdentifier
            
        } else {
            
            SCFileLogger.shared.write("Can't start backgroundTask with identifier \(identifier) since it is already started ...", withTag: .logout)
        }
    }
    
    func endBackgroundTask(identifier : String) {
        
        if let taskIdentifier = tasks[identifier] {
                
            UIApplication.shared.endBackgroundTask(taskIdentifier)
            SCFileLogger.shared.write("Ended background Task with identifier \(taskIdentifier)", withTag: .logout)
            tasks.removeValue(forKey: identifier)
            
        } else {
            
            SCFileLogger.shared.write("Could not end background task with identifier \(identifier) , it could have been already ended", withTag: .logout)
        }
    }
    
}
