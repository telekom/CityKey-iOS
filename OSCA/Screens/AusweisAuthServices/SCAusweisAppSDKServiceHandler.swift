//
//  SCAusweisAppSDKServiceHandler.swift
//  OSCA
//
//  Created by Bharat Jagtap on 27/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

/**
 SCAusweisCommand is the command object used through out the AusweisApp2 Auth Workflow implementation.
 Each case represents a specific command in the workflow
 */
enum SCAusweisCommand {
    /// First command after SDK is initialised . This triggers the authentication process
    case RUN_AUTH (tcTokenURL : String)
    /// To get the Certificate details
    case GET_CERTIFICATE
    /// To accept the certificate and access rights info provided by the SDK. This is needed to let SDK know that user has accepted on what kind of data would be read from the card
    case ACCEPT
    /// To send the PIN  for the card entered by the user
    case SET_PIN(pin : String)
    /// To send the CAN  for the card entered by the user
    case SET_CAN(can : String)
    /// To send the PUK  for the card entered by the user
    case SET_PUK(puk : String)
    /// To cancel the authentication workflow at any point in the workflow process
    case CANCEL
    /// Interrupts current system dialog
    case INTERRUPT
    
    /**
        returns the payload of the command in a regular string format. This payload is what is sent to the SDK as a command
     
     - Returns : payload string for command to tbe sent to the SDK
     */
    
    func payload() -> String {
        
        switch self {
        
        case .RUN_AUTH (let tcTokenURL):
            
            let jsonDic = [ "cmd" : "RUN_AUTH",
                            "tcTokenURL" : tcTokenURL.decodeUrl()]
            return convertToJSONString(jsonDic: jsonDic as Dictionary<AnyHashable, Any>)
            
        case .GET_CERTIFICATE :
            let jsonDic = [ "cmd" : "GET_CERTIFICATE"]
            return convertToJSONString(jsonDic: jsonDic)
            
        case .ACCEPT :
            let jsonDic = [ "cmd" : "ACCEPT"]
            return convertToJSONString(jsonDic: jsonDic)

        case .SET_PIN (let pin):
            let jsonDic = [ "cmd" : "SET_PIN",
                            "value": pin]
            return convertToJSONString(jsonDic: jsonDic)

        case .SET_CAN(let can):
            let jsonDic = [ "cmd" : "SET_CAN",
                            "value": can]
            return convertToJSONString(jsonDic: jsonDic)

        case .SET_PUK(let puk):
            let jsonDic = [ "cmd" : "SET_PUK",
                            "value": puk]
            return convertToJSONString(jsonDic: jsonDic)

        case .CANCEL:
            let jsonDic = [ "cmd" : "CANCEL"]
            return convertToJSONString(jsonDic: jsonDic)
            
        case .INTERRUPT:
            let jsonDic = ["cmd" : "INTERRUPT"]
            return convertToJSONString(jsonDic: jsonDic)

        }
                
    }
    /**
            method to concert dictionary to JSON string
     */
    private func convertToJSONString(jsonDic : Dictionary<AnyHashable,Any> ) -> String {
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted) {
            return String(data: jsonData, encoding: .utf8) ?? ""
        }
        return ""
    }
    
    /**
        Helper method that returns the name of the command.
        To compare two commands.
        
     ** This can be improved if there is a better way to compare two enums with associated values
     */
    func cmd() -> String {
        
        switch self {
        case .RUN_AUTH ( _ ):
            return "RUN_AUTH"
        case .GET_CERTIFICATE :
            return "GET_CERTIFICATE"
        case .ACCEPT :
            return "ACCEPT"
        case .SET_PIN ( _ ):
            return "SET_PIN"
        case .SET_CAN( _ ):
            return "SET_CAN"
        case .SET_PUK( _ ):
            return "SET_PUK"
        case .CANCEL:
            return "CANCEL"
        case .INTERRUPT:
            return "INTERRUPT"
        }
    }
            
}

/**
 **SCAusweisMessage** is the object that will be used through out the workflow implementation for representing the message received from the SDK. Each case represents a specific message that SDK sends time to time
 */

enum SCAusweisMessage {
    /// represents the AUTH message
    case AUTH (payload : [String:Any])
    /// represents the ACCESS_RIGHTS message
    case ACCESS_RIGHTS (payload : [String:Any], model : SCModelAusweisAccessRights?)
    /// represents the CERTIFICATE message
    case CERTIFICATE (payload : [String:Any], model : SCModelAusweisCertificate?)
    /// represents the INSERT_CARD message
    case INSERT_CARD (payload : [String:Any])
    /// represents the ENTER_PIN message
    case ENTER_PIN(payload : [String: Any], model : SCModelAusweisEnterPin?)
    /// represents the READER message
    case READER(payload : [String: Any], model : SCModelAusweisReader?)
    /// represents the ENTER_CAN message
    case ENTER_CAN(payload : [String: Any], model : SCModelAusweisEnterCan?)
    /// represents the ENTER_PUK message
    case ENTER_PUK(payload : [String: Any], model : SCModelAusweisEnterPuk?)
    /// represents the BAD_STATE message
    case BAD_STATE (payload : [String:Any])
    /// represents the error case from the SDK. Not a standard message from the SDK but to handle errors internally
    case MESSAGE_ERROR
    /// provides information about the current workflow and state
    case STATUS
    
    /**
            convinience method to construct the message object with message type name and respective the payload
     */
    static func messageWith(msg : String , payload : [String: Any] ) -> SCAusweisMessage {
        switch msg {
        case "AUTH":
            return .AUTH(payload: payload)
        case "ACCESS_RIGHTS":
            return .ACCESS_RIGHTS(payload: payload, model : nil )
        case "CERTIFICATE":
            return .CERTIFICATE(payload: payload , model : nil)
        case "INSERT_CARD":
            return .INSERT_CARD(payload: payload)
        case "BAD_STATE":
            return .BAD_STATE(payload: payload)
        case "ENTER_PIN":
            return .ENTER_PIN(payload: payload, model : nil )
        case "ENTER_CAN":
            return .ENTER_CAN(payload: payload, model : nil )
        case "ENTER_PUK":
            return .ENTER_PUK(payload: payload, model : nil )
        case "READER":
            return .READER(payload: payload, model : nil )
        case "STATUS":
            return .STATUS
        default:
            return .MESSAGE_ERROR
        }
    }    
    
    /**
        - Returns payload received with the message
     */
    func payload() -> [AnyHashable:Any] {
        switch self {
        case .AUTH(let payload):
            return payload
        case .ACCESS_RIGHTS(let payload, _ ):
            return payload
        case .CERTIFICATE(let payload, _ ):
            return payload
        case .INSERT_CARD(let payload):
            return payload
        case .BAD_STATE(let payload):
            return payload
        case .ENTER_PIN(let payload, _ ):
            return payload
        case .READER(let payload, _ ):
            return payload
        case .ENTER_CAN(let payload, _ ):
            return payload
        case .ENTER_PUK(let payload, _ ):
            return payload
        default:
            return [AnyHashable:Any]()
        }
    }
}

/**
 protocol that sets the expectaions from the Service Handler object
*/
protocol SCAusweisAppSDKServiceHandling : AnyObject {
    
    func handleMessage(message : String)
    func sendCommand(command : SCAusweisCommand)
    var worker : SCAusweisAuthWorking? { get set }
}
/**
 **SCAusweisAppSDKServiceHandler** is the handler that communicates with SDK Service and Worker
 - service handler is the mediator between the SDK Service and the AuthWorker
 - It receives the command in the SCAusweisCommand object and send the SCAusweisMessage object to the worker

 */
class SCAusweisAppSDKServiceHandler {
    
    var service : SCAusweisAppSDKServiceProvider
    weak var worker: SCAusweisAuthWorking?
    
    init(service : SCAusweisAppSDKServiceProvider ) {
        self.service = service
    }
    
    /**
        - Returns the SCAusweisMessage object from the passed in message which is the json payload of the message received from the SDK
        - For easy handling , payloads from certain messages are translated into model objects , rest are simply maintained as the payload objects
     */
    private func parseJSONMessage(message : String ) -> SCAusweisMessage {
        
        guard let data = message.data(using: .utf8) else { return .MESSAGE_ERROR }
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let msg = (jsonObject as? [String : Any])?["msg"] as? String else { return .MESSAGE_ERROR }
        
        var message : SCAusweisMessage
        
        if msg == "CERTIFICATE" {
            
            if let modelCertificte = try? JSONDecoder().decode(SCHTTPModelAusweisCertificate.self, from: data) {
                message = .CERTIFICATE(payload: jsonObject as! [String:Any], model: modelCertificte.toModel())
            } else {
                message = .CERTIFICATE(payload: jsonObject as! [String:Any], model: nil)
            }
            
        } else if msg == "ACCESS_RIGHTS" {
           
            debugPrint("Inside Acces Rights ")
            if let modelAccessRights = try? JSONDecoder().decode(SCHTTPModelAusweisAccessRights.self, from: data) {
                message = .ACCESS_RIGHTS(payload: jsonObject as! [String:Any], model: modelAccessRights.toModel())
            } else {
                message = .ACCESS_RIGHTS(payload: jsonObject as! [String:Any], model: nil)
            }
            
        } else if msg == "ENTER_PIN" {
           
            debugPrint("Inside Enter Pin ")
            if let modelEnterPin = try? JSONDecoder().decode(SCHTTPModelAusweisEnterPin.self, from: data) {
                message = .ENTER_PIN(payload: jsonObject as! [String:Any], model: modelEnterPin.toModel())
            } else {
                message = .ENTER_PIN(payload: jsonObject as! [String:Any], model: nil)
            }
            
        } else if msg == "ENTER_CAN" {
            
            debugPrint("Inside Enter Can ")
            if let modelEnterCan = try? JSONDecoder().decode(SCHTTPModelAusweisEnterCan.self, from: data) {
                message = .ENTER_CAN(payload: jsonObject as! [String:Any], model: modelEnterCan.toModel())
            } else {
                message = .ENTER_CAN(payload: jsonObject as! [String:Any], model: nil)
            }
            
        } else if msg == "ENTER_PUK" {
            
            debugPrint("Inside Enter Puk ")
            if let modelEnterPuk = try? JSONDecoder().decode(SCHTTPModelAusweisEnterPuk.self, from: data) {
                message = .ENTER_PUK(payload: jsonObject as! [String:Any], model: modelEnterPuk.toModel())
            } else {
                message = .ENTER_PUK(payload: jsonObject as! [String:Any], model: nil)
            }            
        } else if msg == "READER" {
            
            debugPrint("Inside Reader ")
            if let modelReader = try? JSONDecoder().decode(SCHTTPModelAusweisReader.self, from: data) {
                message = .READER(payload: jsonObject as! [String:Any], model: modelReader.toModel())
            } else {
                message = .READER(payload: jsonObject as! [String:Any], model: nil)
            }
        } else if msg == "STATUS" {
            message = .STATUS
        } else {
            message = SCAusweisMessage.messageWith(msg: msg, payload: jsonObject as! [String:Any])
        }
        
        return message
    }
     
}

extension SCAusweisAppSDKServiceHandler : SCAusweisAppSDKServiceHandling {
    
    func handleMessage(message : String) {
        // parse the message
        // create Message object
        // pass on the message to Worker
        let message = parseJSONMessage(message: message)
        worker?.messageReceived(message: message)
        debugPrint("** Message Received : \(message.payload())")
        SCFileLogger.shared.write("** Message Received : \(message.payload())", withTag: .ausweis)
    }
        
    func sendCommand(command : SCAusweisCommand) {
        service.sendCommand(command: command.payload())
        debugPrint("** Command Sent : \(command.payload())")
        SCFileLogger.shared.write("** Command Sent : \(command.payload())", withTag: .ausweis)
    }

}
