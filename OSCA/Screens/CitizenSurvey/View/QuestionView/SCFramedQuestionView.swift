/*
Created by Rutvik Kanbargi on 01/12/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

protocol SCOptionViewDelegate {
    func updateAnswer(index: Int, result: Bool)
    func updateTextViewResult(index: Int, option: SCModelQuestionTopicOption)
}

class SCFramedQuestionView: UIView, QuestionViewDelegate {

    let topic: SCModelQuestionTopic
    var topicLabel: UILabel!
    var optionViewList: [SCOptionView]
    var delegate: SCQuestionViewHandlerDelegate?

    init(topic: SCModelQuestionTopic, delegate: SCQuestionViewHandlerDelegate) {
        self.topic = topic
        optionViewList = []
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        topicLabel = UILabel()
        topicLabel.textColor = .labelTextBlackCLR
        topicLabel.font = UIFont.boldSystemFont(ofSize: 16)
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.text = topic.topicName
        topicLabel.numberOfLines = 0
        self.addSubview(topicLabel)
        topicLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        topicLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 12).isActive = true
        topicLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

        for index in 0..<topic.options.count {
            if let qView = SCOptionView.getView(optionIndex: index, delegate: self, option: topic.options[index]) {
                let option = topic.options[index]
                qView.questionLabel.text = option.optionText
                qView.questionHintLabel.isHidden = true
                qView.questionHintTextView.isHidden = true
                qView.questionHintTextView.text = option.textAreaInput
                qView.updateSelection(option: option, isMultipleChoice: topic.topicAnswerType == .multiple)

                qView.optionStackView.isAccessibilityElement = true
                qView.optionStackView.accessibilityLabel = option.optionText
                qView.optionStackView.accessibilityHint = "\(getButtonType()), \(index + 1) of \(topic.options.count) \(LocalizationKeys.Accessibility.radioBtnTapHint.localized()) \(getButtonStatus(isSelected: topic.options[index].optionSelected))"
                
                qView.questionHintLabel.isAccessibilityElement = true
                qView.questionHintLabel.accessibilityLabel = option.textAreaDescription
                qView.questionLabel.accessibilityTraits = .staticText

                qView.questionHintTextView.isAccessibilityElement = true
                qView.questionHintTextView.accessibilityTraits = .staticText
                qView.questionHintTextView.accessibilityLabel = option.textAreaInput
                qView.questionHintTextView.accessibilityHint = "accessibility_textview_input_hint".localized()
                qView.handleDynamicChange()
                stackView.addArrangedSubview(qView)
                optionViewList.append(qView)
            }
        }
        self.addBorder()
        self.addCornerRadius()
        handleDynamicTypeChange()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))
    }
    
    @objc private func handleDynamicTypeChange() {
        topicLabel.adjustsFontForContentSizeCategory = true
        topicLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: 32.0)
        for optionView in optionViewList {
            optionView.handleDynamicChange()
        }
    }
    
    private func getButtonStatus(isSelected: Bool?) -> String {
        if topic.topicAnswerType == .multiple {
            return isSelected == true ? "accessibility_checkbox_state_unchecked".localized() : "accessibility_checkbox_state_checked".localized()
        } else {
            return isSelected == true ? "accessibility_deselect".localized() : "accessibility_select".localized()
        }
    }
    
    private func getButtonType() -> String {
        if topic.topicAnswerType == .multiple {
            return "Checkbox"
        } else {
            return "Radio Button"
        }
    }

    func validateTextView() {
        for index in 0..<topic.options.count {
            if optionViewList.count > index {            
                optionViewList[index].validateTextView(option: topic.options[index])
            }
        }
    }
}

extension SCFramedQuestionView: SCOptionViewDelegate {

    func updateAnswer(index: Int, result: Bool) {
        if optionViewList.count > index {
            if topic.topicAnswerType == .multiple {
                for viewIndex in 0..<optionViewList.count {
                    optionViewList[viewIndex].questionHintTextView.endEditing(true)
                    optionViewList[viewIndex].questionHintTextView.isUserInteractionEnabled = false
                }
                topic.options[index].optionSelected = !(topic.options[index].optionSelected ?? true)
                optionViewList[index].updateSelection(option: topic.options[index], isMultipleChoice: topic.topicAnswerType == .multiple)
                optionViewList[index].optionStackView.accessibilityLabel = topic.options[index].optionText
                optionViewList[index].optionStackView.accessibilityHint = "\(getButtonType()), \(index + 1) of \(topic.options.count) \(LocalizationKeys.Accessibility.radioBtnTapHint.localized()) \(getButtonStatus(isSelected: topic.options[index].optionSelected))"
                optionViewList[index].optionStackView.accessibilityValue = topic.options[index].optionSelected == true ? "accessibility_checkbox_state_checked".localized() : "accessibility_checkbox_state_unchecked".localized()
                optionViewList[index].optionStackView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            } else {
                for viewIndex in 0..<optionViewList.count {
                    if index != viewIndex {
                        topic.options[viewIndex].optionSelected = topic.topicAnswerType == .descriptive ? true : false
                        optionViewList[viewIndex].optionStackView.accessibilityLabel = topic.options[viewIndex].optionText
                        optionViewList[viewIndex].optionStackView.accessibilityHint = "\(getButtonType()), \(viewIndex + 1) of \(topic.options.count) \(LocalizationKeys.Accessibility.radioBtnTapHint.localized()) \(getButtonStatus(isSelected: topic.options[viewIndex].optionSelected))"
                        optionViewList[viewIndex].optionStackView.accessibilityValue = ""
                        optionViewList[viewIndex].optionStackView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
                    } else {
                        topic.options[viewIndex].optionSelected = true
                        optionViewList[viewIndex].optionStackView.accessibilityLabel = topic.options[viewIndex].optionText
                        optionViewList[viewIndex].optionStackView.accessibilityHint =  "\(getButtonType()), \(viewIndex + 1) of \(topic.options.count)"
                        if let hasTextArea = topic.options[viewIndex].hasTextArea, hasTextArea == true {
                            optionViewList[viewIndex].optionStackView.accessibilityValue =  "accessibility_hint_state_selected_with_text_area".localized()
                        } else {
                            optionViewList[viewIndex].optionStackView.accessibilityValue = "accessibility_hint_state_selected".localized()
                        }
                        optionViewList[viewIndex].optionStackView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
                    }
                    optionViewList[viewIndex].updateSelection(option: topic.options[viewIndex], isMultipleChoice: false)
                }
            }
        }

        delegate?.notify(answer: topic, index: 0)
    }
    
    func updateTextViewResult(index: Int, option: SCModelQuestionTopicOption) {
        topic.options[index].textAreaInput = option.textAreaInput
        delegate?.notify(answer: topic, index: 0)
    }
}
