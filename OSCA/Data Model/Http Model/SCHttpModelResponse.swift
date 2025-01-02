//
//  SCModelHttpResponse.swift
//  SmartCity
//
//  Created by telekom on 26.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

typealias SCHTTPCode = Int

enum SCHttpStatus: String, Decodable {
    case ok1 = "OK"
    case ok2 = "200 OK"
    case ok3 = "200"
    case noContent = "204 NO_CONTENT"
    case unauthorized = "401 UNAUTHORIZED"
    case badRequest = "400 BAD_REQUEST"
    case internalServerError = "Internal Server Error"
    case unknown
    
    init(from decoder: Decoder) throws {
        let status = try decoder.singleValueContainer().decode(String.self)
        self = SCHttpStatus(rawValue: status) ?? .unknown
        if self == SCHttpStatus.unknown { debugPrint("Unknown status detected", status) }
    }
    
    func isOK() -> Bool {
        switch self {
        case .ok1, .ok2, .ok3:
            return true
        default:
            return false
        }
    }
}

struct HttpModelResponse<ContentModel: Decodable>: Decodable {
    let content: ContentModel?
}

struct SCHttpModelResponse<ContentModel: Decodable>: Decodable {
    let content: ContentModel
}

struct SCHttpModelBaseResponse: Decodable {
    let errors: [SCHttpErrorModel]?
}

struct SCHttpErrorModel: Decodable {
    let errorCode: String
    let userMsg: String
}

struct SCHttpErrorObjModel: Decodable {
    let field: String
    let userMsg: String
    
    func toModel() -> SCErrorObject {
        
        return SCErrorObject(field: field, userMsg: userMsg)
    }

}

struct SCErrorObject {
    let field: String
    let userMsg: String
}
