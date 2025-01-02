//
//  SCDeleteAccountConfirmationProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import UIKit

protocol SCDeleteAccountConfirmationPresenting: SCPresenting {
    func setDisplay(_ display: SCDeleteAccountConfirmationDisplaying)
    func confirmButtonWasPressedWithPassword(password: String)
    func recoverPwdWasPressed()
    func passwordFieldDidBeginEditing()
    func showPasswordWasPressed()
    func passwordFieldHasText()
    func passwordFieldIsEmpty()
    func closeButtonWasPressed()
}

protocol SCDeleteAccountConfirmationDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String, backTitle: String)
    func setupRecoverLoginBtn(title: String)
    func setupPasswordField(title: String)
    func setupPasswordErrorLabel(title: String)
    func setupConfirmationButton(title: String)
    func setupTitleLabel(title: String)
    func hidePWDError()
    func showPasswordSelected(_ selected: Bool)
    func showTopLabel()
    func hideTopLabel()
    func showPasswordIncorrectLabel()
    func passwordTextfieldResignFirstResponder()
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func popToRootViewController()
    func push(viewController: UIViewController)
    func setConfirmButtonState(_ state : SCCustomButtonState)
    func confirmButtonState() -> SCCustomButtonState
    func dismiss(completion: (() -> Void)?)
}

protocol SCDeleteAccountConfirmationWorking {
    func deleteAccount(_with password: String, completion: @escaping (SCWorkerError?) -> ())
}
