//
//  SCInternalBrowser.swift
//  OSCA
//
//  Created by Michael on 28.07.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import SafariServices

enum SCInternalBrowserType {
    case safari
    case webView
}

class SCInternalBrowser: NSObject {

    static func showURL(_ url: URL, withBrowserType type: SCInternalBrowserType = .safari, title: String? = nil ) {
        
        guard let url = trimWhiteSpaceCharacters(url: url) else { return }
        if isUnsupportedBySafariAndWebView(url: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            
            switch type {
                
            case .safari :
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = false
                let vc = SFSafariViewController(url: url, configuration: config)
                SCUtilities.topViewController().present(vc, animated: true)
                
            case .webView :
                
                let navigationController : UINavigationController = UIStoryboard(name: "AusweisAuth", bundle: nil).instantiateInitialViewController() as! UINavigationController
                let viewController = navigationController.viewControllers[0] as! SCAusweisAuthWebViewController
                let presenter = SCWebBrowserPresenter(url: url)
                viewController.presenter = presenter
                viewController.hidesBottomBarWhenPushed = true
                viewController.title = title
                if let tabbarConctoller = SCUtilities.topViewController() as? SCMainTabBarController {
                    if let navigationController = tabbarConctoller.selectedController() as? UINavigationController {
                        navigationController.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    private static func isUnsupportedBySafariAndWebView(url: URL) -> Bool {
        if url.scheme == "http" || url.scheme == "https" {
            return false
        }
        return true
    }
    
    private static func trimWhiteSpaceCharacters(url: URL) -> URL?{
        let urlStr = url.absoluteString.trimmingCharacters(in: .whitespaces)
        return URL(string: urlStr)
    }
}
