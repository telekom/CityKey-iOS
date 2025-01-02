//
//  GMSMapView+Style.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 18/03/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import GoogleMaps

extension GMSMapView{
    
    // Support Dark mode for Map
    func setupMapForDarkMode(){
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                //Dark
                do {
                    // Set the map style by passing the URL of the local file.
                    if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                        self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                    } else {
                        NSLog("Unable to find style.json")
                    }
                } catch {
                    NSLog("One or more of the map styles failed to load. \(error)")
                }
            }
            else {
                //Light
                do {
                  // Set the map style by passing a valid JSON string.
                    self.mapStyle = try GMSMapStyle(jsonString: "[]")
                } catch {
                  NSLog("One or more of the map styles failed to load. \(error)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
