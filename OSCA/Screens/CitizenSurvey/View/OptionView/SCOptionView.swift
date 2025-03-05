/*
Created by Rutvik Kanbargi on 23/11/20.
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

import UIKit

class SCOptionView: UIView {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionTypeImageView: UIImageView!
    @IBOutlet weak var questionHintLabel: UILabel!
    @IBOutlet weak var questionHintTextView: UITextView! {
        didSet {
            questionHintTextView.addBorder()
            questionHintTextView.delegate = self
        }
    }
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var optionStackView: UIStackView!
    @IBOutlet weak var parentStackView: UIStackView!
	
    var optionIndex: Int?
    var delegate: SCOptionViewDelegate?
    var option: SCModelQuestionTopicOption?
    private var configuration: SCSelectionViewConfigurator?

    static func getView(optionIndex: Int,
                        delegate: SCOptionViewDelegate?,
                        option: SCModelQuestionTopicOption) -> SCOptionView? {
       guard let view = UINib(nibName: String(describing: SCOptionView.self),
                              bundle: nil).instantiate(withOwner: nil, options: nil).first as? SCOptionView else {
        return nil
       }
        view.optionIndex = optionIndex
        view.delegate = delegate
        view.option = option
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(didTapOnOption))
        view.stackView.addGestureRecognizer(tapGesture)
        return view
    }

    @objc private func didTapOnOption() {
        guard let index = optionIndex else {
            return
        }
        delegate?.updateAnswer(index: index, result: true)
    }

    func updateSelection(option: SCModelQuestionTopicOption, isMultipleChoice: Bool) {
        if isMultipleChoice {
            handleMultipleSelection(option: option)
        } else {
            handleSingleSelection(option: option)
        }

        questionHintLabel.text = option.textAreaDescription
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let questionTypeImage = self.questionTypeImageView.image{
                    self.questionTypeImageView?.image = questionTypeImage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
                }
            }
        }
    }


    private func handleMultipleSelection(option: SCModelQuestionTopicOption) {
        let hasTextArea = (option.hasTextArea ?? false)
        if hasTextArea {
            let hintFieldStatus = !(option.optionSelected ?? false)
            questionHintTextView.isHidden = hintFieldStatus
            questionHintLabel.isHidden = hintFieldStatus
        }
        let optionSelected = option.optionSelected ?? false
        questionTypeImageView.image = optionSelected ? UIImage(named: "checkbox_selected")?.maskWithColor(color: kColor_cityColor) : UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_INPUT_FOCUS")!)
        questionLabel.font = optionSelected ? UIFont.systemFont(ofSize: questionLabel.font.pointSize, weight: .bold) : UIFont.systemFont(ofSize: questionLabel.font.pointSize, weight: .regular)
    }

    private func handleSingleSelection(option: SCModelQuestionTopicOption) {
        let hasTextArea = (option.hasTextArea ?? false)
        if hasTextArea {
            let hintFieldStatus = !(option.optionSelected ?? false)
            questionHintTextView.isHidden = hintFieldStatus
            questionHintLabel.isHidden = hintFieldStatus
        }
        let optionSelected = option.optionSelected ?? false
        questionTypeImageView.image = optionSelected ? UIImage(named: "radiobox-marked")?.maskWithColor(color: kColor_cityColor) : UIImage(named: "radiobox-blank")?.maskWithColor(color: UIColor(named: "CLR_INPUT_FOCUS")!)
        questionLabel.font = optionSelected ? UIFont.systemFont(ofSize: questionLabel.font.pointSize, weight: .bold) : UIFont.systemFont(ofSize: questionLabel.font.pointSize, weight: .regular)

    }

    func validateTextView(option: SCModelQuestionTopicOption, completion: ((Bool) -> Void)? = nil) {
        let hasTextArea = (option.hasTextArea ?? false)
        if hasTextArea {
            let hintFieldStatus = !(option.optionSelected ?? false)
            questionHintTextView.isHidden = hintFieldStatus
            questionHintLabel.isHidden = hintFieldStatus

            let isTextAreaMandatory = (option.textAreaMandatory ?? false)

            if isTextAreaMandatory && option.textAreaInput == "" && option.optionSelected ?? false {
                questionHintTextView.text = LocalizationKeys.SCOptionView.cs004MandatoryFieldError.localized()
                questionHintTextView.textColor = .appointmentRejected
                questionHintTextView.addBorder(color: .appointmentRejected)
                completion?(true)
            }
        }
    }
    
    func handleDynamicChange() {
        questionLabel.adjustsFontForContentSizeCategory = true
        questionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 32.0)
        questionHintLabel.adjustsFontForContentSizeCategory = true
        questionHintLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 32.0)
        questionHintTextView.adjustsFontForContentSizeCategory = true
        questionHintTextView.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14.0, maxSize: 28.0)
    }
}

extension SCOptionView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (range.location == 0 && text == " ") {
            return false
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            if textView.textColor == .appointmentRejected && !textView.text.isEmpty {
                textView.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")
                textView.text = ""
                questionHintTextView.addBorder()
            }
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateTextViewResult(textView:)), object: textView)
            perform(#selector(updateTextViewResult(textView:)), with: textView, afterDelay: 0.5)
        }
        return true
    }

    @objc private func updateTextViewResult(textView: UITextView) {
        if let index = optionIndex, let option = option {
            option.textAreaInput = textView.text
            delegate?.updateTextViewResult(index: index, option: option)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .appointmentRejected {
            textView.text = ""
            textView.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")
            questionHintTextView.addBorder()
        }
    }
}

protocol SCSelectionViewConfigurator {
    func selectedImage() -> UIImage?
    func unselectedImage() -> UIImage?
}

class SCSingleSelectionViewConfiguration: SCSelectionViewConfigurator {
    
    func selectedImage() -> UIImage? {
        UIImage(named: "radiobox-marked")?.maskWithColor(color: kColor_cityColor)
    }

    func unselectedImage() -> UIImage? {
        UIImage(named: "radiobox-blank")?.maskWithColor(color: UIColor(named: "CLR_INPUT_FOCUS")!)
    }
}

class SCMultipleSelectionViewConfiguration {

    func selectedImage() -> UIImage? {
        UIImage(named: "checkbox_selected")?.maskWithColor(color: kColor_cityColor)
    }

    func unselectedImage() -> UIImage? {
        UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_INPUT_FOCUS")!)
    }
}
