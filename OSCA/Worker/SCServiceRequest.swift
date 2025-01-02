//
//  SCServiceRequest.swift
//  OSCA
//
//  Created by Bhaskar N S on 13/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

enum SCServiceRequest {
    enum Key {
        static let cityId: String = "cityId"
        static let actionName: String = "actionName"
    }

    enum Value {
        enum ActionName {
            static let GetDpnText: String = "GET_DpnText"
        }
    }
}
