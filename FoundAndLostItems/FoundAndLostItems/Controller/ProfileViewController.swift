//
//  personalInfoViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 24/05/1443 AH.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
   
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
  
    @IBOutlet weak var passwordTextField: UITextField!
    var activityIndicator = UIActivityIndicatorView()
    var selectedUser:User?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = Firestore.firestore()
          
     
        ref.collection("users").document(Auth.auth().currentUser!.uid).getDocument { userSnapshot, error in
                 if let error = error {
                     print("ERROR user Data",error.localizedDescription)
                    print("dddddd")
                 }
                 if let userSnapshot = userSnapshot,
                    let userData = userSnapshot.data(){
                     let user = User(dict:userData)
                     self.nameTextField.text = user.name
                     self.emailTextField.text = user.email
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
               //let password = passwordTextField.text,
               let phoneNumber = phoneNumberTextField.text,
        
        let currentUser = Auth.auth().currentUser {
         Activity.showIndicator(parentView: self.view, childView: activityIndicator)

                let  userId = currentUser.uid     
                     let db = Firestore.firestore()
                     let ref = db.collection("users")
                

                    
                    let userData : [String:Any]  = [
                        "id":userId,
                        "name":name,
                        "email":email,
                        "phoneNumber":phoneNumber]
                    print("wee::::",userData)
                     
                     ref.document(userId).setData(userData) { error in
                         if let error = error {
                             Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                             Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                             
                         }
                         Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                         
        
    //}
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
    

}
