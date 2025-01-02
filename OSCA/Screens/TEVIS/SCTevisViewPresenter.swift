//
//  SCTevisViewPresenter.swift
//  OSCA
//
//  Created by Alexander Lichius on 08.06.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCTevisViewPresenting: SCPresenting {
    func setDisplay(_ display: SCTevisViewDisplaying)
    func webProcessFinishedSuccessfully()
    func dismissWebView()
    func prepareRequest(useProfileData: Bool)
}


class SCTevisViewPresenter {
    
    var userContentSharedWorker: SCUserContentSharedWorking
    var cityContentSharedWorker: SCCityContentSharedWorking
    var userCityContentSharedWorker: SCUserCityContentSharedWorking
    var serviceData : SCBaseComponentItem
    var display: SCTevisViewDisplaying?
    var profile: SCModelProfile?
    var request: NSURLRequest?
    let urlString: String!
    let returnUrl = "http://citykey.callback.url/"
    private let injector: SCAdjustTrackingInjection

    
    init(userContentSharedWorker: SCUserContentSharedWorking, cityContentSharedWorker: SCCityContentSharedWorking, tevisUrl: String, userCityContentSharedWorker: SCUserCityContentSharedWorking, serviceData : SCBaseComponentItem, injector: SCAdjustTrackingInjection) {
        self.userContentSharedWorker = userContentSharedWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.serviceData = serviceData
        self.injector = injector
        #if DEBUG
            self.urlString = "https://termine-reservieren.de/termine/oscaTest/" + "directentry"
        #else
            self.urlString = tevisUrl
        #endif
    }

    func setupProfileData() {
        if self.userContentSharedWorker.isUserDataAvailable() {
            if let userData = self.userContentSharedWorker.getUserData() {
                self.profile = userData.profile
            }
        }
    }
    
    func setupRequest(useProfileData: Bool) {
        let url = URL (string: urlString)
        let request = NSMutableURLRequest(url: url!)
        
        // let cityContent = cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())
        
        // So the token here is a workaround until the information will be delivered
        // by SOL. For now we use the cityname (the city is to difficult, because it is different for each envrionment) to differentiate petween paderborn and musterstadt

        // let entryToken = cityContent?.city.name.lowercased() == "paderborn" ? "TkHKaPCC1hfeMT7fRiSc14GQct0KOnV8" : "fn3767gjn3b6773n5vb3nv3m0zvn87mn"

        /// SMARTC-17116 -> SMARTC-17133 : Previously the entry token was harcoded in the code for two cities , with this now there will be service Params dictionary with every service object that will have some service specific configurations , here we use entry_token from ,  email key name , date of birth key name to be passed to the service
        let entryToken = serviceData.itemServiceParams?["entry_token"] ?? ""
        let emailKey = serviceData.itemServiceParams?["email"] ?? "email"
        let dateOfBirthKey = serviceData.itemServiceParams?["date_of_birth"] ?? "date_of_birth"
        
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var params: [String:String]
        if useProfileData {
            params = ["entry_mode": "app_citykey",
            "entry_token":  entryToken,
            "entry_action":  "reservation_create",
            "ident": prepareIndent(),
            emailKey :  self.profile?.email ?? "",
//            dateOfBirthKey : birthdayStringFromDate(birthdate: self.profile?.birthdate ?? Date()), // kommunixStringFromDate(date: self.profile?.birthdate ?? Date()) ,
            "city":  self.profile?.cityName ?? "",
            "zip":  self.profile?.postalCode ?? "",
            "return_url": self.returnUrl,
            "env": GlobalConstants.kKommunix_Enviornment]
            
            if let birthdate = self.profile?.birthdate {
                params[dateOfBirthKey] = appointmentDateStringFromDate(date: birthdate)
            }
            
        } else {
            params = ["entry_mode": "app_citykey",
            "entry_token":  entryToken,
            "entry_action":  "reservation_create",
            "ident": prepareIndent(),
            "return_url": self.returnUrl,
            "env": GlobalConstants.kKommunix_Enviornment]
        }
        
        let postString = self.getPostString(params: params)
        request.httpBody = postString.data(using: .utf8)
        self.request =  request as NSURLRequest
    }

    private func prepareIndent() -> String {
        return "\(kSelectedCityName)#\(String(self.profile?.accountId ?? 0))"
    }

    func getPostString(params:[String:String]) -> String {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
              
        }
        return data.map { String($0) }.joined(separator: "&")
    }

    private func updateAppointmentOnSuccess() {
        userCityContentSharedWorker.triggerAppointmentsUpdate { (error) in
        }
    }
}

extension SCTevisViewPresenter: SCPresenting {

    func viewDidLoad() {
        self.setupProfileData()
        self.display?.askDataPermission()
    }

    func viewWillAppear() {
        
    }

    func viewDidAppear() {

    }
}

extension SCTevisViewPresenter: SCTevisViewPresenting {

    func prepareRequest(useProfileData: Bool) {
        self.setupRequest(useProfileData: useProfileData)
        self.display?.setCallBackUrl(url: NSURL(string: self.returnUrl)!)
        if let request = self.request {
            self.display?.sendAsParameters(request: request)
        }
    }

    func setDisplay(_ display: SCTevisViewDisplaying) {
        self.display = display
    }

    func webProcessFinishedSuccessfully() {
        // SMARTC-13058 : Track additional events via Adjust - Appointments
        // User successfully creates an appointment
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.appointmentCreated)

        updateAppointmentOnSuccess()
        self.display?.closeWebView()
    }

    func dismissWebView() {
        self.display?.closeWebView()
    }
}
