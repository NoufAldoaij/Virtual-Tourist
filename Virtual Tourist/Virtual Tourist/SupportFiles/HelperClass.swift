//
//  HelperClass.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/24/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.
//

import Foundation
import UIKit
class HelperClass {
    
    
    func showAlert(message:String, _ viewController:UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(alert,animated: true)
    }
}

