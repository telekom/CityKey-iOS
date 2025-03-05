/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
//  SmartCityModelTests.swift
//  SmartCityTests
//
//  Created by Michael on 25.02.19.
//  Copyright © 2019 Michael. All rights reserved.
//

/*
 
import XCTest
import UIKit

@testable import SmartCity

class SmartCityModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSCModelProfile() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SAMPLE api/user/profile call partitial response
        let profile_response = """
        {"password":"TOP_SECRET","dayOfBirthday":"2001-12-15","username":"Chucky","firstName":"Chuck","credit":null,"id":57,"userStatus":null,"city":"Darmstadt","email":"chuck@norris.de",
        "role":"ROLE_USER","lastName":"Norris","street":"Missing in1","postalCode":null,"userImage":null,"userImageUUID":"18beed6f-2f22-11e9-be41-f7723f0cd8d6",
        "favoritesCollection":{"citizenService":[{"ranking":1,"user_id":57,"serviceId":48},{"ranking":2,"user_id":57,"serviceId":5},{"ranking":2,"user_id":57,"serviceId":47},
        {"ranking":4,"user_id":57,"serviceId":4},{"ranking":6,"user_id":57,"serviceId":2},{"ranking":7,"user_id":57,"serviceId":53},{"ranking":9,"user_id":57,"serviceId":21}],
        "marketplace":[{"ranking":1,"user_id":57,"marketplaceId":77},{"ranking":3,"user_id":57,"marketplaceId":14},{"ranking":6,"user_id":57,"marketplaceId":18},
        {"ranking":9,"user_id":57,"marketplaceId":7},{"ranking":12,"user_id":57,"marketplaceId":17}],"cityContent":[]},"paymentCollection":[],
        "userInfoBoxCollection":[{"teaser":"Transfer confirmation","details":"The transfer confirmation for your move is ready to be found in your document safe.",
        "userInfoId":109,"creationDate":"2019-02-09T23:00:00.000+0000","read":true,"description":"Sample description","icon":"/img/Umzug.png","typ":"INFO"}]}
        """
        
        let profile_response_data = profile_response.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        // TEST DECODING FROM JSON
        if let profileModel = try? decoder.decode(SCModelProfile.self, from: profile_response_data) {
            XCTAssertTrue(profileModel.email == "chuck@norris.de", "SCModelProfile email is wrong!")
            XCTAssertTrue(profileModel.profileimageid == "18beed6f-2f22-11e9-be41-f7723f0cd8d6", "SCModelProfile profileimageid is wrong!")
            XCTAssertTrue(profileModel.username == "Chucky", "SCModelProfile username is wrong!")
            XCTAssertTrue(profileModel.lastname == "Norris", "SCModelProfile lastname is wrong!")
            XCTAssertTrue(profileModel.firstname == "Chuck", "SCModelProfile firstname is wrong!")
            
            var birthdate = Date()
            
            let isoFormatter = DateFormatter()
            isoFormatter.dateFormat = "yyyy-MM-dd"
            isoFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = isoFormatter.date(from:"2001-12-15"){
                birthdate = date
            }
            XCTAssertTrue(profileModel.birthdate == birthdate, "SCModelProfile birthdate is wrong!")
            
            XCTAssertTrue(profileModel.address == "Missing in1", "SCModelProfile address is wrong!")
            XCTAssertTrue(profileModel.city == "Darmstadt", "SCModelProfile city is wrong!")
        } else {
            XCTFail("Couldn't decode data for SCModelProfile!")
        }
    }
    
    func testSCModelMessage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SAMPLE api/city/getCityByName call partitial response
        let news_response = """
        {"contentDetails":"Details of content","contentTeaser":"Teaser for the content","contentTyp":"NEWS","contentImage":"/img/image1.jpg","contentId":123,"id":1,"contentSource":"https://www.echo-online.de","favoritesIcon":null,"language":"de","contentCategory":"Bildung","contentCreationDate":20181024121225}
        """

        let info_response = """
        {"contentDetails":"Details of content","contentTeaser":"Teaser for the content","contentTyp":"INFO","contentImage":"/img/image1.jpg","contentId":123,"id":1,"contentSource":"https://www.echo-online.de","favoritesIcon":null,"language":"de","contentCategory":"Bildung","contentCreationDate":20181024121225}
        """

        let offer_response = """
        {"contentDetails":"Details of content","contentTeaser":"Teaser for the content","contentTyp":"ANGEBOTE","contentImage":"/img/image1.jpg","contentId":123,"id":1,"contentSource":"https://www.echo-online.de","favoritesIcon":null,"language":"de","contentCategory":"Bildung","contentCreationDate":2018102412122}
        """

        let tips_response = """
        {"contentDetails":"Details of content","contentTeaser":"Teaser for the content","contentTyp":"TIPPS","contentImage":"/img/image1.jpg","contentId":123,"id":1,"contentSource":"https://www.echo-online.de","favoritesIcon":null,"language":"de","contentCategory":"Bildung","contentCreationDate":20181024121225}
        """

        let discount_response = """
        {"contentDetails":"Details of content","contentTeaser":"Teaser for the content","contentTyp":"RABATTE","contentImage":"/img/image1.jpg","contentId":123,"id":1,"contentSource":"https://www.echo-online.de","favoritesIcon":null,"language":"de","contentCategory":null,"contentCreationDate":20181024121225}
        """
        
        let news_response_data = news_response.data(using: .utf8)!
        let info_response_data = info_response.data(using: .utf8)!
        let offer_response_data = offer_response.data(using: .utf8)!
        let tips_response_data = tips_response.data(using: .utf8)!
        let discount_response_data = discount_response.data(using: .utf8)!

        let decoder = JSONDecoder()
        
        // TEST DECODING FROM JSON
        if let newsModel = try? decoder.decode(SCModelMessage.self, from: news_response_data) {
            XCTAssertTrue(newsModel.id == "123", "SCModelProfile id is wrong!")
            XCTAssertTrue(newsModel.detailText == "Details of content", "SCModelProfile contentDetails is wrong!")
            XCTAssertTrue(newsModel.shortText == "Teaser for the content", "SCModelProfile contentTeaser is wrong!")
            XCTAssertTrue(newsModel.type == .news, "SCModelProfile contentTyp is wrong!")
            XCTAssertTrue(newsModel.title == "Bildung", "SCModelProfile title is wrong!")
            XCTAssertTrue(newsModel.imageURL?.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/image1.jpg", "SCModelProfile imageURL is wrong!")
            XCTAssertTrue(newsModel.contentURL?.absoluteString == nil, "SCModelProfile contentURL is not empty!")
            XCTAssertTrue(newsModel.timestamp == 20181024121225, "SCModelProfile firstname is wrong!")
        } else {
            XCTFail("Couldn't decode data for SCModelMessage!")
        }

        if let infoModel = try? decoder.decode(SCModelMessage.self, from: info_response_data) {
            XCTAssertTrue(infoModel.type == .info, "SCModelProfile contentTyp is wrong!")
            XCTAssertTrue(infoModel.contentURL?.absoluteString == "https://www.echo-online.de", "SCModelProfile contentURL is wrong!")

        } else {
            XCTFail("Couldn't decode data for SCModelMessage!")
        }

        if let offerModel = try? decoder.decode(SCModelMessage.self, from: offer_response_data) {
            XCTAssertTrue(offerModel.type == .offer, "SCModelProfile contentTyp is wrong!")
            XCTAssertTrue(offerModel.title == "content_type_offers".localized(), "SCModelProfile contentTitle is wrong!")
            XCTAssertTrue(offerModel.contentURL?.absoluteString == "https://www.echo-online.de", "SCModelProfile contentURL is wrong!")
            
        } else {
            XCTFail("Couldn't decode data for SCModelMessage!")
        }

        if let tipsModel = try? decoder.decode(SCModelMessage.self, from: tips_response_data) {
            XCTAssertTrue(tipsModel.type == .tip, "SCModelProfile contentTyp is wrong!")
            XCTAssertTrue(tipsModel.title == "content_type_tipps".localized(), "SCModelProfile contentTitle is wrong!")
            XCTAssertTrue(tipsModel.contentURL?.absoluteString == "https://www.echo-online.de", "SCModelProfile contentURL is wrong!")
            
        } else {
            XCTFail("Couldn't decode data for SCModelMessage!")
        }

        if let discountModel = try? decoder.decode(SCModelMessage.self, from: discount_response_data) {
            XCTAssertTrue(discountModel.type == .discount, "SCModelProfile contentTyp is wrong!")
            XCTAssertTrue(discountModel.title == "", "SCModelProfile contentTitle is wrong!")
            XCTAssertTrue(discountModel.contentURL?.absoluteString == "https://www.echo-online.de", "SCModelProfile contentURL is wrong!")
            
        } else {
            XCTFail("Couldn't decode data for SCModelMessage!")
        }
    }


    func testSCModelUserInfo() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SAMPLE api/user/profile call partitial response
        let userinfo_response = """
        {"teaser":"Transfer confirmation","details":"sample details","userInfoId":109,"creationDate":20190209230000,"read":true,"description":"sample description","icon":"/imgUmzug.png","typ":"INFO", "url" : "https://www.spiegel.de"}
        """
        
        let userinfo_response_data = userinfo_response.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        // TEST DECODING FROM JSON
        if let userInfoModel = try? decoder.decode(SCModelUserInfo.self, from: userinfo_response_data) {
            XCTAssertTrue(userInfoModel.id == "109", "SCModelUserInfo id is wrong!")
            XCTAssertTrue(userInfoModel.title == "Transfer confirmation", "SCModelUserInfo title is wrong!")
            XCTAssertTrue(userInfoModel.shortText == "sample details", "SCModelUserInfo shortText is wrong!")
            XCTAssertTrue(userInfoModel.detailText == "sample description", "SCModelUserInfo detailText is wrong!")
            XCTAssertTrue(userInfoModel.contentURL ==  URL(string: "https://www.spiegel.de"), "SCModelUserInfo contentURL is wrong!")
            XCTAssertTrue(userInfoModel.imageURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/imgUmzug.png", "SCModelUserInfo imageURL is wrong!")
            XCTAssertTrue(userInfoModel.type == "INFO", "SCModelUserInfo type is wrong!")
            XCTAssertTrue(userInfoModel.timestamp == 20190209230000, "SCModelUserInfo timestamp is wrong!")
            XCTAssertTrue(userInfoModel.read == true, "SCModelUserInfo read is wrong!")
        } else {
            XCTFail("Couldn't decode data for SCModelUserInfo!")
        }
    }
 
    func testSCModelBranch() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SAMPLE api/city/getCityByName call partitial response
        let branch_response = """
        {"branch":"Mobilität","branchId":1,"marketplaceList":[{"marketplaceRanking":{"rank":1},"marketplaceId":1,"function":"bikeSharing","isNew":true,"restricted":true,"image":"/img/bike_picture.jpg","language":"de","description":"Marketplace description","icon":"/img/bike_icon.png","marketplace":"Bike Sharing"}],"image":"/img/mobility_picture.jpg","language":"de","parent_id":"2","description":"branch description","icon":"/img/mobility_icon.png"}
        """
        
        let branch_response_data = branch_response.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        // TEST DECODING FROM JSON
        if let branchModel = try? decoder.decode(SCModelBranch.self, from: branch_response_data) {
            XCTAssertTrue(branchModel.id == "1", "SCModelBranch id is wrong!")
            XCTAssertTrue(branchModel.parentID == "2", "SCModelBranch parentID is wrong!")
            XCTAssertTrue(branchModel.branchTitle == "Mobilität", "SCModelBranch branchTitle is wrong!")
            XCTAssertTrue(branchModel.branchDescription == "branch description" , "SCModelBranch branchDescription is wrong!")
            XCTAssertTrue(branchModel.imageURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/mobility_picture.jpg", "SCModelBranch imageURL is wrong!")
            XCTAssertTrue(branchModel.iconURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/mobility_icon.png", "SCModelBranch iconURL is wrong!")
            
            XCTAssertTrue(branchModel.marketplaces.count == 1, "SCModelBranch marketplaces is empty!")
            
            let marketplace = branchModel.marketplaces[0]
            XCTAssertTrue(marketplace.id == "1", "SCModelMarketplace id is wrong!")
            XCTAssertTrue(marketplace.marketplaceTitle == "Bike Sharing", "SCModelMarketplace marketplaceTitle is wrong!")
            XCTAssertTrue(marketplace.marketplaceDescription == "Marketplace description", "SCModelMarketplace marketplaceDescription is wrong!")
            XCTAssertTrue(marketplace.marketplaceFunction == "bikeSharing" , "SCModelMarketplace marketplaceFunction is wrong!")
            XCTAssertTrue(marketplace.imageURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/bike_picture.jpg", "SCModelMarketplace imageURL is wrong!")
            XCTAssertTrue(marketplace.iconURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/bike_icon.png", "SCModelMarketplace iconURL is wrong!")
            XCTAssertTrue(marketplace.authNeeded == true , "SCModelMarketplace authNeeded is wrong!")
            XCTAssertTrue(marketplace.isNew == true , "SCModelMarketplace isNew is wrong!")

        } else {
            XCTFail("Couldn't decode data for SCModelBranch!")
        }
    }

    func testSCModelCategory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SAMPLE api/city/getCityByName call partitial response
        let category_response = """
        {"category":"Bürgerservices","citizenServiceList":[{"service":"Ausweis Management","isNew":false,"function":"ausweis","restricted":true,"serviceId":1,"image":"/img/passport_picture.jpg","language":"de","description":"service description","citizenServiceRanking":{"rank":8},"icon":"/img/passport_icon.png","residence":true}],"categoryId":1,"image":"/img/city_picture.jpg","language":"de","parent_id":"2","description":"category description","icon":"/img/city_icon.png"}
        """
        
        let category_response_data = category_response.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        // TEST DECODING FROM JSON
        if let categoryModel = try? decoder.decode(SCModelServiceCategory.self, from: category_response_data) {
            XCTAssertTrue(categoryModel.id == "1", "SCModelServiceCategory id is wrong!")
            XCTAssertTrue(categoryModel.parentID == "2", "SCModelServiceCategory parentID is wrong!")
            XCTAssertTrue(categoryModel.categoryTitle == "Bürgerservices", "SCModelServiceCategory categoryTitle is wrong!")
            XCTAssertTrue(categoryModel.categoryDescription == "category description" , "SCModelServiceCategory categoryDescription is wrong!")
            XCTAssertTrue(categoryModel.imageURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/city_picture.jpg", "SCModelServiceCategory imageURL is wrong!")
            XCTAssertTrue(categoryModel.iconURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/city_icon.png", "SCModelServiceCategory iconURL is wrong!")
            
            XCTAssertTrue(categoryModel.services.count == 1, "SCModelServiceCategory services is empty!")
            
            let service = categoryModel.services[0]
            XCTAssertTrue(service.id == "1", "SCModelService id is wrong!")
            XCTAssertTrue(service.serviceTitle == "Ausweis Management", "SCModelService marketplaceTitle is wrong!")
            XCTAssertTrue(service.serviceDescription == "service description", "SCModelService marketplaceDescription is wrong!")
            XCTAssertTrue(service.serviceFunction == "ausweis" , "SCModelService marketplaceFunction is wrong!")
            XCTAssertTrue(service.imageURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/passport_picture.jpg", "SCModelMarketplace imageURL is wrong!")
            XCTAssertTrue(service.iconURL!.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/passport_icon.png", "SCModelMarketplace iconURL is wrong!")
            XCTAssertTrue(service.authNeeded == true , "SCModelService authNeeded is wrong!")
            XCTAssertTrue(service.isNew == false , "SCModelService isNew is wrong!")
            
        } else {
            XCTFail("Couldn't decode data for SCModelServiceCategory!")
        }
    }

    func testSCModelFavorite() {
        
        let favoriteMarketplace = SCModelFavorite.init(contentId: "1", ranking: 999, favoriteType: .marketplace)
        let favoriteService = SCModelFavorite.init(contentId: "2", ranking: 111, favoriteType: .service)

        XCTAssertTrue(favoriteMarketplace.contentId == "1", "SCModelFavorite id is wrong!")
        XCTAssertTrue(favoriteMarketplace.ranking == 999, "SCModelFavorite ranking is wrong!")
        XCTAssertTrue(favoriteMarketplace.favoriteType == .marketplace, "SCModelUserInfo favoriteType is wrong!")
        XCTAssertTrue(favoriteService.favoriteType == .service, "SCModelUserInfo favoriteType is wrong!")

    }

    func testSCModelCityInfo() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SAMPLE api/city/getAllCities call partitial response
        let city_response = """
            {"cityId":1,"cityName":"Darmstadt","cityColor":"#0066ff","country":"Germany","municipalCoat":"/img/WappenDarmstadt.png","postalCode":64283,"stateName":"Hessen",
            "cityPicture":"/img/header_darmstadt2x.jpg","cityPreviewPicture":"/img/header_prev_darmstadt.jpg",,"cityNightPicture":"/img/header_prev_darmstadt.jpg","marketplacePicture":"/img/header_marktplatz2x.jpg",
            "servicePicture":"/img/header_rathaus2x.jpg","language":"de","cityNameGerman":"Darmstadt","cityNameEnglish":"Darmstadt","weatherDTO":null,"cityContentDTO":null,"citizenServiceCategories":null,"branches":null}
            """
        
        let city_response_data = city_response.data(using: .utf8)!

        let decoder = JSONDecoder()
            
        // TEST DECODING FROM JSON
        if let cityModel = try? decoder.decode(SCModelCity.self, from: city_response_data) {
            XCTAssertTrue(cityModel.cityID == 1, "SCModelCityInfo cityID is wrong!")
            XCTAssertTrue(cityModel.name == "Darmstadt", "SCModelCityInfo cityName is wrong!")
            XCTAssertTrue(cityModel.tintColor == UIColor(hex: "0066ff"), "SCModelCityInfo tintColor is wrong!")
            XCTAssertTrue(cityModel.stateName == "Hessen", "SCModelCityInfo stateName is wrong!")
            XCTAssertTrue(cityModel.country == "Germany", "SCModelCityInfo country is wrong!")
            XCTAssertTrue(cityModel.cityImageUrl.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/header_darmstadt2x.jpg", "SCModelCityInfo cityImageUrl is wrong!")
            XCTAssertTrue(cityModel.cityPreviewImageUrl.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/header_prev_darmstadt.jpg", "SCModelCityInfo cityPreviewImageUrl is wrong!")
            XCTAssertTrue(cityModel.cityNightPicture.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/header_prev_darmstadt.jpg", "SCModelCityInfo cityNightPicture is wrong!")
            XCTAssertTrue(cityModel.serviceImageUrl.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/header_rathaus2x.jpg", "SCModelCityInfo serviceImageUrl is wrong!")
            XCTAssertTrue(cityModel.marketplaceImageUrl.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/header_marktplatz2x.jpg", "SCModelCityInfo marketplaceImageUrl is wrong!")
            XCTAssertTrue(cityModel.municipalCoatImageUrl.absoluteUrlString() == "https://\(GlobalConstants.kBackend_Domain)/img/WappenDarmstadt.png", "SCModelCityInfo municipalCoatImageUrl is wrong!")
        } else {
            XCTFail("Couldn't decode data for SCModelCityInfo!")
        }
    }

    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

 */

