//
//  personalInfoViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 24/05/1443 AH.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingNavigationController") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch  {
            Alert.showAlert(strTitle: "ERROR in signout", strMessage: error.localizedDescription, viewController: self)
        }
    }
    

}
