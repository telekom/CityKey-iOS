//
//  FahrradparkenServiceRequest.swift
//  OSCA
//
//  Created by Bhaskar N S on 23/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import CoreLocation

struct FahrradparkenServiceRequest {
    var northEast: CLLocationCoordinate2D?
    var southWest: CLLocationCoordinate2D?
    var limit: Int
    var serviceCode: String
}
