//
//  SCActivityViewController.swift
//  SmartCity
//
//  Created by Michael on 19.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCActivityViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        
        // Do any additional setup after loading the view.
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.infoLabel.accessibilityIdentifier = "lbl_info"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
