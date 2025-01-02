//
//  SCCitizenSurveyQuestionViewController.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 24/11/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCCitizenSurveyQuestionViewController: UIViewController {

    @IBOutlet weak var surveyNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionHintLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!

    @IBOutlet weak var previousQuestionButton: SCCustomButton!
    @IBOutlet weak var nextQuestionButton: SCCustomButton!
    
    @IBOutlet weak var scrollView: UIScrollView!

    var presenter: SCCitizenSurveyQuestionPresenting?
    weak var delegate: SCCitizenSurveyPageViewPresenterDelegate?
    var questionIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    @objc private func handleDynamicTypeChange() {
        surveyNameLabel.adjustsFontForContentSizeCategory = true
        surveyNameLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: 32.0)
        
        questionLabel.adjustsFontForContentSizeCategory = true
        questionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 32.0)
        
        questionHintLabel.adjustsFontForContentSizeCategory = true
        questionHintLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 32.0)

        nextQuestionButton.titleLabel?.adjustsFontForContentSizeCategory = true
        nextQuestionButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)

        previousQuestionButton.titleLabel?.adjustsFontForContentSizeCategory = true
        previousQuestionButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
    }

    private func setup() {
        previousQuestionButton.customizeCityColorStyleLight()
        nextQuestionButton.customizeCityColorStyleLight()

        presenter?.set(display: self)
        presenter?.viewDidLoad()
        surveyNameLabel.text = presenter?.getSurveyTitle()
        questionLabel.text = presenter?.getSurveyQuestionText()
        questionHintLabel.text = presenter?.getSurveyQuestionHint()
        questionHintLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!

        previousQuestionButton.setTitle(LocalizationKeys.SCCitizenSurveyQuestionViewController.cs004ButtonPrevious.localized(), for: .normal)

        if let questionView = presenter?.getQuestionView() {
            questionView.translatesAutoresizingMaskIntoConstraints = false
            questionContainerView.addSubview(questionView)

            questionView.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor, constant: 0).isActive = true
            questionView.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: 0).isActive = true
            questionView.topAnchor.constraint(equalTo: questionContainerView.topAnchor, constant: 0).isActive = true
            questionView.bottomAnchor.constraint(equalTo: questionContainerView.bottomAnchor, constant: 0).isActive = true
        }

        previousQuestionButton.isHidden =    (questionIndex == 0)
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    @IBAction func didTapOnPrevious(_ sender: UIButton) {
        if let index = questionIndex {
            delegate?.previousPage(index: index)
        }
    }

    @IBAction func didTapOnNext(_ sender: UIButton) {
        if let index = questionIndex {
            if presenter?.isTextViewFilled() == true {
                delegate?.nextPage(index: index)
            } else {
                presenter?.validateTextView()
            }
        }
    }
}

extension SCCitizenSurveyQuestionViewController: SCCitizenSurveyQuestionDisplaying {

    func updateNextButton(isEnabled: Bool, alpha: CGFloat) {
        nextQuestionButton.set(isEnable: isEnabled)
    }
    
    func updateFinishStateOfNextButton(isLastPage: Bool) {
        
        if isLastPage{
            nextQuestionButton.customizeCityColorStyle()
            nextQuestionButton.setTitle(LocalizationKeys.SCCitizenSurveyQuestionViewController.cs004ButtonDone.localized(), for: .normal)
        } else {
            nextQuestionButton.customizeCityColorStyleLight()
            nextQuestionButton.setTitle(LocalizationKeys.SCCitizenSurveyQuestionViewController.cs004ButtonNext.localized(), for: .normal)
        }
        handleDynamicTypeChange()
    }

}

func getDummySurvey() -> SCModelCitizenSurvey? {
    let surveyData = surveyJsonString.data(using: .utf8)
    return try? JSONDecoder().decode(SCModelCitizenSurvey.self, from: surveyData!)
}


let surveyJsonString =  """
 {
     "surveyId": 1,
     "userId": 17,
     "surveyName": "Sport in Hennef",
     "questions": [{
             "questionId": 1,
             "questionAnswered": false,
             "questionOrder": 1,
             "questionText": "Sind Sie mit dem Sportangebot in Hennf zufrieden?",
             "questionHint": "",
             "topics": [{
                 "topicId": 1,
                 "topicName": "",
                 "topicDesignType": 1,
                 "topicOrder": 1,
                 "topicOptionType": "RB",
                 "options": [{
                         "optionNo": 1,
                         "optionText": "Ja, sehr",
                         "optionSelected": false,
                         "hasTextArea": false,
                         "textAreaDescription": "",
                         "textAreaInput": ""
                     },
                     {
                         "optionNo": 2,
                         "optionText": "Geht so",
                         "optionSelected": false,
                         "hasTextArea": false,
                         "textAreaDescription": "",
                         "textAreaInput": ""
                     },
                     {
                         "optionNo": 3,
                         "optionText": "Eher nicht",
                         "optionSelected": false,
                         "hasTextArea": false,
                         "textAreaDescription": "",
                         "textAreaInput": ""
                     },
                     {
                         "optionNo": 4,
                         "optionText": "Gar nicht",
                         "optionSelected": false,
                         "hasTextArea": true,
                         "textAreaDescription": "Bitte beschreiben Sie kurz (optional), warum Sie >> Gar nicht. << Gewalt haben:",
                         "textAreaInput": ""
                     }
                 ]
             }]
         },
         {
             "questionId": 2,
             "questionAnswered": false,
             "questionActive": true,
             "questionOrder": 2,
             "questionText": "Wie findenSie die Sportanlagen (Plätze, Hallen) in Hennef?",
             "questionHint": "Mehrere Antworten sind möglich.",
             "topics": [{
                 "topicId": 1,
                 "topicName": "",
                 "topicDesignType": 1,
                 "topicOrder": 1,
                 "topicOptionType": "CB",
                 "options": [{
                         "optionNo": 1,
                         "optionText": "Ausreichend für alle Sportarten vorhanden.",
                         "optionSelected": false,
                         "hasTextArea": false,
                         "textAreaDescription": "",
                         "textAreaInput": ""
                     },
                     {
                         "optionNo": 2,
                         "optionText": "Die Hallen sind in einem guten Zustand.",
                         "optionSelected": false,
                         "hasTextArea": false,
                         "textAreaDescription": "",
                         "textAreaInput": ""
                     },
                     {
                         "optionNo": 3,
                         "optionText": "Die Plätze sind in einem guten Zustand.",
                         "optionSelected": false,
                         "hasTextArea": false,
                         "textAreaDescription": "",
                         "textAreaInput": ""
                     },
                     {
                         "optionNo": 4,
                         "optionText": "Das Angebot ist unzureichend",
                         "optionSelected": false,
                         "hasTextArea": true,
                         "textAreaDescription": "Bitte beschreiben Sie Kurz",
                         "textAreaInput": ""
                     }
                 ]
             }]
         },
         {
             "questionId": 3,
             "questionAnswered": false,
             "questionOrder": 3,
             "questionText": "Sagen Sie und die Meinung: Was denken sie über das Solortangebot in Hennef, was fehlt, wa wünschen Sie sich?",
             "topics": [{
                     "topicId": 1,
                     "topicName": "Fußball",
                     "topicDesignType": 2,
                     "topicOrder": 1,
                     "topicOptionType": "RB",
                     "options": [{
                             "optionNo": 1,
                             "optionText": "Alles gut",
                             "optionSelected": false,
                             "hasTextArea": false,
                             "textAreaDescription": "",
                             "textAreaInput": ""
                         },
                         {
                             "optionNo": 2,
                             "optionText": "Ich Wünsche mir",
                             "optionSelected": false,
                             "hasTextArea": true,
                             "textAreaDescription": "Bitte beschreiben Sie Kurz",
                             "textAreaInput": ""
                         }
                     ]
                 },
                 {
                     "topicId": 2,
                     "topicName": "Tennis",
                     "topicDesignType": 2,
                     "topicOrder": 2,
                     "topicOptionType": "RB",
                     "options": [{
                             "optionNo": 1,
                             "optionText": "Alles gut",
                             "optionSelected": false,
                             "hasTextArea": false,
                             "textAreaDescription": "",
                             "textAreaInput": ""
                         },
                         {
                             "optionNo": 2,
                             "optionText": "Ich Wünsche mir",
                             "optionSelected": false,
                             "hasTextArea": true,
                             "textAreaDescription": "Bitte beschreiben Sie Kurz",
                             "textAreaInput": ""
                         }
                     ]
                 }
             ]
         }
     ]
 }
"""
