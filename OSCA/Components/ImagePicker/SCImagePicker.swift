//
//  SCImagePicker.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 19/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

public protocol SCImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
    func cancelSelection()

}

public protocol SCImagePicking {
    
    func present(from sourceView: UIView)
}

open class SCImagePicker: NSObject , SCImagePicking {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: SCImagePickerDelegate?
    
    
    private var phPickerController : UIViewController!
    
    fileprivate init(presentationController: UIViewController, delegate: SCImagePickerDelegate) {
        
        self.pickerController = UIImagePickerController()
        super.init()
        
        if #available(iOS 14.0, *) {
            self.setupPhPickerController()
        }
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    @available(iOS 14, *)
    private func  setupPhPickerController() {
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        self.phPickerController = PHPickerViewController(configuration: config)
        (self.phPickerController as! PHPickerViewController).delegate = self
        
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        if #available(iOS 14.0, *) {
            if type == .photoLibrary  {
                return UIAlertAction(title: title, style: .default) { [unowned self] _ in
                    self.presentationController?.present(self.phPickerController, animated: true)
                    debugPrint("Presenting PHPickerViewController")
                }
            } else if type == .savedPhotosAlbum {
                return nil
            }
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            
            if type == .camera {

                checkCameraAccessPermission {
                    DispatchQueue.main.async {
                        self.pickerController.sourceType = type
                        self.presentationController?.present(self.pickerController, animated: true)
                    }
                } onDenied: {
                    DispatchQueue.main.async {
                        showNavigateToSettingsAlert(title: "dr_camera_permission_denied_error_dialog_title".localized(), message: "dr_camera_permission_denied_error_dialog_message".localized() )
                    }
                }
                
            } else if type == .photoLibrary || type == .savedPhotosAlbum {
                
                checkPhotosAccessPermission {
                    DispatchQueue.main.async {
                        self.pickerController.sourceType = type
                        self.presentationController?.present(self.pickerController, animated: true)
                    }
                    
                } onDenied: {
                    DispatchQueue.main.async {
                        showNavigateToSettingsAlert(title: "dr_photos_permission_denied_error_dialog_title".localized(), message: "dr_photos_permission_denied_error_dialog_message".localized() )
                    }
                }
            }
        }
    }
    
    func checkCameraAccessPermission(onSuccess successBlock: @escaping () -> (), onDenied deniedBlock: @escaping () -> () ) {
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            successBlock();
        } else if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied {
            deniedBlock();
        } else if AVCaptureDevice.authorizationStatus(for: .video) ==  .restricted {
            deniedBlock();
        } else if AVCaptureDevice.authorizationStatus(for: .video) ==  .notDetermined {
        
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    successBlock();
                } else {
                    deniedBlock();
                }
            })
        }
    }
    
    func checkPhotosAccessPermission(onSuccess successBlock: @escaping () -> (), onDenied deniedBlock: @escaping () -> () ) {
        
        if #available(iOS 14.0, *) {
            if PHPhotoLibrary.authorizationStatus() == .limited {
                successBlock();
                return
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            successBlock();
            
        } else if PHPhotoLibrary.authorizationStatus() == .denied {
            deniedBlock();
            
        } else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            
            PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus)in
                switch status{
                case .denied:
                    deniedBlock();
                case .authorized:
                    successBlock();
                case .limited:
                    successBlock();
                default:
                    break
                }
            })
        } else {
            deniedBlock();
        }
    }
    
    func showNavigateToSettingsAlert(title : String , message : String) {

        let alertController = UIAlertController(title: title , message: message, preferredStyle: .alert)

        alertController.addAction(
            
            UIAlertAction(title: "dr_004_ok_button".localized(), style: .default, handler: { action  in
                
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                
            })
        )

        alertController.addAction(
            
            UIAlertAction(title: "accessibility_btn_cancel".localized(), style: .cancel, handler: nil)
        )
        
        presentationController?.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: "dr_003_defect_image_option_title".localized(), message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera,
                                    title: "dr_003_defect_image_option_take_photo".localized()) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary,
                                    title: "dr_003_defect_image_option_photo_library".localized()) {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .savedPhotosAlbum,
                                    title: "dr_003_defect_image_option_camera_roll".localized()) {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "c_001_cities_dialog_gps_btn_cancel".localized(), style: .cancel) { (action:UIAlertAction!) in
            self.delegate?.cancelSelection()
        })
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
//        self.delegate?.didSelect(image: image)
        self.checkIfImageSizeAllowed(image)
    }
    
    public static func instance(presentationController: UIViewController, delegate: SCImagePickerDelegate) -> SCImagePicking {
        
        return SCImagePicker(presentationController: presentationController, delegate: delegate)
        
        //        if #available(iOS 14.0, *) {
        //            return SCPHImagePicker(presentationController: presentationController, delegate: delegate)
        //        } else {
        //            return SCImagePicker(presentationController: presentationController, delegate: delegate)
        //        }
    }
    
    func checkIfImageSizeAllowed(_ image: UIImage?){
        if image != nil{
            let imageData = image?.jpegData(compressionQuality: 1.0)!
            let imageSize = Double(imageData!.count) / 1024 / 1024

            if imageSize > 0 && imageSize < 30{
                self.delegate?.didSelect(image: image)
            }else{
                self.delegate?.cancelSelection()
                SCUtilities.topViewController().showUIAlert(with: "dr_003_defect_image_file_too_large".localized(), cancelTitle: "dr_003_dialog_button_ok".localized(), retryTitle: nil, retryHandler: nil, additionalButtonTitle: nil, additionButtonHandler: nil, alertTitle: "dr_003_defect_submission_error_title".localized())
            }
        }else{
            self.delegate?.cancelSelection()
        }
    }
    
}



extension SCImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension SCImagePicker: UINavigationControllerDelegate {
    
    
}

@available(iOS 14, *)
extension SCImagePicker : PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        debugPrint("SCPHImagePicker image pickup callback")
        picker.dismiss(animated: true, completion: nil)
        
        if let resultItem = results.first {
            resultItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        debugPrint("SCPHImagePicker did Select Image")
                        self?.checkIfImageSizeAllowed(image)
                    }
                }
            })
        }else{
            self.delegate?.cancelSelection()
        }
    }
}
