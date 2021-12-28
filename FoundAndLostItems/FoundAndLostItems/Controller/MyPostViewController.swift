//
//  MyPostViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 24/05/1443 AH.
//

import UIKit
import Firebase
class MyPostViewController: UIViewController {
    
    var posts = [Post]()
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    let ref = Firestore.firestore()
    
    @IBOutlet weak var myPostTableView: UITableView!{
        didSet{
            myPostTableView.delegate = self
            myPostTableView.dataSource = self
            myPostTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        if let currentUser = Auth.auth().currentUser,
//           currentUser.uid == posts[indexPath.row].user.id{
//        if let currentUser = Auth.auth().currentUser,
//                 currentUser.uid =
        
//        if let currentUser = Auth.auth().currentUser,
//           currentUser.uid == posts[0].user.id{
//                let found =  ref.collection("posts").whereField("found", isEqualTo: "yes")

        let all =  ref.collection("posts").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid ).order(by: "createdAt",descending: true)
        getPosts(state: all)
      //  }
    }
    func getPosts(state : Query ) {
        self.myPostTableView.reloadData()
        state.addSnapshotListener { snapshot, error in
            let ref = Firestore.firestore()

            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
            }
            if let snapshot = snapshot {
                
                snapshot.documentChanges.forEach { diff in
                    let post = diff.document.data()
                    switch diff.type {
                    case .added :
                        if let userId = post["userId"] as? String {
                            ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error {
                                    print("ERROR user Data",error.localizedDescription)
                                    
                                }
                                
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                    let user = User(dict:userData)
                                    let post = Post(dict:post,id:diff.document.documentID,user:user)
                                    self.posts.insert(post, at: 0)
                                    DispatchQueue.main.async {
                                        self.myPostTableView.reloadData()
                                    }
                                    
                                }
                            }
                        }
                        case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.posts.first(where: {$0.id == postId}),
                           let updateIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            let newPost = Post(dict:post, id: postId, user: currentPost.user)
                            self.posts[updateIndex] = newPost
                            DispatchQueue.main.async {
                                self.myPostTableView.reloadData()
                            }
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            self.posts.remove(at: deleteIndex)
                            DispatchQueue.main.async {
                                self.myPostTableView.reloadData()
                            }
                        }
                        }
                    }
                }
            }

}

}
extension MyPostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        return cell.configure(with: posts[indexPath.row])
    }
    
    
}
extension MyPostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        selectedPostImage = cell.postImageView.image
        selectedPost = posts[indexPath.row]
        if let currentUser = Auth.auth().currentUser,
           currentUser.uid == posts[indexPath.row].user.id{
          performSegue(withIdentifier: "toPostEditVC", sender: self)
            
        }
        
    }
}
