//
//  SCWorker.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 22.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

enum SCWorkerError: Error, Equatable {
    case unauthorized
    case noInternet
    case technicalError
    case fetchFailed(SCWorkerErrorDetails)
    
    static func == (lhs: SCWorkerError, rhs: SCWorkerError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized):
            return true
        case (.noInternet, .noInternet):
            return true
        case (.technicalError, .technicalError):
            return true
        case (.fetchFailed(let lhsType), .fetchFailed(let rhsType)):
            return lhsType == rhsType
        default:
            return false
        }
    }
}

struct SCWorkerErrorDetails: Error, Equatable {
    let message: String
    let errorCode: String?

    init(message: String, errorCode: String? = nil) {
        self.message = message
        self.errorCode = errorCode
    }
}

enum SCWorkerDataLoadingState {
    // data needs to be fetched
    case needsToBefetched
    // data fetching in progress
    case fetchingInProgress
    // last fetching was successful
    case fetchedWithSuccess
    // last fetching did fail
    case fetchFailed
    // sol backend action not available for city
    case backendActionNotAvailableForCity
    
    static func getStateFor(errorCode: String?) -> SCWorkerDataLoadingState {
        switch errorCode {
        case "action.not.available.for.city" :
            return .backendActionNotAvailableForCity
        default :
            return .fetchFailed
        }
    }
    
}

struct SCWorkerDataState {
    // true when the date were once fetched with success
    var dataInitialized = false
    var dataLoadingState : SCWorkerDataLoadingState = .needsToBefetched
}

class SCWorker {
    private var cancelableRequests = [SCDataFetching]()
    
    public var request: SCDataFetching {
        get {
            return requestFactory.createRequest()
        }
    }

    public var cancelableRequest: SCDataFetching {
        get {
            let cRequest = requestFactory.createRequest()
            self.cancelableRequests.append(cRequest)
            return cRequest
        }
    }

    internal let requestFactory: SCRequestCreating
    var appSharedDefaults: AppSharedDefaults
    init(requestFactory: SCRequestCreating,
         appSharedDefaults: AppSharedDefaults = AppSharedDefaults()) {
        self.requestFactory = requestFactory
        self.appSharedDefaults = appSharedDefaults
    }
    
    
    internal func mapRequestError(_ error : SCRequestError) -> SCWorkerError{
        switch error {
        case .unauthorized(_ ):
            return SCWorkerError.unauthorized
        case .noInternet:
            return SCWorkerError.noInternet
        case .requestFailed(_ , let errorDetails):
            return SCWorkerError.fetchFailed(SCWorkerErrorDetails.init(message:errorDetails.userMsg, errorCode: errorDetails.errorCode))
        case .timeout(let errorDetails):
            return SCWorkerError.fetchFailed(SCWorkerErrorDetails.init(message:errorDetails.userMsg, errorCode: errorDetails.errorCode))
        case .unexpected(_ ), .invalidResponse(_ , _):
            return SCWorkerError.technicalError
        }
    }
    
    func cancelRequests(){
        for requestToCancel in self.cancelableRequests {
            requestToCancel.cancel()
        }
        self.cancelableRequests =  [SCDataFetching]()
    }
}
