//
//  SCFirstTimeUsageVC.swift
//  SmartCity
//
//  Created by Michael on 05.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

protocol SCFirstTimeUsageVCDelegate : NSObjectProtocol
{
    func loginBtnWasPressed()
    func registerBtnWasPressed()
    func skipButtonWasPressed()
}

// OPTIONAL
extension SCFirstTimeUsageVCDelegate {
    
    func skipButtonWasPressed(){}
}


/**
 * SCFirstTimeUsageScreen is a data description a single
 *          FirstTimeScreen
 *
 */
struct SCFirstTimeUsageScreen {
    var sortNr : Int
    var description : String
    var imageName : String
    var header : String
    var screenNo: Int

    /**
     * Intitializer for the First Time Usage Screen
     *
     * @param sortNr
     *            sort index
     * @param description
     *            description shown on the screen
     * @param imageName
     *            name if the displayed image
     * @param header
     *            name if the header
     *
     * @return initialized object
     */
    init(sortNr: Int, description: String, imageName: String, header : String, screenNo: Int) {
        self.sortNr = sortNr
        self.description = description
        self.imageName = imageName
        self.header = header
        self.screenNo = screenNo
    }

}

class SCFirstTimeUsageVC: UIViewController, SCSlideShowViewDelegate {
    private var containerView : SCSlideShowView? = nil

    private var screenItems = [SCFirstTimeUsageScreen]()
    private var letsGoBtnTitle : String = ""
    private var skipBtnAvailable : Bool = false
    private var pageControlAvailable : Bool = false
    private var screenNo : Int = 0
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var layerView: UIView!
    @IBOutlet weak var headerLabel: SCTopAlignLabel!
    @IBOutlet weak var descriptionLabel: SCTopAlignLabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginBtn: SCCustomButton!
    @IBOutlet weak var registerBtn: SCCustomButton!
    @IBOutlet weak var letsGoBtn: SCCustomButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var loginCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerCenterXConstraint: NSLayoutConstraint!
    
    weak var delegate : SCFirstTimeUsageVCDelegate?

    //Mark: - Status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shouldNavBarTransparent = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.layerView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.layerView.addGestureRecognizer(swipeLeft)
    
        self.setupAccessibilityIDs()
        self.setupAccessibility()

        self.registerBtn.customizeBlueStyle()
        self.loginBtn.customizeBlueStyleNoBorder()
        self.letsGoBtn.customizeBlueStyleNoBorder()

        self.refreshFTUScreen()
        handleDynamicType()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicType))
    }
    
    @objc private func handleDynamicType() {
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .headline, size: 34.0, maxSize: 50.0)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
        
        registerBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        registerBtn.titleLabel?.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
        
        loginBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        loginBtn.titleLabel?.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
        
        letsGoBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        letsGoBtn.titleLabel?.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18.0, maxSize: 30.0)
        
        skipBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        skipBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: 24.0)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.loginBtn.accessibilityIdentifier = "btn_action"
        self.headerLabel.accessibilityIdentifier = "lbl_header"
        self.descriptionLabel.accessibilityIdentifier = "lbl_description"
        self.registerBtn.accessibilityIdentifier = "btn_register"
        self.letsGoBtn.accessibilityIdentifier = "btn_lets_go"
        self.skipBtn.accessibilityIdentifier = "btn_skip"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){

        self.descriptionLabel.isAccessibilityElement = true
        self.descriptionLabel.accessibilityTraits = .staticText
        self.descriptionLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.pageControl.isAccessibilityElement = true
        self.skipBtn.accessibilityElementsHidden  = self.skipBtn.isHidden
        self.skipBtn.setTitle(LocalizationKeys.SCFirstTimeUsageVC.x001WelcomeMenuBtnSkip.localized(), for: .normal)
        self.skipBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.skipBtn.accessibilityLabel = LocalizationKeys.SCFirstTimeUsageVC.x001WelcomeMenuBtnSkip.localized()

        self.headerLabel.isAccessibilityElement = true
        self.headerLabel.accessibilityTraits = .staticText
        self.headerLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.loginBtn?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.loginBtn?.accessibilityLabel = self.loginBtn.titleLabel?.text

        self.registerBtn?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.registerBtn?.accessibilityLabel = self.registerBtn.titleLabel?.text
        
        self.letsGoBtn?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.letsGoBtn?.accessibilityLabel = self.letsGoBtn.titleLabel?.text
        self.imageView.accessibilityElementsHidden = true

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if containerView == nil && self.screenItems.count > 0 {
            self.screenItems.sort {
                $0.sortNr < $1.sortNr
            }
            
            let frame = self.backView.frame
            let images = screenItems.compactMap{ UIImage(named: $0.imageName)! }
            
            self.descriptionLabel.text = self.screenItems[0].description
            self.headerLabel.text = screenItems[0].header
            self.imageView.image = UIImage(named: screenItems[0].imageName)
            self.screenNo = screenItems[0].screenNo
            
            containerView = SCSlideShowView(frame: frame, parentView: self.backView, images: images )
            containerView?.delegate = self
            containerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.headerLabel.accessibilityLabel = screenItems[0].header
            self.descriptionLabel.accessibilityLabel = screenItems[0].description
            if let container = containerView {
                self.backView.addSubview(container)
            }
//            containerView?.startAnimation()
        }
    }
    
    func addScreen(with imageName: String, description: String, header: String, screenNo: Int) {
        let screen = SCFirstTimeUsageScreen.init(sortNr: screenItems.count, description: description, imageName: imageName, header: header, screenNo: screenNo)
        
        self.screenItems.append(screen)
        
        self.refreshFTUScreen()
    }

    func setUpControlsVisibility(_ skipBtnAvailable: Bool, isPageControlAvailable: Bool) {
        self.skipBtnAvailable = skipBtnAvailable
        self.pageControlAvailable = isPageControlAvailable
        self.refreshFTUScreen()
    }
    
    func refreshFTUScreen(){
        if isViewLoaded {
            self.loginBtn.setTitle(LocalizationKeys.SCFirstTimeUsageVC.x001WelcomeBtnLogin.localized(), for: .normal)
            self.registerBtn.setTitle(LocalizationKeys.SCFirstTimeUsageVC.x001WelcomeBtnRegister.localized(), for: .normal)
            self.skipBtn.setTitle(LocalizationKeys.SCFirstTimeUsageVC.x001WelcomeMenuBtnSkip.localized() , for: .normal)
            self.letsGoBtnTitle = self.pageControl.currentPage == 2  ?  LocalizationKeys.SCFirstTimeUsageVC.x001LetsGoBtnText.localized() : LocalizationKeys.SCFirstTimeUsageVC.x001NextBtnText.localized()
            self.letsGoBtn.setTitle(self.letsGoBtnTitle, for: .normal)
            if self.letsGoBtnTitle == LocalizationKeys.SCFirstTimeUsageVC.x001LetsGoBtnText.localized() {
                self.letsGoBtn.removeTarget(self, action: #selector(self.moveToNextScreen), for: .touchUpInside)
                self.letsGoBtn.addTarget(self, action:#selector(self.moveToLoginScreen), for: .touchUpInside)
            } else {
                self.letsGoBtn.removeTarget(self, action: #selector(self.moveToLoginScreen), for: .touchUpInside)
                self.letsGoBtn.addTarget(self, action:#selector(self.moveToNextScreen), for: .touchUpInside)
            }
            self.descriptionLabel.adaptFontSize()
            self.loginBtn.titleLabel?.adaptFontSize()
            self.registerBtn.titleLabel?.adaptFontSize()
            self.skipBtn.titleLabel?.adaptFontSize()
            self.headerLabel.adaptFontSize()
            
            self.descriptionLabel.alpha = 1.0
            self.pageControl?.numberOfPages = self.screenItems.count - 1

            self.skipBtn.isHidden = !self.skipBtnAvailable
            self.pageControl.isHidden = !self.pageControlAvailable
            self.letsGoBtn.isHidden = !self.pageControlAvailable
            self.loginBtn.isHidden = !pageControl.isHidden ? true : false
            self.registerBtn.isHidden = !pageControl.isHidden ? true : false

            self.setupAccessibility()

        }
    }

    // Delegate method SCSlideShowView
    func screenWillSwitch(to imageNr : Int){
        
        self.descriptionLabel.text = screenItems[imageNr].description
        self.headerLabel.text = screenItems[imageNr].header
        self.imageView.image = UIImage(named: screenItems[imageNr].imageName)
        self.pageControl.currentPage = imageNr
        self.screenNo = screenItems[imageNr].screenNo

        self.descriptionLabel.accessibilityLabel = screenItems[imageNr].description
        self.headerLabel.accessibilityLabel = screenItems[imageNr].header
    }
    
    // delegate methods for the 
    // targets for buttons
    @IBAction func registerBtnWasPressed(_ sender: Any) {
        self.delegate?.registerBtnWasPressed()
    }
 
    @IBAction func loginBtnWasPressed(_ sender: Any) {
        self.delegate?.loginBtnWasPressed()
    }
    
    @IBAction func skipBtnWasPressed(_ sender: Any) {
        self.delegate?.skipButtonWasPressed()
    }
    
    // methods for gesture recognizer
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {

        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            if self.screenNo > 0 && self.screenNo < 3 {
                containerView?.switchToPrevious()
                self.pageControlAvailable = true
                self.refreshFTUScreen()
            }
            else{
            }

        }

        if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            if !self.skipBtnAvailable || self.screenNo > 2{
            }
            else{
                if self.screenNo < 2 {
                    self.moveToNextScreen()
                }else{
                    self.moveToLoginScreen()
                }
            }
        }
    }
    
    @objc func moveToNextScreen(){
        self.pageControlAvailable = true
        containerView?.switchToNext()
        self.refreshFTUScreen()
        UIAccessibility.post(notification: .layoutChanged, argument: skipBtn)
    }
    
    @objc func moveToLoginScreen(){
        self.animateView.isHidden = false
        self.pageControlAvailable = false
        UIView.transition(from: self.animateView, to: self.layerView, duration: 0.5, options: .transitionCrossDissolve, completion: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.screenWillSwitch(to: 3)
        self.refreshFTUScreen()
    }
}
