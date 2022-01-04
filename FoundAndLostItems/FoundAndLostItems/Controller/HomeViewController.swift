//
//  HomeViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
var read = false
    var posts = [Post]()
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    let ref = Firestore.firestore()
  
    @IBOutlet weak var postsTableView: UITableView!{
        didSet{
            postsTableView.delegate = self
            postsTableView.dataSource = self
            postsTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        }
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let all =  ref.collection("posts").order(by: "createdAt" ,descending: true)
        getPosts(state: all)
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func displayFilterSegmentedControl(_ sender: UISegmentedControl) {
  
        posts = [Post]()
        if let filter = sender.titleForSegment(at:sender.selectedSegmentIndex) {
            if filter == "All" {
                let all =  ref.collection("posts").order(by: "createdAt" ,descending: true)

                getPosts(state: all)
            }else if filter == "Found"{
                let found =  ref.collection("posts").whereField("found", isEqualTo: "Found").order(by: "createdAt",descending: true)
                getPosts(state: found)
                
            }else if filter == "Lost" {
                //self.postsTableView.beginUpdates()
                let lost =  ref.collection("posts").whereField("found", isEqualTo: "Lost").order(by: "createdAt",descending: true)
                getPosts(state: lost)
              
                
            }

        }
        
    }
    func getPosts(state : Query ) {
        self.postsTableView.reloadData()
      //  if read {
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
                                    self.postsTableView.beginUpdates()
                                    if snapshot.documentChanges.count != 1 {
                                        self.posts.append(post)
                                      
                                        self.postsTableView.insertRows(at: [IndexPath(row:self.posts.count - 1,section: 0)],with: .automatic)
                                    }else {
                                        self.posts.insert(post,at:0)
                                      
                                        self.postsTableView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                    }
                                  
                                    self.postsTableView.endUpdates()
                                    
                                    
                                }
                            }
                        }
                    case .modified:
                        let postId = diff.document.documentID
                        if let currentPost = self.posts.first(where: {$0.id == postId}),
                           let updateIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            let newPost = Post(dict:postData, id: postId, user: currentPost.user)
                            self.posts[updateIndex] = newPost
                         
                                self.postsTableView.beginUpdates()
                                self.postsTableView.deleteRows(at: [IndexPath(row: updateIndex,section: 0)], with: .left)
                                self.postsTableView.insertRows(at: [IndexPath(row: updateIndex,section: 0)],with: .left)
                                self.postsTableView.endUpdates()
                            
                        }
                    case .removed:
                        let postId = diff.document.documentID
                        if let deleteIndex = self.posts.firstIndex(where: {$0.id == postId}){
                            self.posts.remove(at: deleteIndex)
                          
                                self.postsTableView.beginUpdates()
                                self.postsTableView.deleteRows(at: [IndexPath(row: deleteIndex,section: 0)], with: .automatic)
                                self.postsTableView.endUpdates()
                            
                        }
                    }
                }
            }
            

           
                  
        }
            
      //  }
        
//        else{
//        ref.collection("posts").order(by: "createdAt" , descending: true)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                     //   print("\(document.documentID) => \(document.data())")
//                        if let userSnapshot = querySnapshot,
//                           let userData = userSnapshot.data(){
//                            let user = User(dict:userData)
//                            let post = Post(dict:postData,id:diff.document.documentID,user:user)
//                        posts.append(post)
//                    }
//                }
//        }
//            read = true
//        }
        }
     
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toPostVC" {
                let vc = segue.destination as! PostViewController
                vc.selectedPost = selectedPost
                vc.selectedPostImage = selectedPostImage
            }else {
                let vc = segue.destination as! DetailsViewController
                vc.selectedPost = selectedPost
                vc.selectedPostImage = selectedPostImage
            }
        }
        
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

        return cell.configure(with: posts[indexPath.row])
    }
    
    

        }
    
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        selectedPostImage = cell.postImageView.image
        selectedPost = posts[indexPath.row]
        if let currentUser = Auth.auth().currentUser,
           currentUser.uid == posts[indexPath.row].user.id{
          performSegue(withIdentifier: "toPostVC", sender: self)
        }
        else {
            performSegue(withIdentifier: "toDetailsVC", sender: self)
            
        }
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {

        UIView.animate(withDuration: 0.7) {
            if let cell = (tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell) {
                cell.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                cell.contentView.layoutIfNeeded()
              //  cell.backgroundViewCell.transform = .init(scaleX: 0.70, y: 0.70)
                   //cell.contentView.backgroundColor = UIColor(white: 1,  alpha: 1)
                   //cell.contentView.backgroundColor = UIColor(white: 1,  alpha: 0.5)
               
                 //   cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                  //  cell.layoutIfNeeded()
               
           }

    }

}
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = (tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell) {
                cell.contentView.transform = CGAffineTransform.identity
                cell.contentView.layoutIfNeeded()
            }
            
        }
    }
}


