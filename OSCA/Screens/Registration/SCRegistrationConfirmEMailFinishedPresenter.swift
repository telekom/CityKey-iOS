//
//  SCRegistrationFinishedPresenter.swift
//  SmartCity+
//
//  Created by Michael on 18.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCRegistrationConfirmEMailFinishedDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String)
    func setupUI(titleText: String, detailText: String, btnText: String, topImageSymbol: UIImage)
    func dismissView(completion: (() -> Void)?)
    func popViewController()
    func hideTopImage()
}

protocol SCRegistrationConfirmEMailFinishedPresenting: SCPresenting {
    func setDisplay(_ display: SCRegistrationConfirmEMailFinishedDisplaying)
    func finishedWasPressed()
}

class SCRegistrationConfirmEMailFinishedPresenter {
    weak private var display : SCRegistrationConfirmEMailFinishedDisplaying?
    
    private let injector: SCToolsShowing & SCAdjustTrackingInjection
    private let completionOnSuccess: (() -> Void)?
    private let shouldHideTopImage : Bool
    private let presentationType : SCRegistrationConfirmEMailType

    init(injector: SCToolsShowing & SCAdjustTrackingInjection,
         shouldHideTopImage: Bool,
         presentationType: SCRegistrationConfirmEMailType,
         completionOnSuccess: (() -> Void)?) {
        
        self.injector = injector
        self.completionOnSuccess = completionOnSuccess
        self.shouldHideTopImage = shouldHideTopImage
        self.presentationType = presentationType
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        
        switch presentationType {
        case .confirmMailForPWDReset:
            self.display?.setupNavigationBar(title: "f_001_forgot_password_btn_reset_password".localized())
            self.display?.setupUI(titleText:"f_003_forgot_password_confirm_success_headline".localized(), detailText: "f_003_forgot_password_confirm_success_details".localized(), btnText: "f_003_forgot_password_confirm_success_login_btn".localized(),topImageSymbol: UIImage(named: "icon_reset_password")!)
        case .confirmMailSentBeforeRegistration, .confirmMailForRegistration:

            self.display?.setupNavigationBar(title: "r_005_registration_success_title".localized())
            self.display?.setupUI(titleText:"r_005_registration_success_headline".localized(), detailText: "r_005_registration_success_details".localized(), btnText: "r_005_registration_success_login_btn".localized(),topImageSymbol: UIImage(named: "icon_confirm_email")!)
            
        case .confirmMailForEditEmail:
            self.display?.setupNavigationBar(title: "p_004_profile_email_success_title".localized())
            self.display?.setupUI(titleText:"p_004_profile_email_changed_info_sent_mail".localized(), detailText: "p_004_profile_email_changed_info_received".localized(), btnText: "r_005_registration_success_login_btn".localized(),topImageSymbol: UIImage(named: "icon_confirm_email")!)

        }

        if self.shouldHideTopImage {
            self.hideTopImage()
        }
    }
    
    private func hideTopImage(){
        self.display?.hideTopImage()
    }


}

extension SCRegistrationConfirmEMailFinishedPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
    }
}

extension SCRegistrationConfirmEMailFinishedPresenter: SCRegistrationConfirmEMailFinishedPresenting {
    func setDisplay(_ display: SCRegistrationConfirmEMailFinishedDisplaying) {
        self.display = display
    }
        
    func finishedWasPressed(){
        //MARK: Add "RegistrationComplete" event
        
        if let registration = SCUserDefaultsHelper.getRegistration() {
            var parameters = [String:String]()
            parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
            parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
//            parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = AnalyticsKeys.TrackedParamKeys.notLoggedIn
            parameters[AnalyticsKeys.TrackedParamKeys.userZipcode] = registration.postalCode
            if let userYob = registration.birthdate {
                parameters[AnalyticsKeys.TrackedParamKeys.userYob] = userYob.extractYear()
            }
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.registrationComplete, parameters: parameters)
        }

        completionOnSuccess?()
    }
}
