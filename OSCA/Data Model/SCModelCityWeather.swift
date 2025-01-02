//
//  SCModelCityWeather.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 04.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelCityWeather: Decodable {
    let id: Int
    let description: String
    let temperature: Int
}
/*
 cityWeather =     {
 description = thunderstorm;
 id = 4;
 temp = 15;
 */

