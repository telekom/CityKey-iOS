//
//  SCUserInfoBoxDetailPresenter.swift
//  SmartCity
//
//  Created by Michael on 08.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCUserInfoBoxDetailDisplaying: AnyObject, SCDisplaying  {
    func setupUI(userInfoId : Int,
                 messageId: Int,
                 description: String,
                 details: String,
                 headline: String,
                 creationDate: Date,
                 category: String,
                 icon: String,
                 btnTitle: String?,
                 attachments : [SCUserInfoBoxAttachmentItem])
    
    
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
}

protocol SCUserInfoBoxDetailPresenting: SCPresenting {
    func setDisplay(_ display: SCUserInfoBoxDetailDisplaying)
    func deleteButtonWasPressed()
    func actionButtonWasPressed()
    func attachmentWasSelected(name : String)
}


struct SCUserInfoBoxAttachmentItem {
    let itemType : SCUserInfoBoxAttachmentItemType
    let itemLink : String
    let itemName : String
}

class SCUserInfoBoxDetailPresenter {
    
    weak private var display: SCUserInfoBoxDetailDisplaying?
    
    private let infoBoxItem: SCModelInfoBoxItem
    private let worker: SCUserInfoBoxDetailWorking
    
    private var completionAfterDelete: (() -> Void)? = nil
    private let deeplinkHandler: SCDeeplinkingHanding

    init(infoBoxItem: SCModelInfoBoxItem,
         worker: SCUserInfoBoxDetailWorking,
         completionAfterDelete: (() -> Void)?,
         deeplinkHandler: SCDeeplinkingHanding = SCDeeplinkingHandler.shared) {
        self.infoBoxItem = infoBoxItem
        self.worker = worker
        self.completionAfterDelete = completionAfterDelete
        self.deeplinkHandler = deeplinkHandler
        self.setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeLogin), name: .userDidSignOut, object: nil)
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    
    @objc private func didChangeLogin(notification: Notification) {
        // on logout dismiss this screen
        self.display?.dismiss(completion: nil)
    }

    private func setupUI() {
        
        var attachments = [SCUserInfoBoxAttachmentItem]()
        
        for att in self.infoBoxItem.attachments{
            attachments.append(SCUserInfoBoxAttachmentItem(itemType: .generic, itemLink: att.attachmentLink, itemName: att.attachmentText))
        }
        
        self.display?.setupUI(userInfoId: self.infoBoxItem.userInfoId,
                              messageId: self.infoBoxItem.userInfoId,
                              description: self.infoBoxItem.description,
                              details: self.infoBoxItem.details,
                              headline: self.infoBoxItem.headline,
                              creationDate: self.infoBoxItem.creationDate,
                              category: self.infoBoxItem.category.categoryName,
                              icon: self.infoBoxItem.category.categoryIcon,
                              btnTitle: self.infoBoxItem.buttonText,
                              attachments: attachments)
    }
}

extension SCUserInfoBoxDetailPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCUserInfoBoxDetailPresenter : SCUserInfoBoxDetailPresenting {
    
    func setDisplay(_ display: SCUserInfoBoxDetailDisplaying){
        self.display = display
    }
    
    func deleteButtonWasPressed() {
        self.display?.dismiss(completion: completionAfterDelete)
    }
    
    func actionButtonWasPressed() {
        guard let btnAction = infoBoxItem.buttonAction else {
            return
        }
        var url = URL(string: btnAction)
        if let url = url, url.scheme == "citykey" {
            deeplinkHandler.deeplinkWithUri(btnAction)
        } else {
            if ( url != nil && url!.scheme != "http" && url!.scheme != "https") {
                url =  URL(string: "http://" + url!.absoluteString)
            }
            if let urlToOpen = url, UIApplication.shared.canOpenURL(urlToOpen) {
                SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari, title: nil)
            }
        }
    }

    func attachmentWasSelected(name : String){
        
        let attachment = self.infoBoxItem.attachments.filter { $0.attachmentText == name }

        if attachment.count > 0 {
            if let attachmentStr = attachment.first?.attachmentLink {
                var url = URL(string: attachmentStr)
                if ( url != nil && url!.scheme != "http" && url!.scheme != "https") {
                    url =  URL(string: "http://" + url!.absoluteString)
                }
                
                if let urlToOpen = url, UIApplication.shared.canOpenURL(urlToOpen) {
                    SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari, title: nil)
                }
            }
        }
    }
}
