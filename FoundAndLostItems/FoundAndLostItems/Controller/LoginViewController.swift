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
            navBarTitle.title = "titleApp".localized
        }
    }
    @IBOutlet weak var LanguageButtonOutlet: UIBarButtonItem!{
        didSet{
            self.LanguageButtonOutlet.title = "language".localized
           
        }}
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
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    {
        didSet{
            loginButtonOutlet.setTitle(NSLocalizedString("login", tableName: "Localizable", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet weak var registerButtonOutlet: UIButton!{
        didSet{
            registerButtonOutlet.setTitle("register".localized, for: .normal)
        }
    }
    
    @IBOutlet weak var orLabel: UILabel!
    {
        didSet{
            orLabel.text = "or".localized
        }

    }
    
    @IBOutlet weak var loginLabel: UILabel!
    {
        didSet{
            loginLabel.text = "loginword".localized
        }

    }
    
 
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
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
    
    @IBAction func changeLanguageButton(_ sender: UIBarButtonItem) {

        
            var lang = ""
            
            if let userDefaultLang = UserDefaults.standard.string(forKey: "currentLanguage"){
              lang = userDefaultLang
                print("userDefaultLang:",userDefaultLang)
            }
         
            
        print("uuuuu Lang:",lang)
             if lang == "en" {
                
                
                 lang = "ar"
                 print("set Lang:",lang)
                 Bundle.setLanguage(lang)
                 UserDefaults.standard.set(lang, forKey: "currentLanguage")
                 UIView.appearance().semanticContentAttribute = .forceRightToLeft

            }else{
                
                
                
                lang = "en"
                print("set Lang2:",lang)
                Bundle.setLanguage(lang)
                UserDefaults.standard.set(lang, forKey: "currentLanguage")
                UIView.appearance().semanticContentAttribute = .forceLeftToRight

            }
           
          

        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()

    

}
}
}
extension String {
    var localized: String {

        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
        
       
    }
}
