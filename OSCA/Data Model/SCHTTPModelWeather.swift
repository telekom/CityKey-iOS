//
//  SCHTTPModelWeather.swift
//  OSCA
//
//  Created by Alexander Lichius on 15.04.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCHttpModelWeather: Decodable {
    let id: Int //"id": 19,
    let cityId: Int //"cityId": 4,
    let cityKey: Int //"cityKey": 2869791,
    let cloudiness: Int //"cloudiness": 75,
    let description: String //"description": "Regenschauer",
    let humidity: Int //"humidity": 60,
    let atmosphericPressure: Int // 1027,
    let rainVolume: Int? //"rainVolume": null,
    let sunrise: String? //"sunrise": "1970-01-20 01:07:39",
    let sunset: String?  //"sunset": "1970-01-20 01:08:09",
    let temperature: Double
    let maximumTemperature: Double
    let minimumTemperature: Double
    let visibility: Int
    let windDirection: Int
    let windSpeed: Double //"windSpeed": 9.3,
    let language: String //"language": "de"
}
