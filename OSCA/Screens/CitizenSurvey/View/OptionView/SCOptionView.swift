//
//  SCQuestionView.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 23/11/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
