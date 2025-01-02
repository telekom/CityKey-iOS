//
//  SCDefectReporterFormViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 27/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
import CoreLocation
class SCDefectReporterFormViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCDefectReporterFormPresenting? = nil) -> SCDefectReporterFormViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterFormViewController") as! SCDefectReporterFormViewController
        sut.presenter = presenter ?? SCDefectReporterFormPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterFormPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewLoaded)
    }
    
    func testViewWillAppear() {
        let sut = prepareSut()
        sut.viewWillAppear(true)
        guard let presenter = sut.presenter as? SCDefectReporterFormPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewWillAppearCalled)
    }
    
    func testSetupPrefilledEmail() {
        let sut = prepareSut()
        sut.setupPrefilledEmail()
        guard let presenter = sut.presenter as? SCDefectReporterFormPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.updateSendReportBtnStateCalled)
    }
    
    func testDeleteSelectedImage() {
        let sut = prepareSut()
        sut.deleteSelectedImage()
        XCTAssertTrue(sut.defectPhotoImageView.isHidden)
        XCTAssertTrue(sut.deletePhotoBtn.isHidden)
        XCTAssertFalse(sut.addPhotoLabel.isHidden)
        XCTAssertFalse(sut.addPhotoBtn.isHidden)
    }
    
    func testTermsBtnWasPressed() {
        let sut = prepareSut()
        sut.termsViewWasPressed()
        guard let presenter = sut.presenter as? SCDefectReporterFormPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isTermsWasPressed)
    }
    
    func testAddPhotoBtnWasPressed() {
        let sut = prepareSut()
        sut.addPhotoBtnWasPressed(UIButton())
        XCTAssertFalse(sut.activityIndicator.isHidden)
        XCTAssertTrue(sut.defectPhotoImageView.isHidden)
        XCTAssertTrue(sut.addPhotoLabel.isHidden)
        XCTAssertTrue(sut.addPhotoBtn.isHidden)
        XCTAssertTrue(sut.deletePhotoBtn.isHidden)
    }
    
    func testDeletePhotoBtnWasPressed() {
        let sut = prepareSut()
        sut.deletePhotoBtnWasPressed(UIButton())
        XCTAssertNil(sut.defectPhotoImageView.image)
        XCTAssertTrue(sut.defectPhotoImageView.isHidden)
        XCTAssertTrue(sut.deletePhotoBtn.isHidden)
        XCTAssertFalse(sut.addPhotoLabel.isHidden)
        XCTAssertFalse(sut.addPhotoBtn.isHidden)
    }
    
    func testSetupFormUI() {
        let subCategory = SCModelDefectSubCategory(serviceCode: "serviceCode",
                                                   serviceName: "serviceName",
                                                   description: "description",
                                                   isAdditionalInfo: false)
        let sut = prepareSut()
        sut.setupFormUI(subCategory)
        XCTAssertEqual(sut.locationTitleLabel.text, LocalizationKeys.SCDefectReporterFormVC.dr003LocationLabel.localized())
        XCTAssertEqual(sut.changeLocationBtn.titleLabel?.text, LocalizationKeys.SCDefectReporterFormVC.dr003ChangeLocationButton.localized())
        XCTAssertEqual(sut.sendReportBtn.titleLabel?.text, LocalizationKeys.SCDefectReporterFormVC.dr003SendReportLabel.localized())
        XCTAssertEqual(sut.issueDetailLabel.text, LocalizationKeys.SCDefectReporterFormVC.dr003DescribeIssueLabel.localized())
    }
    
    func testSetNavigation() {
        let sut = prepareSut()
        sut.setNavigation(title: "title")
        XCTAssertEqual(sut.navigationItem.title, "title")
        XCTAssertEqual(sut.navigationItem.backButtonTitle, LocalizationKeys.Common.navigationBarBack.localized())
    }
    
    func testUpdateTermsValidationStateTrue() {
        let sut = prepareSut()
        sut.updateTermsValidationState(false, showErrorInfoWhenNotAccepted: true)
        XCTAssertEqual(sut.termsValidationStateLabel.text, LocalizationKeys.SCDefectReporterFormVC.r001RegistrationLabelConsentRequired.localized())
        XCTAssertFalse(sut.termsValidationStateLabel.accessibilityElementsHidden)
        XCTAssertEqual(sut.termsValidationStateLabel.accessibilityLabel,
                       LocalizationKeys.SCDefectReporterFormVC.r001RegistrationLabelConsentRequired.localized().localized())
    }
    
    func testUpdateTermsValidationStateFalse() {
        let sut = prepareSut()
        sut.updateTermsValidationState(true, showErrorInfoWhenNotAccepted: true)
        XCTAssertTrue(sut.termsValidationStateLabel.accessibilityElementsHidden)
    }
    
    func testUpdateTermsCheckbox() {
        let sut = prepareSut()
        sut.updateTermsCheckbox(accepted: true)
        XCTAssertNil(sut.termsValidationStateLabel.text)
        XCTAssertNil(sut.termsValidationStateView.image)
        
    }
}

class SCDefectReporterFormPresenterMock: SCDefectReporterFormPresenting {
    private(set) var isViewLoaded: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    var mandatoryFields: [SCDefectReporterInputFields] = []
    private(set) var updateSendReportBtnStateCalled: Bool = false
    private(set) var isTermsWasPressed: Bool = false
    func setDisplay(_ display: SCDefectReporterFormViewDisplay) {
        isViewLoaded = true
    }
    
    func viewWillAppear() {
        isViewWillAppearCalled = true
    }
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCDefectReporterInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable? {
        nil
    }
    
    func textFieldComponentDidChange(for inputField: SCDefectReporterInputFields) {
        
    }
    
    func txtFieldEditingDidEnd(value: String, inputField: SCDefectReporterInputFields, textFieldType: SCTextfieldComponentType) {
        
    }
    
    func termsWasPressed() {
        isTermsWasPressed = true
    }
    
    func presentTermsAndConditions() {
        
    }
    
    func presentRulesOfUse() {
        
    }
    
    func changeLocationBtnWasPressed() {
        
    }
    
    func sendReportBtnWasPressed(defectLocation: LocationDetails?) {
        
    }
    
    func getDefectLocation() -> CLLocation {
        CLLocation(latitude: 0.00, longitude: 0.00)
    }
    
    func getServiceData() -> SCBaseComponentItem {
        let serviceParams = ["field_firstName": "OPTIONAL", "field_email": "REQUIRED", "field_checkBoxTerms2": "NOT REQUIRED", "field_lastName": "OPTIONAL", "dataPrivacyNoticeLink": "https://www.leanact.de/agb-und-datenschutz/", "field_uploadImage": "OPTIONAL", "field_yourConcern": "REQUIRED"]
        return SCBaseComponentItem(itemID: "186", itemTitle: "Defect Reporter", itemTeaser: nil, itemSubtitle: nil,
                            itemImageURL: SCImageURL(urlString: "/img/defect-reporter-img.png", persistence: false),
                            itemImageCredit: nil, itemThumbnailURL: nil, itemIconURL: SCImageURL(urlString: "/img/mangelmelder-icon.png", persistence: false),
                            itemURL: nil, itemDetail: "<html><body style=\"margin: 0; padding: 0\"><h3>Tell us!</h3> <p>With our defect report you can tell us if there are problems in our cityscape (wild garbage, noise pollution, wanton damage, etc.). Your concern will be processed by us as soon as possible. You help us to make our city more beautiful.</p> </body</html>",
                            itemHtmlDetail: true, itemCategoryTitle: Optional("My services"), itemColor: .black, itemCellType: OSCA.SCBaseComponentItemCellType.tiles_icon, itemLockedDueAuth: false, itemLockedDueResidence: false, itemIsNew: false, itemFunction: "mängelmelder",
                            itemBtnActions: nil,
                            itemContext: SCBaseComponentItemContext.none, badgeCount: nil,
                            itemServiceParams: serviceParams,
                            helpLinkTitle: nil, templateId: nil, headerImageURL: nil)
    }
    
    func setManadatoryFields() -> [SCDefectReporterInputFields] {
        mandatoryFields
    }
    
    func updateManadatoryFields(_ field: SCDefectReporterInputFields) {
        
    }
    
    func getProfileData() -> SCModelProfile? {
        nil
    }
    
    func updateSendReportBtnState() {
        updateSendReportBtnStateCalled = true
    }

    func getServiceFlow() -> Services {
        return .defectReporter
    }
}
