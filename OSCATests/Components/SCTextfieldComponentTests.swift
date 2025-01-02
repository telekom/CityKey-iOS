//
//  SCTextfieldComponentTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 29.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
//@testable import SmartCity

class SCTextfieldComponentTests: XCTestCase {

    var component: SCTextfieldComponent? = nil

    override func setUp() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "TextfieldComponent", bundle: bundle)
        component = storyboard.instantiateViewController(withIdentifier: "SCTextfieldComponent") as? SCTextfieldComponent
        _ = component?.view
        XCTAssertNotNil(component)
    }

    func testTextfieldComponentIsConfigurable() {
        component?.setTextfieldType(.password)
        component?.configure(placeholder: "myPlaceholder", fieldType: .password, maxCharCount: 255, autocapitalization: .none)
        XCTAssertTrue(component?.textField.isSecureTextEntry == true)
        XCTAssertTrue(component?.textField.placeholder == "myPlaceholder")
        XCTAssertTrue(component?.maxCharCount == 255)
    }

    func testAccessibilityIdentifiersAreSet() {
        component?.accessibilityIdentifier = "testComponent"
        XCTAssertTrue(component?.actionButton.accessibilityIdentifier != nil)
    }

    func testValidationState() {
        XCTAssertTrue(component?.validationState == .unmarked)
        XCTAssertNil(component?.validationStateImageView.image)
    }

    func testSetValidationStateWrong() {
        component?.validationState = .wrong
        XCTAssertTrue(component?.validationStateImageView.image == UIImage(named: "icon_val_error"))
    }

    func testSetValidationStateOk() {
        component?.validationState = .ok
        XCTAssertTrue(component?.validationStateImageView.image == UIImage(named: "icon_val_ok"))
    }

    func testSetValidationStateWarning() {
        component?.validationState = .warning
        XCTAssertTrue(component?.validationStateImageView.image == UIImage(named: "icon_val_warning"))
    }

}
