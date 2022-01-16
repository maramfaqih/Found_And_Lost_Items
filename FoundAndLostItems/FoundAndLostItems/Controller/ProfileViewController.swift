//
//  personalInfoViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 24/05/1443 AH.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    var allowConnection : Bool?
var userName = ""
var phoneNumber = ""
    @IBOutlet weak var allowContactLabel: UILabel!{
        didSet{
            allowContactLabel.text = "allowContact".localized
        }
    }
    @IBOutlet weak var contactSwitchOutlet : UISwitch!

    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized
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
    @IBOutlet weak var saveChangesButtonOutlet: UIButton!
    {
        didSet{
            saveChangesButtonOutlet.setTitle("saveChanges".localized, for: .normal)
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
    @IBOutlet weak var phoneNumberTextField: UITextField!{
        
        didSet{
            phoneNumberTextField.delegate = self

        }
    
    
}
  
    @IBOutlet weak var passwordTextField: UITextField!{
        
        didSet{
            passwordTextField.delegate = self

        }
    
    
}
    @IBOutlet weak var rePasswordTextField: UITextField!{
        
        didSet{
            rePasswordTextField.delegate = self

        }
    }
    
    var activityIndicator = UIActivityIndicatorView()
    var selectedUser:User?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = Firestore.firestore()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        
     
        ref.collection("users").document(Auth.auth().currentUser!.uid).getDocument { userSnapshot, error in
                 if let error = error {
                     print("ERROR user Data",error.localizedDescription)
                 }
                 if let userSnapshot = userSnapshot,
                    let userData = userSnapshot.data(){
                     let user = User(dict:userData)
                     self.nameTextField.text = user.name
                     self.emailTextField.text = Auth.auth().currentUser?.email
                     self.phoneNumberTextField.text = user.phoneNumber
                     self.userName = user.name
                     self.phoneNumber = user.phoneNumber
                     self.contactSwitchOutlet.isOn = user.allowConnection
                     
                    
                     
        }
                }
 
   
    }
    @IBAction func contactSwitch(_ sender: UISwitch) {
        if (sender.isOn == true){
            allowConnection = true
         }
         else{
             allowConnection = false
         }
    }
    @IBAction func handleUpdate(_ sender: UIButton) {
        
        //
                    if let name = nameTextField.text,
                      let email = emailTextField.text,
                       let phoneNumber = phoneNumberTextField.text,
                       let allowConnection = self.allowConnection,
                let currentUser = Auth.auth().currentUser {
                 Activity.showIndicator(parentView: self.view, childView: activityIndicator)

                        let  userId = currentUser.uid
                             let db = Firestore.firestore()
                             let ref = db.collection("users")
                        let user = Auth.auth().currentUser
                        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: "email", password: "password")
                       
                        // Prompt the user to re-provide their sign-in credentials
                        if emailTextField.text != Auth.auth().currentUser?.email {
                        user?.reauthenticate(with: credential) { error,arg  in
                            if error != nil {
                              Alert.showAlert(strTitle: "error autho", strMessage: "error", viewController: self)
                                
                            } else {
                        
                              if let email = self.emailTextField.text {
                        Auth.auth().currentUser?.updateEmail(to: email) { error in
                                  if let error = error {
                                    // An error happened.
                                      Alert.showAlert(strTitle: "error email", strMessage: error.localizedDescription, viewController: self)
                                     
                                  }else{
                                      Alert.showAlert(strTitle: "", strMessage: "Your Email has been changed successfully.", viewController: self)

                                  }
                            
                        }}
                         
                            }}
                    }
                    
                            let userData : [String:Any]  = [
                                "id":userId,
                                "name":name,
                                "email": email,
                                "phoneNumber":phoneNumber,
                                "allowConnection" : allowConnection]
                        
       
                        
                        if let password = passwordTextField.text {
                            if password != "" {
                                if password == rePasswordTextField.text {
                        Auth.auth().currentUser?.updatePassword(to: password) { error in
                                  if let error = error {
                                      print("password.....")
                                    // An error happened.
                                      Alert.showAlert(strTitle: "error password", strMessage: error.localizedDescription, viewController: self)
                                      Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                  }else{
                                      Alert.showAlert(strTitle: "", strMessage: "Your password has been changed successfully.", viewController: self)
                                      self.passwordTextField.text = ""
                                      self.rePasswordTextField.text = ""
                                      

                                  }
                            
                        }}else{
                            Alert.showAlert(strTitle: "", strMessage: "Password confirmation doesn't match Password", viewController: self)
                            self.passwordTextField.text = ""
                            self.rePasswordTextField.text = ""
                            
                        }}
                        }
                        if  self.nameTextField.text != self.userName {
                            Alert.showAlert(strTitle: "", strMessage: "Your name has been changed successfully.", viewController: self)
                        }
                        if self.phoneNumberTextField.text != self.phoneNumber {
                            Alert.showAlert(strTitle: "", strMessage: "Your Phone Number has been changed successfully.", viewController: self)
                        }

                             ref.document(userId).setData(userData) { error in
                                 if let error = error {
                                     Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                                     Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                     
                                 }
                                 Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                 
                
         
                }
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

        rePasswordTextField.isSecureTextEntry.toggle()
           if rePasswordTextField.isSecureTextEntry {
               if let image = UIImage(systemName: "eye.slash") {
                   sender.setImage(image, for: .normal)
               }
           } else {
               if let image = UIImage(systemName: "eye") {
                   sender.setImage(image, for: .normal)
               }
           }
    }
    @IBAction func handleLogout(_ sender: UIBarButtonItem) {
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

        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        
        
   

    }
}

}
