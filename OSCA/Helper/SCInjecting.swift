/*
Created by Robert Swoboda - Telekom on 08.05.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCAppDelegateInjection {
    func initializeNotificationForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error)

    func refreshInfoBoxData()
    func initializeMoEngageForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}

protocol SCAdjustTrackingInjection {
    func trackEvent(eventName: String)
    func trackEvent(eventName: String, parameters: [String : String])
    func appWillOpen(url: URL)
}

// List of tools: location, registration, profile, login
protocol SCToolsShowing {
    func showLocationSelector()
    func showRegistration()
    func showProfile()
    func showLogin(completionOnSuccess: (() -> Void)?)
}

// LegalInfo is injected everywhere
protocol SCLegalInfoInjecting {
    func getDataPrivacyController(preventSwipeToDismiss: Bool, shouldPushSettingsController: Bool) -> UIViewController
    func getInfoNoticeController(title: String, content: String, insideNavCtrl: Bool) -> UIViewController
    func getDataPrivacyNoticeController(insideNavCtrl: Bool) -> UIViewController
    
    func getDataPrivacyFirstRunController(preventSwipeToDismiss : Bool, completionHandler: (() -> Void)?) -> UIViewController
    func getDataPrivacySettingsController(shouldPushDataPrivacyController: Bool, preventSwipeToDismiss: Bool, isFirstRunSettings: Bool, completionHandler: (() -> Void)?) -> UIViewController
    func registerRemotePushForApplication()
}

protocol SCToolsInjecting {
    func setToolsShower(_ shower: SCToolsShowing)
    func getLocationViewController(presentationMode: SCLocationPresentationMode, includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController
    func getRegistrationViewController(completionOnSuccess: ((_ eMail : String,_ isErrorPresent: Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController
    func getLoginViewController(dismissAfterSuccess: Bool, completionOnSuccess: (() -> Void)?) -> UIViewController
    func getProfileViewController() -> UIViewController
    func getFeedbackController() -> UIViewController
    func getFeedbackConfirmationViewController() -> UIViewController
    func getForceUpdateVersionViewController() -> UIViewController
    func getVersionInformationViewController() -> UIViewController
}

protocol SCMainInjecting {
    func getMainPresenter() -> SCMainPresenting
    func getMainTabBarController() -> UIViewController
    func registerPushForApplication()

    func configureMainTabViewController(_ viewController: UIViewController)
    func getFTUFlowViewController() -> UIViewController
}

protocol SCLoginInjecting {
    func getForgottenViewController(email: String, completionOnSuccess: ((_ eMail : String, _ emailWasAlreadySentBefore: Bool, _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController
    func getTempBlockedViewController(email: String) -> UIViewController
}

protocol SCPWDRestoreUnlockInjecting {
    func getRestoreUnlockFinishedViewController(email: String) -> UIViewController
}

protocol SCRegistrationInjecting {
    func getRegistrationViewController(completionOnSuccess: ((_ eMail : String,  _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage : Bool, presentationType : SCRegistrationConfirmEMailType, isError:Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController
    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage : Bool, presentationType : SCRegistrationConfirmEMailType,completionOnSuccess: (() -> Void)?) -> UIViewController
    func getProfileEditDateOfBirthViewController(in flow: DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController
}

protocol SCProfileInjecting {
    func getProfileEditOverviewViewController(email: String) -> UIViewController
    func getProfileEditPersonalDataOverviewViewController(postcode: String, profile: SCModelProfile) -> UIViewController

}

protocol SCEditProfileInjecting {
    func getProfileEditEMailViewController(email: String) -> UIViewController
    func getProfileEditPasswordViewController(email: String) -> UIViewController
    func getDeleteAccountViewController() -> UIViewController
    func getProfileEditDateOfBirthViewController(in flow: DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController
    func getProfileEditResidenceViewController(postcode: String) -> UIViewController

}

protocol SCDeleteAccountInjecting {
    func getDeleteAccountConfirmationController() -> UIViewController
    func getDeleteAccountSuccessController() -> UIViewController
    func getDeleteAccountErrorController() -> UIViewController
}

protocol SCEditEMailInjecting {
    func getEditEMailFinishedViewController(email: String) -> UIViewController
    func getPWDForgottenViewController(email: String, completionOnSuccess: ((_ eMail : String, _ emailWasAlreadySentBefore: Bool, _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController
}

protocol SCEditPasswordInjecting {
    func getEditPasswordFinishedViewController(email: String) -> UIViewController
    func getPWDForgottenViewController(email: String, completionOnSuccess: ((_ eMail : String, _ emailWasAlreadySentBefore: Bool, _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController
}

protocol SCSharedWorkerInjecting {
    func getAuthorizationSharedWorker() -> SCAuthorizationWorking
    func getCityContentSharedWorker() -> SCCityContentSharedWorking
    func getAppContentSharedWorker() -> SCAppContentSharedWorking
    func getUserContentSharedWorker() -> SCUserContentSharedWorking
    func getUserCityContentSharedWorker() -> SCUserCityContentSharedWorking
}

protocol SCMonheimPassInjecting {
    func getViewControllerForMonheimPass() -> UIViewController
    func getPaymentHistoryViewController() -> UIViewController
}

protocol SCWebContentInjecting {
    func getWebContentViewController(for url : String, title : String?, insideNavCtrl: Bool) -> UIViewController
    
    
    func getWebContentViewController(for url : String, title : String?, insideNavCtrl: Bool, itemServiceParams: [String: String]?, serviceFunction: String?) -> UIViewController
    
    func getWebContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController
    
    func getTextViewContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController
    
    func getTextInWebViewContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController
}

protocol SCLocationInjecting {

}

protocol SCDashboardInjecting: SCToolsShowing {
    func getNewsOverviewController(with itemList: [SCBaseComponentItem]) -> UIViewController
    func getEventsOverviewController(with eventList: SCModelEventList) -> UIViewController
}

protocol SCMarketplaceInjecting: SCToolsShowing {
    func getMarketplaceOverviewController(for item: SCBaseComponentItem?) -> UIViewController
}

protocol SCServicesInjecting: SCToolsShowing {
    func getWasteCalendarViewController(wasteCalendarItems: [SCModelWasteCalendarItem],
                                        calendarAddress: SCModelWasteCalendarAddress?,
                                        wasteReminders: [SCHttpModelWasteReminder],
                                        item: SCBaseComponentItem,
                                        month: String?) -> UIViewController
    func getTEVISViewController(for system: String, serviceData : SCBaseComponentItem) -> UIViewController
    func getServicesOverviewController(for item: SCBaseComponentItem?) -> UIViewController
    func getServicesDetailController(for item: SCBaseComponentItem, serviceDetailProvider: SCServiceDetailProvider, isDisplayOverviewScreen: Bool) -> UIViewController
    func getAppointmentOverviewController(serviceData: SCBaseComponentItem) -> UIViewController
    func getWasteServicesDetailController(for item: SCBaseComponentItem, openCalendar: Bool, with month: String?) -> UIViewController
//    func getAusweisAuthServicesDetailController(for item: SCBaseComponentItem) -> UIViewController
    func getDefectReporterCategoryViewController(categoryList: [SCModelDefectCategory], serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController
    func getDefectReporterMoreViewController() -> UIViewController
    func getAusweisAuthServicesDetailController(for serviceWebDetails: SCModelEgovServiceWebDetails) -> UIViewController
    func getEgovServicesDetailController(for item: SCBaseComponentItem, serviceDetailProvider: SCServiceDetailProvider) -> UIViewController
    func getServicesMoreInfoViewController(for serviceDetailProvider: SCServiceDetailProvider, injector : SCServicesInjecting) -> UIViewController

}

protocol SCUserInfoBoxInjecting: SCToolsShowing {
    func getUserInfoboxDetailController(with infoBoxItem: SCModelInfoBoxItem, completionAfterDelete: (() -> Void)?) -> UIViewController
}

protocol SCEventOverviewInjecting: SCToolsShowing {
    func getDatePickerController(preSelectedStartDate: Date?, preSelectedEndDate: Date?, delegate : SCDatePickerDelegate) -> UIViewController
}

protocol SCEventDetailInjecting: SCToolsShowing{
    func getEventDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController
    func getEventLightBoxController(_with imageURL: SCImageURL, _and credit: String) -> UIViewController
}

protocol SCDisplayEventInjecting: SCToolsShowing {
    func getEventDetailController(with event: SCModelEvent, isCityChanged: Bool, cityId: Int?) -> UIViewController
}

protocol SCCategoryFilterInjecting {
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool?, filterWorker: SCFilterWorking, preselectedCategories: [SCModelCategory]?, delegate: SCCategorySelectionDelegate) -> UIViewController
}

protocol SCWasteCategoryFilterInjecting {
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool?, filterWorker: SCWasteFilterWorking, preselectedCategories: [SCModelCategoryObj]?, delegate: SCWasteCategorySelectionDelegate) -> UIViewController
}

protocol SCAppointmentInjecting: SCToolsShowing {
    func getAppointmentDetailController(for appointment: SCModelAppointment,
                                        cityID: Int,
                                        serviceData: SCBaseComponentItem,
                                        appointmentDelegate: (SCAppointmentDeleting & SCAppointmentStatusChanging)?) -> SCAppointmentDetailViewController
}

protocol SCQRCodeInjecting: SCToolsShowing {
    func getQRCodeController(for appointment: SCModelAppointment) -> UIViewController
}

protocol SCMapViewInjecting {
    func getMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController
}

protocol SCWasteServiceInjecting {
    func getWasteAddressController(delegate: SCWasteAddressViewResultDelegate?, wasteAddress: SCModelWasteCalendarAddress?, item: SCBaseComponentItem) -> UIViewController
    func getWasteReminderController(wasteType: SCWasteCalendarDataSourceItem, delegate: SCWasteReminderResultDelegate?, reminders: SCHttpModelWasteReminder?) -> UIViewController
    func getExportEventOptionsVC(exportWasteTypes: [SCWasteCalendarDataSourceItem]) -> UIViewController
    func getCalendarOptionsTableViewController(items: [String], selectedColorName: String, delegate: SCColorSelectionDelegate) -> UIViewController
}

protocol SCServiceDetailProviderInjecting {
    func getWasteService(serviceData: SCBaseComponentItem,
                         wasteCalendarWorker: SCWasteCalendarWorking,
                         delegate: SCWasteAddressViewResultDelegate) -> SCWasteCalendarService
}

protocol SCCitizenSurveyServiceInjecting {
    func getCitizenSurveyPageViewController(survey: SCModelCitizenSurvey) -> UIViewController
    func getCitizenSurveyDetailViewController(survey: SCModelCitizenSurveyOverview, serviceData: SCBaseComponentItem) -> UIViewController
    func getCitizenSurveyOverViewController(surveyList: [SCModelCitizenSurveyOverview], serviceData: SCBaseComponentItem) -> UIViewController
    func getCitizenSurveyDataPrivacyViewController(survey: SCModelCitizenSurveyOverview, delegate: SCCitizenSurveyDetailViewDelegate?, dataPrivacyNotice: DataPrivacyNotice) -> UIViewController
}

protocol SCBasicPOIGuideServiceInjecting {
    func getBasicPOIGuideCategoryViewController(with poiCategory: [POICategoryInfo], includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController
    func getBasicPOIGuideListMapViewController(with poi: [POIInfo], poiCategory: [POICategoryInfo], item: SCBaseComponentItem) -> UIViewController
}

protocol SCBasicPOIGuideListMapFilterInjecting: SCToolsShowing{
    func getEventDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController
}

protocol SCBasicPOIGuideDetailInjecting: SCToolsShowing{
    func getBasicPOIGuideDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController
    func getBasicPOIGuideLightBoxController(_with imageURL: SCImageURL, _and credit: String) -> UIViewController
}

protocol SCDisplayBasicPOIGuideInjecting: SCToolsShowing {
    func getBasicPOIGuideDetailController(with poi: POIInfo) -> UIViewController
}

protocol SCAusweisAuthServiceInjecting {
  
    func getAusweisAuthWorkFlowViewController(tcTokenURL : String, cityContentSharedWorker: SCCityContentSharedWorking , injector : SCAusweisAuthServiceInjecting) -> UIViewController
    
    func getAusweisAuthLoadingViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController
    
    func getAusweisAuthServiceOverviewViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController
    
    func getAusweisAuthEnterPINViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthInsertCardViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthSuccessViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController
    
    func getAusweisAuthFailureViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController
    
    func getAusweisAuthProviderInfoViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthHelpViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthNeedCANViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthEnterCANViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthNeedPUKViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

    func getAusweisAuthEnterPUKViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController
    
    func getAusweisAuthCardBlockedViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController

}

protocol SCDefectReporterInjecting {

    func getDefectReporterLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController
    func getDefectReporterSubCategoryViewController(category: SCModelDefectCategory, subCategoryList: [SCModelDefectSubCategory], serviceData: SCBaseComponentItem, service: Services) -> UIViewController
    func getDefectReporterFormViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController
    func getDefectReporterFormSubmissionViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String, serviceFlow: Services, email: String?) -> UIViewController
    func getDefectReportTermsViewController(for url : String, title : String?, insideNavCtrl: Bool) -> UIViewController
    func getFahrradparkenReportedLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController
    func getFahrradParkenReportedLocationDetailsViewController(with location: FahrradparkenLocation, serviceData: SCBaseComponentItem, compltionHandler: (() -> Void)?) -> UIViewController
    
}

protocol SCEgovServiceInjecting {
    
    func getEgovServicesListViewController(for serviceDetailProvider: SCServiceDetailProvider , worker : SCEgovServiceWorking , injector : SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection, group : SCModelEgovGroup ) -> UIViewController

    func getEgovServiceHelpViewController(for serviceDetailProvider: SCServiceDetailProvider , worker : SCEgovServiceWorking , injector : SCEgovServiceInjecting & SCServicesInjecting) -> UIViewController
    
    func getEgovSearchViewController(worker : SCEgovSearchWorking , injector : SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection, serviceDetail: SCServiceDetailProvider) -> UIViewController

    func getEgovServiceLongDescriptionViewController(service: SCModelEgovService) -> UIViewController

}

protocol MoEngageAnalyticsInjection {
    func setupMoEngageUserAttributes()
}
