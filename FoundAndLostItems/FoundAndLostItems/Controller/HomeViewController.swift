//
//  HomeViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    var posts = [Post]()
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    let ref = Firestore.firestore()
    
    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized

        }
    }
    
 var firstLunch = true

    @IBOutlet weak var LanguageButtonOutlet: UIBarButtonItem!{
        didSet{
            self.LanguageButtonOutlet.title = "language".localized
            
           
        }
    }
    
    @IBOutlet weak var filterSegmentedControlOutlet: UISegmentedControl!{
        didSet{
            filterSegmentedControlOutlet.setTitle("all".localized, forSegmentAt: 0)
            filterSegmentedControlOutlet.setTitle("found".localized, forSegmentAt: 1)
            filterSegmentedControlOutlet.setTitle("lost".localized, forSegmentAt: 2)
        }
    }
    @IBOutlet weak var postsTableView: UITableView!{
        didSet{
            postsTableView.delegate = self
            postsTableView.dataSource = self
            postsTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let all =  ref.collection("posts").order(by: "createdAt",descending: true)
        getPosts(state: all)
      
          
        
    }
    
    
    @IBAction func displayFilterSegmentedControl(_ sender: UISegmentedControl) {
  
        posts = [Post]()
         let filter = sender.selectedSegmentIndex
            if filter == 0 {
                let all =  ref.collection("posts").order(by: "createdAt", descending: true)
                getPosts(state: all)
            }else if filter == 1 {
                let found =  ref.collection("posts").order(by: "createdAt",descending: true).whereField("found", isEqualTo: "found")
                getPosts(state: found)
                
            }else if filter == 2 {
                let lost =  ref.collection("posts").order(by: "createdAt",descending: true).whereField("found", isEqualTo: "lost")
                getPosts(state: lost)
                
            }
    }
    func getPosts(state : Query ) {

        self.postsTableView.reloadData()
      
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
    
    @IBAction func changeLanguageButton(_ sender: UIBarButtonItem) {
        var lang = ""
        if let userDefaultLang = UserDefaults.standard.string(forKey: "currentLanguage"){
                lang = userDefaultLang
        }
 
         if lang == "en" {

             lang = "ar"
             UIView.appearance().semanticContentAttribute = .forceRightToLeft

        }else{
  
            lang = "en"
            UIView.appearance().semanticContentAttribute = .forceLeftToRight

        }
       
        Bundle.setLanguage(lang)
        UserDefaults.standard.set(lang, forKey: "currentLanguage")
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController {
            vc.modalPresentationStyle = .fullScreen  
            self.present(vc, animated: false, completion: nil)
        

    }
}
}
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        cell.selectionStyle = .none
        return cell.configure(with: posts[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        UIView.animate(withDuration: 0.4) {
               if let cell = tableView.cellForRow(at: indexPath) as? PostCell {
                   cell.effectViewCell.backgroundColor = UIColor(white: 1,  alpha: 0.2)
                   
               }
           }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4){
            if let cell = tableView.cellForRow(at: indexPath) as? PostCell {
        cell.effectViewCell.backgroundColor = .clear
    }

    }
    
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
}


