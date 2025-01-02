//
//  LocalizationKeys.swift
//  OSCA
//
//  Created by A200111500 on 12/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

enum LocalizationKeys {
    enum Common {
        static let navigationBarBack: String = "navigation_bar_back"
        static let accessibilityBtnSelectLocation: String = "accessibility_btn_select_location"
        static let accessibilityBtnOpenProfile: String = "accessibility_btn_open_profile"
        static let accessbilityHeadingLevel: String = "accessbility_heading_level"
    }
    
    enum Accessibility {
        static let cellDblTapHint: String = "accessibility_cell_dbl_click_hint"
        static let radioBtnTapHint: String = "accessibility_radio_btn_tap_hint"
    }
    
    enum AppPreviewUI {
        static let h001HomeAppPreviewBannerText: String = "h_001_home_app_preview_banner_text"
        static let p001ProfileLabelMode: String = "p_001_profile_label_mode"
        static let p001ProfileLabelModeLive: String = "p_001_profile_label_mode_live"
        static let p001ProfileLabelModePreview: String = "p_001_profile_label_mode_preview"
    }
    
    //Dashboard 
    enum SCDashboardVC {
        static let h001HomeTitleNews: String = "h_001_home_title_news"
        static let h001HomeNoNews: String = "h_001_home_no_news"
        static let h001HomeBtnMoreNews: String = "h_001_home_btn_more_news"
        static let h001HomeTitleTips: String = "h_001_home_title_tips"
        static let h001HomeTitleOffers: String = "h_001_home_title_offers"
        static let h001HomeTitleDiscounts: String = "h_001_home_title_discounts"
        static let h001HomeTitleEvents: String = "h_001_home_title_events"
        static let h001HomeBtnAllEvents: String = "h_001_home_btn_all_events"
        static let h001EventsNoEventsMsg: String = "h_001_events_no_events_msg"
        static let h001HomeToolTipSwitchLocation: String = "h_001_home_tooltip_switch_location"
    }
    enum SCDashboardPresenter{
        static let h001HomeTitlePart: String = "h_001_home_title_part"
        static let h001HomeNewsActionError: String = "h_001_home_news_action_error"
        static let h001HomeNewsError: String = "h_001_home_news_error"
        static let h001EventsLoadError: String = "h_001_events_load_error"
        static let h001EventsLoadActionError: String = "h_001_events_load_action_error"
    }
    //News
    enum SCNewsOverviewTableViewController{
        static let h001HomeTitleNews: String = "h_001_home_title_news"
        static let AccessibilityTableSelectedCell: String = "accessibility_table_selected_cell"
        static let AccessibilityCellDblClickHint: String = "accessibility_cell_dbl_click_hint"
    }
    enum SCNewsOverviewTableVC{
        static let accessibilityCellDblClickHint: String = "accessibility_cell_dbl_click_hint"
    }
    //DefectReporter
    enum SCDefectReporterCategorySelectionPresenter{
        static let dr001ChooseCategoryLabel: String = "dr_001_choose_category_label"
    }
    enum SCDefectReporterFormPresenter{
        static let dr003YourConcernHint: String = "dr_003_your_concern_hint"
        static let dr003DialogButtonOk: String = "dr_003_dialog_button_ok"
        static let dr003DefectSubmissionErrorTitle: String = "dr_003_defect_submission_error_title"
        static let dr003DefectSubmissionError: String = "dr_003_defect_submission_error"
        static let dr003EmailAddressHint: String = "dr_003_email_address_hint"
        static let dr003FirstNameHint: String = "dr_003_first_name_hint"
        static let dr003LastNameHint: String = "dr_003_last_name_hint"
        static let dr003OptionalFieldLabel: String = "dr_003_optional_field_label"
        static let dr003TermsTitle: String = "dr_003_terms_title"
        static let dr003WasteBinIdHint: String = "dr_003_waste_bin_id_hint"
        static let dr005RulesOfUseTitle: String = "dr_005_rules_of_use_title"
        static let fa003DescribeIssueLabel: String = "fa_003_describe_issue_label"
        static let dr003YourConcernDisclaimer = "dr_003_your_concern_disclaimer"

    }
    enum SCBasicPOIGuideCategorySelectionTableVC{
        static let accessibilityCellDblClickHint: String = "accessibility_cell_dbl_click_hint"
    }
    enum SCBasicPOIGuideListMapFilterViewController{
        static let e006EventRoute: String = "e_006_event_route"
        static let poi001TabListLabel: String = "poi_001_tab_list_label"
        static let poi001TabMapLabel: String = "poi_001_tab_map_label"
        static let poi001RetryButtonDecription: String = "poi_001_retry_button_decription"
        static let poi001TabMapLocateMeButtonDecription: String = "poi_001_tab_map_locate_me_button_decription"
        static let poi002CloseButtonContentDescription: String = "poi_002_close_button_content_description"
        static let c001CitiesDialogGpsTitle: String = "c_001_cities_dialog_gps_title"
        static let c001CitiesDialogGpsMessage: String = "c_001_cities_dialog_gps_message"
        static let poi001AddressLabel: String = "poi_001_address_label"
        static let poi001OpeningHoursLabel: String = "poi_001_opening_hours_label"
        static let e006EventAppleMaps: String = "e_006_event_apple_maps"
        static let e006EventGoogleMaps: String = "e_006_event_google_maps"
        static let e006EventNoMapFoundText: String = "e_006_event_no_map_found_text"
        static let e006EventRoutingOptions: String = "e_006_event_routing_options"
        static let e006EventRoutingOptionsMsgText: String = "e_006_event_routing_options_msg_text"
        static let e006EventBtnCancel: String = "e_006_event_btn_cancel"
    }

    enum SCDefectReporterLocationViewController{
        static let dr002LocateMeButtonLabel: String = "dr_002_locate_me_button_label"
        static let poi002CloseButtonContentDescription: String = "poi_002_close_button_content_description"
        static let c001CitiesDialogGpsTitle: String = "c_001_cities_dialog_gps_title"
        static let c001CitiesDialogGpsMessage: String = "c_001_cities_dialog_gps_message"
        static let dr002LocationSelectionToolbarLabel: String = "dr_002_location_selection_toolbar_label"
        static let dr003LocationPageInfo1: String = "dr_003_location_page_info1"
        static let dr002SaveButtonLabel: String = "dr_002_save_button_label"
        static let c001CitiesDialogGpsBtnCancel: String = "c_001_cities_dialog_gps_btn_cancel"
        static let c001CitiesDialogGpsBtnOk: String = "c_001_cities_dialog_gps_btn_ok"
    }
    enum SCDefectReporterFormVC{
        static let dr003ChangeLocationButton: String = "dr_003_change_lacation_button"
        static let dr003SendReportLabel: String = "dr_003_send_report_label"
        static let dr003AddPhotoLabel: String = "dr_003_add_photo_label"
        static let dr003OptionalFieldLabel: String = "dr_003_optional_field_label"
        static let dr003DeletePhotoLabel: String = "dr_003_delete_photo_label"
        static let dr003LocationLabel: String = "dr_003_location_label"
        static let dr003SendReportLabel1: String = "dr_003_send_report_label"
        static let dr003DescribeIssueLabel: String = "dr_003_describe_issue_label"
        static let dr003YourDetailsLabel: String = "dr_003_your_details_label"
        static let dialogTitleNote: String = "dialog_title_note"
        static let dr003TermsText: String = "dr_003_terms_text"
        static let dr003TermsEndText: String = "dr_003_terms_end_text"
        static let dr003RulesOfUseLink: String = "dr_003_rules_of_use_link"
        static let dr003AddLabel: String =  "dr_003_add_label"
        static let r001RegistrationLabelConsentRequired = "r_001_registration_label_consent_required"
    }
    enum SCDefectReporterFormSubmissionVC{
        static let dr004OkButton: String = "dr_004_ok_button"
        static let dr004ThankYouMsg: String = "dr_004_thank_you_msg"
        static let dr004ThankYouMsg1: String = "dr_004_thank_you_msg1"
        static let dr004CategoryLabel: String = "dr_004_category_label"
        static let dr004UniqueIdLabel: String = "dr_004_unique_id_label"
        static let d004ReportedOnLabel: String =  "d_004_reported_on_label"
        static let d004SubmitInfoMsg: String = "d_004_submit_info_msg"
        static let fa009UniqueIdLabel: String = "fa_009_unique_id_label"
        static let fa010SubmitInfoMsg: String = "fa_010_submit_info_msg"
        static let fa011ThankYouMsg1: String = "fa_011_thank_you_msg1"
    }
    //Events
    enum SCEventsOverviewVC{
        static let e002PageTitle: String  = "e_002_page_title"
        static let e002FilterDateLabel: String = "e_002_filter_date_label"
        static let e002FilterCategoriesLabel: String = "e_002_filter_categories_label"
    }
    enum SCEventsOverviewTVC{
        static let e002PageLoadError: String = "e_002_page_load_error"
        static let e002NoEventsMsg: String = "e_002_no_events_msg"
        static let e002NoEventsHintMsg: String = "e_002_no_events_hint_msg"
        static let h001EventsFavoritesHeader: String = "h_001_events_favorites_header"
        static let h001EventsHeader: String = "h_001_events_header"
        static let e007CancelledEvents: String = "e_007_cancelled_events"
        static let e007EventsNewDateDesc: String = "e_007_events_new_date_desc"
        static let e007EventsNewDateLabel: String = "e_007_events_new_date_label"
        static let e007EventsSoldOutDesc: String = "e_007_events_sold_out_desc"
        static let e007EventsSoldOutLabel: String = "e_007_events_sold_out_label"
    }
    enum SCEventDetailVC{
        static let AccessibilityBtnShareContent: String = "accessibility_btn_share_content"
        static let e005StartTimeLabel: String = "e_005_start_time_label"
        static let e005EndTimeLabel: String = "e_005_end_time_label"
        static let dialogRetryDescription: String = "dialog_retry_description"
        static let dialogButtonOk: String = "dialog_button_ok"
        static let dialogRetryRetryButton: String = "dialog_retry_retry_button"
        static let e007EventCancelledDesc: String = "e_007_event_cancelled_desc"
        static let e005ImageLoadError: String = "e_005_image_load_error"
        static let e002PageLoadRetry: String = "e_002_page_load_retry"
        static let e005AddToCalendar: String = "e_005_add_to_calendar"
        static let e005Favourite: String =  "e_005_favourite"
        static let e005DescriptionReadMoreInformation: String = "e_005_description_read_more_information"
        static let e005PdfLabel: String = "e_005_pdf_label"
        static let e006EventTapOnMapHint: String = "e_006_event_tap_on_map_hint"
    }
    enum SCEventDetailMapVC{
        static let e006EventGetDirections: String = "e_006_event_get_directions"
        static let e006EventRoute: String = "e_006_event_route"
        static let e006EventAppleMaps: String = "e_006_event_apple_maps"
        static let e006EventGoogleMaps: String = "e_006_event_google_maps"
        static let e006EventNoMapFoundText: String = "e_006_event_no_map_found_text"
        static let e006EventRoutingOptions: String = "e_006_event_routing_options"
        static let e006EventRoutingOptionsMsgText: String = "e_006_event_routing_options_msg_text"
        static let e006EventBtnCancel: String = "e_006_event_btn_cancel"
    }
    enum SCEventsOverviewPresenter{
        static let e002FilterEmptyLabel: String = "e_002_filter_empty_label"
        static let e004EventsFilterCategoriesTitle: String  = "e_004_events_filter_categories_title"
        static let e004EventsFilterCategoriesShowEvents: String = "e_004_events_filter_categories_show_events"
    }
    enum SCEventDetailPresenter{
        static let dialogLoginRequiredMessage: String = "dialog_login_required_message"
        static let aMessageEventFavoredError: String = "a_message_event_favored_error"
        static let shareStoreHeader: String = "share_store_header"
        static let e006EventSwitchCityInfo: String = "e_006_event_switch_city_info"
    }
    enum SCDisplayingDefaultImplementation{
        static let cityNotAvailableDialogOkButton: String =  "city_not_available_dialog_ok_button"
        static let cityNotAvailableDialogBody: String = "city_not_available_dialog_body"
        static let cityNotAvailableDialogTitle: String = "city_not_available_dialog_title"
        static let dialogAuthenticationErrorMessage: String = "dialog_authentication_error_message"
        static let dialogTechnicalErrorMessage: String = "dialog_technical_error_message"
        static let dialogTechnicalErrorTitle: String = "dialog_technical_error_title"
    }
    //Appointment
    enum SCAppointmentOverviewDataSource{
        static let apnmtDeleteNotAllowed: String = "apnmt_delete_not_allowed"
    }
    enum SCAppointmentOverviewController{
        static let apnmt002ErrorInfo: String = "apnmt_002_error_info"
        static let apnmt002ErrorDescription: String = "apnmt_002_error_description"
        static let b005InfoboxErrorBtnReload: String = "b_005_infobox_error_btn_reload"
        static let apnmt002EmptyStateLabel: String = "apnmt_002_empty_state_label"
        static let apnmt002PageTitle: String = "apnmt_002_page_title"
    }
    enum SCAppointmentOverviewTableViewCell{
        static let apnmt002ShowQrCodeButton: String = "apnmt_002_show_qr_code_button"
        static let apnmt002MoreInfoButton: String = "apnmt_002_more_info_button"
        static let b002InfoboxSwipedBtnDelete: String = "b_002_infobox_swiped_btn_delete"
        static let apnmt002DateLabel: String = "apnmt_002_date_label"
    }
    enum SCAppointmentDetailViewController{
        static let apnmt003PageTitle: String = "apnmt_003_page_title"
        static let e005StartTimeLabel: String = "e_005_start_time_label"
        static let e005EndTimeLabel: String = "e_005_end_time_label"
        static let e005AddToCalendar: String = "e_005_add_to_calendar"
        static let apnmt002ShowQrCodeButton: String = "apnmt_002_show_qr_code_button"
        static let apnmt003ConcernsLabel: String = "apnmt_003_concerns_label"
        static let apnmt003WaitingNoFormat: String = "apnmt_003_waiting_no_format"
        static let apnmt003ParticipantsLabel: String = "apnmt_003_participants_label"
        static let apnmt003BringWithLabel: String = "apnmt_003_bring_with_label"
        static let apnmt003AdditionalLabel: String = "apnmt_003_additional_label"
        static let apnmt003ResponsibleLabel: String = "apnmt_003_responsible_label"
        static let apnmt003CancelAppointmentBtn: String = "apnmt_003_cancel_appointment_btn"
        static let e006EventTapOnMapHint: String = "e_006_event_tap_on_map_hint"
        static let apnmt003CancelApnmtTitle: String = "apnmt_003_cancel_apnmt_title"
        static let apnmt003CancelApnmtInfo: String = "apnmt_003_cancel_apnmt_info"
        static let apnmt003CancelApnmtCancel: String = "apnmt_003_cancel_apnmt_cancel"
        static let apnmt003CancelApnmtOk: String = "apnmt_003_cancel_apnmt_ok"
        
    }
    enum QRCodeViewController{
        static let apnmt004QrcodeTitle: String = "apnmt_004_qrcode_title"
        static let apnmt004QrcodeWaitingNoLabel: String = "apnmt_004_qrcode_waiting_no_label"
    }
    enum SCTevisViewController{
        static let appointmentWebViewTitle: String = "appointment_webview_title"
        static let appointmentWebCancelDialogMessage: String = "appointment_web_cancel_dialog_message"
        static let appointmentWebCancelDialogBtnCancel: String = "appointment_web_cancel_dialog_btnCancel"
        static let appointmentWebCancelDialogBtnClose: String = "appointment_web_cancel_dialog_btnClose"
        static let appointmentWebPrivateDataPermissionMessage: String = "appointment_web_private_data_permission_message"
        static let appointmentWebPrivateDataPermissionBtnNegative: String = "appointment_web_private_data_permission_btnNegative"
        static let appointmentWebPrivateDataPermissionBtnPositive: String = "appointment_web_private_data_permission_btnPositive"
        static let appointmentWebPrivateDataPermissionTitle: String = "appointment_web_private_data_permission_title"
    }
    enum SCAppointmentOverviewPresenter{
        static let apnmtSnackbarSuccessfullyDelete: String = "apnmt_snackbar_successfully_delete"
        static let b006SnackbarDeleteUndo: String = "b_006_snackbar_delete_undo"
        static let apnmtDeleteErrorSnackbar: String = "apnmt_delete_error_snackbar"
        static let apnmt003SnackbarMarkReadFailed: String = "apnmt_003_snackbar_mark_read_failed"
    }
    enum SCAppointmentDetailPresenter{
        static let apnmt003ConcernsLabel: String = "apnmt_003_concerns_label"
        static let apnmt003ParticipantsLabel: String = "apnmt_003_participants_label"
        static let apnmt003CalExportLocationFormat: String = "apnmt_003_cal_export_location_format"
        static let apnmt005ShareTitle: String = "apnmt_005_share_title"
        static let apnmt005ShareConcerns: String = "apnmt_005_share_concerns"
        static let apnmt003AppointmentCreationFormat: String = "apnmt_003_appointment_creation_format"
        static let p001ProfileLabelEmail: String = "p_001_profile_label_email"
        static let apnmt003ApnmtTelefonLabel: String = "apnmt_003_apnmt_telefon_label"
        static let b002InfoboxSwipedBtnDelete: String = "b_002_infobox_swiped_btn_delete"
        static let accessibilityBtnShareContent: String = "accessibility_btn_share_content"
        static let apnmt005ShareWaitingNoFormat: String = "apnmt_005_share_waiting_no_format"
        static let apnmt005ShareAddress: String = "apnmt_005_share_address"
        static let apnmt003ShareTextTitle: String = "apnmt_003_share_text_title"
        static let shareStoreHeader: String = "share_store_header"
        static let apnmt003CancelAppointmentBtn: String = "apnmt_003_cancel_appointment_btn"
        static let apnmt003CancelErrorApnmtInfo: String = "apnmt_003_cancel_error_apnmt_info"
        static let appointmentWebCancelDialogBtnCancel: String = "appointment_web_cancel_dialog_btnCancel"
        static let apnmt003SnackbarCancelationFailed: String = "apnmt_003_snackbar_cancelation_failed"
    }
    // Services
    enum SCDefectReporterServiceDetail{
        static let d001DefectReporterDetailButtonLabel: String = "d_001_defect_reporter_detail_button_label"
    }
    enum SCServicesViewController{
        static let s001services002MarketplacesBtnCategoriesShowAll: String = "s_001_services_002_marketplaces_btn_categories_show_all"
        static let accessibilityBtnOpenProfile: String = "accessibility_btn_open_profile"
        static let s001ServicesTitleNew: String = "s_001_services_title_new"
        static let s001services002MarketplacesTitleOurs: String = "s_001_services_002_marketplaces_title_ours"
        static let s001Services002MarketplacesTitleMostUsed: String = "s_001_services_002_marketplaces_title_most_used"
        static let s001services002MarketplacesTitleCategories: String = "s_001_services_002_marketplaces_title_categories"
        static let s001Services002MarketplacesTitleFavorites: String = "s_001_services_002_marketplaces_title_favorites"
        static let s001Services002MarketplacesBtnFavoritesEdit: String = "s_001_services_002_marketplaces_btn_favorites_edit"
        static let s001ServicesTitle: String = "s_001_services_title"
        static let s001ServicesErrorModuleMsg: String = "s_001_services_error_module_msg"
        static let s001services002MarketplacesBtnFaoritesSave: String = "s_001_services_002_marketplaces_btn_favorites_save"

    }
    enum SCServicesOverviewTableViewCell{
        static let s001002003004RibbonLabelNewItem: String = "s_001_002_003_004_ribbon_label_new_item"
    }
    enum SCServicesInfoDetailVC{
        static let accessibilityBtnClose: String = "accessibility_btn_close"
    }
    enum SCMarketplacePresenter{
        static let s002MarketplacesTitle: String = "s_002_marketplaces_title"
    }
    enum SCMarketplaceOverviewPresenter{
        static let s002MarketplacesTitleBranches: String = "s_002_marketplaces_title_branches"
    }
    
    enum SCFTUFlowNavigationController{
        static let x003WelcomeInfo: String = "x_003_welcome_info"
        static let x001WelcomeInfo01: String = "x_001_welcome_info_01"
        static let x001WelcomeInfo02: String = "x_001_welcome_info_02"
        static let x001WelcomeInfo03: String = "x_001_welcome_info_03"
        static let x003WelcomeInfoTitle: String = "x_003_welcome_info_title"
        static let x001welcomeInfoTitle01: String = "x_001_welcome_info_title_01"
        static let x001welcomeInfoTitle02: String = "x_001_welcome_info_title_02"
        static let x001welcomeInfoTitle03: String = "x_001_welcome_info_title_03"
        static let x001WelcomeLabelLogin: String = "x_001_welcome_label_login"
        static let x001WelcomeMenuBtnSkip: String = "x_001_welcome_menu_btn_skip"
    }
    
    enum SCFirstTimeUsageVC{
        static let x001WelcomeMenuBtnSkip: String = "x_001_welcome_menu_btn_skip"
        static let x001WelcomeBtnLogin: String = "x_001_welcome_btn_login"
        static let x001WelcomeBtnRegister: String = "x_001_welcome_btn_register"
        static let x001NextBtnText: String = "x_001_next_btn_text"
        static let x001LetsGoBtnText: String = "x_001_lets_go_btn_text"
        static let x001WelcomeLabelLogin: String = "x_001_welcome_label_login"
    }

    enum SCDataPrivacyPresenter{
        static let x001WelcomeBtnPrivacyShort: String = "x_001_welcome_btn_privacy_short"
    }
    enum SCWasteCalendarViewController{
        static let wc004FilterCategoryEmpty: String = "wc_004_filter_category_empty"
        static let wc004FilterCategoryEmptyData: String = "wc_004_filter_category_empty_data"
        static let wc004FilterMultipleCategoryEmptyData: String = "wc_004_filter_multiple_category_empty_data"
        static let wc004PickupsFilterBtn: String = "wc_004_pickups_filter_btn"
        static let wc004AddressFilterBtn: String = "wc_004_address_filter_btn"
        static let dialogTechnicalErrorMessage: String = "dialog_technical_error_message"
        static let accessibilityBtnNextMonth: String = "accessibility_btn_next_month"
        static let accessibilityBtnPreviousMonth: String = "accessibility_btn_previous_month"
        static let accessibilityBtnExportCalendar: String = "accessibility_btn_export_calendar"
    }
    
    enum SCWasteAddressPresenter{
        static let wc004FtuTitle: String = "wc_004_ftu_title"
        static let wc004FtuShowResultBtn: String = "wc_004_ftu_show_result_btn"
        static let wc004FtuStreetName: String = "wc_004_ftu_street_name"
        static let wc004FtuHouseNumber: String = "wc_004_ftu_house_number"
        static let wc004FtuCity: String = "wc_004_ftu_city"
        static let wc004FilterCategoryTitle: String = "wc_004_filter_category_title"
        static let wc004FilterCategoryShowResult: String = "wc_004_filter_category_show_result"
    }
    enum SCExportEventOptionsViewController{
        static let wc006BlueColor: String = "wc_006_blue_color"
        static let wc006MyWasteCalendar: String = "wc_006_my_waste_calendar"
        static let e003ClearButton: String = "e_003_clear_button"
        static let wc006ChooseExistingCalendar: String = "wc_006_choose_existing_calendar"
        static let wc006CreateANewCalendar: String = "wc_006_create_a_new_calendar"
        static let appointmentWebCancelDialogBtnCancel: String = "appointment_web_cancel_dialog_btnCancel"
        static let e005AddToCalendar: String = "e_005_add_to_calendar"
        static let wc006CalendarName: String = "wc_006_calendar_name"
        static let wc006AddEvents: String = "wc_006_add_events"
        static let wc006AddToCalendar: String = "wc_006_add_to_calendar"
        static let wc006AlertMessageSuccessfull: String = "wc_006_alert_message_successfull"
        static let dr004OkButton: String = "dr_004_ok_button"
        static let wc006SuccessfullyExported: String = "wc_006_successfully_exported"
    }
    enum SCExportEventOptionsViewPresenter{
        static let wc006RedColor: String = "wc_006_red_color"
        static let wc006OrangeColor: String = "wc_006_orange_color"
        static let wc006YellowColor: String = "wc_006_yellow_color"
        static let wc006GreenColor: String = "wc_006_green_color"
        static let wc006BlueColor: String = "wc_006_blue_color"
        static let wc006PurpleColor: String = "wc_006_purple_color"
        static let wc006BrownColor: String = "wc_006_brown_color"
        static let wc006EventsNotAdded: String = "wc_006_events_not_added"
    }
    enum SCCalendarGenericTableViewController{
        static let wc006CalendarColour: String = "wc_006_calendar_colour"
        static let wc006Colour: String = "wc_006_colour"
    }
    enum SCWasteCalendarPresenter{
        static let wc005ErrorToastMessage: String = "wc_005_error_toast_message"
        static let wc004FilterCategoryNothingSelected: String = "wc_004_filter_category_nothing_selected"
        static let wc004FilterCategoryAllSelected: String = "wc_004_filter_category_All_selected"
        static let wc004FilterCategorySelectedCount: String =
            "wc_004_filter_category_selected_count"
        static let wc004PageTitle: String = "wc_004_page_title"
        static let wc004FilterCategoryTitle: String = "wc_004_filter_category_title"
        static let wc004FilterCategoryShowResult: String = "wc_004_filter_category_show_result"
    }
    enum SCWasteAddressViewController{
        static let wc004FtuHouseError: String = "wc_004_ftu_house_error"
        static let wc004FtuStreetError: String = "wc_004_ftu_street_error"
        static let wc004ChangeAddressResetReminderTitle: String = "wc_004_change_address_reset_reminder_title"
        static let wc004ChangeAddressResetReminderInfo: String = "wc_004_change_address_reset_reminder_info"
        static let wc004ChangeAddressResetReminderCancel: String = "wc_004_change_address_reset_reminder_cancel"
        static let wc004ChangeAddressResetReminderOk: String = "wc_004_change_address_reset_reminder_ok"
    }
    enum SCWasteReminderPresenting{
        static let wc005MoengageLabel: String = "wc_005_moengage_label"
        static let wc005MoengageSettingInfoLabel: String = "wc_005_moengage_setting_info_label"
        static let wc005PushNotificationSettingInfoLabel: String = "wc_005_push_notification_setting_info_label"
        static let wc005PushNotificaionLabel: String = "wc_005_push_notificaion_label"
    }
    enum SCWasteSelectionViewController{
        static let accessibilityLabelPickupReadStateSelected: String = "accessibility_label_pickup_read_state_selected"
        static let accessibilityLabelPickupReadStateNotSelected: String = "accessibility_label_pickup_read_state_not_selected"
        static let accessibilityLabelPickupChangeStateSelect: String = "accessibility_label_pickup_change_state_select"
        static let accessibilityLabelPickupChangeStateDeSelect: String = "accessibility_label_pickup_change_state_deselect"
    }
    enum SCCitizenSurveyOverviewPresenter{
        static let openServiceSurveyList: String = "OpenServiceSurveyList"
    }
    enum SCCitizenSurveyOverviewTableViewDataSource{
        static let cs002RunningListHeader: String = "cs_002_running_list_header"
        static let cs002ClosedListHeader: String = "cs_002_closed_list_header"
        static let cs002ErrorNoRunningSurveys: String = "cs_002_error_no_running_surveys"
        static let cs002UpcomingListHeader: String = "cs_002_upcoming_list_header"
        
    }
    enum SCCitizenSurveyDetailPresenter{
        static let cs003CreationDateFormat: String = "cs_003_creation_date_format"
        static let cs003EndDateLabel: String = "cs_003_end_date_label"
        static let dialogTechnicalErrorMessage: String = "dialog_technical_error_message"
    }
    enum SCOptionView{
        static let cs004MandatoryFieldError: String = "cs_004_mandatory_field_error"
    }
    enum SCCitizenSurveyPageViewController{
        static let cs003PageTitle: String = "cs_003_page_title"
        static let cs004BackButtonDialog: String = "cs_004_back_button_dialog"
        static let negativeButtonDialog: String = "negative_button_dialog"
        static let positiveButtonDialog: String = "positive_button_dialog"
    }
    enum SCCitizenSurveyPageViewPresenter{
        static let cs004SurveyŚubmissionDialogTitle: String = "cs_004_survey_submission_dialog_title"
        static let cs004SurveySubmissionDialogMessage: String = "cs_004_survey_submission_dialog_message"
        static let apnmt003CancelApnmtCancel: String = "apnmt_003_cancel_apnmt_cancel"
        static let p001ProfileConfirmEmailChangeBtn: String = "p_001_profile_confirm_email_change_btn"
    }
    enum SCCitizenSurveyQuestionViewController{
        static let cs004ButtonPrevious: String = "cs_004_button_previous"
        static let cs004ButtonDone: String = "cs_004_button_done"
        static let cs004ButtonNext: String = "cs_004_button_next"
    }
    enum SCCitizenSurveyOverviewViewController{
        static let cs002ErrorNoSurveys: String = "cs_002_error_no_surveys"
        static let cs002PageTitle: String = "cs_002_page_title"
        static let cs002PreviewErrorNoSurveys: String = "cs_002_preview_error_no_surveys"
    }
    enum SCFavouriteView{
        static let cs002FavoredListItemLabel: String = "cs_002_favored_list_item_label"
    }
    enum SCCitizenSurveyDetailViewController{
        static let cs003PageTitle: String = "cs_003_page_title"
        static let cs003ButtonText: String = "cs_003_button_text"
        static let cs002SurveyCompletedMessage: String = "cs_002_survey_completed_message"
    }
    enum SCSurveyDaysLeftView{
        static let cs002DaysLabel: String = "cs_002_days_label"
        static let TAG: String = "TAG"
    }
    enum SCCitizenSurveyDataPrivacyViewController{
        static let dataPrivacySurveyTitle: String = "data_privacy_survey_title"
        static let dataPrivacySurveyButtonText: String = "data_privacy_survey_button_text"
    }
    enum SCBasicPOIGuideListTableViewCell{
        static let accessibilityTableSelectedCell: String = "accessibility_table_selected_cell"
        static let accessibilityCellDblClickHint: String = "accessibility_cell_dbl_click_hint"
    }
    enum SCBasicPOIGuideCategorySelectionVC{
        static let poi002CloseButtonContentDescription: String = "poi_002_close_button_content_description"
        static let poi001RetryButtonDecription: String = "poi_001_retry_button_decription"
        static let poi002Title: String = "poi_002_title"
        
    }
    enum SCBasicPOIGuideDetailViewController{
        static let poi003DescriptionLabel: String = "poi_003_description_label"
        static let poi003WebsiteLabel: String = "poi_003_website_label"
        static let e006EventTapOnMapHint: String = "e_006_event_tap_on_map_hint"
    }
    enum  SCBasicPOIGuideCategorySelectionVCDisplaying{
        static let poi002ErrorText: String = "poi_002_error_text"
        static let e002PageLoadRetry: String = "e_002_page_load_retry"
        static let actionResendEmail: String = "action_resend_email"
        static let c001CitiesDialogGpsBtnCancel: String = "c_001_cities_dialog_gps_btn_cancel"
        static let c001CitiesDialogGpsBtnOk: String = "c_001_cities_dialog_gps_btn_ok"
    }
    enum SCBasicPOIGuideDetailPresenter{
        static let accessibilityBtnShareContent: String = "accessibility_btn_share_content"
        static let shareStoreHeader: String = "share_store_header"
    }
    enum SCFeedbackViewController {
        static let canWeContactYouTitleLabel: String = "feedback_box_title2"
        static let contactMeViaLabel: String = "feedback_box_title3"
    }
    enum SCVersionInformationViewController{
        static let wn001WhatIsNewTitle: String = "wn_001_what_is_new_title"
        static let wn002NewsWidgetTitle: String = "wn_002_news_widget_title"
        static let wn003NewsWidgetUpdateDescription: String = "wn_003_news_widget_update_description"
        static let wn004ContinueTitle: String = "wn_004_continue_title"
        static let wn005MailAleartText: String = "wn_005_mail_aleart_text"
    }
    enum SCLocationSubTableVC{
        static let c003ContactLinkTitleText: String = "c_003_contact_link_title_text"
        static let c003ContactLinkMessageText: String = "c_003_contact_link_message_text"
        static let c003ContactLinkSubTitleText: String = "c_003_contact_link_sub_title_text"
        static let c003AleartGetInContactButton: String = "c_003_aleart_get_in_contact_button"
        static let c003AleartCancelButton: String = "c_003_aleart_cancel_button"
        static let c003MailSubjectText: String = "c_003_mail_subject_text"
        static let c003MailBodyNameText: String = "c_003_mail_body_name_text"
        static let c003MailBodyCityText: String = "c_003_mail_body_city_text"
        static let c003MailBodyPermissionOne: String = "c_003_mail_body_permission_one"
        static let c003MailBodyPermissionTwo: String = "c_003_mail_body_permission_two"
        static let c003AleartMessageSentText: String = "c_003_aleart_message_sent_text"
        static let c003AleartMessageSavedText: String = "c_003_aleart_message_saved_text"
        static let c003AleartMessageFailedText: String = "c_003_aleart_message_failed_text"
        static let c003AleartTitleMailStatusText: String = "c_003_aleart_title_mail_status_text"
        static let c003EmailOptionAleartText: String = "c_003_email_option_aleart_text"
    }
    
    enum FahrrahdparkenReportedLocationVC {
        static let fa004SearchThisAreaLabel: String = "fa_004_search_this_area_label"
        static let fa007LocationPageInfo: String = "fa_007_location_page_info"
        static let fa012UnknowErrorTitle: String = "fa_012_unknow_error_title"
    }
    
    enum FahrradparkenReportedLocationDetailVC {
        static let fa006MoreInformationLabel: String = "fa_006_more_information_label"
    }
}
