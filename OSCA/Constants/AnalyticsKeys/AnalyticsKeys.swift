//
//  AnalyticsKeys.swift
//  OSCA
//
//  Created by Bhaskar N S on 27/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

enum AnalyticsKeys {
    enum Widget {
        static let newsLargeWidget: String = "NewsLargeWidget"
        static let newsMediumWidget: String = "NewsMediumWidget"
        static let newsSmallWidget: String = "NewsSmallWidget"
        static let newsWidgetTapped: String = "NewsWidgetTapped"
        static let removeNewsLargeWidget: String = "RemoveNewsLargeWidget"
        static let removeNewsMediumWidget: String = "RemoveNewsMediumWidget"
        static let removeNewsSmallWidget: String = "RemoveNewsSmallWidget"

        enum WasteCalendar {
            static let smallWidget: String = "WasteCalendarSmallWidget"
            static let mediumWidget: String = "WasteCalendarMediumWidget"
            static let removeSmallWidget: String = "RemoveWasteCalendarSmallWidget"
            static let removeMediumWidget: String = "RemoveWasteCalendarMediumWidget"
            static let wasteWidgetTapped: String = "WasteWidgetTapped"
        }
    }
    
    enum EventName {
        static let openEGovExternalURL: String = "OpenEGovExternalURL"
        static let openEventDetailPage: String = "OpenEventDetailPage"
        static let openNewsDetailPage: String = "OpenNewsDetailPage"
        static let changePOICategory: String = "ChangePOICategory"
        static let sendFeedback: String = "SendFeedback"
        static let setWasteReminder: String = "SetWasteReminder"
        static let switchCity: String = "SwitchCity"
        static let submitPoll: String = "SubmitPoll"
        static let openServiceDestinations: String = "OpenServiceDestinations"
        static let openNewsList: String = "OpenNewsList"
        static let openEventsList: String = "OpenEventsList"
        static let openHome: String = "OpenHome"
        static let openInfobox: String = "OpenInfobox"
        static let openProfile: String = "OpenProfile"
        static let openService: String = "OpenService"
        static let openWasteCalendar: String = "OpenWasteCalendar"
        static let openServiceAppointments: String = "OpenServiceAppointments"
        static let openServiceSurveyDetail: String = "OpenServiceSurveyDetail"
        static let openServiceSurveyList: String = "OpenServiceSurveyList"
        static let openServiceWasteCalendar: String = "OpenServiceWasteCalendar"
        static let openServicePoiGuide: String = "OpenServicePoiGuide"
        static let openServiceEgov: String = "OpenServiceEgov"
        static let openServiceDefectReporter: String = "OpenServiceDefectReporter"
        static let appointmentCreated: String = "AppointmentCreated"
        static let defectSubmitted: String = "DefectSubmitted"
        static let eidProcessStarted: String = "EidProcessStarted"
        static let eidAuthenticationFailed: String = "EidAuthenticationFailed"
        static let eidAuthenticationSuccessful: String = "EidAuthenticationSuccessful"
        static let eventfavoriteMarked: String = "EventfavoriteMarked"
        static let unexpectedLogout: String = "UnexpectedLogout"
        static let logInWithKeep: String = "LogInWithKeep"
        static let logInWithoutKeep: String = "LogInWithoutKeep"
        static let eidAuthenticationFailedAccessRightsError: String = "EidAuthenticationFailedAccessRightsError"
        static let eidAuthenticationFailedBadStateError: String = "EidAuthenticationFailedBadStateError"
        static let eidAuthenticationFailedMajorError: String = "EidAuthenticationFailedMajorError"
        static let eidAuthenticationFailedMessageError: String = "EidAuthenticationFailedMessageError"
        static let eidAuthenticationFailedPayloadError: String = "EidAuthenticationFailedPayloadError"
        static let eventEngagement: String = "EventEngagement"
        static let loginComplete: String = "LoginComplete"
        static let registrationComplete: String = "RegistrationComplete"
        static let digitalAdmSubcategories: String = "DigitalAdmSubcategories"
        static let appLaunched: String = "AppLaunched"
        static let openServiceFahrradparken: String = "OpenServiceFahrradparken"
        static let FahrradparkenSubmitted: String = "FahrradparkenSubmitted"
        static let openFahrradparkenExistingDefects: String = "OpenFahrradparkenExistingDefects"
        static let webTileButtonTapped: String = "WebTileButtonTapped"
        static let webTileTapped: String = "WebTileTapped"
    }
    
    enum TrackedParamKeys {
        static let citySelected: String = "city_selected"
        static let cityId: String = "city_id"
        static let userZipcode: String = "user_zipcode"
        static let userStatus: String = "user_status"
        static let citykeyUserId: String = "citykey_user_id"
        static let adjustDeviceId: String = "adjust_device_id"
        static let moengageCustomerId: String = "moengage_customer_id"
        static let selectedCity: String = "SelectedCity"
        static let usersCity: String = "UsersCity"
        static let loggedIn: String = "Logged In"
        static let notLoggedIn: String = "Not Logged In"
        static let smartCity: String = "Smart City"
        static let categoryOfServices: String = "category_of_services"
        static let subcategoryOfServices: String = "subcategory_of_services"
        static let engagementOption: String = "engagement_option"
        static let eventId: String = "event_id"
        static let userYob: String = "user_yob"
        static let registeredCityName: String = "registered_city_name"
        static let registeredCityId: String = "registered_city_id"
        static let serviceType = "service_type"
        static let serviceActionType = "service_action_type"
    }
    
    enum TrackedParamValues {
        enum QA {
            static let adjustAppSecretInfo0: Int = 2
            static let adjustAppSecretInfo1: Int = 1014389372
            static let adjustAppSecretInfo2: Int = 1258316081
            static let adjustAppSecretInfo3: Int = 1431545865
            static let adjustAppSecretInfo4: Int = 439071541
        }
        enum Release {
            static let adjustAppSecretInfo0: Int = 2
            static let adjustAppSecretInfo1: Int = 1014389372
            static let adjustAppSecretInfo2: Int = 1258316081
            static let adjustAppSecretInfo3: Int = 1431545865
            static let adjustAppSecretInfo4: Int = 439071541
        }
    }
}
