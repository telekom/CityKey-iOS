//
//  URL+subscript.swift
//  SmartCity
//
//  Created by Michael on 12.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension URL {
    
    // getting pararmetes out of an url
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
    
    var email: String? {
        return scheme == "mailto" ? URLComponents(url: self, resolvingAgainstBaseURL: false)?.path : nil
    }
}

extension URLRequest {
    var isHttpLink: Bool {
        return self.url?.scheme?.contains("http") ?? false
    }
}
