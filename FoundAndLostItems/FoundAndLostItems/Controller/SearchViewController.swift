//
//  SearchViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 24/05/1443 AH.
//

import UIKit
import Firebase
class SearchViewController: UIViewController {
    var posts = [Post]()
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    
    @IBOutlet weak var searchTableView: UITableView!{
        didSet{
            searchTableView.delegate = self
            searchTableView.dataSource = self
            searchTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        }
        
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        let ref = Firestore.firestore()
        posts = [Post]()
        let searchKeyTitle =  ref.collection("posts").whereField("title", isEqualTo: searchTextField.text!)
        getPosts(state: searchKeyTitle)
        let searchKeyDescriotion =  ref.collection("posts").whereField("description", isEqualTo: searchTextField.text!)
        getPosts(state: searchKeyDescriotion)
        
        
    }
    func getPosts(state : Query ) {
        self.searchTableView.reloadData()
        state.addSnapshotListener { snapshot, error in
            let ref = Firestore.firestore()

            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
            }
            if let snapshot = snapshot {
                snapshot.documentChanges.forEach { diff in
                    let postData = diff.document.data()
                    switch diff.type {
                    case .added :
                        
                        if let userId = postData["userId"] as? String {
                            ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error {
                                    print("ERROR user Data",error.localizedDescription)
                                    
                                }
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                    let user = User(dict:userData)
                                    let post = Post(dict:postData,id:diff.document.documentID,user:user)
                                    self.searchTableView.beginUpdates()
                                    if snapshot.documentChanges.count != 1 {
                                        self.posts.append(post)
                                      
                                        self.searchTableView.insertRows(at: [IndexPath(row:self.posts.count - 1,section: 0)],with: .automatic)
                                    }else {
                                        self.posts.insert(post,at:0)
                                      
                                        self.searchTableView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                    }
                                  
                                    self.searchTableView.endUpdates()
                                    
                                    
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.posts.first(where: {$0.id == postId}),
                           let updateIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            let newPost = Post(dict:postData, id: postId, user: currentPost.user)
                            self.posts[updateIndex] = newPost
                         
                                self.searchTableView.beginUpdates()
                                self.searchTableView.deleteRows(at: [IndexPath(row: updateIndex,section: 0)], with: .left)
                                self.searchTableView.insertRows(at: [IndexPath(row: updateIndex,section: 0)],with: .left)
                                self.searchTableView.endUpdates()
                            
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            self.posts.remove(at: deleteIndex)
                          
                                self.searchTableView.beginUpdates()
                                self.searchTableView.deleteRows(at: [IndexPath(row: deleteIndex,section: 0)], with: .automatic)
                                self.searchTableView.endUpdates()
                            
                        }
                    }
                }
            }
            }
     

}
    
}
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        return cell.configure(with: posts[indexPath.row])
    }
    
    
}
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        selectedPostImage = cell.postImageView.image
        selectedPost = posts[indexPath.row]
      
            performSegue(withIdentifier: "fromSearchPostEditVC", sender: self)
            
        }
    }

