//
//  SCDeleteAccountConfirmationPresenter+Presenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import UIKit

extension SCDeleteAccountConfirmationPresenter: SCDeleteAccountConfirmationPresenting {
    func showPasswordWasPressed(){
        self.showPwdSelected = !self.showPwdSelected
    }
    
    func passwordFieldDidBeginEditing() {
        self.display?.hidePWDError()
        self.display?.hideTopLabel()
    }
    
    func passwordFieldHasText() {
        self.display?.showTopLabel()
        self.display?.hidePWDError()
        self.display?.setConfirmButtonState(.normal)
    }
    
    func passwordFieldIsEmpty() {
        self.display?.hideTopLabel()
        self.display?.setConfirmButtonState(.disabled)
    }
    
    func setDisplay(_ display: SCDeleteAccountConfirmationDisplaying) {
        self.display = display
    }
    
    func recoverPwdWasPressed(){
        let navCtrl = UINavigationController()
        guard let profile = getUserProfile() else {
            return
        }
        navCtrl.viewControllers = [self.loginInjector.getForgottenViewController(email: profile.email, completionOnSuccess: { (email, emailWasAlreadySentBefore, isError, errorMessage) in
            navCtrl.dismiss(animated: true, completion: {
                let confirmViewController = self.loginInjector.getRegistrationConfirmEMailVC(registeredEmail:email, shouldHideTopImage: false, presentationType: emailWasAlreadySentBefore ? .confirmMailSentBeforeRegistration : .confirmMailForPWDReset,isError: isError, errorMessage: errorMessage, completionOnSuccess: {
                    self.presentedVC?.dismiss(animated: true, completion:{})
                    self.presentedVC = nil
                })
                self.presentedVC = confirmViewController
                self.display?.presentOnTop(viewController: confirmViewController, completion: nil)
            })
        })]

        self.display?.presentOnTop(viewController: navCtrl, completion: nil)
    }
    
    func confirmButtonWasPressedWithPassword(password: String) {
        self.display?.passwordTextfieldResignFirstResponder()
        guard passwordFulfillsCriteria(password) else {
            return
        }
        if authProvider.isUserLoggedIn() {
            guard getUserProfile() != nil else { return }
            self.display?.setConfirmButtonState(.progress)
            self.worker.deleteAccount(_with: password, completion: {
                [weak self] error in
                self?.display?.setConfirmButtonState(.disabled)
                
                if error != nil {
                    switch error {
                    case .noInternet:
                        self?.display?.showErrorDialog(error!, retryHandler: nil)
                        return

                    case .fetchFailed(let errorDetail):
                        if errorDetail.errorCode == "delete.password.wrong" {
                            let errorString = errorDetail.message.localized()
                            self?.display?.setupPasswordErrorLabel(title: errorString)
                            self?.display?.showPasswordIncorrectLabel()
                        } else {
                            self?.display?.showErrorDialog(with: "d_004_delete_account_error_info1".localized(), retryHandler: { self?.confirmButtonWasPressedWithPassword(password: password)}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                        }
                    default:
                        break
                    }
                } else {
                    self?.showSuccessScreen()
                }
            })
        }
    }
    
    private func showSuccessScreen() {
        let deleteAccountSuccessViewController = self.injector.getDeleteAccountSuccessController()
        self.display?.push(viewController: deleteAccountSuccessViewController)
    }
}

extension SCDeleteAccountConfirmationPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
        self.subscribeToLogoutNotification()
        self.display?.setConfirmButtonState(.disabled)
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: LocalizationKeys.DeleteAccountConfirmation.d002DeleteAccountValidationTitle.localized(),
                                         backTitle: "")
        self.display?.setupRecoverLoginBtn(title: LocalizationKeys.DeleteAccountConfirmation.l001LoginBtnForgotPassword.localized())
        self.display?.setupPasswordField(title: LocalizationKeys.DeleteAccountConfirmation.l001LoginHintPassword.localized())
        self.display?.setupConfirmationButton(title: LocalizationKeys.DeleteAccountConfirmation.d002DeleteAccountValidationButtonText.localized())
        self.display?.setupTitleLabel(title: LocalizationKeys.DeleteAccountConfirmation.d002DeleteAccountValidationInfo.localized())
    }
}
