//
//  SCUnframedQuestionProvider.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 23/11/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol QuestionViewDelegate {
    func validateTextView()
}

class SCUnFramedQuestionView: UIView, QuestionViewDelegate {
    let topic: SCModelQuestionTopic
    var topicLabel: UILabel!

    private var optionViewList: [SCOptionView]
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
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.text = ""
        topicLabel.numberOfLines = 0
        self.addSubview(topicLabel)
        topicLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        topicLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        topicLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true

        for index in 0..<topic.options.count {
            if let qView = SCOptionView.getView(optionIndex: index, delegate: self, option: topic.options[index]) {
                let option = topic.options[index]
                
                if topic.topicAnswerType == .descriptive {
                    qView.questionTypeImageView.isHidden = true
                    qView.questionLabel.isHidden = true
                    qView.optionStackView.isHidden =  true
                    qView.leadingConstraint.constant = 0.0
                    qView.trailingConstraint.constant = 0.0
                    qView.topConstraint.constant = 0.0
                    qView.parentStackView.spacing = 0
                } else {
                    qView.containerView.addBorder()
                    qView.containerView.addCornerRadius()
                }
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
                qView.questionHintLabel.accessibilityTraits = .staticText
                
                qView.questionHintTextView.isAccessibilityElement = true
                qView.questionHintTextView.accessibilityTraits = .staticText
                qView.questionHintTextView.accessibilityLabel = option.textAreaInput
                qView.questionHintTextView.accessibilityHint = "accessibility_textview_input_hint".localized()

                stackView.addArrangedSubview(qView)
                qView.handleDynamicChange()
                optionViewList.append(qView)
            }
        }
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
        var mandatoryFieldIndex: Int?
        for index in 0..<topic.options.count {
            if optionViewList.count > index {
                optionViewList[index].validateTextView(option: topic.options[index]) { [weak self] isAnnounce in
                    guard let strongSelf = self else {
                        return
                    }
                    if isAnnounce, mandatoryFieldIndex == nil  {
                        mandatoryFieldIndex = index
                    }
                }
            }
        }
        if let mandatoryFieldIndex = mandatoryFieldIndex {
            UIAccessibility.post(notification: .layoutChanged,
                                 argument: optionViewList[mandatoryFieldIndex].questionHintTextView)
        }
    }
}

extension SCUnFramedQuestionView: SCOptionViewDelegate {

    func updateAnswer(index: Int, result: Bool) {
        if optionViewList.count > index {
            if topic.topicAnswerType == .multiple {
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
                        optionViewList[viewIndex].optionStackView.accessibilityHint = "\(getButtonType()), \(viewIndex + 1) of \(topic.options.count)"
                        if let hasTextArea = topic.options[viewIndex].hasTextArea,
                           hasTextArea == true {
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
