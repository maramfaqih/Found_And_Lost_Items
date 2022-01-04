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
    @IBOutlet weak var titleApp1Label: UILabel!{
        didSet{
            titleApp1Label.text = "titleApp1".localized
        }
    }
    
    @IBOutlet weak var titleApp2Label: UILabel!{
        didSet{
            titleApp2Label.text = "titleApp2".localized
        }
    }
    @IBOutlet weak var LanguageButtonOutlet: UIButton!{
        didSet{
            LanguageButtonOutlet.setTitle(NSLocalizedString("language", tableName: "Localizable", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet weak var filterSegmentedControlOutlet: UISegmentedControl!{
        didSet{
            filterSegmentedControlOutlet.setTitle("all".localized, forSegmentAt: 0)
            filterSegmentedControlOutlet.setTitle("found".localized, forSegmentAt: 1)
            filterSegmentedControlOutlet.setTitle("lost".localized, forSegmentAt: 2)
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
        
         let filter = sender.selectedSegmentIndex
            if filter == 0 {
                let all =  ref.collection("posts").order(by: "createdAt" ,descending: true)

                getPosts(state: all)
            }else if filter == 1 {
                let found =  ref.collection("posts").whereField("found", isEqualTo: "found").order(by: "createdAt",descending: true)
                getPosts(state: found)
                
            }else if filter == 2 {
                //self.postsTableView.beginUpdates()
                let lost =  ref.collection("posts").whereField("found", isEqualTo: "lost").order(by: "createdAt",descending: true)
                getPosts(state: lost)
              
                
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
    
    @IBAction func changeLanguageButton(_ sender: UIButton) {
       
        var lang = UserDefaults.standard.string(forKey: "currentLanguage")
         if lang == "ar" {
             Bundle.setLanguage(lang ?? "ar")
             UIView.appearance().semanticContentAttribute = .forceRightToLeft
            lang = "en"
             
        }else{

            Bundle.setLanguage(lang ?? "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            lang = "ar"
        }
      
        UserDefaults.standard.set(lang, forKey: "currentLanguage")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()

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


