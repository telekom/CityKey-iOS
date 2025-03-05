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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

extension LocalizationKeys {

    enum SCDataPrivacy {
        static let m001MoengageDialogPushBtnCancel: String = "m_001_moengage_dialog_push_btn_cancel"
        static let m001MoengageDialogPushBtnSettings: String = "m_001_moengage_dialog_push_btn_settings"
        static let x001WelcomeBtnPrivacyShort: String = "x_001_welcome_btn_privacy_short"
        static let dialogDpnNoticeSettingsBtn: String = "dialog_dpn_notice_settings_btn"
    }
    
    enum SCDataPrivacyNotice {
        static let dialogTechnicalErrorMessage: String = "dialog_technical_error_message"
        static let dialogDpnUpdatedTitle: String = "dialog_dpn_updated_title"
    }
    
    enum DataPrivacySettings {
        static let dialogDpnSettingsShowMoreBtn: String = "dialog_dpn_settings_show_more_btn"
        static let dialogDpnSettingsShowLessBtn: String = "dialog_dpn_settings_show_less_btn"
        static let dialogDpnSettingsTitle: String = "dialog_dpn_settings_title"
        static let dialogDpnSettingsHeadline: String = "dialog_dpn_settings_headline"
        static let dialogDpnSettingsDescription: String = "dialog_dpn_settings_description"
        static let dialogDpnSettingsRequiredHeadline: String = "dialog_dpn_settings_required_headline"
        static let dialogDpnSettingsRequiredDescription: String = "dialog_dpn_settings_required_description"
        static let dialogDpnSettingsOptionalHeadline: String = "dialog_dpn_settings_optional_headline"
        static let dialogDpnSettingsOptionalDescription: String = "dialog_dpn_settings_optional_description"
        static let dialogDpnSettingsAcceptChosenBtn: String = "dialog_dpn_settings_accept_chosen_btn"
        static let dialogDpnSettingsAcceptAllBtn: String = "dialog_dpn_settings_accept_all_btn"
        static let dialogDpnSettingsDataSecurityLink: String = "dialog_dpn_settings_data_security_link"
    }
    
    enum DataPrivacyFirstRun {
        static let dialogDpnFtuTextFormat: String = "dialog_dpn_ftu_text_format"
        static let dialogDpnSettingsChangeBtn: String = "dialog_dpn_settings_change_btn"
        static let dialogDpnSettingsAcceptAllBtn: String = "dialog_dpn_settings_accept_all_btn"
        static let dialogDpnFtuDpnLink: String = "dialog_dpn_ftu_dpn_link"
        static let dialogDpnFtuContinueLink: String = "dialog_dpn_ftu_continue_link"
    }
}
