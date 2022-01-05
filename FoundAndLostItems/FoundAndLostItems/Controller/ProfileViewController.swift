//
//  personalInfoViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 24/05/1443 AH.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    
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
 
    @IBOutlet weak var titleApp1Label: UILabel!{
        didSet{
            titleApp1Label.text = "titleApp1".localized
        }
    }
    
    @IBOutlet weak var titleApp2Label: UILabel!{
        didSet{
            titleApp2Label.text = "titleApp2".localized
        }
    }
    @IBOutlet weak var LanguageButtonOutlet: UIButton!{
        didSet{
            LanguageButtonOutlet.setTitle(NSLocalizedString("language".localized, tableName: "Localizable", comment: ""), for: .normal)
        }
    }
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
  
    @IBOutlet weak var passwordTextField: UITextField!
    var activityIndicator = UIActivityIndicatorView()
    var selectedUser:User?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = Firestore.firestore()
//        Auth.auth().currentUser?.updateEmail(to: email) { error in
//            if let error = error {
//
//            }
//        let user = Auth.auth().currentUser
//        var credential: AuthCredential
//        user?.reauthenticate(with: credential) { error,athuUser  in
//          if let error = error {
//          }
              
      //  Auth.auth().currentUser?.updatePassword(to: password) { error in
          // ...
         //   if let error = error {
         
              //       }
        
     
        ref.collection("users").document(Auth.auth().currentUser!.uid).getDocument { userSnapshot, error in
                 if let error = error {
                     print("ERROR user Data",error.localizedDescription)
                    print("dddddd")
                 }
                 if let userSnapshot = userSnapshot,
                    let userData = userSnapshot.data(){
                     let user = User(dict:userData)
                     self.nameTextField.text = user.name
                     self.emailTextField.text = Auth.auth().currentUser?.email
                     self.phoneNumberTextField.text = user.phoneNumber
                     print("s\(user.name)")
                     print("m***")
                     
        }
                }
 
   
    }
    
    @IBAction func handleUpdate(_ sender: UIButton) {
        
        //
                    if let name = nameTextField.text,
                      let email = emailTextField.text,
                     // let password = passwordTextField.text,
                       let phoneNumber = phoneNumberTextField.text,
                
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
                                      print("email.....")
                                    // An error happened.
                                      Alert.showAlert(strTitle: "error email", strMessage: error.localizedDescription, viewController: self)
                                     
                                  }else{
                                      Alert.showAlert(strTitle: "email", strMessage: "y", viewController: self)

                                  }
                            
                                // ...
                        }}
                          }}
                    }
                            let userData : [String:Any]  = [
                                "id":userId,
                                "name":name,
                                "email": email,
                                "phoneNumber":phoneNumber]
                        
        //                let user = Auth.auth().currentUser
        //                var credential: AuthCredential
        //
        //                // Prompt the user to re-provide their sign-in credentials
        //
        //                user?.reauthenticate(with: credential) { error,arg  in
        //                  if let error = error {
        //                    // An error happened.
        //                  } else {
                            // User re-authenticated.
//                        if passwordTextField.text!.count >= 6 {
//                        if let password = passwordTextField.text {
//                        Auth.auth().currentUser?.updatePassword(to: password) { error in
//                                  if let error = error {
//                                      print("password.....")
//                                    // An error happened.
//                                      Alert.showAlert(strTitle: "error password", strMessage: error.localizedDescription, viewController: self)
//                                      Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
//                                  }else{
//                                      Alert.showAlert(strTitle: "password", strMessage: "y", viewController: self)
//
//                                  }
//
//                                // ...
//                        }}
//                        }
                        
                        if let password = passwordTextField.text {
                            if password != "" {
                        Auth.auth().currentUser?.updatePassword(to: password) { error in
                                  if let error = error {
                                      print("password.....")
                                    // An error happened.
                                      Alert.showAlert(strTitle: "error password", strMessage: error.localizedDescription, viewController: self)
                                      Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                  }else{
                                      Alert.showAlert(strTitle: "password", strMessage: "y", viewController: self)

                                  }
                            
                                // ...
                        }}
                        }
                       
        //                = emailTextField.text

                             ref.document(userId).setData(userData) { error in
                                 if let error = error {
                                     Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                                     Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                     
                                 }
                                 Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                 
                
            //}
               //  }
                }
            }
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
    
    @IBAction func changeLanguageButton(_ sender: UIButton) {
       
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
