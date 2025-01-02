//
//  UIButton+BigStyle.swift
//  SmartCity
//
//  Created by Michael on 05.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

enum SCCustomButtonState {
    case disabled
    case normal
    case progress
}

class SCCustomButton: UIButton {
    
    let activityIndicator = UIActivityIndicatorView(style: .white)
    
    var textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
    
    var normalBackgroundColor: UIColor?{
        didSet {
            backgroundColor = normalBackgroundColor
        }
    }
    
    var btnState: SCCustomButtonState = .normal{
        didSet {
            
            switch btnState {
            case .disabled:
                self.isEnabled = false
                if self.activityIndicator.superview != nil{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                }
                self.setTitleColor(self.textColor, for: .normal)
                self.alpha = 0.5
            case .progress:
                self.isEnabled = false
                if self.activityIndicator.superview == nil{
                    self.addSubview(self.activityIndicator)
                }
                self.activityIndicator.startAnimating()
                self.activityIndicator.frame = self.bounds
                self.setTitleColor(self.normalBackgroundColor, for: .normal)
                self.alpha = 1.0
            default:
                self.isEnabled = true
                if self.activityIndicator.superview != nil{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                }
                self.setTitleColor(self.textColor, for: .normal)
                self.alpha = 1.0
            }
            backgroundColor = normalBackgroundColor
        }
    }

    var highlightedBackgroundColor: UIColor?
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.highlightedBackgroundColor: self.normalBackgroundColor
        }
    }

    func customizeCityColorStyle() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.backgroundColor = kColor_cityColor
        self.normalBackgroundColor = kColor_cityColor
        self.highlightedBackgroundColor = kColor_cityColor.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeBlueStyle() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
        self.normalBackgroundColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
        self.highlightedBackgroundColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")?.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeAusweisBlueStyle() {
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.backgroundColor = UIColor(named: "CLR_AUSWEIS_BLUE")
        self.normalBackgroundColor = UIColor(named: "CLR_AUSWEIS_BLUE")
        self.highlightedBackgroundColor = UIColor(named: "CLR_AUSWEIS_BLUE")?.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }
    
    func customizeBlueStyleSolidLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor =  UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = UIColor(named: "CLR_BCKGRND")!
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
        activityIndicator.color = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
    }
    
    func customizeBlueStyleLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor =  UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
        activityIndicator.color = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
    }

    func customizeWhiteStyle() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "CLR_BUTTON_BORDER_WHITE")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = UIColor(named: "CLR_BUTTON_WHITE_BCKGRND")
        self.highlightedBackgroundColor = UIColor(named: "CLR_BUTTON_WHITE_BCKGRND")?.darker()
        self.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeWhiteStyleLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "CLR_BUTTON_BORDER_WHITE")!.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor =  UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeCityColorStyleLight() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = kColor_cityColor.cgColor
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor =  kColor_cityColor
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
    }

    func customizeBlueStyleNoBorder() {
        self.clipsToBounds = true
        self.normalBackgroundColor = .clear
        self.highlightedBackgroundColor = UIColor(named: "CLR_BCKGRND")!.withAlphaComponent(0.15)
        self.textColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!
        self.setTitleColor(self.textColor, for: .normal)
        self.btnState = .normal
        activityIndicator.color = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
    }
    
    /// This method is used to set the alpha and userInteraction flag.
    /// IsEnabled flag wont work with layer
    /// - Parameter isEnable: Bool value either true / false
    func set(isEnable: Bool) {
        isUserInteractionEnabled = isEnable
        alpha = isEnable ? 1.0 : 0.3
    }
}
