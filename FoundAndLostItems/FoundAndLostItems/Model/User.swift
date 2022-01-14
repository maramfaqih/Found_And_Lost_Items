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
    var email = ""
    var phoneNumber = ""
    var allowConnection = true
    
    init(dict:[String:Any]) {
        if let id = dict["id"] as? String,
           let name = dict["name"] as? String,
           let phoneNumber = dict["phoneNumber"] as? String,
           let email = dict["email"] as? String,
           let allowConnection = dict["allowConnection"] as? Bool {
            self.name = name
            self.id = id
            self.email = email
            self.phoneNumber =  phoneNumber
            self.allowConnection =  allowConnection
        }
    }
}
