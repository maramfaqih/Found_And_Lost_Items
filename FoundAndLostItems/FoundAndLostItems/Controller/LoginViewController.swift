//
//  LoginViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {


    var activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "login".localized
        }
    }
  
    @IBOutlet weak var emailLabel: UILabel!{
        didSet{
            emailLabel.text = "email".localized
        }
    }
    @IBOutlet weak var passwordLabel: UILabel!{
        didSet{
            passwordLabel.text = "password".localized
        }
    }
 
    
    
    @IBOutlet weak var loginLabel: UILabel!
    {
        didSet{
            loginLabel.text = "loginword".localized
        }

    }
    
    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            emailTextField.delegate = self

        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {   didSet{
        passwordTextField.delegate = self

    }
}
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    {
        didSet{
            loginButtonOutlet.setTitle("login".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var backGroundInfoLogin: UIView!{
        didSet{
            backGroundInfoLogin.layer.cornerRadius = 15
            backGroundInfoLogin.layer.masksToBounds = true
            backGroundInfoLogin.layer.shadowOpacity = 0.2
            backGroundInfoLogin.layer.shadowRadius = 4
            backGroundInfoLogin.layer.masksToBounds = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
     
    }
    
    @IBAction func passwordVisibilityAction(_ sender: UIButton) {

        passwordTextField.isSecureTextEntry.toggle()
           if passwordTextField.isSecureTextEntry {
               if let image = UIImage(systemName: "eye.slash") {
                   sender.setImage(image, for: .normal)
               }
           } else {
               if let image = UIImage(systemName: "eye") {
                   sender.setImage(image, for: .normal)
               }
           }
    }
    @IBAction func handleLogin(_ sender: Any) {

        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                }
                if let _ = authResult {
                  
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController {
                        vc.modalPresentationStyle = .fullScreen

                        Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                        self.present(vc, animated: true, completion: nil)
                    }

                }
            }
        }
    }
    
}
extension String {
    var localized: String {

        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
        
       
    }
}
extension UIViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


