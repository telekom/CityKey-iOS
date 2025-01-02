//
//  WebServiceUsable.swift
//  OSCA
//
//  Created by Bhaskar N S on 23/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol WebServiceUsable {
    func fetchData(from url: URL,
                   method: String,
                   body: Data?,
                   needsAuth: Bool,
                   completion: @escaping (Result<Data?, NetworkError>) -> Void)
}
