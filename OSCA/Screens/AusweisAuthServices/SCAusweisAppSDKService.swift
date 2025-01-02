//
//  SCAusweisAppSDKService.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import AusweisApp2

/*
 Below functions are provided by the AusweisApp2 SDK
    
 - `typedef void (* AusweisApp2Callback)(const char* pMsg);`
 - `bool ausweisapp2_init(AusweisApp2Callback pCallback);`
 - `void ausweisapp2_shutdown(void);`
 - `bool ausweisapp2_is_running(void);`
 - `void ausweisapp2_send(const char* pCmd);`
 
 */


/**
 **SCAusweisAppSDKServiceProvider**  is the protocol that sets the expectations from the AusweisApp2 SDK Service Class
 
 */
protocol SCAusweisAppSDKServiceProvider : AnyObject {
    
    /// to initialise the SDK
    static func initialiseSDK()
    /// to send the command to the SDK
    func sendCommand(command : String )
    // to process the message delivered by the SDK
    func processMessage(message : String)
    /// static property to get the shared instance of the the provider
    static var shared : SCAusweisAppSDKServiceProvider { get }
    /// handler/delegate for the messages received from the AusweisApp SDK
    var handler : SCAusweisAppSDKServiceHandling? { get set }
}

/**
 SCAusweisAppSDKService class that conforms the **SCAusweisAppSDKServiceProvider**  protocol. This is the end point fot interacting with the AusweisApp SDK
 
 */
class SCAusweisAppSDKService : SCAusweisAppSDKServiceProvider {
    
    static var shared: SCAusweisAppSDKServiceProvider { return _sharedInstance }
    static private let _sharedInstance = SCAusweisAppSDKService()
    weak var handler: SCAusweisAppSDKServiceHandling?
    
    // commandsQueue and isInitialised are supposed to queue up received commands and sends those to SDK once the SDK is initialised. Although this is not tested thoroughly and to be on the safer side SDK is initialised quite early in the flow to make sure when we send RUN_AUTH ( first command from the flow ) , the skd is already initialised
    var commandsQueue : [String]
    var isInitialised = false {
        
        didSet {

            if oldValue == false && isInitialised {
            
                for cmd in self.commandsQueue {
                    sendCommand(command: cmd)
                }
            }
        }
    }
    
    init() {
        
        commandsQueue = [String]()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessage(notification:)), name: Notification.Name.ausweisSDKServiceDidReceiveMessage , object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didInitialiseAusweisSDK(notification:)), name: Notification.Name.ausweisSDKServiceDidInititalise, object: nil)

        // AusweisApp2 SDK inititialisation call with callback block argument
        ausweisapp2_init ({ (message) in
            
            // when the sdk is initialised , it sends a nil message via the completion block , else you get different types of messages from the sdk
            guard let message = message else {
                            
                NotificationCenter.default.post(Notification(name: Notification.Name.ausweisSDKServiceDidInititalise , object: nil, userInfo: nil))
                return
            }

            let messageString = String(cString: message)
            NotificationCenter.default.post(Notification(name: Notification.Name.ausweisSDKServiceDidReceiveMessage, object: messageString, userInfo: nil))
        }, nil)

    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    /// called when SDK is intitialised
    @objc private func didInitialiseAusweisSDK(notification : Notification) {
        self.isInitialised = true
    }
    
    /// called when message is receiced from the SDK
    @objc private func didReceiveMessage(notification : Notification) {
        guard let messageString = notification.object as? String else { return }
        self.processMessage(message: messageString)
    }
    
}

extension SCAusweisAppSDKService  {
    
    static func initialiseSDK() { _ = SCAusweisAppSDKService.shared }
    
    /// to send the command to the SDK
    func sendCommand(command : String )  {
        
        if !isInitialised {
            commandsQueue.append(command)
        }
        debugPrint("Command Sent : \(command)")
        let cmd = UnsafeMutablePointer<Int8>(mutating: (command as NSString).utf8String)
        ausweisapp2_send(cmd)
    }
    
    // to process the message received from the SDK
    func processMessage(message : String)  {
        
        debugPrint("Message Received : \(message.debugDescription)")
        handler?.handleMessage(message: message)
        
    }      
}

