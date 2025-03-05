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
//  SCEventDetailViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 23/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCEventDetailViewControllerTests: XCTestCase {

    private func prepareSut() -> SCEventDetailViewController {
        let storyboard = UIStoryboard(name: "EventDetailScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCEventDetailViewController") as! SCEventDetailViewController
        sut.presenter = SCEventDetailPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testCloseButtonWasPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.closeBtnWasPressed("")
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isCloseCalled)
    }
    
    func testShareBtnWasPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.shareBtnWasPressed("")
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isshareCalled)
    }
    
    func testHandleFavoriteViewTapped() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.handleFavoriteViewTapped("")
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isHandleFavoriteCalled)
    }
    
    func testHandleImageViewTapped() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.handleImageViewTapped("")
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isHandleImageViewCalled)
    }
    
    func testMoreLinkWasPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.moreLinkWasPressed()
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isMoreLinkCalled)
    }
    
    func testAddToCalendardWasPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.addToCalendardWasPressed()
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isAddToCalendarCalled)
    }
    
    func testHideMapView() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.hideMapView()
        XCTAssertEqual(sut.mapHeightConstraint.constant, 0.0)
        XCTAssertTrue(sut.tapOnInfolbl.isHidden)
        XCTAssertTrue(sut.mapViewBottomSeperator.isHidden)
        XCTAssertEqual(sut.tapOnInfolblHeightConstraint.constant, 0.0)
    }
    
    func testNoImageToShow() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.noImageToShow()
        XCTAssertTrue(sut.imageView.isHidden)
        XCTAssertEqual(sut.imageViewHeightConstraint.constant, 0)
        XCTAssertEqual(sut.imageViewHeightConstraint1.constant, 0)
        XCTAssertTrue(sut.failedImageView.isHidden)
        XCTAssertEqual(sut.failedImageViewHeightConstraint.constant, 0)
    }

    func testLoadImageWithNoUrl() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.imageURL = nil
        sut.loadImage()
        XCTAssertTrue(sut.imageView.isHidden)
        XCTAssertEqual(sut.imageViewHeightConstraint.constant, 0)
        XCTAssertEqual(sut.imageViewHeightConstraint1.constant, 0)
        XCTAssertTrue(sut.failedImageView.isHidden)
        XCTAssertEqual(sut.failedImageViewHeightConstraint.constant, 0)
    }
    
    func testLoadImageWithUrl() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.imageURL = SCImageURL(urlString: "test", persistence: false)
        sut.loadImage()
        XCTAssertFalse(sut.imageView.isHidden)
    }
    
    func testMapWasTapped() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.mapWasTapped(latitude: 1.0, longitude: 1.0, zoomFactor: 20, address: "test")
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isMapViewTapCalled)
    }
    
    func testDirectionsBtnWasPressed() {
        let sut = prepareSut()
        sut.viewDidLoad()
        sut.directionsBtnWasPressed(latitude: 1.0, longitude: 1.0, address: "")
        guard let presenter = sut.presenter as? SCEventDetailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isDirectionButtonTapped)
    }
    
}
