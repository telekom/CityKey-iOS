/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
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
