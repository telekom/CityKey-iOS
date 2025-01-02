//
//  MockQueue.swift
//  OSCATests
//
//  Created by Bhaskar N S on 27/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class MockQueue: Dispatching {
    func async(block: @escaping () -> Void) {
        block()
    }
}
