//
//  SCRegistrationTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 09.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

private struct DummyInput {
    let input: String
    let fieldType: SCTextfieldComponentType
}

class SCRegistrationTests: XCTestCase {

    func testIsInputValidWithValidInputs() {
        let dummyInputs = [DummyInput(input: "tester@test.de", fieldType: .email),
                          DummyInput(input: "abcd1234!&%$", fieldType: .newPassword),
                          DummyInput(input: "Apr 9, 2019", fieldType: .birthdate),
                          DummyInput(input: "34443", fieldType: .postalCode)]
        
        for dummy in dummyInputs {
            let result = SCInputValidation.isInputValid(dummy.input, fieldType: dummy.fieldType)
            XCTAssert(result.isValid)
            XCTAssertNil(result.message)
        }
    }
    
    func testIsInputValidWithInvalidInputs() {
        // We dont check Email and Card No format in client side, Just if it is empty
        let dummyInputs = [DummyInput(input: "", fieldType: .email),
                           DummyInput(input: "", fieldType: .newPassword),
                           DummyInput(input: "", fieldType: .birthdate),
                           DummyInput(input: "", fieldType: .postalCode)]
        
        for dummy in dummyInputs {
            let result = SCInputValidation.isInputValid(dummy.input, fieldType: dummy.fieldType)
            XCTAssertFalse(result.isValid)
            XCTAssertNotNil(result.message)
            XCTAssert((result.message?.count ?? 0) > 0)
        }
    }
    
    func testValidateFirstPassword() {
        
        XCTAssertTrue(SCInputValidation.validateFirstPassword("aq@bb.de", email: "aq@bb.de") == .sameAsEMail)
        XCTAssertTrue(SCInputValidation.validateFirstPassword("123Start", email: "aq@bb.de") == .tooWeak)
        XCTAssertTrue(SCInputValidation.validateFirstPassword("123St!", email: "aq@bb.de") == .tooWeak)
        XCTAssertTrue(SCInputValidation.validateFirstPassword("testtest!!!!", email: "aq@bb.de") == .tooWeak)
        XCTAssertTrue(SCInputValidation.validateFirstPassword("Test123!", email: "aq@bb.de") == .strong)
        XCTAssertTrue(SCInputValidation.validateFirstPassword("", email: "aq@bb.de") == .empty)
    }
    
    func testValidateSecondPassword() {
        
        XCTAssertTrue(SCInputValidation.validateSecondPassword("Start123!", firstPwd: "Start123!") == .pwdsAreMatching)
        XCTAssertTrue(SCInputValidation.validateSecondPassword("123Start", firstPwd: "Start123!!") == .pwdsAreDifferent)
        XCTAssertTrue(SCInputValidation.validateSecondPassword("", firstPwd: "aq@bb.de") == .empty)

        XCTAssertTrue(SCInputValidation.isPwdString("12345", startingWith: "123"))
        XCTAssertFalse(SCInputValidation.isPwdString("12345", startingWith: "123456"))
        XCTAssertFalse(SCInputValidation.isPwdString("rwerew", startingWith: "wevwvw"))
    }
    
    func testValidateInputTypes() {
        
        //email
        XCTAssertTrue(SCInputValidation.validateEmail("Star@223").isValid == false && SCInputValidation.validateEmail("Star@223").message == "r_001_registration_error_incorrect_email".localized())
        XCTAssertTrue(SCInputValidation.validateEmail("").isValid == false && SCInputValidation.validateEmail("").message == "r_001_registration_error_empty_field".localized())
        XCTAssertTrue(SCInputValidation.validateEmail("start@ffff.de").isValid == true)
        
        //birthdate
        XCTAssertTrue(SCInputValidation.validateBirthdate("").isValid == false && SCInputValidation.validateBirthdate("").message == "r_001_registration_error_empty_field".localized())
        XCTAssertTrue(SCInputValidation.validateBirthdate("31.12.2000").isValid == true)

        //postal code
        XCTAssertTrue(SCInputValidation.validatePostalCode("4444").isValid == false && SCInputValidation.validatePostalCode("4444").message == "r_001_registration_error_incorrect_postcode".localized())
        XCTAssertTrue(SCInputValidation.validatePostalCode("").isValid == false && SCInputValidation.validatePostalCode("").message == "r_001_registration_error_empty_field".localized())
        XCTAssertTrue(SCInputValidation.validatePostalCode("55555").isValid == true)

        //text
        XCTAssertTrue(SCInputValidation.validateText("").isValid == false && SCInputValidation.validateText("").message == "r_001_registration_error_empty_field".localized())
        XCTAssertTrue(SCInputValidation.validateText("fwfefwef").isValid == true)

        //text
        XCTAssertTrue(SCInputValidation.validateText("").isValid == false && SCInputValidation.validateText("").message == "r_001_registration_error_empty_field".localized())
        XCTAssertTrue(SCInputValidation.validateText("fwfefwef").isValid == true)
    }

    func testPWDCriterias() {
        
        //passwordMinCharReached
        XCTAssertTrue(SCInputValidation.passwordMinCharReached(pwd: "Start12!"))
        XCTAssertFalse(SCInputValidation.passwordMinCharReached(pwd: "Start1!"))
        
        //passwordContainsSymbol
        XCTAssertTrue(SCInputValidation.passwordMinCharReached(pwd: "Start12!"))
        XCTAssertTrue(SCInputValidation.passwordMinCharReached(pwd: "St@art12"))
        XCTAssertFalse(SCInputValidation.passwordMinCharReached(pwd: "Start1"))
 
        //passwordContainsDigit
        XCTAssertTrue(SCInputValidation.passwordContainsDigit(pwd: "Starter3"))
        XCTAssertTrue(SCInputValidation.passwordContainsDigit(pwd: "S1arter!"))
        XCTAssertFalse(SCInputValidation.passwordContainsDigit(pwd: "StartABC!!"))

        //passwordContainsSpace
        XCTAssertTrue(SCInputValidation.passwordContainsSpace(pwd: "Star ter3"))
        XCTAssertTrue(SCInputValidation.passwordContainsSpace(pwd: " S1arter!"))
        XCTAssertFalse(SCInputValidation.passwordContainsSpace(pwd: "StartABC!!"))

    }

        
    func passwordMinCharReached(pwd: String) -> Bool {
        return pwd.count >= 8
    }
    
    func passwordContainsSymbol(pwd: String) -> Bool {
        return pwd.containsSpecialCharacter()
    }
    
    func passwordContainsDigit(pwd: String) -> Bool {
        return pwd.containsDigit()
    }
    
    func passwordContainsSpace(pwd: String) -> Bool {
        return pwd.containsSpace()
    }

    

    func testFieldConfiguration() {
        //@Michael: I don't get the need to assert equality of instances.
        let presenter = SCRegistrationPresenter(registrationWorker: MockRegistrationWorker(), appContentSharedWorker: MockAppContentWorker(), injector: MockInjector(), completionOnSuccess: nil)

        let mockedEmailField = MockTextField()
        let emailField = presenter.configureField(mockedEmailField, identifier: "sgtxtfldEmail", type: .email, autocapitalizationType: .none)
        XCTAssertTrue(emailField === mockedEmailField)
        
        let mockedPwd1Field = MockTextField()
        let pwd1Field = presenter.configureField(mockedPwd1Field, identifier: "sgtxtfldPwd1", type: .pwd1, autocapitalizationType: .none)
        XCTAssertTrue(pwd1Field === mockedPwd1Field)
        
        let mockedPwd2Field = MockTextField()
        let pwd2Field = presenter.configureField(mockedPwd2Field, identifier: "sgtxtfldPwd2", type: .pwd2, autocapitalizationType: .none)
        XCTAssertTrue(pwd2Field === mockedPwd2Field)
                
        let mockedBirthdateField = MockTextField()
        let birthdateField = presenter.configureField(mockedBirthdateField, identifier: "sgtxtfldBirthdate", type: .birthdate, autocapitalizationType: .none)
        XCTAssertTrue(birthdateField === mockedBirthdateField)
        
        let mockedCardField = MockTextField()
        let cardField = presenter.configureField(mockedCardField, identifier: "sgtxtfldPostalCode", type: .postalCode, autocapitalizationType: .none)
        XCTAssertTrue(cardField === mockedCardField)
    }
        
    func testDisplayErrorNotShown() {
        let presenter = SCRegistrationPresenter(registrationWorker: MockRegistrationWorker(), appContentSharedWorker: MockAppContentWorker(), injector: MockInjector(), completionOnSuccess: nil)
        let errorDetail = SCWorkerErrorDetails(message: "", errorCode: "")
        XCTAssertFalse(presenter.isErrorHandled(errorDetail))
        XCTAssertFalse(presenter.isErrorHandled(errorDetail))
    }
    
    
    func testPasswordInvalidErrorIsShown() {
        let presenter = SCRegistrationPresenter(registrationWorker: MockRegistrationWorker(), appContentSharedWorker: MockAppContentWorker(), injector: MockInjector(), completionOnSuccess: nil)
        let errorDetail = SCWorkerErrorDetails(message: "", errorCode: SCHandledRegistrationError.passwordValidationError.rawValue)
        XCTAssertTrue(presenter.isErrorHandled(errorDetail))
    }

    func testEmailInvalidErrorIsShown() {
        let presenter = SCRegistrationPresenter(registrationWorker: MockRegistrationWorker(), appContentSharedWorker: MockAppContentWorker(), injector: MockInjector(), completionOnSuccess: nil)
        let errorDetail = SCWorkerErrorDetails(message: "", errorCode: SCHandledRegistrationError.emailValidationError.rawValue)
        XCTAssertTrue(presenter.isErrorHandled(errorDetail))
    }
    
    func testBirthdateInvalidErrorIsShown() {
        let presenter = SCRegistrationPresenter(registrationWorker: MockRegistrationWorker(), appContentSharedWorker: MockAppContentWorker(), injector: MockInjector(), completionOnSuccess: nil)
        let errorDetail = SCWorkerErrorDetails(message: "", errorCode: SCHandledRegistrationError.birthdateValidationError.rawValue)
        XCTAssertTrue(presenter.isErrorHandled(errorDetail))
    }

    func testPostalCodeInvalidErrorIsShown() {
        let presenter = SCRegistrationPresenter(registrationWorker: MockRegistrationWorker(), appContentSharedWorker: MockAppContentWorker(), injector: MockInjector(), completionOnSuccess: nil)
        let errorDetail = SCWorkerErrorDetails(message: "", errorCode: SCHandledRegistrationError.postalValidationError.rawValue)
        XCTAssertTrue(presenter.isErrorHandled(errorDetail))
    }
}

private class MockRegistrationWorker: SCRegistrationWorking{
    func register(registration: SCModelRegistration, completion: @escaping ((Bool, String?, SCWorkerError?) -> Void)) {
        completion(true, "ok", nil)
    }
    
}


private class MockInjector: SCRegistrationInjecting & SCLegalInfoInjecting  & SCAdjustTrackingInjection & SCRegistrationInjecting{
    func getProfileEditDateOfBirthViewController(in flow: OSCA.DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController {
        return UIViewController()
    }
    

    func registerRemotePushForApplication() {
        
    }

    func getDataPrivacyController(preventSwipeToDismiss: Bool, shouldPushSettingsController: Bool) -> UIViewController {
        
        return UIViewController()
    }
    
    func getInfoNoticeController(title: String, content: String, insideNavCtrl: Bool) -> UIViewController{
        return UIViewController()
    }
    
    func getDataPrivacyController(insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacyFirstRunController(preventSwipeToDismiss: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        
        return UIViewController()
    }
    
    func getDataPrivacySettingsController(shouldPushDataPrivacyController: Bool, preventSwipeToDismiss: Bool, isFirstRunSettings: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        
        return UIViewController()
    }

    func trackEvent(eventName: String) {
        
    }
    
    func trackEvent(eventName: String, parameters: [String : String]) {
        
    }
    
    func appWillOpen(url: URL) {
    }
    
    func getRegistrationViewController(completionOnSuccess: ((_ eMail : String,   _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController{
        return UIViewController()
    }
    
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, isError:Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }

    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage: Bool, presentationType: SCRegistrationConfirmEMailType, completionOnSuccess: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getRegistrationFinishedViewController(registeredEmail: String) -> UIViewController {
        return UIViewController()
    }
    
    func getDataPrivacyNoticeController(insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }

    
}

private class MockAppContentWorker: SCAppContentSharedWorking {
    
    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void) {
        
    }
    
    func isNearestCityAvailable() -> Bool {
        return false
    }
    
    func updateNearestCity(cityId: Int) {
        
    }
    
    func storedNearestCity() -> Int {
        return 0
    }
    
    func isDistanceToNearestLocationAvailable() -> Bool {
        return false
    }
    
    func updateDistanceToNearestLocation(distance: Double) {
        
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return 0.0
    }
    

    var termsDataState =  SCWorkerDataState()

    var firstTimeUsageFinished: Bool = true
    
    var switchLocationToolTipShouldBeShown: Bool = true

    var trackingPermissionFinished: Bool = true
    
    func getDataSecurity() -> SCModelTermsDataSecurity? {
        return nil
    }

    var isToolTipShown: Bool = true
    
    var privacyOptOutMoEngage: Bool = true
    
    var privacyOptOutAdjust: Bool = true
     
    var isCityActive: Bool = true

    func getDataPrivacyLink() -> String? {
        return nil
    }
    
    func observePrivacySettings(completion: @escaping (Bool, Bool) -> Void) {
        
    }
    
    func getFAQLink() -> String? {
        return nil
    }
    
    func getLegalNotice() -> String? {
        return nil
    }
    
    func getTermsAndConditions() -> String? {
        return nil
    }
    
    func triggerTermsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    

}

fileprivate class MockTextField: SCTextFieldConfigurable {
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType) {
    }
    
    func setEnabled(_ enabled: Bool) {
    }
    
}
