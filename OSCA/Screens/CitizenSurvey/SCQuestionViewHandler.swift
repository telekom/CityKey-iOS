//
//  SCQuestionViewHandler.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 01/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCQuestionViewHandlerDelegate {
    func notify(answer: SCModelQuestionTopic, index: Int)
}

protocol SCQuestionViewHandlerResultDelegate: AnyObject {
    func update(_ topics: [SCModelQuestionTopic])
}

class SCQuestionViewHandler {

    var topics: [SCModelQuestionTopic]
    private weak var delegate: SCQuestionViewHandlerResultDelegate?
    private var questionViewList: [QuestionViewDelegate]

    init(topics: [SCModelQuestionTopic], delegate: SCQuestionViewHandlerResultDelegate) {
        self.topics = topics
        self.delegate = delegate
        questionViewList = []
    }

    func provideView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for topic in topics {
            if topic.topicDesign == .framed {
                let topicView = SCFramedQuestionView(topic: topic, delegate: self)
                stackView.addArrangedSubview(topicView)
                questionViewList.append(topicView)
            } else if topic.topicDesign == .unframed {
                let topicView = SCUnFramedQuestionView(topic: topic, delegate: self)
                stackView.addArrangedSubview(topicView)
                questionViewList.append(topicView)
            }
        }

        return stackView
    }

    func validateTextView() {
        for view in questionViewList {
            view.validateTextView()
        }
    }
}

extension SCQuestionViewHandler: SCQuestionViewHandlerDelegate {

    func notify(answer: SCModelQuestionTopic, index: Int) {
        for index in 0..<topics.count {
            if topics[index].topicId == answer.topicId {
                topics[index] = answer
            }
        }
        delegate?.update(topics)
    }
}
