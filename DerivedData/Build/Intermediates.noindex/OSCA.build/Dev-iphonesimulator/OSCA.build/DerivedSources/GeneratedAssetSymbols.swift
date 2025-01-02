import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

    /// The "CLR_APPBAR_BCKGRND" asset catalog color resource.
    static let CLR_APPBAR_BCKGRND = ColorResource(name: "CLR_APPBAR_BCKGRND", bundle: resourceBundle)

    /// The "CLR_AUSWEIS_BLUE" asset catalog color resource.
    static let CLR_AUSWEIS_BLUE = ColorResource(name: "CLR_AUSWEIS_BLUE", bundle: resourceBundle)

    /// The "CLR_BCKGRND" asset catalog color resource.
    static let CLR_BCKGRND = ColorResource(name: "CLR_BCKGRND", bundle: resourceBundle)

    /// The "CLR_BORDER_COOLGRAY" asset catalog color resource.
    static let CLR_BORDER_COOLGRAY = ColorResource(name: "CLR_BORDER_COOLGRAY", bundle: resourceBundle)

    /// The "CLR_BORDER_DARKGRAY" asset catalog color resource.
    static let CLR_BORDER_DARKGRAY = ColorResource(name: "CLR_BORDER_DARKGRAY", bundle: resourceBundle)

    /// The "CLR_BORDER_SILVERGRAY" asset catalog color resource.
    static let CLR_BORDER_SILVERGRAY = ColorResource(name: "CLR_BORDER_SILVERGRAY", bundle: resourceBundle)

    /// The "CLR_BTM_MENU_BCKGRND" asset catalog color resource.
    static let CLR_BTM_MENU_BCKGRND = ColorResource(name: "CLR_BTM_MENU_BCKGRND", bundle: resourceBundle)

    /// The "CLR_BTM_MENU_ITEM" asset catalog color resource.
    static let CLR_BTM_MENU_ITEM = ColorResource(name: "CLR_BTM_MENU_ITEM", bundle: resourceBundle)

    /// The "CLR_BUTTON_BLUE_BCKGRND" asset catalog color resource.
    static let CLR_BUTTON_BLUE_BCKGRND = ColorResource(name: "CLR_BUTTON_BLUE_BCKGRND", bundle: resourceBundle)

    /// The "CLR_BUTTON_BORDER_BLACK" asset catalog color resource.
    static let CLR_BUTTON_BORDER_BLACK = ColorResource(name: "CLR_BUTTON_BORDER_BLACK", bundle: resourceBundle)

    /// The "CLR_BUTTON_BORDER_WHITE" asset catalog color resource.
    static let CLR_BUTTON_BORDER_WHITE = ColorResource(name: "CLR_BUTTON_BORDER_WHITE", bundle: resourceBundle)

    /// The "CLR_BUTTON_GREY_DISABLED" asset catalog color resource.
    static let CLR_BUTTON_GREY_DISABLED = ColorResource(name: "CLR_BUTTON_GREY_DISABLED", bundle: resourceBundle)

    /// The "CLR_BUTTON_WHITE_BCKGRND" asset catalog color resource.
    static let CLR_BUTTON_WHITE_BCKGRND = ColorResource(name: "CLR_BUTTON_WHITE_BCKGRND", bundle: resourceBundle)

    /// The "CLR_CARD_BCKGRND" asset catalog color resource.
    static let CLR_CARD_BCKGRND = ColorResource(name: "CLR_CARD_BCKGRND", bundle: resourceBundle)

    /// The "CLR_CARD_SEP_BCKGRND" asset catalog color resource.
    static let CLR_CARD_SEP_BCKGRND = ColorResource(name: "CLR_CARD_SEP_BCKGRND", bundle: resourceBundle)

    /// The "CLR_CELL_BACKGRND" asset catalog color resource.
    static let CLR_CELL_BACKGRND = ColorResource(name: "CLR_CELL_BACKGRND", bundle: resourceBundle)

    /// The "CLR_CITY_KEY_BLUE" asset catalog color resource.
    static let CLR_CITY_KEY_BLUE = ColorResource(name: "CLR_CITY_KEY_BLUE", bundle: resourceBundle)

    /// The "CLR_CONTROL_BACKGRND" asset catalog color resource.
    static let CLR_CONTROL_BACKGRND = ColorResource(name: "CLR_CONTROL_BACKGRND", bundle: resourceBundle)

    /// The "CLR_DARK_LAYER" asset catalog color resource.
    static let CLR_DARK_LAYER = ColorResource(name: "CLR_DARK_LAYER", bundle: resourceBundle)

    /// The "CLR_FTU_LABEL_TEXT_BLACK" asset catalog color resource.
    static let CLR_FTU_LABEL_TEXT_BLACK = ColorResource(name: "CLR_FTU_LABEL_TEXT_BLACK", bundle: resourceBundle)

    /// The "CLR_ICON_SCND_ACTION" asset catalog color resource.
    static let CLR_ICON_SCND_ACTION = ColorResource(name: "CLR_ICON_SCND_ACTION", bundle: resourceBundle)

    /// The "CLR_ICON_TINT_BLACK" asset catalog color resource.
    static let CLR_ICON_TINT_BLACK = ColorResource(name: "CLR_ICON_TINT_BLACK", bundle: resourceBundle)

    /// The "CLR_ICON_TINT_GRAY" asset catalog color resource.
    static let CLR_ICON_TINT_GRAY = ColorResource(name: "CLR_ICON_TINT_GRAY", bundle: resourceBundle)

    /// The "CLR_ICON_TINT_WHITE" asset catalog color resource.
    static let CLR_ICON_TINT_WHITE = ColorResource(name: "CLR_ICON_TINT_WHITE", bundle: resourceBundle)

    /// The "CLR_INFOVIEW_BCKGRND" asset catalog color resource.
    static let CLR_INFOVIEW_BCKGRND = ColorResource(name: "CLR_INFOVIEW_BCKGRND", bundle: resourceBundle)

    /// The "CLR_INPUT" asset catalog color resource.
    static let CLR_INPUT = ColorResource(name: "CLR_INPUT", bundle: resourceBundle)

    /// The "CLR_INPUT_FOCUS" asset catalog color resource.
    static let CLR_INPUT_FOCUS = ColorResource(name: "CLR_INPUT_FOCUS", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_BLACK" asset catalog color resource.
    static let CLR_LABEL_TEXT_BLACK = ColorResource(name: "CLR_LABEL_TEXT_BLACK", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_CANCELLED" asset catalog color resource.
    static let CLR_LABEL_TEXT_CANCELLED = ColorResource(name: "CLR_LABEL_TEXT_CANCELLED", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_FULL_BLACK" asset catalog color resource.
    static let CLR_LABEL_TEXT_FULL_BLACK = ColorResource(name: "CLR_LABEL_TEXT_FULL_BLACK", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_GRAY_COOLGRAY" asset catalog color resource.
    static let CLR_LABEL_TEXT_GRAY_COOLGRAY = ColorResource(name: "CLR_LABEL_TEXT_GRAY_COOLGRAY", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_GRAY_DARKGRAY" asset catalog color resource.
    static let CLR_LABEL_TEXT_GRAY_DARKGRAY = ColorResource(name: "CLR_LABEL_TEXT_GRAY_DARKGRAY", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_GRAY_GRAY" asset catalog color resource.
    static let CLR_LABEL_TEXT_GRAY_GRAY = ColorResource(name: "CLR_LABEL_TEXT_GRAY_GRAY", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_GRAY_SILVERGRAY" asset catalog color resource.
    static let CLR_LABEL_TEXT_GRAY_SILVERGRAY = ColorResource(name: "CLR_LABEL_TEXT_GRAY_SILVERGRAY", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_GREEN" asset catalog color resource.
    static let CLR_LABEL_TEXT_GREEN = ColorResource(name: "CLR_LABEL_TEXT_GREEN", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_ORANGE" asset catalog color resource.
    static let CLR_LABEL_TEXT_ORANGE = ColorResource(name: "CLR_LABEL_TEXT_ORANGE", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_RED" asset catalog color resource.
    static let CLR_LABEL_TEXT_RED = ColorResource(name: "CLR_LABEL_TEXT_RED", bundle: resourceBundle)

    /// The "CLR_LABEL_TEXT_WHITE" asset catalog color resource.
    static let CLR_LABEL_TEXT_WHITE = ColorResource(name: "CLR_LABEL_TEXT_WHITE", bundle: resourceBundle)

    /// The "CLR_LAUNCH_SCREEN_COLOR" asset catalog color resource.
    static let CLR_LAUNCH_SCREEN = ColorResource(name: "CLR_LAUNCH_SCREEN_COLOR", bundle: resourceBundle)

    /// The "CLR_LIGHT_LAYER" asset catalog color resource.
    static let CLR_LIGHT_LAYER = ColorResource(name: "CLR_LIGHT_LAYER", bundle: resourceBundle)

    /// The "CLR_LISTITEM_ACTIVE" asset catalog color resource.
    static let CLR_LISTITEM_ACTIVE = ColorResource(name: "CLR_LISTITEM_ACTIVE", bundle: resourceBundle)

    /// The "CLR_LISTITEM_TAKINGINPUT" asset catalog color resource.
    static let CLR_LISTITEM_TAKINGINPUT = ColorResource(name: "CLR_LISTITEM_TAKINGINPUT", bundle: resourceBundle)

    /// The "CLR_MONHEIM_DONUT_CURRENT" asset catalog color resource.
    static let CLR_MONHEIM_DONUT_CURRENT = ColorResource(name: "CLR_MONHEIM_DONUT_CURRENT", bundle: resourceBundle)

    /// The "CLR_MONHEIM_DONUT_MAX" asset catalog color resource.
    static let CLR_MONHEIM_DONUT_MAX = ColorResource(name: "CLR_MONHEIM_DONUT_MAX", bundle: resourceBundle)

    /// The "CLR_MONHEIM_LEGIBLE" asset catalog color resource.
    static let CLR_MONHEIM_LEGIBLE = ColorResource(name: "CLR_MONHEIM_LEGIBLE", bundle: resourceBundle)

    /// The "CLR_MONHEIM_PRIMARY" asset catalog color resource.
    static let CLR_MONHEIM_PRIMARY = ColorResource(name: "CLR_MONHEIM_PRIMARY", bundle: resourceBundle)

    /// The "CLR_MONHEIM_TH_PAYOUT" asset catalog color resource.
    static let CLR_MONHEIM_TH_PAYOUT = ColorResource(name: "CLR_MONHEIM_TH_PAYOUT", bundle: resourceBundle)

    /// The "CLR_NAVBAR_EXPORT" asset catalog color resource.
    static let CLR_NAVBAR_EXPORT = ColorResource(name: "CLR_NAVBAR_EXPORT", bundle: resourceBundle)

    /// The "CLR_NAVBAR_SOLID_BCKGRND" asset catalog color resource.
    static let CLR_NAVBAR_SOLID_BCKGRND = ColorResource(name: "CLR_NAVBAR_SOLID_BCKGRND", bundle: resourceBundle)

    /// The "CLR_NAVBAR_SOLID_ITEMS" asset catalog color resource.
    static let CLR_NAVBAR_SOLID_ITEMS = ColorResource(name: "CLR_NAVBAR_SOLID_ITEMS", bundle: resourceBundle)

    /// The "CLR_NAVBAR_SOLID_TITLE" asset catalog color resource.
    static let CLR_NAVBAR_SOLID_TITLE = ColorResource(name: "CLR_NAVBAR_SOLID_TITLE", bundle: resourceBundle)

    /// The "CLR_NAVBAR_TOOLBAR_BCKGRND" asset catalog color resource.
    static let CLR_NAVBAR_TOOLBAR_BCKGRND = ColorResource(name: "CLR_NAVBAR_TOOLBAR_BCKGRND", bundle: resourceBundle)

    /// The "CLR_NAVBAR_TRANSPARENT_ITEMS" asset catalog color resource.
    static let CLR_NAVBAR_TRANSPARENT_ITEMS = ColorResource(name: "CLR_NAVBAR_TRANSPARENT_ITEMS", bundle: resourceBundle)

    /// The "CLR_NOTE_LABEL_TEXT_GREY" asset catalog color resource.
    static let CLR_NOTE_LABEL_TEXT_GREY = ColorResource(name: "CLR_NOTE_LABEL_TEXT_GREY", bundle: resourceBundle)

    /// The "CLR_OSCA_BLUE" asset catalog color resource.
    static let CLR_OSCA_BLUE = ColorResource(name: "CLR_OSCA_BLUE", bundle: resourceBundle)

    /// The "CLR_OSCA_LEGIBLE" asset catalog color resource.
    static let CLR_OSCA_LEGIBLE = ColorResource(name: "CLR_OSCA_LEGIBLE", bundle: resourceBundle)

    /// The "CLR_PAGE_CONTROL_SELECTED" asset catalog color resource.
    static let CLR_PAGE_CONTROL_SELECTED = ColorResource(name: "CLR_PAGE_CONTROL_SELECTED", bundle: resourceBundle)

    /// The "CLR_PAGE_CONTROL_UNSELECTED" asset catalog color resource.
    static let CLR_PAGE_CONTROL_UNSELECTED = ColorResource(name: "CLR_PAGE_CONTROL_UNSELECTED", bundle: resourceBundle)

    /// The "CLR_PULL_TO_REFRESH" asset catalog color resource.
    static let CLR_PULL_TO_REFRESH = ColorResource(name: "CLR_PULL_TO_REFRESH", bundle: resourceBundle)

    /// The "CLR_SEPARATOR" asset catalog color resource.
    static let CLR_SEPARATOR = ColorResource(name: "CLR_SEPARATOR", bundle: resourceBundle)

    /// The "CLR_SNACKBAR_BCKGRND" asset catalog color resource.
    static let CLR_SNACKBAR_BCKGRND = ColorResource(name: "CLR_SNACKBAR_BCKGRND", bundle: resourceBundle)

    /// The "CLR_SPLASH_BACKGROUND" asset catalog color resource.
    static let CLR_SPLASH_BACKGROUND = ColorResource(name: "CLR_SPLASH_BACKGROUND", bundle: resourceBundle)

    /// The "CLR_TABLE_SEPARATOR" asset catalog color resource.
    static let CLR_TABLE_SEPARATOR = ColorResource(name: "CLR_TABLE_SEPARATOR", bundle: resourceBundle)

    /// The "CLR_TOOLTIP_BCKGRND" asset catalog color resource.
    static let CLR_TOOLTIP_BCKGRND = ColorResource(name: "CLR_TOOLTIP_BCKGRND", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "210421-citykey-layout-city-key-55" asset catalog image resource.
    static let _210421CitykeyLayoutCityKey55 = ImageResource(name: "210421-citykey-layout-city-key-55", bundle: resourceBundle)

    /// The "FTU-screen1" asset catalog image resource.
    static let ftuScreen1 = ImageResource(name: "FTU-screen1", bundle: resourceBundle)

    /// The "FTU-screen2" asset catalog image resource.
    static let ftuScreen2 = ImageResource(name: "FTU-screen2", bundle: resourceBundle)

    /// The "FTU-screen3" asset catalog image resource.
    static let ftuScreen3 = ImageResource(name: "FTU-screen3", bundle: resourceBundle)

    /// The "FTU-screen4" asset catalog image resource.
    static let ftuScreen4 = ImageResource(name: "FTU-screen4", bundle: resourceBundle)

    /// The "Infobox_outline" asset catalog image resource.
    static let infoboxOutline = ImageResource(name: "Infobox_outline", bundle: resourceBundle)

    /// The "Infobox_solid" asset catalog image resource.
    static let infoboxSolid = ImageResource(name: "Infobox_solid", bundle: resourceBundle)

    /// The "Information" asset catalog image resource.
    static let information = ImageResource(name: "Information", bundle: resourceBundle)

    /// The "Locate me" asset catalog image resource.
    static let locateMe = ImageResource(name: "Locate me", bundle: resourceBundle)

    /// The "Locate me OFF" asset catalog image resource.
    static let locateMeOFF = ImageResource(name: "Locate me OFF", bundle: resourceBundle)

    /// The "Marktplatz_outline" asset catalog image resource.
    static let marktplatzOutline = ImageResource(name: "Marktplatz_outline", bundle: resourceBundle)

    /// The "Marktplatz_solid" asset catalog image resource.
    static let marktplatzSolid = ImageResource(name: "Marktplatz_solid", bundle: resourceBundle)

    /// The "QR-Code Icon Black" asset catalog image resource.
    static let qrCodeIconBlack = ImageResource(name: "QR-Code Icon Black", bundle: resourceBundle)

    /// The "QRpedia_QR-Code Blue" asset catalog image resource.
    static let qRpediaQRCodeBlue = ImageResource(name: "QRpedia_QR-Code Blue", bundle: resourceBundle)

    /// The "accessibility-solid-copy" asset catalog image resource.
    static let accessibilitySolidCopy = ImageResource(name: "accessibility-solid-copy", bundle: resourceBundle)

    /// The "action_edit" asset catalog image resource.
    static let actionEdit = ImageResource(name: "action_edit", bundle: resourceBundle)

    /// The "action_resend_email" asset catalog image resource.
    static let actionResendEmail = ImageResource(name: "action_resend_email", bundle: resourceBundle)

    /// The "activated" asset catalog image resource.
    static let activated = ImageResource(name: "activated", bundle: resourceBundle)

    /// The "add_photo" asset catalog image resource.
    static let addPhoto = ImageResource(name: "add_photo", bundle: resourceBundle)

    /// The "bars-search-bars-x-clear-glyph-light" asset catalog image resource.
    static let barsSearchBarsXClearGlyphLight = ImageResource(name: "bars-search-bars-x-clear-glyph-light", bundle: resourceBundle)

    /// The "bg_top_bar_ausweis" asset catalog image resource.
    static let bgTopBarAusweis = ImageResource(name: "bg_top_bar_ausweis", bundle: resourceBundle)

    /// The "bike-parking-default" asset catalog image resource.
    static let bikeParkingDefault = ImageResource(name: "bike-parking-default", bundle: resourceBundle)

    /// The "bike-parking-default-selected" asset catalog image resource.
    static let bikeParkingDefaultSelected = ImageResource(name: "bike-parking-default-selected", bundle: resourceBundle)

    /// The "bike-parking-done" asset catalog image resource.
    static let bikeParkingDone = ImageResource(name: "bike-parking-done", bundle: resourceBundle)

    /// The "bike-parking-done-selected" asset catalog image resource.
    static let bikeParkingDoneSelected = ImageResource(name: "bike-parking-done-selected", bundle: resourceBundle)

    /// The "bike-parking-error" asset catalog image resource.
    static let bikeParkingError = ImageResource(name: "bike-parking-error", bundle: resourceBundle)

    /// The "bike-parking-error-selected" asset catalog image resource.
    static let bikeParkingErrorSelected = ImageResource(name: "bike-parking-error-selected", bundle: resourceBundle)

    /// The "bike-parking-in-progress" asset catalog image resource.
    static let bikeParkingInProgress = ImageResource(name: "bike-parking-in-progress", bundle: resourceBundle)

    /// The "bike-parking-in-progress-selected" asset catalog image resource.
    static let bikeParkingInProgressSelected = ImageResource(name: "bike-parking-in-progress-selected", bundle: resourceBundle)

    /// The "bike-parking-queued" asset catalog image resource.
    static let bikeParkingQueued = ImageResource(name: "bike-parking-queued", bundle: resourceBundle)

    /// The "bike-parking-queued-selected" asset catalog image resource.
    static let bikeParkingQueuedSelected = ImageResource(name: "bike-parking-queued-selected", bundle: resourceBundle)

    /// The "calendar-arrow-left" asset catalog image resource.
    static let calendarArrowLeft = ImageResource(name: "calendar-arrow-left", bundle: resourceBundle)

    /// The "calendar-arrow-right" asset catalog image resource.
    static let calendarArrowRight = ImageResource(name: "calendar-arrow-right", bundle: resourceBundle)

    /// The "checkbox_selected" asset catalog image resource.
    static let checkboxSelected = ImageResource(name: "checkbox_selected", bundle: resourceBundle)

    /// The "checkbox_unselected" asset catalog image resource.
    static let checkboxUnselected = ImageResource(name: "checkbox_unselected", bundle: resourceBundle)

    /// The "checkmark" asset catalog image resource.
    static let checkmark = ImageResource(name: "checkmark", bundle: resourceBundle)

    /// The "cityImprintHeader" asset catalog image resource.
    static let cityImprintHeader = ImageResource(name: "cityImprintHeader", bundle: resourceBundle)

    /// The "citykey_splash_logo" asset catalog image resource.
    static let citykeySplashLogo = ImageResource(name: "citykey_splash_logo", bundle: resourceBundle)

    /// The "copyLinkImage" asset catalog image resource.
    static let copyLink = ImageResource(name: "copyLinkImage", bundle: resourceBundle)

    /// The "darken_btm_large" asset catalog image resource.
    static let darkenBtmLarge = ImageResource(name: "darken_btm_large", bundle: resourceBundle)

    /// The "delete_photo" asset catalog image resource.
    static let deletePhoto = ImageResource(name: "delete_photo", bundle: resourceBundle)

    /// The "deletion_effects" asset catalog image resource.
    static let deletionEffects = ImageResource(name: "deletion_effects", bundle: resourceBundle)

    /// The "dpn_icon" asset catalog image resource.
    static let dpnIcon = ImageResource(name: "dpn_icon", bundle: resourceBundle)

    /// The "eGov_Service_Eid_Icon" asset catalog image resource.
    static let eGovServiceEidIcon = ImageResource(name: "eGov_Service_Eid_Icon", bundle: resourceBundle)

    /// The "eGov_Service_Form_Icon" asset catalog image resource.
    static let eGovServiceFormIcon = ImageResource(name: "eGov_Service_Form_Icon", bundle: resourceBundle)

    /// The "eGov_Service_MoreInfo_Icon" asset catalog image resource.
    static let eGovServiceMoreInfoIcon = ImageResource(name: "eGov_Service_MoreInfo_Icon", bundle: resourceBundle)

    /// The "eGov_Service_Pdf_Icon" asset catalog image resource.
    static let eGovServicePdfIcon = ImageResource(name: "eGov_Service_Pdf_Icon", bundle: resourceBundle)

    /// The "eGov_Service_Website_Icon" asset catalog image resource.
    static let eGovServiceWebsiteIcon = ImageResource(name: "eGov_Service_Website_Icon", bundle: resourceBundle)

    /// The "egov_browser_reload" asset catalog image resource.
    static let egovBrowserReload = ImageResource(name: "egov_browser_reload", bundle: resourceBundle)

    /// The "eid_can_locator" asset catalog image resource.
    static let eidCanLocator = ImageResource(name: "eid_can_locator", bundle: resourceBundle)

    /// The "eid_card_blocked" asset catalog image resource.
    static let eidCardBlocked = ImageResource(name: "eid_card_blocked", bundle: resourceBundle)

    /// The "eid_eye_logo_fill" asset catalog image resource.
    static let eidEyeLogoFill = ImageResource(name: "eid_eye_logo_fill", bundle: resourceBundle)

    /// The "eid_eye_logo_outline" asset catalog image resource.
    static let eidEyeLogoOutline = ImageResource(name: "eid_eye_logo_outline", bundle: resourceBundle)

    /// The "eid_icon_information" asset catalog image resource.
    static let eidIconInformation = ImageResource(name: "eid_icon_information", bundle: resourceBundle)

    /// The "file_download_small" asset catalog image resource.
    static let fileDownloadSmall = ImageResource(name: "file_download_small", bundle: resourceBundle)

    /// The "group-2" asset catalog image resource.
    static let group2 = ImageResource(name: "group-2", bundle: resourceBundle)

    /// The "group-5" asset catalog image resource.
    static let group5 = ImageResource(name: "group-5", bundle: resourceBundle)

    /// The "home_outline" asset catalog image resource.
    static let homeOutline = ImageResource(name: "home_outline", bundle: resourceBundle)

    /// The "home_solid" asset catalog image resource.
    static let homeSolid = ImageResource(name: "home_solid", bundle: resourceBundle)

    /// The "iPhone_Card_Failure" asset catalog image resource.
    static let iPhoneCardFailure = ImageResource(name: "iPhone_Card_Failure", bundle: resourceBundle)

    /// The "iPhone_Card_Success" asset catalog image resource.
    static let iPhoneCardSuccess = ImageResource(name: "iPhone_Card_Success", bundle: resourceBundle)

    /// The "iPhone_with_card" asset catalog image resource.
    static let iPhoneWithCard = ImageResource(name: "iPhone_with_card", bundle: resourceBundle)

    /// The "icon-action-filter-default" asset catalog image resource.
    static let iconActionFilterDefault = ImageResource(name: "icon-action-filter-default", bundle: resourceBundle)

    /// The "icon-category-activities" asset catalog image resource.
    static let iconCategoryActivities = ImageResource(name: "icon-category-activities", bundle: resourceBundle)

    /// The "icon-category-children" asset catalog image resource.
    static let iconCategoryChildren = ImageResource(name: "icon-category-children", bundle: resourceBundle)

    /// The "icon-category-culture" asset catalog image resource.
    static let iconCategoryCulture = ImageResource(name: "icon-category-culture", bundle: resourceBundle)

    /// The "icon-category-family" asset catalog image resource.
    static let iconCategoryFamily = ImageResource(name: "icon-category-family", bundle: resourceBundle)

    /// The "icon-category-filter" asset catalog image resource.
    static let iconCategoryFilter = ImageResource(name: "icon-category-filter", bundle: resourceBundle)

    /// The "icon-category-insiders" asset catalog image resource.
    static let iconCategoryInsiders = ImageResource(name: "icon-category-insiders", bundle: resourceBundle)

    /// The "icon-category-life" asset catalog image resource.
    static let iconCategoryLife = ImageResource(name: "icon-category-life", bundle: resourceBundle)

    /// The "icon-category-mobility" asset catalog image resource.
    static let iconCategoryMobility = ImageResource(name: "icon-category-mobility", bundle: resourceBundle)

    /// The "icon-category-mobility-2" asset catalog image resource.
    static let iconCategoryMobility2 = ImageResource(name: "icon-category-mobility-2", bundle: resourceBundle)

    /// The "icon-category-nature" asset catalog image resource.
    static let iconCategoryNature = ImageResource(name: "icon-category-nature", bundle: resourceBundle)

    /// The "icon-category-other" asset catalog image resource.
    static let iconCategoryOther = ImageResource(name: "icon-category-other", bundle: resourceBundle)

    /// The "icon-category-recycling" asset catalog image resource.
    static let iconCategoryRecycling = ImageResource(name: "icon-category-recycling", bundle: resourceBundle)

    /// The "icon-category-sights" asset catalog image resource.
    static let iconCategorySights = ImageResource(name: "icon-category-sights", bundle: resourceBundle)

    /// The "icon-disclosure-indicator" asset catalog image resource.
    static let iconDisclosureIndicator = ImageResource(name: "icon-disclosure-indicator", bundle: resourceBundle)

    /// The "icon-more-arrow" asset catalog image resource.
    static let iconMoreArrow = ImageResource(name: "icon-more-arrow", bundle: resourceBundle)

    /// The "icon-more-arrow-light" asset catalog image resource.
    static let iconMoreArrowLight = ImageResource(name: "icon-more-arrow-light", bundle: resourceBundle)

    /// The "icon-page-control-dot" asset catalog image resource.
    static let iconPageControlDot = ImageResource(name: "icon-page-control-dot", bundle: resourceBundle)

    /// The "icon-page-control-dot-current" asset catalog image resource.
    static let iconPageControlDotCurrent = ImageResource(name: "icon-page-control-dot-current", bundle: resourceBundle)

    /// The "icon-search" asset catalog image resource.
    static let iconSearch = ImageResource(name: "icon-search", bundle: resourceBundle)

    /// The "icon-whatsnew-ios-widgets" asset catalog image resource.
    static let iconWhatsnewIosWidgets = ImageResource(name: "icon-whatsnew-ios-widgets", bundle: resourceBundle)

    /// The "icon-yellow-trash" asset catalog image resource.
    static let iconYellowTrash = ImageResource(name: "icon-yellow-trash", bundle: resourceBundle)

    /// The "icon_accessibility_statement" asset catalog image resource.
    static let iconAccessibilityStatement = ImageResource(name: "icon_accessibility_statement", bundle: resourceBundle)

    /// The "icon_account_deleted" asset catalog image resource.
    static let iconAccountDeleted = ImageResource(name: "icon_account_deleted", bundle: resourceBundle)

    /// The "icon_account_locked" asset catalog image resource.
    static let iconAccountLocked = ImageResource(name: "icon_account_locked", bundle: resourceBundle)

    /// The "icon_action_share" asset catalog image resource.
    static let iconActionShare = ImageResource(name: "icon_action_share", bundle: resourceBundle)

    /// The "icon_add_to_calendar" asset catalog image resource.
    static let iconAddToCalendar = ImageResource(name: "icon_add_to_calendar", bundle: resourceBundle)

    /// The "icon_analytics_tool_data_privacy" asset catalog image resource.
    static let iconAnalyticsToolDataPrivacy = ImageResource(name: "icon_analytics_tool_data_privacy", bundle: resourceBundle)

    /// The "icon_back" asset catalog image resource.
    static let iconBack = ImageResource(name: "icon_back", bundle: resourceBundle)

    /// The "icon_calendar_small" asset catalog image resource.
    static let iconCalendarSmall = ImageResource(name: "icon_calendar_small", bundle: resourceBundle)

    /// The "icon_categories_small" asset catalog image resource.
    static let iconCategoriesSmall = ImageResource(name: "icon_categories_small", bundle: resourceBundle)

    /// The "icon_citykey_phone_loading" asset catalog image resource.
    static let iconCitykeyPhoneLoading = ImageResource(name: "icon_citykey_phone_loading", bundle: resourceBundle)

    /// The "icon_close" asset catalog image resource.
    static let iconClose = ImageResource(name: "icon_close", bundle: resourceBundle)

    /// The "icon_compass" asset catalog image resource.
    static let iconCompass = ImageResource(name: "icon_compass", bundle: resourceBundle)

    /// The "icon_compass_fail_dark" asset catalog image resource.
    static let iconCompassFailDark = ImageResource(name: "icon_compass_fail_dark", bundle: resourceBundle)

    /// The "icon_confirm_email" asset catalog image resource.
    static let iconConfirmEmail = ImageResource(name: "icon_confirm_email", bundle: resourceBundle)

    /// The "icon_data_privacy" asset catalog image resource.
    static let iconDataPrivacy = ImageResource(name: "icon_data_privacy", bundle: resourceBundle)

    /// The "icon_data_privacy_settings" asset catalog image resource.
    static let iconDataPrivacySettings = ImageResource(name: "icon_data_privacy_settings", bundle: resourceBundle)

    /// The "icon_datenschutz_dark" asset catalog image resource.
    static let iconDatenschutzDark = ImageResource(name: "icon_datenschutz_dark", bundle: resourceBundle)

    /// The "icon_datenschutz_light" asset catalog image resource.
    static let iconDatenschutzLight = ImageResource(name: "icon_datenschutz_light", bundle: resourceBundle)

    /// The "icon_default_pin" asset catalog image resource.
    static let iconDefaultPin = ImageResource(name: "icon_default_pin", bundle: resourceBundle)

    /// The "icon_eid_card" asset catalog image resource.
    static let iconEidCard = ImageResource(name: "icon_eid_card", bundle: resourceBundle)

    /// The "icon_eid_card_blue" asset catalog image resource.
    static let iconEidCardBlue = ImageResource(name: "icon_eid_card_blue", bundle: resourceBundle)

    /// The "icon_fav2_active" asset catalog image resource.
    static let iconFav2Active = ImageResource(name: "icon_fav2_active", bundle: resourceBundle)

    /// The "icon_fav2_available" asset catalog image resource.
    static let iconFav2Available = ImageResource(name: "icon_fav2_available", bundle: resourceBundle)

    /// The "icon_favourite_active" asset catalog image resource.
    static let iconFavouriteActive = ImageResource(name: "icon_favourite_active", bundle: resourceBundle)

    /// The "icon_favourite_available" asset catalog image resource.
    static let iconFavouriteAvailable = ImageResource(name: "icon_favourite_available", bundle: resourceBundle)

    /// The "icon_favourite_small" asset catalog image resource.
    static let iconFavouriteSmall = ImageResource(name: "icon_favourite_small", bundle: resourceBundle)

    /// The "icon_feedback" asset catalog image resource.
    static let iconFeedback = ImageResource(name: "icon_feedback", bundle: resourceBundle)

    /// The "icon_help_profile" asset catalog image resource.
    static let iconHelpProfile = ImageResource(name: "icon_help_profile", bundle: resourceBundle)

    /// The "icon_imprint" asset catalog image resource.
    static let iconImprint = ImageResource(name: "icon_imprint", bundle: resourceBundle)

    /// The "icon_infobox_empty" asset catalog image resource.
    static let iconInfoboxEmpty = ImageResource(name: "icon_infobox_empty", bundle: resourceBundle)

    /// The "icon_limited_content" asset catalog image resource.
    static let iconLimitedContent = ImageResource(name: "icon_limited_content", bundle: resourceBundle)

    /// The "icon_location_small" asset catalog image resource.
    static let iconLocationSmall = ImageResource(name: "icon_location_small", bundle: resourceBundle)

    /// The "icon_locked_content" asset catalog image resource.
    static let iconLockedContent = ImageResource(name: "icon_locked_content", bundle: resourceBundle)

    /// The "icon_login" asset catalog image resource.
    static let iconLogin = ImageResource(name: "icon_login", bundle: resourceBundle)

    /// The "icon_menu_software_license" asset catalog image resource.
    static let iconMenuSoftwareLicense = ImageResource(name: "icon_menu_software_license", bundle: resourceBundle)

    #warning("The \"icon_more_arrow\" image asset name resolves to the symbol \"iconMoreArrow\" which already exists. Try renaming the asset.")

    /// The "icon_nav_back" asset catalog image resource.
    static let iconNavBack = ImageResource(name: "icon_nav_back", bundle: resourceBundle)

    /// The "icon_osca_start" asset catalog image resource.
    static let iconOscaStart = ImageResource(name: "icon_osca_start", bundle: resourceBundle)

    /// The "icon_register" asset catalog image resource.
    static let iconRegister = ImageResource(name: "icon_register", bundle: resourceBundle)

    /// The "icon_reminder_small" asset catalog image resource.
    static let iconReminderSmall = ImageResource(name: "icon_reminder_small", bundle: resourceBundle)

    /// The "icon_reset_password" asset catalog image resource.
    static let iconResetPassword = ImageResource(name: "icon_reset_password", bundle: resourceBundle)

    /// The "icon_share" asset catalog image resource.
    static let iconShare = ImageResource(name: "icon_share", bundle: resourceBundle)

    /// The "icon_showpass_selected" asset catalog image resource.
    static let iconShowpassSelected = ImageResource(name: "icon_showpass_selected", bundle: resourceBundle)

    /// The "icon_showpass_unselected" asset catalog image resource.
    static let iconShowpassUnselected = ImageResource(name: "icon_showpass_unselected", bundle: resourceBundle)

    /// The "icon_success" asset catalog image resource.
    static let iconSuccess = ImageResource(name: "icon_success", bundle: resourceBundle)

    /// The "icon_terms_and_condition" asset catalog image resource.
    static let iconTermsAndCondition = ImageResource(name: "icon_terms_and_condition", bundle: resourceBundle)

    /// The "icon_tools_required_data_privacy" asset catalog image resource.
    static let iconToolsRequiredDataPrivacy = ImageResource(name: "icon_tools_required_data_privacy", bundle: resourceBundle)

    /// The "icon_val_error" asset catalog image resource.
    static let iconValError = ImageResource(name: "icon_val_error", bundle: resourceBundle)

    /// The "icon_val_ok" asset catalog image resource.
    static let iconValOk = ImageResource(name: "icon_val_ok", bundle: resourceBundle)

    /// The "icon_val_warning" asset catalog image resource.
    static let iconValWarning = ImageResource(name: "icon_val_warning", bundle: resourceBundle)

    /// The "imprint_outline" asset catalog image resource.
    static let imprintOutline = ImageResource(name: "imprint_outline", bundle: resourceBundle)

    /// The "imprint_solid" asset catalog image resource.
    static let imprintSolid = ImageResource(name: "imprint_solid", bundle: resourceBundle)

    /// The "launch-screen" asset catalog image resource.
    static let launchScreen = ImageResource(name: "launch-screen", bundle: resourceBundle)

    /// The "lightbox_close" asset catalog image resource.
    static let lightboxClose = ImageResource(name: "lightbox_close", bundle: resourceBundle)

    /// The "location-icon-outline" asset catalog image resource.
    static let locationIconOutline = ImageResource(name: "location-icon-outline", bundle: resourceBundle)

    /// The "location-icon-outline-white-thick" asset catalog image resource.
    static let locationIconOutlineWhiteThick = ImageResource(name: "location-icon-outline-white-thick", bundle: resourceBundle)

    /// The "location_solid" asset catalog image resource.
    static let locationSolid = ImageResource(name: "location_solid", bundle: resourceBundle)

    /// The "pattern" asset catalog image resource.
    static let pattern = ImageResource(name: "pattern", bundle: resourceBundle)

    /// The "profil_outline" asset catalog image resource.
    static let profilOutline = ImageResource(name: "profil_outline", bundle: resourceBundle)

    /// The "profil_solid" asset catalog image resource.
    static let profilSolid = ImageResource(name: "profil_solid", bundle: resourceBundle)

    /// The "radiobox-blank" asset catalog image resource.
    static let radioboxBlank = ImageResource(name: "radiobox-blank", bundle: resourceBundle)

    /// The "radiobox-blank1" asset catalog image resource.
    static let radioboxBlank1 = ImageResource(name: "radiobox-blank1", bundle: resourceBundle)

    /// The "radiobox-marked" asset catalog image resource.
    static let radioboxMarked = ImageResource(name: "radiobox-marked", bundle: resourceBundle)

    /// The "radiobox-marked1" asset catalog image resource.
    static let radioboxMarked1 = ImageResource(name: "radiobox-marked1", bundle: resourceBundle)

    /// The "registration_main" asset catalog image resource.
    static let registrationMain = ImageResource(name: "registration_main", bundle: resourceBundle)

    /// The "ribbon_75pt" asset catalog image resource.
    static let ribbon75Pt = ImageResource(name: "ribbon_75pt", bundle: resourceBundle)

    /// The "ribbon_top_left" asset catalog image resource.
    static let ribbonTopLeft = ImageResource(name: "ribbon_top_left", bundle: resourceBundle)

    /// The "service_outline" asset catalog image resource.
    static let serviceOutline = ImageResource(name: "service_outline", bundle: resourceBundle)

    /// The "service_solid" asset catalog image resource.
    static let serviceSolid = ImageResource(name: "service_solid", bundle: resourceBundle)

    /// The "share_white" asset catalog image resource.
    static let shareWhite = ImageResource(name: "share_white", bundle: resourceBundle)

    /// The "slash_separator" asset catalog image resource.
    static let slashSeparator = ImageResource(name: "slash_separator", bundle: resourceBundle)

    /// The "splash-logo" asset catalog image resource.
    static let splashLogo = ImageResource(name: "splash-logo", bundle: resourceBundle)

    /// The "survey-icon-finished" asset catalog image resource.
    static let surveyIconFinished = ImageResource(name: "survey-icon-finished", bundle: resourceBundle)

    /// The "survey-icon-idle" asset catalog image resource.
    static let surveyIconIdle = ImageResource(name: "survey-icon-idle", bundle: resourceBundle)

    /// The "text_clear_button" asset catalog image resource.
    static let textClearButton = ImageResource(name: "text_clear_button", bundle: resourceBundle)

    /// The "wl_cancel" asset catalog image resource.
    static let wlCancel = ImageResource(name: "wl_cancel", bundle: resourceBundle)

}

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Hashable {

    /// An asset catalog color resource name.
    fileprivate let name: String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Hashable {

    /// An asset catalog image resource name.
    fileprivate let name: String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif