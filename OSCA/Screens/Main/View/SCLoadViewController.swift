//
//  SCLoadViewController.swift
//  SmartCity
//
//  Created by Michael on 07.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import Lottie

class SCLoadViewController: UIViewController {

    @IBOutlet weak var launchImage: UIImageView!
    @IBOutlet weak var oscaImageView: UIImageView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    var loadCompletionHandler: (() -> Void)?
    var refreshHandler : SCSharedWorkerRefreshHandling?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        createAndPlayLoadingAnimation()
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .launchScreenNoInternet, with: #selector(noInternetOnLaunchScreen))
        SCDataUIEvents.registerNotifications(for: self, on: .launchScreenRetry, with: #selector(handleRetryOnNoInterenete))
    }
    
    @objc private func noInternetOnLaunchScreen() {
        self.launchImage.isHidden = false
        self.loadingView.isHidden = true
    }
    
    @objc private func handleRetryOnNoInterenete() {
        refreshHandler?.reloadContent(force: true)
        self.launchImage.isHidden = true
        self.loadingView.isHidden = false
        
    }
    
    func createAndPlayLoadingAnimation() {
        loadingView.animation = LottieAnimation.named(animationAssestForLoader())
        loadingView.play(fromFrame: 0, toFrame: 29) { isFinished in
            self.loadingView.play(fromFrame: 30, toFrame: 59, loopMode: .loop) { _ in
            }
        }
    }
    
    func finishLoading() {
        self.loadingView.loopMode = .playOnce
        loadingView.play(fromFrame: 60, toFrame: 69) { isFinished in
            self.loadCompletionHandler?()
        }
    }
    
    private func animationAssestForLoader() -> String {
        switch traitCollection.userInterfaceStyle {
        case .unspecified,
                .light:
            return "CityKey_Splashlogo_lightmode"
        case .dark:
            return "CityKey_Splashlogo_darkmode"
        @unknown default:
            return "CityKey_Splashlogo_lightmode"
        }
    }
}
