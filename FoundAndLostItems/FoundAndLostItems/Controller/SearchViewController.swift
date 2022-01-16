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
    var postsSearch = [Post]()
    var selectedPostImage:UIImage?
    var selectedPost:Post?
    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized
        }
    }
    
    @IBOutlet weak var LanguageButtonOutlet: UIBarButtonItem!{
        didSet{
            self.LanguageButtonOutlet.title = "language".localized
           
        }}
    @IBOutlet weak var searchController: UISearchBar!{
        didSet{
            searchController.delegate = self
        }
    }
    @IBOutlet weak var searchTableView: UITableView!{
        didSet{
            searchTableView.delegate = self
            searchTableView.dataSource = self
            searchTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
       getPosts()
        
    }
    
 
    func getPosts() {
        let ref = Firestore.firestore()
        self.searchTableView.reloadData()
        ref.collection("posts").addSnapshotListener { snapshot, error in
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "fromSearchPostEditVC" {
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
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !postsSearch.isEmpty ? postsSearch.count : posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = !postsSearch.isEmpty ? postsSearch[indexPath.row] : posts[indexPath.row]
        return cell.configure(with: post )
    }
    
    
}
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        
        selectedPostImage = cell.postImageView.image
        let post = !postsSearch.isEmpty ? postsSearch[indexPath.row] : posts[indexPath.row]
        selectedPost = post
      //  performSegue(withIdentifier: "", sender: self)
        if let currentUser = Auth.auth().currentUser,
           currentUser.uid == posts[indexPath.row].user.id{
          performSegue(withIdentifier: "fromSearchPostEditVC", sender: self)
        }
        else {
            performSegue(withIdentifier: "fromSearchPostDetailsVC", sender: self)
            
        }
        }
    }

extension SearchViewController:UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.showsCancelButton = true
        searchBar.showsSearchResultsButton = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
        if searchText == "" {
            postsSearch = [Post]()
        }
        postsSearch = searchText.isEmpty ? postsSearch : posts.filter({ (item ) in
            return (item.title.lowercased().contains(searchBar.text!.lowercased())||item.description.lowercased().contains(searchBar.text!.lowercased())||item.country.lowercased().contains(searchBar.text!.lowercased())||item.city.lowercased().contains(searchBar.text!.lowercased()))
    })
        searchTableView.reloadData()
}
}
