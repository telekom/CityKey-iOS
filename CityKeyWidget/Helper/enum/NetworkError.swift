//
//  NetworkError.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 11/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case apiError(String)
    case systemError(String)
}

enum SCRefreshTokenState {
    case empty
    case valid
    case invalid
}
