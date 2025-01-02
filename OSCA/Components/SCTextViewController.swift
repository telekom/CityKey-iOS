//
//  SCTextViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 17/01/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MessageUI

class SCTextViewController: UIViewController {

    @IBOutlet weak var textView : UITextView!

    var content : String = "" {
        didSet{
            setTextViewContent(text: content)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextViewContent(text: content)
        textView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        textView.delegate = self
    }
 
    private func setTextViewContent(text : String) {
        
        if let textView = textView {
         
            if let attrString =  text.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines) {
                
                let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
                htmlAttributedString.replaceFont(with:UIFont.SystemFont.medium.forTextStyle(style: .body, size: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, maxSize: nil),color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
                textView.attributedText = htmlAttributedString
            }
        }
    }
    
    private func stripOutAppleWebData(requestURL: URL) -> URL {
        if requestURL.scheme == "applewebdata" {
            let requestURLString = requestURL.absoluteString
            let trimmedRequestURLString = (requestURLString as NSString).replacingOccurrences(of: "^(?:applewebdata://[0-9A-Z-]*/?)",
                                                                                              with: "", options: .regularExpression,
                                                                                              range: NSRange(location: 0, length: requestURLString.count))
                
            if trimmedRequestURLString.count > 0 {
                return URL(string: trimmedRequestURLString) ?? requestURL
            }
        }
        return requestURL
    }
}

extension SCTextViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let url = stripOutAppleWebData(requestURL: URL)
        if let email = url.email {
            sendMail(recipient: email)
            return false
        } else if UIApplication.shared.canOpenURL(url) {
            SCInternalBrowser.showURL(URL, withBrowserType: .safari, title: title)
            return false
        }
        return true
    }
}

extension SCTextViewController  {

    private func sendMail(recipient: String) {
        if MFMailComposeViewController.canSendMail(){
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([recipient])
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else{
            let to = recipient
            let gmailUrl = (URL(string: "googlegmail://co?to=\(to)"), "Gmail")
            let outlookUrl = (URL(string: "ms-outlook://compose?to=\(to)"), "Outlook")
            let sparkUrl = (URL(string: "readdle-spark://compose?recipient=\(to)"), "Spark")
            let yahooMail = (URL(string: "ymail://mail/compose?to=\(to)"), "YahooMail")
            let availableUrls = [gmailUrl, outlookUrl, sparkUrl, yahooMail].filter { (item) -> Bool in
                return item.0 != nil && UIApplication.shared.canOpenURL(item.0!)
            }
            if availableUrls.isEmpty {
                let alert = UIAlertController(title: nil, message: LocalizationKeys.SCVersionInformationViewController.wn005MailAleartText.localized(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewPresenter.p001ProfileConfirmEmailChangeBtn.localized(), style: UIAlertAction.Style.default, handler: { action in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }else {
                self.showEmailOptions(for: availableUrls as! [(url: URL, friendlyName: String)])
            }
            
        }
    }
    
    func showEmailOptions(for items: [(url: URL, friendlyName: String)]) {
        let ac = UIAlertController(title: LocalizationKeys.SCLocationSubTableVC.c003EmailOptionAleartText.localized(), message: nil, preferredStyle: .actionSheet)
        for item in items {
            ac.addAction(UIAlertAction(title: item.friendlyName, style: .default, handler: { (_) in
                UIApplication.shared.open(item.url, options: [:],
                                          completionHandler: nil)
            }))
        }
        ac.addAction(UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnCancel.localized(),
                                   style: .cancel,
                                   handler: nil))
        present(ac, animated: true)
    }
}

extension SCTextViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
