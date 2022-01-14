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
    var allowConnection : Bool?
    @IBOutlet weak var allowContactLabel: UILabel!{
        didSet{
            allowContactLabel.text = "allowContact".localized
        }
    }
    
    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized
        }
    }
    @IBOutlet weak var LanguageButtonOutlet: UIBarButtonItem!{
        didSet{
            self.LanguageButtonOutlet.title = "language".localized
        }}
       
    @IBOutlet weak var nameTextField: UITextField!{
        didSet{
            nameTextField.delegate = self

        }
    
    }
    
    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            emailTextField.delegate = self

        }
    
    }
    
    @IBOutlet weak var passwordTextField: UITextField!{
        didSet{
            passwordTextField.delegate = self

        }
    
    }
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!{
        didSet{
            confirmPasswordTextField.delegate = self

        }
    
    }
    
    @IBOutlet weak var phoneNumberTextField: UITextField! { didSet{
        phoneNumberTextField.delegate = self

    }
}
    @IBOutlet weak var langugeButtonOutlet: UIButton!
    {
        didSet{
            langugeButtonOutlet.setTitle(NSLocalizedString("language", tableName: "Localizable", comment: ""), for: .normal)
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
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
      
        
    }
    
    @IBAction func contactSwitch(_ sender: UISwitch) {
        if (sender.isOn == true){
            allowConnection = true
         }
         else{
             allowConnection = false
         }
    }
    @IBAction func handleRegister(_ sender: Any) {
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text,
           let phoneNumber = phoneNumberTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
           let allowConnection = self.allowConnection,
           password == confirmPassword {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                    
                }
                if let authResult = authResult {

                                let db = Firestore.firestore()
                                let userData: [String:Any] = [
                                    "id":authResult.user.uid,
                                    "name":name,
                                    "email":email,
                                    "phoneNumber":phoneNumber,
                                    "allowConnection" : allowConnection
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
    @IBAction func rePasswordVisibilityAction(_ sender: UIButton) {

        confirmPasswordTextField.isSecureTextEntry.toggle()
           if confirmPasswordTextField.isSecureTextEntry {
               if let image = UIImage(systemName: "eye.slash") {
                   sender.setImage(image, for: .normal)
               }
           } else {
               if let image = UIImage(systemName: "eye") {
                   sender.setImage(image, for: .normal)
               }
           }
    }

    @IBAction func changeLanguageButton(_ sender: UIBarButtonItem) {
       
        var lang = UserDefaults.standard.string(forKey: "currentLanguage")
         if lang == "ar" {
             Bundle.setLanguage(lang ?? "ar")
             UIView.appearance().semanticContentAttribute = .forceRightToLeft
            lang = "en"
             
        }else{

            Bundle.setLanguage(lang ?? "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            lang = "ar"
        }
      
        
          UserDefaults.standard.set(lang, forKey: "currentLanguage")
          let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
          if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let sceneDelegate = windowScene.delegate as? SceneDelegate {
              sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
        
   

    }
}

    }
    


