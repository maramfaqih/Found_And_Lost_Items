//
//  User.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import Foundation
struct User {
    var id = ""
    var name = ""
    var imageUrl = ""
    var email = ""
    var phoneNumber = ""
    
    init(dict:[String:Any]) {
        if let id = dict["id"] as? String,
           let name = dict["name"] as? String,
           let imageUrl = dict["imageUrl"] as? String,
           let phoneNumber = dict["phoneNumber"] as? String,
           let email = dict["email"] as? String {
            self.name = name
            self.id = id
            self.email = email
            self.imageUrl = imageUrl
            self.phoneNumber =  phoneNumber
        }
    }
}
