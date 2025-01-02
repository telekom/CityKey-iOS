//
//  SCEditDateOfBirthVC.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 15/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEditDateOfBirthVC: UIViewController, SCTextfieldComponentDelegate {
    
    public var presenter: SCEditDateOfBirthPresenting!
    
    private let keyboardOffsetSpace : CGFloat = 35.0
    var keyboardHeight : CGFloat = 0.0
    
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var submitBtn: SCCustomButton!
    @IBOutlet weak var clearDOBBtn: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var constraintCurrentDOBHeight : NSLayoutConstraint!
    @IBOutlet weak var constraintClearDOBBtnHeight : NSLayoutConstraint!
    
    private var txtfldNewDOB : SCTextfieldComponent?
    private var txtfldCurrentDOB : SCTextfieldComponent?
    
    private  var activeComponent: SCTextfieldComponent?
    private var oldDOB: String?
    
    @IBOutlet weak var dayTableView: UITableView!
    @IBOutlet weak var monthTableView: UITableView!
    @IBOutlet weak var yearTableView: UITableView!
    
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearView: UIView!
    
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    
    @IBOutlet weak var dayIcon: UIImageView!
    @IBOutlet weak var monthIcon: UIImageView!
    @IBOutlet weak var yearIcon: UIImageView!
    
    @IBOutlet weak var dayContainerView: UIView!
    @IBOutlet weak var monthContainerView: UIView!
    @IBOutlet weak var yearContainerView: UIView!
    
    

    private let days = Array(1...31)
    private let months = getLocalizedMonths()
    private var years: [Int] = []
    private var selectedDay: Int?
    private var selectedMonth: String?
    private var selectedYear: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.shouldNavBarTransparent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        handleDynamicType()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicType))
        
    }

    fileprivate func setupUI() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((1900...currentYear).reversed())
        setupButtons()
        setupTableViews()
    }
    
    fileprivate func setupButtons() {
        dayView.layer.borderColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")?.cgColor
        dayView.layer.cornerRadius = 4.0
        dayView.layer.borderWidth = 1.0
        dayLbl.textColor = UIColor(named: "CLR_DOB_FONT")
        dayLbl.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 14, maxSize: 22)
        dayLbl.text = "p_003_day".localized()
        dayIcon.image = UIImage(systemName: "chevron.down")
        dayIcon.tintColor = UIColor(named: "CLR_DOB_FONT")
        
        monthView.layer.borderColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")?.cgColor
        monthView.layer.cornerRadius = 4.0
        monthView.layer.borderWidth = 1.0
        monthLbl.textColor = UIColor(named: "CLR_DOB_FONT")
        monthLbl.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 14, maxSize: 22)
        monthLbl.text = "p_003_month".localized()
        monthIcon.image = UIImage(systemName: "chevron.down")
        monthIcon.tintColor = UIColor(named: "CLR_DOB_FONT")
        
        yearView.layer.borderColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")?.cgColor
        yearView.layer.cornerRadius = 4.0
        yearView.layer.borderWidth = 1.0
        yearLbl.textColor = UIColor(named: "CLR_DOB_FONT")
        yearLbl.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 14, maxSize: 22)
        yearLbl.text = "p_003_year".localized()
        yearIcon.image = UIImage(systemName: "chevron.down")
        yearIcon.tintColor = UIColor(named: "CLR_DOB_FONT")
        
    }
    private func setupTableViews() {
        [dayTableView, monthTableView, yearTableView].forEach { tableView in
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.showsVerticalScrollIndicator = true
            tableView.layer.cornerRadius = 4.0
            tableView.separatorColor = UIColor.clear
            tableView.clipsToBounds = true
        }
        addShadowToContainerViews()
    }
    
    func addShadowToContainerViews() {
        dayContainerView.layer.cornerRadius = 4.0
        dayContainerView.clipsToBounds = true
        dayContainerView.layer.shadowColor = UIColor.black.cgColor
        dayContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dayContainerView.layer.shadowOpacity = 0.2
        dayContainerView.layer.shadowRadius = 4
        dayContainerView.layer.masksToBounds = false
        
        monthContainerView.layer.cornerRadius = 4.0
        monthContainerView.clipsToBounds = true
        monthContainerView.layer.shadowColor = UIColor.black.cgColor
        monthContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        monthContainerView.layer.shadowOpacity = 0.2
        monthContainerView.layer.shadowRadius = 4
        monthContainerView.layer.masksToBounds = false
        
        yearContainerView.layer.cornerRadius = 4.0
        yearContainerView.clipsToBounds = true
        yearContainerView.layer.shadowColor = UIColor.black.cgColor
        yearContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        yearContainerView.layer.shadowOpacity = 0.2
        yearContainerView.layer.shadowRadius = 4
        yearContainerView.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        self.presenter.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    @objc private func handleDynamicType() {
        // Setup Dynamic font for txtfldNewDOB
        txtfldNewDOB?.textField.adjustsFontForContentSizeCategory = true
        txtfldNewDOB?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldNewDOB?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldNewDOB?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldNewDOB?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldNewDOB?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for txtfldCurrentDOB
        txtfldCurrentDOB?.textField.adjustsFontForContentSizeCategory = true
        txtfldCurrentDOB?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldCurrentDOB?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldCurrentDOB?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldCurrentDOB?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldCurrentDOB?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for activeComponent
        activeComponent?.textField.adjustsFontForContentSizeCategory = true
        activeComponent?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        activeComponent?.placeholderLabel.adjustsFontForContentSizeCategory = true
        activeComponent?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        activeComponent?.errorLabel.adjustsFontForContentSizeCategory = true
        activeComponent?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for submitBtn
        submitBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        submitBtn.titleLabel?.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: 30)
        
        // Setup Dynamic font for submitBtn
        clearDOBBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        clearDOBBtn.titleLabel?.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: 30)
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.txtfldNewDOB?.accessibilityIdentifier = "tf_email"
        self.txtfldCurrentDOB?.accessibilityIdentifier = "tf_current_email"
        self.submitBtn.accessibilityIdentifier = "btn_submit"
        self.clearDOBBtn.accessibilityIdentifier = "btn_clear_dob"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility() {
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.txtfldNewDOB?.textField?.accessibilityLabel = "accessbility_new_dob".localized()
        self.txtfldNewDOB?.textField.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.dayView.accessibilityElementsHidden = true
        self.monthView.accessibilityElementsHidden = true
        self.yearView.accessibilityElementsHidden = true
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    
    /**
     *
     * Handle Keyboard
     *
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.height + keyboardOffsetSpace
        self.keyboardHeight = height
        
        self.contentScrollview.contentInset.bottom = height
        
        if self.activeComponent != nil {
            self.scrollComponentToVisibleArea(component: self.activeComponent!)
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.contentScrollview.contentInset.bottom = 0.0
    }
    
    
    /**
     *
     * Method to scroll to a component
     */
    
    func scrollComponentToVisibleArea(component: SCTextfieldComponent) {
        var navBarHeight : CGFloat = 0.0
        var aRect : CGRect = self.contentScrollview.bounds
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        aRect.size.height -= self.keyboardHeight
        aRect.size.height += navBarHeight
        let fieldPoint = CGPoint(x: 0.0 , y: component.textfieldFrame().origin.y + component.textfieldFrame().size.height)
        if !(aRect.contains(fieldPoint))
        {
            self.contentScrollview.setContentOffset(CGPoint(x:0, y:component.textfieldFrame().origin.y - aRect.size.height + keyboardOffsetSpace + component.textfieldFrame().size.height  ), animated: true)
            
        }
    }
    
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        component.resignResponder()
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        self.activeComponent = component
        self.scrollComponentToVisibleArea(component:component)
    }
    
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        self.presenter.dobFieldDidEnd()
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        self.presenter.dobFieldDidChange()
    }
    
    func datePickerDoneWasPressed() {
        self.activeComponent?.resignResponder()
    }
    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let textfield as SCTextfieldComponent:
            textfield.delegate = self
            switch segue.identifier {
            case "sgtxtfldCurrentDOB":
                self.txtfldCurrentDOB = textfield
                self.txtfldCurrentDOB?.configure(placeholder: "p_003_change_dob_old_date".localized(),
                                                 fieldType: .birthdate,
                                                 maxCharCount: 8,
                                                 autocapitalization: .none)
                self.txtfldCurrentDOB?.setEnabled(false)
                self.txtfldCurrentDOB?.initialText = self.oldDOB
                
            case "sgtxtfldNewDOB":
                self.txtfldNewDOB = textfield
                self.txtfldNewDOB?.configure(placeholder: "p_003_change_dob_new_date".localized(),
                                             fieldType: .birthdate,
                                             maxCharCount: 8,
                                             autocapitalization: .none)
                
            default:
                break
            }
        default:
            break
        }
    }
    

    @IBAction func submitBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        
        self.presenter.confirmWasPressed()
    }

    @IBAction func clearDOBBtnWasPressed(_ sender: Any) {
            
        self.activeComponent?.resignResponder()
        self.presenter.clearDOBButtonWasPressed()
    }

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }

    @IBAction func selectDayTapped(_ sender: Any) {
        if dayContainerView.isHidden {
            showTableViewContainerWithAnimation(containerView: dayContainerView)
            dayIcon.image = UIImage(systemName: "chevron.up")
        } else {
            hideTableViewConainerWithAnimation(containerView: dayContainerView)
            dayIcon.image = UIImage(systemName: "chevron.down")
        }
        [monthContainerView, yearContainerView].forEach { containerView in
            hideTableViewConainerWithAnimation(containerView: containerView)
        }
    }

    @IBAction func selectMonthTapped(_ sender: Any) {
        if monthContainerView.isHidden {
            showTableViewContainerWithAnimation(containerView: monthContainerView)
            monthIcon.image = UIImage(systemName: "chevron.up")
        } else {
            hideTableViewConainerWithAnimation(containerView: monthContainerView)
            monthIcon.image = UIImage(systemName: "chevron.down")
        }
        [dayContainerView, yearContainerView].forEach { containerView in
            hideTableViewConainerWithAnimation(containerView: containerView)
        }
    }

    @IBAction func selectYearTapped(_ sender: Any) {
        if yearContainerView.isHidden {
            showTableViewContainerWithAnimation(containerView: yearContainerView)
            yearIcon.image = UIImage(systemName: "chevron.up")
        } else {
            hideTableViewConainerWithAnimation(containerView: yearContainerView)
            yearIcon.image = UIImage(systemName: "chevron.down")
        }
        [dayContainerView, monthContainerView].forEach { containerView in
            hideTableViewConainerWithAnimation(containerView: containerView)
        }
    }

    func showTableViewContainerWithAnimation(containerView: UIView) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            containerView.isHidden = false
            containerView.transform = .identity
        }, completion: nil)
    }

    func hideTableViewConainerWithAnimation(containerView: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            containerView.isHidden = true
            containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            completion?()
        })
    }
}

extension SCEditDateOfBirthVC: SCEditDateOfBirthDisplaying {
    
    func showDobMessage(message: String) {
        self.txtfldNewDOB?.show(message: message, color: UIColor(named: "CLR_LABEL_TEXT_GREEN")! )
    }
    
    func dismissView(completion: (() -> Void)?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupUI(dob : String?){

        self.submitBtn.customizeBlueStyle()
        self.submitBtn.titleLabel?.adaptFontSize()
        self.submitBtn.setTitle("p_003_change_dob_save_btn".localized(), for: .normal)

        self.clearDOBBtn.customizeBlueStyleLight()
        self.clearDOBBtn.titleLabel?.adaptFontSize()
        self.clearDOBBtn.setTitle("p_003_change_dob_delete_dob_btn".localized(), for: .normal)

        self.oldDOB = dob
        
        if let _ = dob {
            self.txtfldCurrentDOB?.initialText  = oldDOB
        } else {
            hideCurrentDOBComponent()
            hideClearDOBBtn()
        }
    }
    
    func hideCurrentDOBComponent() {
        constraintCurrentDOBHeight.constant = 0
        self.txtfldNewDOB?.configure(placeholder: "p_001_profile_label_birthday".localized(), fieldType: .birthdate, maxCharCount: 255, autocapitalization: .none)

    }

    func hideClearDOBBtn() {
        constraintClearDOBBtnHeight.constant = 0
    }

    func setSubmitButtonState(_ state : SCCustomButtonState){
        self.submitBtn.btnState = state
    }
    
    func setClearDOBButtonState(_ state: SCCustomButtonState) {
        self.clearDOBBtn.btnState = state
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.present(viewController, animated: true, completion: nil)
    }
    
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(viewController, animated: true, completion: completion)
    }

    func dobFieldContent() -> String? {
        return self.txtfldNewDOB?.text ?? nil
    }

    func showDobError(message: String){
        self.txtfldNewDOB?.showError(message: message)
        self.txtfldNewDOB?.validationState = .wrong
    }
    
    func showDobOK() {
        self.txtfldNewDOB?.validationState = .ok
    }
    
    func hideDobError(){
        self.txtfldNewDOB?.hideError()
        self.txtfldNewDOB?.validationState = .unmarked
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SCEditDateOfBirthVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case dayTableView: return days.count
        case monthTableView: return months.count
        case yearTableView: return years.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 22)
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        
        switch tableView {
        case dayTableView:
            cell.textLabel?.text = String(days[indexPath.row])
        case monthTableView:
            cell.textLabel?.text = months[indexPath.row]
        case yearTableView:
            cell.textLabel?.text = String(years[indexPath.row])
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case dayTableView:
            selectedDay = days[indexPath.row]
            dayContainerView.isHidden = true
            dayLbl.text = String(selectedDay ?? 0)
        case monthTableView:
            selectedMonth = months[indexPath.row]
            monthContainerView.isHidden = true
            monthLbl.text = selectedMonth
        case yearTableView:
            selectedYear = years[indexPath.row]
            yearContainerView.isHidden = true
            yearLbl.text = String(selectedYear ?? 0)
        default:
            break
        }
        dayIcon.image = UIImage(systemName: "chevron.down")
        monthIcon.image = UIImage(systemName: "chevron.down")
        yearIcon.image = UIImage(systemName: "chevron.down")
        
        if let day = selectedDay, let month = selectedMonth, let year = selectedYear {
            if oldDOB == nil {
                txtfldNewDOB?.placeholderLabel.isHidden = false
                txtfldNewDOB?.text = "\(day). \(month) \(year)"
            } else {
                txtfldNewDOB?.placeholderLabel.isHidden = false
                txtfldNewDOB?.text = "\(day). \(month) \(year)"
            }
            print("Selected date: \(day)/\(month)/\(year)")
            self.presenter.dobFieldDidChange()
        }
    }
}
