//
//  SCGlobalConstants.swift
//  SmartCity
//
//  Created by Michael on 04.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// the Color of the current selected city
public var kColor_cityColor = UIColor(named: "CLR_OSCA_BLUE")!

// the Location of the current selected city
public var kSelectedCityLocation = CLLocation(latitude: 0.0, longitude: 0.0)

// the Name and City Id of the current selected city
public var kSelectedCityName = ""
public var kSelectedCityId = ""

// flag for the App Preview UI for CSP
public var isPreviewMode : Bool = false

struct GlobalConstants {

    // SUPPORTED CoNTENT LANGUAGES
    static let kSupportedContentLanguages = ["en","de","tr"]
    
    // BACKEND
    static let kSOL_Domain = Bundle.main.infoDictionary?["SCSOLDomain"] as! String

    static let kSOL_Image_Domain = Bundle.main.infoDictionary?["SCSOLImageDomain"] as! String

    static let kKommunix_Enviornment = Bundle.main.infoDictionary?["SCKommunixEnvironment"] as! String

    static var components = URLComponents()
    
    static var kSOL_UrlString: String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(GlobalConstants.kSOL_Domain)"
        return components.string!
    }
    
    static var kSOL_Image_UrlString: String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(GlobalConstants.kSOL_Image_Domain)"
        return components.string!
    }

    //   Constant Base Screen Width iPhoneX
    static let kBaseScreenWidthiPhoneX : CGFloat = 375.0
    static let kBaseAdaptiveScreenFactor : CGFloat =  UIScreen.main.bounds.size.width  < GlobalConstants.kBaseScreenWidthiPhoneX ? (UIScreen.main.bounds.size.width  / GlobalConstants.kBaseScreenWidthiPhoneX) : 1.0

    static let kBaseAdaptiveTilesScreenFactorFactor : CGFloat =  (UIScreen.main.bounds.size.width  / GlobalConstants.kBaseScreenWidthiPhoneX)

    //   Constant Variables Header
    static let kHeaderHeight : CGFloat          =    90.0

    //   Constant Variables  Dashboard NewsList
    static let kNewsListHeaderHeight : CGFloat          =    66.0
    static let kNewsListMaxEntries :Int             =    4
    static let kNewsListRowHeight : CGFloat          =    130.0
    static let kEventListRowHeight : CGFloat          =    86.0

    //   Constant Variables TableViewList
    static let kListNoDataHeight : CGFloat         =    60.0
    static let kListHeaderHeight : CGFloat         =    40.0  //adapt to be consistent with Event Calendar Design

    //   Constant Variables Carousel
    static let kCarouselContentSpacer : CGFloat         =    20.0
    static let kCarouselContentOffset : CGFloat         =    15.0
    static let kCarouselShadowSafeArea : CGFloat         =    12.0

    //   Constant Variables TilesList
    static let kTilesListContentOffset : CGFloat         =    15.0
    static let kTilesListContentSpacerHorizontal : CGFloat         =    10.0
    static let kTilesListContentSpacerVertical : CGFloat         =    15.0
    static let kTilesListShadowSafeArea : CGFloat         =    12.0

    //   Constant Variables Scollable Content View
    static let kScrollableContentBottomHeight : CGFloat         =    20.0
    
    //   Constant Variables  Dashboard NewsList
    static let kLocationCellRegularHeight : CGFloat       =    65.0

    //   Constant Variables  Overview list
    static let kOverviewListSectionHeaderHeight : CGFloat          =    54.0
    //   Constant Variables Special View Tags
    static let kNavigationBarTilteImageViewTag : Int       =   61754
    static let kOverlayActivityViewTag : Int       =   53454
    static let kOverlayErrorViewTag : Int       =   53455
    static let kOverlayNoDataViewTag : Int       =   53456

    //   Constant Variables  POI Guide CategoryList
    static let kPOIGuideCellRegularHeight : CGFloat       =    44.0
    
    //   First Time Usage
    static let firstTimeUsageSwitchDuration : Double = 1.5
    static let firstTimeUsagePresentDuration : Double = 4

    // Profile Image Upload Size in pixel
    static let profile_upload_size = 400
    
    // Events Loading Data Page Size
    static let events_fetch_data_page_size = 25

    //   Constant Variable  Service Detail Page button height
    static let kServiceDetailPageButtonHeight : CGFloat = 52.0
    static let kWasteCalendarButtonHeight : CGFloat = 54.0
    static let kSearchThisAreaButtonHeight: CGFloat = 30.0
    
    //   Constant Variable  Egov Service Detail Page tableView cell and header height
    static let kEgovServiceDetailCellHeight : CGFloat = 44.0
    static let kEgovServiceDetailsTableHeaderHeight : CGFloat = 44.0
    
    /// This constant is used to inform the SOL about service and city list API version.
    /// Based on this version services will be filtered out from the API. We will be increasing this constant manually each time new service or city onboarded.
    static let kSupportedServiceAPIVersion = "1.10"
    
    // User Deafaults for user profile
    static let postalCodeKey: String = "postalCode"
    static let cityNameKey: String = "cityName"
    static let profileKey: String = "profile"

    static let poiKey: String = "poiKey"
    static let poiCategoryKey: String = "poiCategoryKey"
    static let poiCategoryIDKey: String = "poiCategoryIDKey"
    static let poiCategoryNameKey: String = "poiCategoryNameKey"
    static let poiListMapLoaded: String = "poiListMapLoaded"
    static let poiCategoryGroupKey: String = "poiCategoryGroupKey"
    static let currentLocation: String = "currentLocation"
    static let defectLocation: String = "defectLocation"
    static let isDefectLocationSet: String = "isDefectLocationSet"
    static let defectImage: String = "defectImage"
    static let isLoginApi: String = "isLoginApi"
    static let logoutEventInfo: String = "logoutEventInfo"
    static let userIDKey: String = "userIDKey"
    static let selectedCityID: String = "selectedCityID"

    static let isCityActive: String = "isCityActive"
    static let defaultCityName: String = "defaultCityName"
    static let defaultCityID: String = "defaultCityID"
    
    static let someoneEverloggedIn: String = "someoneEverloggedIn"
    static let prefferedLanguage = "prefferedLanguage"
    static let registrationKey: String = "registration"

    /// Method to append URL path to URL String
      /// - Parameters:
      ///  - urlString: URLString for API calling
      ///  - path: path for the url
      ///  - parameter: parameter to be used in query part of url
      ///  - appendPath: if true, the url string path will be appended to the path, if false path will replace url components path
      /// - Returns: URL object will be created with all the details required
    static func appendURLPathToUrlString(_ urlString : String, path: String, parameter: Dictionary<String,String>?, appendPathToURLStringpath: Bool? = false) -> URL {
        guard let baseComponents = URLComponents(string: urlString), let pathComponents = URLComponents(string: path) else { return URL(string: urlString)! }
        
        var queries: [URLQueryItem] = []
        if let parameter = parameter {
            for keyValue in parameter {
                queries.append(URLQueryItem(name: keyValue.key, value: keyValue.value))
            }
        }
        var allComponents = baseComponents
        if let appendPath = appendPathToURLStringpath, !appendPath {
            allComponents.path = pathComponents.path
        } else {
            allComponents.path.append(pathComponents.path)
        }
        if !queries.isEmpty {
            allComponents.queryItems = queries
        }
        return allComponents.url ?? URL(string: urlString)!
    }

    static func appendURLPathToSOLUrl(path: String, parameter: Dictionary<String,String>?) -> URL {
        return GlobalConstants.appendURLPathToUrlString(kSOL_UrlString, path: path, parameter: parameter)
    }
    
    static func appendURLPathToSOLImageUrl(path: String, parameter: Dictionary<String,String>?) -> URL {
        return GlobalConstants.appendURLPathToUrlString(kSOL_Image_UrlString, path: path, parameter: parameter)
    }
    
    
    struct Ausweis {
        static let ausweisAppStoreURL = "https://apps.apple.com/us/app/ausweisapp2/id948660805#?platform=iphone"
        static let ausweisAppHelpURL = "https://www.ausweisapp.bund.de/hilfe-und-support/haeufig-gestellte-fragen/"
    }
}
