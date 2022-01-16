//
//  PostViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class PostViewController: UIViewController {
    
    let ref = Firestore.firestore()
    var  comments = [Comment]()
    var latitude : CLLocationDegrees = 0.0
    var longitude :  CLLocationDegrees = 0.0
    var locationManager  = CLLocationManager()
    let annotation = MKPointAnnotation()
    var foundItem = "found"
    var foundItems = ["found".localized,"lost".localized]
    var flag = 0
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    let activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var commentsLabel: UILabel!{
        didSet{
            commentsLabel.text = "comments".localized
        }
    }

    @IBOutlet weak var commentTextField: UITextField!{
        didSet{
            commentTextField.delegate = self

        }
    
    }
    @IBOutlet weak var commentsTableView: UITableView!{
        didSet{
            commentsTableView.delegate = self
            commentsTableView.dataSource = self
            commentsTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        }
    }

    @IBOutlet weak var navBarTitle: UINavigationItem!{
        didSet{
            navBarTitle.title = "titleApp".localized
        }
    }
    @IBOutlet weak var countryLabelOutlet: UILabel!{
        didSet{
            countryLabelOutlet.text = "country".localized
        }
    }
    @IBOutlet weak var cityLabelOutlet: UILabel!{
        didSet{
            cityLabelOutlet.text = "city".localized
        }
    }
    @IBOutlet weak var selectLocationLabelOutlet: UILabel!{
        didSet{
            selectLocationLabelOutlet.text = "selectLocationOnMap".localized
        }
    }
    @IBOutlet weak var descriptionLableOutlet: UILabel!{
        didSet{
            descriptionLableOutlet.text = "description".localized
        }
    }
    @IBOutlet weak var categoryLableOutlet: UILabel!{
        didSet{
            categoryLableOutlet.text = "category".localized
        }
    }
    @IBOutlet weak var titleLableOutlet: UILabel!{
        didSet{
            titleLableOutlet.text = "title".localized
        }
    }
    @IBOutlet weak var itemLocationMapView: MKMapView!
    

    @IBOutlet weak var postImageView: UIImageView!{
        didSet {
        postImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        postImageView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var cencelButtonOutlet: UIBarButtonItem!{
        didSet{
            self.cencelButtonOutlet.title = "cencel".localized
           
        }
       
   }
    @IBOutlet weak var postTitleTextField: UITextField!
    {
        didSet{
            postTitleTextField.delegate = self
        }
    }

    @IBOutlet weak var postFoundPickerView: UIPickerView!{
        didSet{
            postFoundPickerView.delegate = self
            postFoundPickerView.dataSource = self
        }
    }
    @IBOutlet weak var postDescriptionTextField: UITextView!
    {
        didSet{
            postDescriptionTextField.layer.cornerRadius = 5.0
            postDescriptionTextField.layer.borderWidth = 0.34
        }
    }
    
    @IBOutlet weak var postCityTextField: UITextField!{
        didSet{
            postCityTextField.delegate = self
        }
    }
    @IBOutlet weak var postCountryTextField: UITextField!{
        didSet{
            postCountryTextField.delegate = self
        }
    }
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var sendButtonOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
       
        
        if let selectedPost = selectedPost,
        let selectedImage = selectedPostImage{
            postTitleTextField.text = selectedPost.title
            postDescriptionTextField.text = selectedPost.description
            latitude = selectedPost.latitude
            longitude = selectedPost.longitude
            postImageView.image = selectedImage
            actionButton.setTitle("updatePost".localized, for: .normal)
            flag = 1
            getComments()
        }else {
            
            actionButton.setTitle("addPost".localized, for: .normal)
            self.navBarTitle.leftBarButtonItem = nil
            self.navBarTitle.rightBarButtonItem = nil
            commentsTableView.isHidden = true
            commentTextField.isHidden = true
            commentsLabel.isHidden = true
            sendButtonOutlet.isHidden = true
            
            
        }
        //----------------location------------------//
        
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.distanceFilter = kCLLocationAccuracyHundredMeters

           locationManager.stopUpdatingLocation()
           locationManager.requestAlwaysAuthorization()
         

           // check if location enabled
           if CLLocationManager.locationServicesEnabled() {
               locationManager.startUpdatingLocation()
           }
        
           //--------------------------------------------//

    }
    
    func getComments(){

        self.commentsTableView.reloadData()

         ref.collection("comments").whereField("postId", isEqualTo: selectedPost!.id).order(by: "createdAt",descending: true).addSnapshotListener{  snapshot, error in
           

            if let error = error {
                print("DB ERROR Posts",error.localizedDescription)
        
            }
            if let snapshot = snapshot {
                
                snapshot.documentChanges.forEach { diff in
                    let commentData = diff.document.data()
                    switch diff.type {
                    case .added :
                        if let userId = commentData["userId"] as? String {
                            self.ref.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error {
                                    Alert.showAlert(strTitle: "Error", strMessage: error.localizedDescription, viewController: self)
                                }
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                  let user = User(dict:userData)

                                    let comment = Comment(dict:commentData,id:diff.document.documentID,user:user)
                                  self.commentsTableView.beginUpdates()
                                    if snapshot.documentChanges.count != 1 {
                                  
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
    @IBAction func cencelButtonAction(_ sender: UIBarButtonItem) {
         
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func customLocationAction(_ sender: UILongPressGestureRecognizer) {

        let allAnnotation = itemLocationMapView.annotations
        itemLocationMapView.removeAnnotations(allAnnotation)
            let touchLocation = sender.location(in: itemLocationMapView)
            let locationCoordinate = itemLocationMapView.convert(touchLocation, toCoordinateFrom: itemLocationMapView)
            latitude = locationCoordinate.latitude
            longitude = locationCoordinate.longitude


       
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            pin.title = "location".localized
            itemLocationMapView.addAnnotation(pin)
            locationManager.startUpdatingLocation()

   
    }
    
    @IBAction func handleActionTouch(_ sender: Any) {
        var category : String?
        if foundItem == "موجود" || foundItem == "found" {
             category = "found" }
            else {
                category = "lost"
            }
        if let image = postImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let title = postTitleTextField.text,
           let found = category,
           let description = postDescriptionTextField.text,
           let country = postCountryTextField.text,
           let city = postCityTextField.text,
           let currentUser = Auth.auth().currentUser {
         
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            var postId = ""
            if let selectedPost = selectedPost {
                postId = selectedPost.id
            }else {
                postId = "\(Firebase.UUID())"
            }
            let storageRef = Storage.storage().reference(withPath: "posts/\(currentUser.uid)/\(postId)")
            let updloadMeta = StorageMetadata.init()
            updloadMeta.contentType = "image/jpeg"
            storageRef.putData(imageData, metadata: updloadMeta) { storageMeta, error in
                if let error = error {
                    print("Upload error",error.localizedDescription)
                }
                storageRef.downloadURL { url, error in
                    var postData = [String:Any]()
                    if let url = url {
                        let db = Firestore.firestore()
                        let ref = db.collection("posts")
                        if let selectedPost = self.selectedPost {
                            postData = [
                                "id": postId,
                                "userId":selectedPost.user.id,
                                "title":title,
                                "found":found,
                                "country": country,
                                "city":city,
                                "description":description,
                                "imageUrl":url.absoluteString,
                                "createdAt":selectedPost.createdAt ?? FieldValue.serverTimestamp(),
                                "updatedAt": FieldValue.serverTimestamp(),
                                "latitude": self.latitude,
                                "longitude": self.longitude
                                
                            ]
                        }else {
                            postData = [
                                "id": postId,
                                "userId":currentUser.uid,
                                "title":title,
                                "description":description,
                                "found":found,
                                "country": country,
                                "city":city,
                                "imageUrl":url.absoluteString,
                                "createdAt":FieldValue.serverTimestamp(),
                                "updatedAt": FieldValue.serverTimestamp(),
                                "latitude": self.latitude,
                                "longitude": self.longitude
                            ]
                        }
                        ref.document(postId).setData(postData) { error in
                            if let error = error {
                                print("FireStore Error",error.localizedDescription)
                            }
                          
                            
                              if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController {
                                  vc.modalPresentationStyle = .fullScreen

                                  Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                  self.present(vc, animated: true, completion: nil)
                              }
                        }
                    }
                }
            }
        }
        
    }
    @IBAction func sendCommentAction(_ sender: UIButton) {

        Activity.showIndicator(parentView: self.view, childView: self.activityIndicator)


            if let comment = commentTextField.text,
               let currentUser = Auth.auth().currentUser {

                  let  commentId = "\(Firebase.UUID())"

                        var commentData = [String:Any]()

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
}
extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func chooseImage() {
        self.showAlert()
    }
    private func showAlert() {
        
        let alert = UIAlertController(title: "Choose Profile Picture", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        postImageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension PostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //number of colume
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       
        return 1
    }
    
    //number of elments = array.count
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
            return foundItems.count
    }
    //write elment array on  PickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
            return foundItems[row]
}
            
        
    //print on label & do any thing when select row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       foundItem = foundItems[row]
    
    }


}
extension PostViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if flag == 0 {
        let userLocation = locations[0] as CLLocation
              latitude = userLocation.coordinate.latitude
              longitude = userLocation.coordinate.longitude
        
         print("userLocation: \(userLocation)")
            flag = 1
        }
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation){ (placeMarks, error) in
            if error != nil {
                print("Error")
            }
            if let placeMarks = placeMarks{
            let placeMark = placeMarks as [CLPlacemark]
            if placeMark.count>0 {
                let placeMark = placeMarks[0]
                self.locationManager.stopUpdatingLocation()

                let country =
                placeMark.country
                
                let city =
                placeMark.locality
                self.postCountryTextField.text = country ?? "Unknown"
                self.postCityTextField.text = city ?? "Unknown"
                

            }
                
           } 
        }
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        setStartingLocation(location: initialLocation, distance: 100)

        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        pin.title = "Current location"
        itemLocationMapView.addAnnotation(pin)
    }
    func setStartingLocation(location: CLLocation, distance: CLLocationDistance){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        itemLocationMapView.setRegion(region, animated: true)
        
     

    }
    
}
extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell

        return cell.configure(with: comments[indexPath.row])
    }
    
}
    
extension PostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
 
}
