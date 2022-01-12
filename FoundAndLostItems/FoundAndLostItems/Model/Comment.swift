//
//  Comment.swift
//  FoundAndLostItems
//
//  Created by Maram F on 05/06/1443 AH.
//

import Foundation
import Firebase
struct Comment {
    var postId = ""
    var comment = ""
    var userId = ""
    var publisherUserId = ""
    var id = ""
    var createdAt:Timestamp?
    var user:User
    
    init(dict:[String:Any],id:String,user:User) {
        if let postId = dict["postId"] as? String,
           let comment = dict["comment"] as? String,
           let userId = dict["userId"] as? String,
           let publisherUserId = dict["publisherUserId"] as? String,
           let id = dict["id"] as? String,
           let createdAt = dict["createdAt"] as? Timestamp {
            self.postId = postId
            self.userId = userId
            self.publisherUserId = publisherUserId
            self.comment = comment
            self.createdAt =  createdAt
            self.id =  id
        
        
     }
     self.id = id
     self.user = user
 }
}
