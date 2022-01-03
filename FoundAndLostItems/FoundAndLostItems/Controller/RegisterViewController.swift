//
//  RegisterViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit
import Firebase
class RegisterViewController: UIViewController {
var activityIndicator = UIActivityIndicatorView()

 
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var langugeButtonOutlet: UIButton!
    {
        didSet{
            langugeButtonOutlet.setTitle(NSLocalizedString("languge", tableName: "Localizable", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var registerLabel: UILabel!
    {
        didSet{
            registerLabel.text = "registerword".localized
}
    }
    @IBOutlet weak var phoneNolabel: UILabel!
    {
        didSet{
            phoneNolabel.text = "phoneNo".localized
}
    }
    @IBOutlet weak var passwordLabel: UILabel!  {
        didSet{
            passwordLabel.text = "password".localized
}
    }
    
    @IBOutlet weak var rePasswordLabel: UILabel!  {
        didSet{
            rePasswordLabel.text = "repassword".localized
}
    }
    @IBOutlet weak var nameLblel: UILabel!
    {
        didSet{
            nameLblel.text = "name".localized
}
    }
    @IBOutlet weak var emailLabel: UILabel!
    {
        didSet{
            emailLabel.text = "email".localized
}
    }
    @IBOutlet weak var registerButtonOutlet: UIButton!
    {
        didSet{
            registerButtonOutlet.setTitle("register".localized, for: .normal)
        }
    }
    @IBOutlet weak var loginButtonOutlet: UIButton!
    {
        didSet{
            loginButtonOutlet.setTitle(NSLocalizedString("login", tableName: "Localizable", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var orLabel: UILabel!
    {
        didSet{
            orLabel.text = "or".localized
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
        
    }
    
    @IBAction func handleRegister(_ sender: Any) {
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text,
           let phoneNumber = phoneNumberTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
           password == confirmPassword {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                    
                }
                if let authResult = authResult {

                                let db = Firestore.firestore()
                                let userData: [String:String] = [
                                    "id":authResult.user.uid,
                                    "name":name,
                                    "email":email,
                                    "phoneNumber":phoneNumber,
                                ]
                    
                                db.collection("users").document(authResult.user.uid).setData(userData) { error in
                                    if let error = error {
                                        Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                                        Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                    }else {
                                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController {
                                            vc.modalPresentationStyle = .fullScreen
                                            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                            self.present(vc, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
        
        }else{
            
               
                Alert.showAlert(strTitle: "Error", strMessage: "Password confirmation doesn't match Password", viewController: self)
                       
        }
        }
    }
    


