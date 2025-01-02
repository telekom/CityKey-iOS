//
//  SCPrivacySettingsOptionView.swift
//  OSCA
//
//  Created by Bharat Jagtap on 29/06/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class AccessibilityUiSwitch: UISwitch {
    override var accessibilityValue: String? {
        get {
            return isOn ? "Setting On" : "Setting Off"
        }
        set {
            self.accessibilityValue = newValue
        }
    }
}

class SCPrivacySettingsOptionView: UIView {
    
    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var expandCollapseButton: UIButton!
    var permissionSwitch: AccessibilityUiSwitch!
    
    
    private var isExpanded : Bool = false {
        
        didSet {
            expandCollapseDescriptionText()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {

        
        
        // iconImageView
        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        
        addConstraint(NSLayoutConstraint(item: iconImageView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 12.0))
        
        // permission Switch
        permissionSwitch = AccessibilityUiSwitch()
        permissionSwitch.translatesAutoresizingMaskIntoConstraints = false
        permissionSwitch.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        addSubview(permissionSwitch)
        
        addConstraint(NSLayoutConstraint(item: permissionSwitch!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15))
        addConstraint(NSLayoutConstraint(item: permissionSwitch!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 12.0))
        permissionSwitch.addConstraint(NSLayoutConstraint(item: permissionSwitch!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 49))
        permissionSwitch.addConstraint(NSLayoutConstraint(item: permissionSwitch!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 31))
        permissionSwitch.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // titleLabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 70.0))
        addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 12.0))
        addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: .trailing, relatedBy: .equal, toItem: permissionSwitch, attribute: .leading, multiplier: 1.0, constant: -40))
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // descriptionLabel
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        addConstraint(NSLayoutConstraint(item: descriptionLabel!, attribute: .leading, relatedBy: .equal, toItem: titleLabel!, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: descriptionLabel!, attribute: .trailing, relatedBy: .equal, toItem: titleLabel!, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: descriptionLabel!, attribute: .top, relatedBy: .equal, toItem: titleLabel!, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        // expandCollapseButton
        expandCollapseButton = UIButton(type: .roundedRect)
        expandCollapseButton.setTitle("Expand", for: .normal)
        expandCollapseButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(expandCollapseButton)
        
        addConstraint(NSLayoutConstraint(item: expandCollapseButton!, attribute: .leading, relatedBy: .equal, toItem: descriptionLabel!, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: expandCollapseButton!, attribute: .top, relatedBy: .equal, toItem: descriptionLabel!, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        expandCollapseButton.addConstraint(NSLayoutConstraint(item: expandCollapseButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20))
        
        // seperatorLine
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)
        addConstraint(NSLayoutConstraint(item: separatorLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: separatorLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: separatorLine, attribute: .top, relatedBy: .equal, toItem: expandCollapseButton!, attribute: .bottom, multiplier: 1.0, constant: 10.0))
        separatorLine.addConstraint(NSLayoutConstraint(item: separatorLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0))
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: separatorLine, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expandCollapseClicked(_:)))
        addGestureRecognizer(tapGesture)
    
        
        // All Customizations ( setupUI )
        
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 3
        self.iconImageView.image = UIImage(named: "icon_tools_required_data_privacy")
        self.titleLabel.text = "Erforderliche Tools"
        self.descriptionLabel.text = "Sie ermöglichen Grundfunktionen, wie das Versenden von Push-Nachrichten im Zusammenhang mit Funktionalität der App, und den Zugriff auf gesicherte Bereiche der App. Zudem dienen sie der anonymen Auswertung des Nutzerverhaltens, die von uns verwendet werden, um unsere App stetig für Sie weiterzuentwickeln.\nWeniger erfahren"
        self.expandCollapseButton.setTitle(LocalizationKeys.DataPrivacySettings.dialogDpnSettingsShowMoreBtn.localized(),
                                           for: .normal)
        self.permissionSwitch.isOn = true
        expandCollapseButton.addTarget(self, action: #selector(expandCollapseClicked(_:)), for: .touchUpInside)
        separatorLine.backgroundColor = UIColor(named: "CLR_SEPARATOR")!
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        titleLabel.textColor = UIColor.labelTextBlackCLR
        descriptionLabel.font = UIFont.systemFont(ofSize: 12.0)
        descriptionLabel.textColor = UIColor.labelTextBlackCLR
        expandCollapseButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        expandCollapseButton.setTitleColor(UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")!, for: .normal)
        self.backgroundColor = UIColor.clearBackground
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .caption1, size: 12, maxSize: nil)
      
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .caption1, size: 12, maxSize: nil)

        expandCollapseButton.titleLabel?.adjustsFontForContentSizeCategory = true
        expandCollapseButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .caption1, size: 12, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)

    }
    
    
    @IBAction func expandCollapseClicked(_ sender: Any) {
        
        isExpanded = !isExpanded
    }
    
    private func expandCollapseDescriptionText() {
        
        if isExpanded {
            expandCollapseButton.setTitle(LocalizationKeys.DataPrivacySettings.dialogDpnSettingsShowLessBtn.localized(),
                                          for: .normal)
            descriptionLabel.numberOfLines = 0
            
        } else {
            expandCollapseButton.setTitle(LocalizationKeys.DataPrivacySettings.dialogDpnSettingsShowMoreBtn.localized(),
                                          for: .normal)
            descriptionLabel.numberOfLines = 3
        }
    
        setNeedsLayout()
    }
    
    override var intrinsicContentSize: CGSize {
        return self.bounds.size
    }
    
    override func prepareForInterfaceBuilder() {
        invalidateIntrinsicContentSize()
    }
}
