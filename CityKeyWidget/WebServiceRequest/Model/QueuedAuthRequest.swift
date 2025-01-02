//
//  QueuedAuthRequest.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 23/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

typealias RequestCompletionBlock = ((Result<Data?, NetworkError>) -> ())
struct QueuedAuthRequest {
    var request: URLRequest
    let completion: RequestCompletionBlock
}

