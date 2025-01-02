//
//  SCRequestMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 10/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class SCRequestMock: SCDataFetching, SCRequestCreating {
    private let successResponse: Data?
    private let errorResponse: SCRequestError?
    
    init(successResponse: Data? = nil, errorResponse: SCRequestError? = nil) {
        self.successResponse = successResponse
        self.errorResponse = errorResponse
    }
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        if let successResponse = successResponse {
            completion(.success(successResponse))
        } else if let errorResponse = errorResponse {
            completion(.failure(errorResponse))
        } else {
            completion(.from(error: SCWorkerError.technicalError))
        }
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        if let successResponse = successResponse {
            completion(.success(successResponse))
        } else {
            completion(.failure(SCRequestError.noInternet))
        }
    }
    
    func cancel() {
        
    }
    
    func createRequest() -> SCDataFetching {
        SCRequestMock(successResponse: successResponse, errorResponse: errorResponse)
    }
}
