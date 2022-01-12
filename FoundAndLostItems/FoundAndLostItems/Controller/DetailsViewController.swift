//
//  DetailsViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 23/05/1443 AH.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
class DetailsViewController: UIViewController {
    let ref = Firestore.firestore()

    let activityIndicator = UIActivityIndicatorView()
    @IBOutlet weak var sendCommentButton: UIButton!{
        didSet{
          
            sendCommentButton.setTitle(NSLocalizedString("send", tableName: "Localized",  comment: ""),for: .normal)
        }
    }
    
    @IBOutlet weak var commentsLabelOutlet: UILabel!{
        didSet{
            commentsLabelOutlet.text = "comments".localized

        }
    }
    @IBOutlet weak var commentsTableView: UITableView!{
        didSet{
            commentsTableView.delegate = self
            commentsTableView.dataSource = self
            commentsTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        }
    }
    @IBOutlet weak var selectLocationLabelOutlet: UILabel!{
        didSet{
            selectLocationLabelOutlet.text = "selectLocationOnMap".localized
        }
    }
    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized
        }
    }
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var descriptionLableOutlet: UILabel!{
        didSet{
            descriptionLableOutlet.text = "description".localized
        }
    }
  
  
    var latitude : CLLocationDegrees = 0.0
    var longitude :  CLLocationDegrees = 0.0
    var selectedPost:Post?
    var  comments = [Comment]()
    var selectedPostImage:UIImage?
    @IBOutlet weak var itemLocationMapView: MKMapView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionTextView: UITextView!{
        didSet{
            postDescriptionTextView.layer.cornerRadius = 5.0
            postDescriptionTextView.layer.borderWidth = 0.34
           

        }
    }
    @IBOutlet weak var country : UILabel!
    @IBOutlet weak var  time : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        getComments()
        // Do any additional setup after loading the view.
        if let selectedPost = selectedPost,
        let selectedImage = selectedPostImage{
            postTitleLabel.text = selectedPost.title
            postDescriptionTextView.text = selectedPost.description
            country.text = "\(selectedPost.country), \(selectedPost.city)"
            if let timeStamp = selectedPost.createdAt {
               
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeStamp.seconds))

                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"

                let dateString = dayTimePeriodFormatter.string(from: date as Date)

                time.text = dateString
            }
            postImageView.image = selectedImage
            let initialLocation = CLLocation(latitude: selectedPost.latitude, longitude: selectedPost.longitude)
            setStartingLocation(location: initialLocation, distance: 1000)

            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(selectedPost.latitude, selectedPost.longitude)
            pin.title = "location".localized
            itemLocationMapView.addAnnotation(pin)
        }
    }
    @IBAction func sendCommentAction(_ sender: UIButton) {

        Activity.showIndicator(parentView: self.view, childView: self.activityIndicator)
//

            if let comment = commentTextField.text,
               let currentUser = Auth.auth().currentUser {

                  let  commentId = "\(Firebase.UUID())"
//
                        var commentData = [String:Any]()
//
                            let db = Firestore.firestore()
                            let ref = db.collection("comments")
                            commentData = [
                                    "id": commentId,
                                    "userId":currentUser.uid,
                                    "publisherUserId":selectedPost!.user.id,
                                    "comment":comment,
                                    "postId":selectedPost!.id,
                                    "createdAt":FieldValue.serverTimestamp()
                                ]

                            ref.document(commentId).setData(commentData) { error in
                                if let error = error {
                                    print("FireStore Error",error.localizedDescription)
                                }


                                      Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                print("Document added with ID: \(commentId)")
                                self.commentTextField.text = ""
                                  }
                            }

        }
                        
                    
    
    
    

func setStartingLocation(location: CLLocation, distance: CLLocationDistance){
    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
    itemLocationMapView.setRegion(region, animated: true)
   

}
    
    func getComments(){
        self.commentsTableView.reloadData()

         ref.collection("comments").whereField("postId", isEqualTo: selectedPost!.id).order(by: "createdAt",descending: true).addSnapshotListener{  snapshot, error in
           

            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
//                Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
            }
            if let snapshot = snapshot {
                
                snapshot.documentChanges.forEach { diff in
                    let commentData = diff.document.data()
                    switch diff.type {
                    case .added :
                        if let userId = commentData["userId"] as? String {
                            self.ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error {
                                    print("ERROR user Data",error.localizedDescription)
                                    
                                }
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                  let user = User(dict:userData)

                                    let comment = Comment(dict:commentData,id:diff.document.documentID,user:user)
                                  self.commentsTableView.beginUpdates()
                                    if snapshot.documentChanges.count != 1 {
                                        //self.comments.insert(comment, at: 0)
                                        self.comments.append(comment)

                                        self.commentsTableView.insertRows(at: [IndexPath(row:self.comments.count - 1,section: 0)],with: .automatic)
                                    }else {
                                     
                                       self.comments.insert(comment, at: 0)
                                        self.commentsTableView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                    }
                                    self.commentsTableView.endUpdates()
                                }}}
                    case .modified:
                        let commentId = diff.document.documentID
                       
                            if let currentComment = self.comments.first(where: {$0.id == commentId}),

                                let updateIndex = self.comments.firstIndex(where: {$0.id == commentId}){
                                let newComment = Comment(dict:commentData,id:commentId,user:currentComment.user)
                            self.comments[updateIndex] = newComment

                                self.commentsTableView.beginUpdates()
                                self.commentsTableView.deleteRows(at: [IndexPath(row: updateIndex,section: 0)], with: .left)
                                self.commentsTableView.insertRows(at: [IndexPath(row: updateIndex,section: 0)],with: .left)
                                self.commentsTableView.endUpdates()

                        }
                    case .removed:
                        let commentId = diff.document.documentID
                        if let deleteIndex = self.comments.firstIndex(where: {$0.id == commentId}){
                            self.comments.remove(at: deleteIndex)

                                self.commentsTableView.beginUpdates()
                                self.commentsTableView.deleteRows(at: [IndexPath(row: deleteIndex,section: 0)], with: .automatic)
                                self.commentsTableView.endUpdates()

                        }
                    }
                }
            }

             }}
       
        }
    



 func toDate(_ timestamp: Any?) -> Date? {
    if let any = timestamp {
        if let str = any as? NSString {
            return Date(timeIntervalSince1970: str.doubleValue)
        } else if let str = any as? NSNumber {
            return Date(timeIntervalSince1970: str.doubleValue)
        }
    }
    return nil
}
extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("----count----\n",comments.count)
        print("----*comments*----\n",comments)
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell

        return cell.configure(with: comments[indexPath.row])
    }
    
}
    
extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
 
}
