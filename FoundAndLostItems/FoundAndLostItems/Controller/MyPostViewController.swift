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
    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized
        }
    }
    

  
    @IBOutlet weak var myPostTableView: UITableView!{
        didSet{
            myPostTableView.delegate = self
            myPostTableView.dataSource = self
            myPostTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let all =  ref.collection("posts").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid ).order(by: "createdAt",descending: true)
        getPosts(state: all)
    
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
                                    self.posts.append(post)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toPostEditVC" {
                let vc = segue.destination as! PostViewController
                vc.selectedPost = selectedPost
                vc.selectedPostImage = selectedPostImage
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectedPost = posts[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "") { action, view, completionHandler in
            
                let ref = Firestore.firestore().collection("posts")
            if let selectedPost = self.selectedPost {
                   
                    ref.document(selectedPost.id).delete { error in
                        if let error = error {
                            print("Error in db delete",error)
                        }else {
                            // Create a reference to the file to delete
                            let storageRef = Storage.storage().reference(withPath: "posts/\(selectedPost.user.id)/\(selectedPost.id)")
                            // Delete the file
                            storageRef.delete { error in
                                if let error = error {
                                    print("Error in storage delete",error)
                                }
                            }
                            
                        }
                    }
                }
            
            self.posts.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
        
            performSegue(withIdentifier: "toPostEditVC", sender: self)
    }
    
}

