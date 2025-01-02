//
//  SCAusweisAuthWorker.swift
//  OSCA
//
//  Created by Bharat Jagtap on 23/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

/**
 Protocol that sets the expectations from a AuthWorker object
 */
protocol SCAusweisAuthWorking : AnyObject {
    
    /**
            inititalises the Worker object with the tcTokenURL retrieved from the web
     */
    init(tcTokenURL : String)
    
    /**
            starts the Authentication workflow
     */
    func startAuth()
    /**
            cancels the authentication workflow
     */
    func cancelOrFinishAuth()
    /**
            to pass in the message received from the handler. Worker would decide on what screen to render based on the message .
     */
    func messageReceived(message : SCAusweisMessage)
    
    /**
            worklow presenter that helps render different screens in the workflow.
     */
    var workflowPresenter : SCAusweisAuthWorkflowPresenting? { get set}
    
    /**
            state of different objects received in the workflow.
     */
    var state : SCAusweisAuthState { get }
    
    // from Individual Workflow Step Controller
    /**
            triggered when user accepts/reviews  the certiicate and access rights data and is ready to enter the PIN
     */
    func onAcceptCertificate() // Triggered from the Servie Overview Presenter

    /**
            when user submits the PIN of the card
     */
    func onSubmitPIN(pin : String) // triggered from the Enter Pin View Presenter
    
    
    /**
            when user reads why CAN is required next and is ready to enter CAN in next step
     */
    func onSubmitCANInfoRead() // triggered from the Need CAN View Presenter
    
    /**
            when user submits the CAN of the CARD
     */
    func onSubmitCAN(can : String) // triggered from Enter CAN View Presenter

    /**
            when user reads why PUK is required and is ready to enter PUK in next step
     */
    func onSubmitPUKInfoRead() // triggered from Need PUK View Presenter
    /**
            when user submits the PUK of the CARD
     */
    func onSubmitPUK(puk : String) // triggered from the Enter PUK View Presenter

    /**
            when the workflow succeds
     */
    func onSuccess() // triggered from the Success View Presenter
    
    /**
            when user wants to navigate to service provider details screen from the Service overview screen
     */
    func onServiceOverviewMoreInfoClicked() // triggered from Service Overview Presenter
    
    /**
            when user clicks general help button available at different places in the workflow where they would enter PIN, CAN or PUK
     */
    func onEnterPinHelpClicked() // triggered from the screens where user enters PIN , CAN or PUK

    /**
            if workflow fails for some reason , user can restart it from the Failure screen
     */
    func restartWorkflow() // triggered from the screens where user enters PIN , CAN or PUK
    
    /**
            if users eid card is blocked due to serveral wrong PIN,CAN or PUK entries , user will be shown a screen accordingly with the information for the same . User will click ok and this method will be triggered
     */
    func onCardblockedOkClicked()
    /**
            clears the storted PIN, CAN or PUK from the memory. To be called when a workflow is restarted .
     */
    func clearPinCanPukStoredState()
}

/**
 **SCAusweisAuthWorker** has got few important responsibilities in the whole ausweis workflow
    1. AutWorker is the single worker that provides data to all the presenters in the workflow. It also received method calls from all the presenters.
    2. AuthWorker , based on different messages it receives, it communicates to the WorkFlowPresneter in order to display different screen
    3. It also maintains the state of the workflow with respect to different messages and the PIN,CAN & PUK entered by the user in the flow
 */

class SCAusweisAuthWorker  {
    var tcTokenURL : String
    var handler : SCAusweisAppSDKServiceHandling?
    weak var workflowPresenter: SCAusweisAuthWorkflowPresenting?
    var state : SCAusweisAuthState = SCAusweisAuthState()
    
    
    var submitPinCompletionClosure : ((_ success : Bool, _ model : SCModelAusweisEnterPin?) -> ())?

    
    required init(tcTokenURL: String) {
        self.tcTokenURL = tcTokenURL        
    }
}

extension SCAusweisAuthWorker : SCAusweisAuthWorking {
        
    func startAuth() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> startAuth", withTag: .ausweis)
        let cmd : SCAusweisCommand = .RUN_AUTH(tcTokenURL: self.tcTokenURL)
        handler?.sendCommand(command: cmd)
        self.state.lastCommand = cmd
        workflowPresenter?.showAusweisLoading()
    }
    
    func cancelOrFinishAuth() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> cancelOrFinishAuth", withTag: .ausweis)
        let cmd = SCAusweisCommand.CANCEL
        self.state.lastCommand = cmd
        handler?.sendCommand(command: cmd)
    }
    
    func interruptCurrentSystemDialog() {
        let cmd : SCAusweisCommand = .INTERRUPT
        self.handler?.sendCommand(command: cmd)
    }

    func messageReceived(message : SCAusweisMessage) {
        
        debugPrint("Worker Message Received : \(message)")
        SCFileLogger.shared.write("SCAusweisAuthWorker -> messageReceived (\(message.payload())", withTag: .ausweis)
        switch message {
        case .AUTH(let payload):
            
            DispatchQueue.main.async {
                /// if payload contains error field then there is an error that has occured , we are not currently showing what exact error occured but it would be good to log it somewhere for debugging
                if let _ = payload["error"] as? String {
                    self.workflowPresenter?.showAusweisError(.payloadError)
                }
                /// when user cancels the iOS dialog that popsup while NFC session is trying to read the card then Ausweis adds #error at the end of major value.
                /// Note : this payload still contains the 'url' value that seems like a success response but we do need to check for #error in major
                /// if there is an error then we retrive the reason from 'description' and 'message' fields from the result payload
                else if (payload["result"] as? [String:String])?["major"]?.contains("#error") ?? false {
                    
                    let description = (payload["result"] as? [String:String])?["description"]
                    let message = (payload["result"] as? [String:String])?["message"]
                    self.state.authWorkflowError = SCAusweisAuthState.AuthWorkflowErrorState(authReStarted: false, authErrorMessage: message, authErrorDescription: description)
                    self.workflowPresenter?.showAusweisError(.majorError)
                }
                /// if both of the above two cases are invalid then the url we get in the payload seems to be the final success url
                else if let url = payload["url"] as? String {
                    self.state.finalURL = url
                    self.workflowPresenter?.showAusweisSuccess()
                } else {
                    self.state.isAuthenticationStarted = true
                }
            }
            return
            
        case .ACCESS_RIGHTS( _ , let accessRights):
            self.state.accessRights = accessRights
            DispatchQueue.main.async {
                if self.state.isAuthenticationStarted {
                    let cmd : SCAusweisCommand = .GET_CERTIFICATE
                    self.state.lastCommand = cmd
                    self.handler?.sendCommand(command: cmd)
            
                } else {
                    self.workflowPresenter?.showAusweisError(.accessRightsError)
                }
            }
            return
            
        case .CERTIFICATE( _ , let certificate):
            self.state.certificate = certificate
            DispatchQueue.main.async {
                self.workflowPresenter?.showAusweisOverview()
            }
            return

        case .INSERT_CARD( _ ):
            DispatchQueue.main.async {
                self.workflowPresenter?.showAusweisInsertCardView()
            }
            return

        case .READER( _ , let reader) :
            
            debugPrint("AuthWorker : reader model Received \(String(describing: reader))")
            if ( reader?.card?.deactivated ?? false ) || ( reader?.card?.inoperative ?? false ) {
                
                DispatchQueue.main.async {
                    self.workflowPresenter?.showAusweisCardBlockedView()
                }
            }
            return
        
        case .ENTER_PIN( _ , let enterPinModel):

            debugPrint("AuthWorker : enterPinModel Received \(String(describing: enterPinModel))")
            interruptCurrentSystemDialog()
            self.state.enterCan = nil
            self.state.enterPuk = nil

            self.state.enterPin = SCAusweisAuthState.EnterPinState(pinModel: enterPinModel, pinSubmitted: self.state.enterPin?.pinSubmitted)
            
            DispatchQueue.main.async {
                self.workflowPresenter?.showAusweisEnterPIN()
            }
            
        case .ENTER_CAN( _ , let enterCanModel):

            debugPrint("AuthWorker : enterCanModel Received \(String(describing: enterCanModel))")
            interruptCurrentSystemDialog()
            self.state.enterPin = nil
            self.state.enterPuk = nil
            
            self.state.enterCan = SCAusweisAuthState.EnterCanState(canModel: enterCanModel, canSubmitted: self.state.enterCan?.canSubmitted)

            DispatchQueue.main.async {
            
                if self.state.lastCommand?.cmd() != SCAusweisCommand.SET_CAN(can: "").cmd() {
                    self.workflowPresenter?.showAusweisNeedCAN()
                } else {
                    self.workflowPresenter?.showAusweisEnterCAN()
                }
            }

        case .ENTER_PUK( _ , let enterPukModel):

            debugPrint("AuthWorker : enterPukModel Received \(String(describing: enterPukModel))")
            interruptCurrentSystemDialog()
            self.state.enterPin = nil
            self.state.enterCan = nil
            
            self.state.enterPuk = SCAusweisAuthState.EnterPukState(pukModel: enterPukModel, pukSubmitted: self.state.enterPuk?.pukSubmitted)

            DispatchQueue.main.async {
            
                if self.state.lastCommand?.cmd() != SCAusweisCommand.SET_PUK(puk: "").cmd() {
                    self.workflowPresenter?.showAusweisNeedPUK()
                } else {
                    self.workflowPresenter?.showAusweisEnterPUK()
                }
            }

        case .BAD_STATE( _ ):
           
            DispatchQueue.main.async {
                self.workflowPresenter?.showAusweisError(.badStateError)
            }
            return
            
        case .MESSAGE_ERROR :
            
            DispatchQueue.main.async {
                self.workflowPresenter?.showAusweisError(.messageError)
            }
            return

        case .STATUS:
            // in progress
            return
        }
    }

    func onAcceptCertificate() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onAcceptCertificate", withTag: .ausweis)
        let cmd = SCAusweisCommand.ACCEPT
        self.state.lastCommand = cmd
        handler?.sendCommand(command: cmd )
    }

    func onSubmitPIN(pin : String ) {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onSubmitPIN", withTag: .ausweis)
        self.state.enterPin = SCAusweisAuthState.EnterPinState(pinModel: nil, pinSubmitted: pin)
        let cmd = SCAusweisCommand.SET_PIN(pin: pin)
        self.state.lastCommand = cmd
        handler?.sendCommand(command: cmd)
    }
    
    func onSubmitCANInfoRead() {
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onSubmitCANInfoRead", withTag: .ausweis)
        self.workflowPresenter?.showAusweisEnterCAN()
    }
    
    func onSubmitCAN(can : String) {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onSubmitCAN", withTag: .ausweis)
        self.state.enterCan = SCAusweisAuthState.EnterCanState(canModel: nil, canSubmitted: can)
        let cmd = SCAusweisCommand.SET_CAN(can: can)
        self.state.lastCommand = cmd
        handler?.sendCommand(command: cmd)
    }
    
    func onSubmitPUKInfoRead() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onSubmitPUKInfoRead", withTag: .ausweis)
        self.workflowPresenter?.showAusweisEnterPUK()
    }
    
    func onSubmitPUK(puk : String) {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onSubmitPUK", withTag: .ausweis)
        self.state.enterPuk = SCAusweisAuthState.EnterPukState(pukModel: nil, pukSubmitted: puk)
        let cmd = SCAusweisCommand.SET_PUK(puk: puk)
        self.state.lastCommand = cmd
        handler?.sendCommand(command: cmd)
    }
    
    func onSuccess() {
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onSuccess", withTag: .ausweis)
        if let finalURL = self.state.finalURL {
            SCFileLogger.shared.write("SCAusweisAuthWorker -> onSuccess withFinalURL \(finalURL)", withTag: .ausweis)
            debugPrint("Worker : onSuccess() finalURL : \(finalURL)")
            workflowPresenter?.finishWithSuccess(url: finalURL)
        }
    }
    
    func onServiceOverviewMoreInfoClicked() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onServiceOverviewMoreInfoClicked", withTag: .ausweis)
        workflowPresenter?.showAusweisServiceDetailInfo()
    }
    
    func onEnterPinHelpClicked() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onEnterPinHelpClicked", withTag: .ausweis)
        workflowPresenter?.showAusweisEnterPINHelpView()
    }
    
    func restartWorkflow() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> restartWorkflow", withTag: .ausweis)
        self.cancelOrFinishAuth()
        self.startAuth()
    }
    
    func onCardblockedOkClicked() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> onCardblockedOkClicked", withTag: .ausweis)
        self.cancelOrFinishAuth()
        workflowPresenter?.handleWorkflowCloseButton()
    }
    
    func clearPinCanPukStoredState() {
        
        SCFileLogger.shared.write("SCAusweisAuthWorker -> clearPinCanPukStoredState", withTag: .ausweis)
        self.state.enterPin = nil
        self.state.enterCan = nil
        self.state.enterPuk = nil
        self.state.authWorkflowError = nil
    }
}

/**
 **SCAusweisAuthState** holds the state of the workflow for various things
 * `lastCommand` : holds the last command that was sent to handler
 *  `certificate` : holds the certificate model object that was receiced as the part of the auth workflow
 *  `accessRights` : holds the access rights model object that was receied as the part of the auth workflow
 *  `finalURL` : final  url receiced after the workflow finishes successfully
 *  `enterPin` : holds the SCModelAusweisEnterPin model received as ENTER_PIN message. Also holds the PIN that was entered by the user and was sent into the last SET_PIN command
 *  `enterCan` : holds the SCModelAusweisEnterCan model received as ENTER_CAN message. Also holds the can that was entered by the user and was sent into the last SET_CAN command
 *  `enterPuk` : holds the SCModelAusweisEnterPuk model received as ENTER_PUK message. Also holds the puk that was entered by the user and was sent into the last SET_PUK command

 */
class SCAusweisAuthState {
    
    /// indicates if the authentication is stared but not actively used
    var isAuthenticationStarted : Bool = false
    
    /// holds the last command that was sent to handler
    var lastCommand : SCAusweisCommand?
    
    /// holds the certificate model object that was received as a part of the auth workflow
    var certificate : SCModelAusweisCertificate?
    
    /// holds the access rights model object that was recevied as a part of the auth workflow
    var accessRights : SCModelAusweisAccessRights?
    
    /// final  url receiced after the workflow finishes successfully
    var finalURL : String?
    
    /// holds the SCModelAusweisEnterPin model received with ENTER_PIN message. It also holds the PIN that was entered by the user and was sent into the last SET_PIN command
    var enterPin : EnterPinState?
    struct EnterPinState {
        var pinModel : SCModelAusweisEnterPin?
        var pinSubmitted : String?
    }
    
    /// holds the SCModelAusweisEnterCan model received with ENTER_CAN message. It also holds the CAN that was entered by the user and was sent into the last SET_CAN command
    var enterCan : EnterCanState?
    struct EnterCanState{
        var canModel : SCModelAusweisEnterCan?
        var canSubmitted : String?
    }
    
    /// holds the SCModelAusweisEnterPuk model received as ENTER_PUK message. It also holds the PUK that was entered by the user and was sent into the last SET_PUK command
    var enterPuk : EnterPukState?
    struct EnterPukState {
        var pukModel : SCModelAusweisEnterPuk?
        var pukSubmitted : String?
    }
    
    /// holds the error message and authStatedFlag to manipulate the SCAusweisAuthFailure screen messages
    var authWorkflowError : AuthWorkflowErrorState?
    struct AuthWorkflowErrorState {
        var authReStarted : Bool
        var authErrorMessage : String?
        var authErrorDescription : String?
    }
}
