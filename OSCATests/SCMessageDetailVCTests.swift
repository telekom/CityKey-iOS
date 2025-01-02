//
//  SCMessageDetailVCTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 23/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCMessageDetailVCTests: XCTestCase {

    private func prepareSut() -> SCMessageDetailVC {
        let storyboard = UIStoryboard(name: "MessageDetailScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCMessageDetailTyp2") as! SCMessageDetailVC
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let navTitle: String = "News"
        let title: String = "22. June 2022"
        let teaser: String = "Checkliste der Stadt zur Grundsteuerreform"
        let details: String = "Das Bauordnungsamt der Stadt Bonn hat grundlegende Informationen zum Verfahren zusammengestellt und die Checkliste der Finanzverwaltung NRW um einige Hinweise ergänzt."
        let image = SCImageURL(urlString: "https://obs.eu-de.otc.t-systems.com/city-news-images/qa/img/8/moneynattanan_Kanchanaprat_pixabay.jpg", persistence: false)
        let subtitle = ""
        let sut = prepareSut()
        sut.setContent(navTitle: navTitle, title: title, teaser: teaser,
                       subtitle: subtitle, details: details,
                       imageURL: image, photoCredit: nil,
                       contentURL: nil, tintColor: nil,
                       injector: MockSCInjector())
        sut.viewDidLoad()
        XCTAssertEqual(sut.teaserLabel.text, teaser)
        XCTAssertEqual(sut.titleLabel.text,  title)
        XCTAssertEqual(sut.navigationItem.title, navTitle)
        XCTAssertEqual(sut.subtitleLabel.text,  subtitle)
    }
    
    func testLinkBtnWasPressed() {
        let navTitle: String = "News"
        let title: String = "22. June 2022"
        let teaser: String = "Checkliste der Stadt zur Grundsteuerreform"
        let details: String = "Das Bauordnungsamt der Stadt Bonn hat grundlegende Informationen zum Verfahren zusammengestellt und die Checkliste der Finanzverwaltung NRW um einige Hinweise ergänzt."
        let image = SCImageURL(urlString: "https://obs.eu-de.otc.t-systems.com/city-news-images/qa/img/8/moneynattanan_Kanchanaprat_pixabay.jpg", persistence: false)
        let subtitle = ""
        let contentURL: URL = URL(string: "https://www.bonn.de/pressemitteilungen/juni-2022/checkliste-der-stadt-zur-grundsteuerreform.php")!
        let sut = prepareSut()
        sut.setContent(navTitle: navTitle, title: title, teaser: teaser,
                       subtitle: subtitle, details: details,
                       imageURL: image, photoCredit: nil,
                       contentURL: contentURL, tintColor: nil,
                       injector: MockSCInjector(),
                       beforeDismissCompletion: nil)
        sut.viewDidLoad()
        sut.linkBtnWasPressed("")
        XCTAssertEqual(sut.contentURL, contentURL)
        
        
    }

}
