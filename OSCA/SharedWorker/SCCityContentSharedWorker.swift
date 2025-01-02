//
//  SCCityContentSharedWorker.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 22.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import MapKit

// SUPPORTED CoNTENT LANGUAGES
let kNoCityIDAvaiable = -1

enum SCSunriseOrSunset {
    case sunrise
    case sunset
}

protocol SCCityContentCityIdentifing {
    func getCityID() -> Int
    func getCityLocation() -> CLLocation
}

protocol SCCityContentSharedWorking : SCCityContentCityIdentifing {
    
    var citiesDataState: SCWorkerDataState { get }
    var cityContentDataState: SCWorkerDataState { get }
    var newsDataState: SCWorkerDataState { get }
    var servicesDataState: SCWorkerDataState { get }
    var weatherDataState: SCWorkerDataState { get }

    func getCities() -> [CityLocationInfo]?
    func triggerCitiesUpdate(errorBlock: @escaping (SCWorkerError?)->())

    func isCityContentAvailable(for cityID : Int) -> Bool
    
    func getNews(for cityID : Int) -> [SCModelMessage]?
    func getServices(for cityID : Int) -> [SCModelServiceCategory]?
    func getWeather(for cityID : Int) -> String
    func getCityContentData(for cityID : Int) -> SCCityContentModel?
    func triggerCityContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ())
    
    func cityInfo(for cityID : Int) -> SCModelCity?
    func cityIDForPostalCode(postalcode: String) -> Int?
    func setStoredCityID(for cityID : Int)
    func setStoredCityLocation(for cityLocation : CLLocation)
    
    func getServiceMoreInfoHTMLText(cityId: String, serviceId: String, completion: @escaping (String, SCWorkerError?) -> Void)
    func checkIfDayOrNightTime() -> SCSunriseOrSunset
    func updateSelectedCityIdIfNotFoundInCitiesList(errorBlock: ((SCWorkerError?) -> ())?)
    
}

class SCCityContentSharedWorker: SCWorker {
    
    let storedCityIDKey: String = "storedCityIDKey"
    let storedCityLocationKey: String = "storedCityLocationKey"

    private let allCitiesApiPath = "/api/v2/smartcity/city/cityService"
    
    private let cityContentApiPath = "/api/v2/smartcity/city/cityService"
    private let cityNewsApiPath = "/api/v2/smartcity/news"
    private let cityServiceApiPath = "/api/v2/smartcity/city/cityService"
    private let cityWeatherContentApiPath = "/api/v2/smartcity/city/weather"
    
    internal var citiesDataState = SCWorkerDataState()
    internal var cityContentDataState = SCWorkerDataState()
    internal var newsDataState = SCWorkerDataState()
    internal var servicesDataState = SCWorkerDataState()
    internal var weatherDataState = SCWorkerDataState()

    private var cities : [SCModelCity]?
    private var cityContent: SCModelCityAllContent?
    private var cityNews: [SCModelMessage]?
    private var cityServiceCategories: [SCModelServiceCategory]?
    private var weather: SCHttpModelWeather?
    
    private var storedCityID: Int {
        set {
            storeCity(id: newValue)
            UserDefaults.standard.set(newValue, forKey: storedCityIDKey)
        }
        get {
            return UserDefaults.standard.value(forKey: storedCityIDKey) as? Int ?? kNoCityIDAvaiable
        }
    }
    
    private var storedCityLocation: CLLocation {
        set {
            if let locationData = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) {
                UserDefaults.standard.set(locationData, forKey: storedCityLocationKey)
            }
        }
        get {
            if let loadedData = UserDefaults.standard.data(forKey: storedCityLocationKey){
                
                if let loadedLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedData) as? CLLocation {
                    return loadedLocation
                }
            }
            return CLLocation(latitude: 0.0, longitude: 0.0)
        }
    }
    
    private func prepare(){
        
    }
    
    private func storeCity(id: Int) {
        if #available(iOS 14, *) {
            appSharedDefaults.storeCityId(cityId: "\(id)")
        } else {
            //do nothing because widget supports from iOS 14 and later
        }
    }
    
    private func storeNews(data: Data?) {
        if #available(iOS 14, *) {
            appSharedDefaults.storeCityNews(cityNews: data)
            appSharedDefaults.saveNewsError(message: nil)
        } else {
            // Fallback on earlier versions
        }
    }

}

extension SCCityContentSharedWorker: SCCityContentSharedWorking, SCCityContentCityIdentifing {
    
    func cityIDForPostalCode(postalcode: String) -> Int? {
        if let cities = self.cities {
            for city in cities {
                for postalCode in city.postalCode {
                    if postalCode == postalcode {
                        return city.cityID
                    }
                }
            }
        }
        return nil
    }

    func getCityID() -> Int {
        return self.storedCityID
    }
    
    func setStoredCityID(for cityID: Int) {
        self.storedCityID = cityID
    }
    
    func getCityLocation() -> CLLocation {
        return self.storedCityLocation
    }
    
    func setStoredCityLocation(for cityLocation: CLLocation) {
        self.storedCityLocation = cityLocation
    }

    func getCities() -> [CityLocationInfo]? {
        guard let cities = self.cities else {
            return nil
        }
        var cityLocations = [CityLocationInfo]()
        
        for city in cities {
            cityLocations.append(CityLocationInfo(cityID: city.cityID, cityName: city.name, cityState: city.stateName, cityImageUrl: city.cityPreviewImageUrl, cityFavorite: false))
        }
        
        return cityLocations.sorted {
            $0.cityName < $1.cityName
        }

    }
    
    func triggerCitiesUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        
        guard self.citiesDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            return
        }
        
        self.citiesDataState.dataLoadingState = .fetchingInProgress
        
        self.fetchCities { (error, allCities) in
            guard error == nil else {
                self.citiesDataState.dataLoadingState = .fetchFailed
                errorBlock(error)
                return
            }
            self.citiesDataState.dataInitialized = true
            self.citiesDataState.dataLoadingState = .fetchedWithSuccess

            SCUtilities.delay(withTime: 0.0, callback: {
                SCDataUIEvents.postNotification(for: .didChangeCityContent)
                errorBlock(nil) // this is ONLY for the appDelegate/Injector case, needs to be rethought
            })
        }
    }
    
    func updateSelectedCityIdIfNotFoundInCitiesList(errorBlock: ((SCWorkerError?) -> ())?) {
        guard let cities = self.cities else {
            errorBlock?(.technicalError)
            return
        }
        var cityId: Int = storedCityID
        for city in cities {
            if city.cityID == self.storedCityID {
                cityId = city.cityID
                break
            }
        }
        if cityId == -1 {
            cityId = self.getCities()?.first?.cityID ?? -1
        }
        self.storedCityID = cityId
        errorBlock?(nil)
    }

    func isCityContentAvailable(for cityID : Int) -> Bool {
        if cityID == self.storedCityID && self.cityContent != nil  {
            return true
        }
        return false
    }
    
    func getNews(for cityID : Int) -> [SCModelMessage]?{
        if cityID != self.storedCityID {
            self.cityNews = nil
        }
        
        return self.cityNews
    }
    
    func getServices(for cityID : Int) -> [SCModelServiceCategory]?{
        if cityID != self.storedCityID {
            self.cityServiceCategories = nil
        }
        
        return self.cityServiceCategories
    }
    
    func getWeather(for cityID : Int) -> String{
        var cityWeather = ""

        if cityID != self.storedCityID {
            self.weather = nil
        }

        if let desc = self.weather?.description,
            let temp = self.weather?.temperature {
            cityWeather = "\(desc), \(String(describing: Int(round(temp))))°"
        }
        return cityWeather
    }
    
    func checkIfDayOrNightTime() -> SCSunriseOrSunset {

        if let sunrise = self.weather?.sunrise,
            let sunset = self.weather?.sunset {
            
            let date = Date()
            let timeIsBeforeSunrise = date <= (dateFromString(dateString: sunrise) ?? Date()) ? true : false
            let timeIsAfterSunset = date >= (dateFromString(dateString: sunset) ?? Date()) ? true : false
            let isCityNightPicture = !((self.cityContent?.cityNightPictureImageUrl?.absoluteUrlString().isSpaceOrEmpty()) ?? true) ? true : false
            if isCityNightPicture && (timeIsBeforeSunrise || timeIsAfterSunset) {
                return .sunset
            } else {
                return .sunrise
            }
        }
        
        return .sunrise
    }
    
    func getCityContentData(for cityID : Int) -> SCCityContentModel? {
        if cityID != self.storedCityID {
            self.cityContent = nil
        }
        
        if let cityContent = self.cityContent,
            let cityInfo = self.cityInfo(for: cityID) {
            
            // set the color of city as a gloabl cityColor
            kColor_cityColor = cityInfo.cityTintColor

            // set the location of selectd city
            kSelectedCityLocation = CLLocation(latitude: Double(cityContent.latitude), longitude: Double(cityContent.longitude))
            
            // set the name of selectd city
            kSelectedCityName = cityContent.cityName
            kSelectedCityId = String(cityID)
            
            let cityConfig = cityContent.cityConfig

            let cityContent = SCCityContentModel(city: cityInfo, cityImprint: cityContent.cityImprintLink, cityConfig: cityConfig,
                                                 cityImprintDesc: cityContent.imprintDesc, cityServiceDesc: cityContent.serviceDesc,
                                                 cityNightPicture: cityContent.cityNightPictureImageUrl, imprintImageUrl: cityContent.imprintImageUrl)
            
            return cityContent
        }
        
        return nil
    }
    
    func triggerCityContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        guard self.cityContentDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            return
        }
        

        if cityID != self.storedCityID {
            self.cityContent = nil
            self.cityContentDataState = SCWorkerDataState()
            self.newsDataState = SCWorkerDataState()
            self.servicesDataState = SCWorkerDataState()
            self.weatherDataState = SCWorkerDataState()
            self.storedCityID = cityID
        }
        
        self.cityContentDataState.dataLoadingState = .fetchingInProgress
        
        var cityID = cityID
        
        let contentFetching = {


            self.newsDataState.dataLoadingState = .fetchingInProgress
            self.servicesDataState.dataLoadingState = .fetchingInProgress
            
            SCDataUIEvents.postNotification(for: .didChangeServiceContentState)
            SCDataUIEvents.postNotification(for: .didChangeNewsContentState)

            self.fetchCityContent(for: cityID, completion: { (error, allCityContent) in
                guard error == nil else {
                    self.cityContentDataState.dataLoadingState = .fetchFailed
                    errorBlock(error)
                    SCDataUIEvents.postNotification(for: .citiesLoadingFailed)
                    
                    return
                }
                
                errorBlock(nil)
                
                SCUtilities.delay(withTime: 0.0, callback: {
                    self.cityContentDataState.dataInitialized = true
                    self.cityContentDataState.dataLoadingState = .fetchedWithSuccess
                    SCDataUIEvents.postNotification(for: .updateEventWorkerFetchState)
                    SCDataUIEvents.postNotification(for: .didChangeCityContent)
                })
            })

            // fetch services
            self.fetchServiceContent(for: cityID, completion: { (error, services) in
                if error != nil {
                    self.servicesDataState.dataLoadingState = .fetchFailed
                
                    // only throw errors for the services back, when service content is available needs to refreshed
                    // ToDo: Michael: This will bei refactored (new error handling) and is only a workaround to display error message when updating service content.
                    if self.servicesDataState.dataInitialized {
                        errorBlock(error)
                    }
                } else {
                    self.servicesDataState.dataInitialized = true
                    self.servicesDataState.dataLoadingState = .fetchedWithSuccess
                    SCDataUIEvents.postNotification(for: .didChangeServiceContentState)
                }
            })
            
            // fetch news
            self.fetchNewsContent(for: cityID, completion: { (error, news) in
                if error != nil {
                    
                    switch error {
                    case .fetchFailed(let errorDetails):
                        self.newsDataState.dataLoadingState = SCWorkerDataLoadingState.getStateFor(errorCode : errorDetails.errorCode)
                    default:
                        self.newsDataState.dataLoadingState = .fetchFailed

                    }
                
                    if self.newsDataState.dataInitialized {
                        errorBlock(error)
                    }
                } else {
                    self.newsDataState.dataInitialized = true
                    self.newsDataState.dataLoadingState = .fetchedWithSuccess
                }
                SCDataUIEvents.postNotification(for: .didChangeNewsContentState)
                
            })

        }
        
        let weatherFetching = {
            self.weatherDataState.dataLoadingState = .fetchingInProgress
            self.fetchWeather(for: cityID) { (error, cityWeather) in
                guard error == nil else {
                    self.weatherDataState.dataLoadingState = .fetchFailed
                    //errorBlock(error)
                    return
                }
                SCUtilities.delay(withTime: 0.0, callback: {
                    self.weatherDataState.dataInitialized = true
                    self.weatherDataState.dataLoadingState = .fetchedWithSuccess
                    SCDataUIEvents.postNotification(for: .didChangeCityContent)
                })
            }
        }
        
        if self.cityContentDataState.dataInitialized == false {
            self.triggerCitiesUpdate { (error) in
                guard error == nil else {
                    self.citiesDataState.dataLoadingState = .fetchFailed
                    self.cityContentDataState.dataLoadingState = .fetchFailed
                    errorBlock(error)
                    return
                }
                self.updateSelectedCityIdIfNotFoundInCitiesList { error in
                    guard error == nil else {
                        errorBlock(error)
                        return
                    }
                    cityID = self.storedCityID
                    contentFetching()
                    weatherFetching()
                }
            }
        } else {
            contentFetching()
            weatherFetching()
        }
        
    }
    
    func triggerServiceContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        guard self.cityContentDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            return
        }
        

        if cityID != self.storedCityID {
            self.servicesDataState = SCWorkerDataState()
        }
        
        self.cityContentDataState.dataLoadingState = .fetchingInProgress
        SCDataUIEvents.postNotification(for: .didChangeServiceContentState)

        self.fetchServiceContent(for: cityID, completion: { (error, services) in
           guard error == nil else {
                self.servicesDataState.dataLoadingState = .fetchFailed
                errorBlock(error)
                SCDataUIEvents.postNotification(for: .didChangeServiceContentState)
                return
            }
            self.servicesDataState.dataInitialized = true
            self.servicesDataState.dataLoadingState = .fetchedWithSuccess
            SCDataUIEvents.postNotification(for: .didChangeServiceContentState)
        })

    }

    func cityInfo(for cityID : Int) -> SCModelCity? {
    
        if let cities = self.cities {
            for city in cities {
                if city.cityID == cityID{
                    return city
                }
            }
        }
        return nil
    }
}

//MARK: - the actual fetching
extension SCCityContentSharedWorker {
    
    private func fetchWeather(for cityID: Int, completion: @escaping ((SCWorkerError?, SCHttpModelWeather?) -> Void)) {
        let queryDictionary = ["cityId": String(cityID), "actionName": "GET_Weather", "language": SCUtilities.preferredContentLanguage()] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.cityWeatherContentApiPath, parameter: queryDictionary )

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            
            self.weather = nil
            
            switch response {
                
            case .success(let fetchedData):
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelWeather]>.self, from: fetchedData )
                    self.weather = httpModel.content[0]
                    completion(nil, self.weather)}
                catch {
                    completion(SCWorkerError.technicalError,nil)
                }
            case .failure(let error):
                SCFileLogger.shared.write("Harshada -> fetchWeather | SCCityContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                completion(self.mapRequestError(error), nil)
            }
        }
        
    }
    
    private func fetchCities(completion: @escaping ((SCWorkerError?, [SCModelCity]?) -> Void)) {
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": cityID, "actionName": "GET_AllCities"] as [String : String] //TODO: what is up with those constantsi
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.allCitiesApiPath, parameter: queryDictionary )

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in

            switch response {

            case .success(let fetchedData):
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelCity]>.self, from: fetchedData)
                    self.cities = httpModel.content.map { $0.toModel() }
                    completion(nil, self.cities)
                } catch {
                    completion(SCWorkerError.technicalError,nil)
                    NotificationCenter.default.post(name: .cityContentLoadingFailed, object: nil)
                }
                
            case .failure(let error):
                SCFileLogger.shared.write("Harshada -> fetchCities | SCCityContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                completion(self.mapRequestError(error), nil)
                NotificationCenter.default.post(name: .cityContentLoadingFailed, object: nil)
             }
        }
    }
    
    private func fetchCityContent(for cityID: Int, completion: @escaping ((SCWorkerError?, SCModelCityAllContent?) -> Void)) {
        let queryDictionary = ["cityId": String(cityID), "actionName": "GET_CityData"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: cityContentApiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            
            switch response {
                
            case .success(let fetchedData):
                do {
                    let type = HttpModelResponse<[SCHttpModelCityAllContent?]?>.self
                    let httpModel = try JSONDecoder().decode(type, from: fetchedData)
                    let cityContent = httpModel.content??.first??.toModel() ?? self.getDefaultModelForCityAllContent()
                    self.cityContent = cityContent
                    self.storedCityID = cityID
                    self.storedCityLocation = CLLocation(latitude: Double(self.cityContent?.latitude ?? 0.0),
                                                         longitude: Double(self.cityContent?.longitude ?? 0.0))

                    completion(nil, cityContent)
                    
                } catch {
                    completion(SCWorkerError.technicalError,nil)
                    SCDataUIEvents.postNotification(for: .citiesLoadingFailed)
                }
                
            case .failure(let error):
                SCFileLogger.shared.write("Harshada -> fetchCityContent | SCCityContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                completion(self.mapRequestError(error), nil)
                SCDataUIEvents.postNotification(for: .citiesLoadingFailed)
            }
        }
    }

    private func fetchNewsContent(for cityID: Int, completion: @escaping ((SCWorkerError?, [SCModelMessage]?) -> Void)) {
        let queryDictionary = ["cityId": String(cityID), "actionName": "GET_News"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: cityNewsApiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            
            self.cityNews = nil

            switch response {
            

            case .success(let fetchedData):
                do {
                    let type = SCHttpModelResponse<[SCHttpModelMessage]>.self
                    let httpModel = try JSONDecoder().decode(type, from: fetchedData)
                    let news = httpModel.content.map{$0.toModel()}
                    self.storeNews(data: fetchedData)
                    self.cityNews = news

                    completion(nil, news)

                } catch {
                    self.storeNews(data: nil)
                    completion(SCWorkerError.technicalError,nil)
                }
                
            case .failure(let error):
                self.storeNews(data: nil)
                SCFileLogger.shared.write("Harshada -> fetchNewsContent | SCCityContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                completion(self.mapRequestError(error), nil)
             }
        }
    }
    
    private func fetchServiceContent(for cityID: Int, completion: @escaping ((SCWorkerError?, [SCModelServiceCategory]?) -> Void)) {
        
        let queryDictionary: [String : String] = ["cityId": String(cityID), "actionName": "GET_CityServiceData"]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: cityServiceApiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { [self] (response) in
            
            switch response {

            case .success(let fetchedData):
                do {
                    let type = SCHttpModelResponse<[SCHttpModelServiceCategories]>.self
                    let httpModel = try JSONDecoder().decode(type, from: fetchedData)
                    let categoriesLists = httpModel.content.map{$0.toModel()}
                    self.cityServiceCategories = categoriesLists.first
                    completion(nil, self.cityServiceCategories)
                    
                } catch {
                    completion(SCWorkerError.technicalError,nil)
                }
                
            case .failure(let error):
                SCFileLogger.shared.write("Harshada -> fetchServiceContent | SCCityContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)
                
                // SMARTC-27859 - Handdle unexpected alert 'something went wrong' displayed when user switch to preview mode
                if !isPreviewMode {
                    completion(self.mapRequestError(error), nil)
                } else {
                    self.cityServiceCategories = []
                    completion(nil, self.cityServiceCategories)
                }
             }
        }
    }
    
    func getServiceMoreInfoHTMLText(cityId: String, serviceId: String, completion: @escaping (String, SCWorkerError?) -> Void) {
        let queryParameter = ["cityId": cityId, "actionName": "GET_ServiceHelpContent", "cityServiceId": serviceId]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: cityServiceApiPath, parameter: queryParameter)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            
            print("result", result)
            
            switch result {
            case .success(let response):
                do {
                    struct wasteCalendarMoreInfoContent : Codable {
                        let textId : Int
                        let helpText : String
                    }
                    
                    let httpResponseModel = try JSONDecoder().decode(SCHttpModelResponse<[wasteCalendarMoreInfoContent]>.self, from: response)
                    completion( httpResponseModel.content.first?.helpText ?? "" , nil)
                    
                } catch (let error) {
                    debugPrint("Error passing waste more info response : \(error)")
                    completion("", .technicalError)
                }
                
            case .failure(let error):
                debugPrint("SCWasteCalendarWorker -> Error : \(error)")
                completion("", self.mapRequestError(error))
            }
        }
    }

    private func getDefaultModelForCityAllContent() -> SCModelCityAllContent {
        SCModelCityAllContent(cityId: -1,
                              cityName: "",
                              cityImprintLink: nil,
                              cityConfig: SCModelCityConfig(showFavouriteServices: false,
                                                            showHomeDiscounts: false,
                                                            showHomeOffers: false,
                                                            showHomeTips: false,
                                                            showFavouriteMarketplaces: false,
                                                            showNewServices: false,
                                                            showNewMarketplaces: false,
                                                            showMostUsedServices: false,
                                                            showMostUsedMarketplaces: false,
                                                            showCategories: false,
                                                            showBranches: false,
                                                            showDiscounts: false,
                                                            showOurMarketPlaces: false,
                                                            showOurServices: false,
                                                            showMarketplacesOption: false,
                                                            showServicesOption: false,
                                                            stickyNewsCount: 0),
                              latitude: 0.0, longitude: 0.0, serviceDesc: nil, imprintDesc: nil,
                              cityNightPictureImageUrl: nil, imprintImageUrl: nil)
    }
}
