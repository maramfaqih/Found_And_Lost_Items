//
//  File.swift
//  FoundAndLostItems
//
//  Created by Maram F on 23/05/1443 AH.
//

import Foundation
import UIKit
struct Alert{

    static func showAlert(strTitle: String, strMessage: String, viewController: UIViewController) {
        let myAlert = UIAlertController(title: strTitle, message: strMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        viewController.present(myAlert, animated: true, completion: nil)
    }
}
