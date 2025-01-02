//
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
