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
//  SCCityContentSharedWorkerTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 04.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCCityContentSharedWorkerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTriggerAndGetCities() {
        
        let cityContentWorker = SCCityContentSharedWorker(requestFactory: MockRequest())
        
        let citiesTriggeredAndFetchedExpectation = expectation(description: "content triggered and fetched")
        
        // trigger update, then switch, then trigger again
        // this will change in the near future
        cityContentWorker.triggerCitiesUpdate() { (error) in
            XCTAssertNil(error)
            
            XCTAssertEqual(cityContentWorker.getCities()?.count, 6)

            citiesTriggeredAndFetchedExpectation.fulfill()
        }
        
        wait(for: [citiesTriggeredAndFetchedExpectation], timeout: 1)
    }


    func testTriggerAndGetContent() {
        
        let cityContentWorker = SCCityContentSharedWorker(requestFactory: MockRequest())
        
        cityContentWorker.triggerCityContentUpdate(for: 4) { (error) in
            
            let cityContentData = cityContentWorker.getCityContentData(for: cityContentWorker.getCityID())
            
//            XCTAssertEqual(cityContentData?.city.name, "München")
        }

    }
}

private class MockRequest: SCRequestCreating, SCDataFetching {
    
    
    func createRequest() -> SCDataFetching {
        return MockRequest()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
        if url.absoluteString.lowercased().contains("get_allcities") {
            let mockData = citiesJson.data(using: .utf8)!
            completion(.success(mockData))
        } else if url.absoluteString.lowercased().contains("get_cityservicedata") {
            let mockData = citiyServicesJson.data(using: .utf8)!
            completion(.success(mockData))
        } else if url.absoluteString.lowercased().contains("get_news") {
            let mockData = citiyNewsJson.data(using: .utf8)!
            completion(.success(mockData))
        } else {
            let mockData = cityJson.data(using: .utf8)!
            completion(.success(mockData))
        }
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

    // MARK: - WARNING!
    /*
     Beware: in mock jsons using the """ text """ format,
     we need to DOUBLE ESCAPE and special charaters, e.g.:
     \\n instead of \m
     and
     \\" insteand if \"
     */
    // MARK: -
    private let citiesJson = """
{
    "content": [
        {
            "cityColor": "#FF0000",
            "cityId": 4,
            "cityName": "München",
            "cityPicture": "/img/headerMonheim.jpg",
            "cityPreviewPicture": "/img/headerprevMonheim.jpg",
            "cityNightPicture": "/img/headerprevMonheim.jpg",
            "country": "Germany",
            "municipalCoat": "/img/logo_monheim3x.png",
            "postalCode": [
                "80331",
                "81929"
            ],
            "servicePicture": "/img/headerBuergerservicfeMonheim.jpg",
            "stateName": "Bavaria",
            "latitude": 0.0,
            "longitude": 0.0
        },
        {
            "cityColor": "#AFC541",
            "cityId": 6,
            "cityName": "Bingöl",
            "cityPicture": "/img/MonheimPassIcon.png",
            "cityPreviewPicture": "/img/MonheimPassIcon.png",
            "cityNightPicture": "/img/MonheimPassIcon.png",
            "country": "Ağrı",
            "municipalCoat": "/img/MonheimPassIcon.png",
            "postalCode": [
                "93333"
            ],
            "servicePicture": "/img/MonheimPassIcon.png",
            "stateName": "Hakkâri",
            "latitude": 0.0,
            "longitude": 0.0
        },
        {
            "cityColor": "#7141C5",
            "cityId": 7,
            "cityName": "Baden-Württemberg",
            "cityPicture": "/img/monheimPass.jpg",
            "cityPreviewPicture": "/img/monheimPass.jpg",
            "cityNightPicture": "/img/monheimPass.jpg",
            "country": "Altötting",
            "municipalCoat": "/img/monheimPass.jpg",
            "postalCode": [
                "72568",
                "72985",
                "78954"
            ],
            "servicePicture": "/img/monheimPass.jpg",
            "stateName": "Weiß Ferdl ",
            "latitude": 0.0,
            "longitude": 0.0
        },
        {
            "cityColor": "fdsfsfs",
            "cityId": 11,
            "cityName": "abc",
            "cityPicture": "abc",
            "cityPreviewPicture": "abc",
            "cityNightPicture": "abc",
            "country": "df",
            "municipalCoat": "abc",
            "postalCode": [
                "1223"
            ],
            "servicePicture": "abc",
            "stateName": "sad",
            "latitude": 0.0,
            "longitude": 0.0
        },
        {
            "cityColor": "#fefefe",
            "cityId": 13,
            "cityName": "pune",
            "cityPicture": "test",
            "cityPreviewPicture": "test",
            "cityNightPicture": "test",
            "country": "india",
            "municipalCoat": "test",
            "postalCode": [
                "11111"
            ],
            "servicePicture": "test",
            "stateName": "maharashtra",
            "latitude": 0.0,
            "longitude": 0.0
        },
        {
            "cityColor": "#D50000",
            "cityId": 17,
            "cityName": "Dortmund ",
            "cityPicture": "/img/headerDortmund.png",
            "cityPreviewPicture": "/img/headerprevDortmund.jpg",
            "cityNightPicture": "/img/headerprevDortmund.jpg",
            "country": "Germany ",
            "municipalCoat": "/img/municipalCoatDortmund.png",
            "postalCode": [
                "44135",
                "44137",
                "44139",
                "44141",
                "44143",
                "44145",
                "44147",
                "44149",
                "44225",
                "44227",
                "44229",
                "44263",
                "44265",
                "44267",
                "44269",
                "44287",
                "44289",
                "44309",
                "44319",
                "44328",
                "44329",
                "44339",
                "44357",
                "44359",
                "44369",
                "44379",
                "44388"
            ],
            "servicePicture": "/img/headerBuergerServiceDortmund.jpg",
            "stateName": "North Rhine-Westphalia",
            "latitude": 0.0,
            "longitude": 0.0
        }
    ]
}
"""

    private let citiyServicesJson = """
        {
        "content": [
            {
                "cityServiceCategoryList": [
                    {
                        "categoryId": "4",
                        "category": "Library",
                        "icon": "/img/wallet_icon.png",
                        "image": "/img/tourism_picture.jpg",
                        "description": "Use many advantages in Monheim with the Monheim Pass, simple and uncomplicated.",
                        "cityServiceList": [
                            {
                                "serviceId": 8,
                                "service": "Library",
                                "description": "Use many advantages in Monheim with the Monheim Pass, simple and uncomplicated.",
                                "icon": "/img/bibliothek-icon.png",
                                "image": "/img/library-tile.jpg",
                                "function": "monicard",
                                "isNew": false,
                                "new": false,
                                "residence": true,
                                "restricted": true
                            }
                        ]
                    },
                    {
                        "categoryId": "11",
                        "category": "Transport",
                        "icon": "/img/wallet_icon.png",
                        "image": "/img/transportMonheim.png",
                        "description": "With the public transport service you can find stops in your area, select journeys and buy tickets for your public transport journeys.",
                        "cityServiceList": [
                            {
                                "serviceId": 20,
                                "service": "Public Transport",
                                "description": "<html><body><h3>How to buy a ticket?</h3><p>This service is currently provided via the Handyticket-Deutschland-App.</p><p>If you already have the Handyticket-Deutschland-App, you can start buying tickets directly from here.</p> </body</html>",
                                "icon": "/img/opnvicon.png",
                                "image": "/img/transportMonheimTile.jpg",
                                "function": "transport",
                                "isNew": false,
                                "new": false,
                                "residence": false,
                                "restricted": false
                            }
                        ]
                    },
                    {
                        "categoryId": "12",
                        "category": "Participation-Portal",
                        "icon": "/img/wallet_icon.png",
                        "image": "/img/mitmachenMonheim.jpg",
                        "description": "Your engagement is welcome. Here we offer you the opportunity to participate actively.",
                        "cityServiceList": [
                            {
                                "serviceId": 21,
                                "service": "Citizen-Participation",
                                "description": "<h3>Shape Your City</h3> <p>Here you will find four platforms on which you can get involved in different ways. With the Monheim-Pass you can log in easily and conveniently. Join in!",
                                "icon": "/img/mitmachenMonheimIcon.png",
                                "image": "/img/mitmachenMonheim.jpg",
                                "function": "mitmach",
                                "isNew": false,
                                "new": false,
                                "residence": false,
                                "restricted": false
                            }
                        ]
                    }
                ],
                "cityId": 4
            }
        ]
    }
    """

    private let citiyNewsJson = """
    {
        "content": [
            {
                "contentId": 15639,
                "contentCreationDate": "2020-04-17 14:04:39",
                "contentDetails": "Corona macht bisweilen auch erfinderisch: Die Musikschule startet ab Montag, 20. April, ein Online-Angebot für alle ihre Instrumental- und Gesangsschüler. Es ist aktuell kostenlos, auch weiterhin müssen keine Entgelte gezahlt werden.\\n\\n„Normalerweise würden wir so ein Angebot mit ausführlichen Tests und Schulungen der Lehrkräfte vorbereiten, das war in der momentanen Situation nicht möglich. Daher testen wir nun direkt ‚live‘ mit unseren Schülerinnen und Schülern, berechnen den Unterricht aber nicht – zunächst bis Ende Mai. Es sei denn, der Regelbetrieb startet wieder“, erläutert Musikschulleiter Jörg Sommerfeld. Besonders froh sei man, dass man für alle Schüler Lizenzen bei einem deutschen Spezialanbieter für einen Musikunterricht per Video beschaffen konnte. Insbesondere das wichtige Thema Datenschutz sei damit sehr gut gelöst. Aber auch die Spezialfunktionen dieser Software gehen deutlich über das hinaus, was mit den üblichen Videokonferenzprogrammen musikalisch möglich wäre.\\n\\nFür den Videounterricht benötigt man ein Tablet, Smartphone oder einen PC mit Kamera und Mikrophon. Die Software selbst funktioniert ohne Installation im Browser. Aber auch ein telefonischer Unterricht ist möglich. Für den Unterricht muss eine Einverständniserklärung unterschrieben werden und der Lehrkraft zum Beispiel als Handyfoto zugemailt werden.\\n\\nAlle Eltern wurden von der Musikschule schriftlich informiert. Darüber hinaus wurde eine Hotline zum Thema Fernunterricht eingerichtet, an die sich Schüler und Eltern bei Fragen und Problemen wenden können. Unter Telefon 02173 951-4126 ist an jedem Werktag von 13 bis 18 Uhr ein Mitglied der Musikschulleitung erreichbar.\\n\\nAuch für die Vorschulkinder der Musikalischen Früherziehung und des Musikgartens gibt es übrigens regelmäßig die „Monheimer Musikkiste“ mit einem Video und musikalischen Anregungen. Fachleiterin Corinna Nasirat freut sich: „Wir möchten auch im Lockdown den Kontakt zu den Kindern halten. Durch die vielen Bilder, die uns immer danach zugemailt werden, bekommen wir auch Gefühl dafür, was bei den Kindern ankommt.“ (nj)",
                "contentImage": "https://www.monheim.de/fileadmin/_processed_/e/6/csm_20200417js_Musikschule_Online_3fdbeed6c2.jpg",
                "imageCredit": "Foto: Jörg Sommerfeld",
                "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/fernunterricht-der-musikschule-nach-den-ferien-8433",
                "contentTeaser": "Fernunterricht der Musikschule nach den Ferien",
                "cityId": 4,
                "language": "de",
                "sticky": false,
                "thumbnail": "https://www.monheim.de/fileadmin/_processed_/e/6/csm_20200417js_Musikschule_Online_3fdbeed6c2.jpg",
                "thumbnailCredit": "Foto: Jörg Sommerfeld",
                "contentSubtitle": "Fernunterricht der Musikschule nach den Ferien",
                "uid": 8433
            }
        ]
    }
    """

    private let cityJson = """
    {
        "content": [
            {
                "cityId": 4,
                "cityName": "Monheim am Rhein",
                "cityColor": "#0098DB",
                "country": "Germany",
                "municipalCoat": "/img/logo_monheim3x.png",
                "postalCode": "40788",
                "stateName": "Nordrhein-Westfalen",
                "cityPicture": "/img/headerMonheim.jpg",
                "cityPreviewPicture": "/img/headerprevMonheim.jpg",
                "cityNightPicture": "/img/headerprevMonheim.jpg",
                "servicePicture": "/img/headerBuergerserviceMonheim.jpg",
                "imprintLink": "https://imprint.com",
                "cityConfig": {
                    "showCategories": false,
                    "showFavouriteServices": false,
                    "showHomeDiscounts": false,
                    "showHomeOffers": false,
                    "showHomeTips": false,
                    "showFavouriteMarketplaces": false,
                    "showNewServices": false,
                    "showNewMarketplaces": false,
                    "showMostUsedServices": false,
                    "showMostUsedMarketplaces": false,
                    "showBranches": false,
                    "showDiscounts": false,
                    "showOurMarketPlaces": false,
                    "showOurServices": true,
                    "showMarketplacesOption": false,
                    "showServicesOption": false,
                    "stickyNewsCount": 4,
                    "yourEventsCount": 2,
                    "eventsCount": 4
                },
                "cityEventCategories": [
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": 4,
                        "icon": "/img/wallet_icon.png",
                        "description": "Use many advantages in Monheim with the Monheim Pass, simple and uncomplicated.",
                        "category": "Library",
                        "image": "/img/tourism_picture.jpg"
                    },
                    {
                        "categoryId": 4,
                        "icon": "/img/wallet_icon.png",
                        "description": "Use many advantages in Monheim with the Monheim Pass, simple and uncomplicated.",
                        "category": "Library",
                        "image": "/img/tourism_picture.jpg"
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": null,
                        "icon": null,
                        "description": null,
                        "category": null,
                        "image": null
                    },
                    {
                        "categoryId": 11,
                        "icon": "/img/wallet_icon.png",
                        "description": "With the public transport service you can find stops in your area, select journeys and buy tickets for your public transport journeys.",
                        "category": "Transport",
                        "image": "/img/transportMonheim.png"
                    },
                    {
                        "categoryId": 11,
                        "icon": "/img/wallet_icon.png",
                        "description": "With the public transport service you can find stops in your area, select journeys and buy tickets for your public transport journeys.",
                        "category": "Transport",
                        "image": "/img/transportMonheim.png"
                    },
                    {
                        "categoryId": 12,
                        "icon": "/img/wallet_icon.png",
                        "description": "Your engagement is welcome. Here we offer you the opportunity to participate actively.",
                        "category": "Participation-Portal",
                        "image": "/img/mitmachenMonheim.jpg"
                    },
                    {
                        "categoryId": 12,
                        "icon": "/img/wallet_icon.png",
                        "description": "Your engagement is welcome. Here we offer you the opportunity to participate actively.",
                        "category": "Participation-Portal",
                        "image": "/img/mitmachenMonheim.jpg"
                    }
                ]
            }
        ]
    }
"""
}
