//
//  SCWebView.swift
//  OSCA
//
//  Created by Bhaskar N S on 08/03/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import WebKit

class SCWebView: UIView {

    var webView: WKWebView!

    func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController()
        return configuration
    }

    private func userContentController() -> WKUserContentController {
        let controller = WKUserContentController()
        controller.addUserScript(viewPortScript())
        controller.addUserScript(appearanceScript())
        return controller
    }

    private func appearanceScript() -> WKUserScript {
        let appearance = """
                   var style = document.createElement('style');
                   style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                   document.head.appendChild(style);
           """
        return WKUserScript(source: appearance, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }

    private func viewPortScript() -> WKUserScript {
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=\(UIScreen.main.bounds.width - 36.0)');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: viewPortScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView()
    }

    private func setupWebView() {
        webView = WKWebView(frame: bounds, configuration: webViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        addSubview(webView)
        webView.navigationDelegate = self
        webView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }

    // MARK: - Public Methods
    func loadWebView(with content: String?) {
        guard let content = content else { return }
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = "<span style=\"font-family:-apple-system; font-size: \(fontSize); color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>"
        webView.loadHTMLString(fontSetting + content, baseURL: nil)
    }

    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension SCWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                       var style = document.createElement('style');
                       style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                       document.head.appendChild(style);
               """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    SCInternalBrowser.showURL(url, withBrowserType: .safari)
                }
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
