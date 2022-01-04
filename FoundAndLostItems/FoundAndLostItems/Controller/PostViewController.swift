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
    @IBOutlet weak var itemLocationMapView: MKMapView!
    var latitude : CLLocationDegrees = 0.0
    var longitude :  CLLocationDegrees = 0.0
    var locationManager  = CLLocationManager()
    let annotation = MKPointAnnotation()
    var foundItem = "Found"
    var foundItems = ["Found","Lost"]
var flag = 0
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    let activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var postImageView: UIImageView!{ didSet {
        postImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        postImageView.addGestureRecognizer(tapGesture)
    }
}
    @IBOutlet weak var cencelButtonOutlet: UIButton!
    
    @IBOutlet weak var postTitleTextField: UITextField!
    
 
  
    @IBOutlet weak var postFoundPickerView: UIPickerView!
    @IBOutlet weak var postDescriptionTextField: UITextView!
    {
        didSet{
            postDescriptionTextField.layer.cornerRadius = 5.0
            postDescriptionTextField.layer.borderWidth = 0.34
           

        }
    }
    
    @IBOutlet weak var postCityTextField: UITextField!
    @IBOutlet weak var postICountryTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        postFoundPickerView.delegate = self
        postFoundPickerView.dataSource = self
        if let selectedPost = selectedPost,
        let selectedImage = selectedPostImage{
            postTitleTextField.text = selectedPost.title
            postDescriptionTextField.text = selectedPost.description
            latitude = selectedPost.latitude
            longitude = selectedPost.longitude
            postImageView.image = selectedImage
            actionButton.setTitle("Update Post", for: .normal)
            flag = 1
            
        }else {
            actionButton.setTitle("Add Post", for: .normal)
            self.navigationItem.rightBarButtonItem = nil
            cencelButtonOutlet.isHidden = true
        }
        //----------------location------------------//
        
           locationManager.delegate = self
           //locationManager1  = CLLocationManager()
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.distanceFilter = kCLLocationAccuracyHundredMeters

           locationManager.stopUpdatingLocation()
           locationManager.requestAlwaysAuthorization()
          // locationManager1.requestLocation()

           // check if location enabled
           if CLLocationManager.locationServicesEnabled() {
               print("Yes")
               locationManager.startUpdatingLocation()
           }else{
               print("No")
           }
           //--------------------------------------------//
//        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
//setStartingLocation(location: initialLocation, distance: 100)
////        annotation.coordinate = CLLocationCoordinate2D(latitude:self.latitude, longitude: self.longitude)
////        itemLocationMapView.addAnnotation(annotation)
////        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
//        let pin = MKPointAnnotation()
//        pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
//        pin.title = "Current location"
//        itemLocationMapView.addAnnotation(pin)
    }
   
    @IBAction func cencelButtonAction(_ sender: UIButton) {
         
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func customLocationAction(_ sender: UILongPressGestureRecognizer) {
       // if sender.state != UITapGestureRecognizer.State.ended{
        let allAnnotation = itemLocationMapView.annotations
        itemLocationMapView.removeAnnotations(allAnnotation)
            let touchLocation = sender.location(in: itemLocationMapView)
            let locationCoordinate = itemLocationMapView.convert(touchLocation, toCoordinateFrom: itemLocationMapView)
           // locationCoordinate.latitude
            latitude = locationCoordinate.latitude
            longitude = locationCoordinate.longitude
            print("-------",locationCoordinate.latitude)

//            let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
//            setStartingLocation(location: initialLocation, distance: 1000)
//
       
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            //pin.title = "location"
            itemLocationMapView.addAnnotation(pin)
        locationManager.startUpdatingLocation()

        
       // }
      //  if sender.state != UITapGestureRecognizer.State.began{
        //    return
       // }
//            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
//            itemLocationMapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func handleActionTouch(_ sender: Any) {
        if let image = postImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let title = postTitleTextField.text,
           let description = postDescriptionTextField.text,
           let country = postICountryTextField.text,
           let city = postCityTextField.text,
           let currentUser = Auth.auth().currentUser {
            let found = foundItem
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
    //write elment array on  pv
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
               // print(country)
                self.postICountryTextField.text = country ?? "Unknown"
                self.postCityTextField.text = city ?? "Unknown"
                print(country ?? ",,,,,,")
                

            }}

        
           
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
        
       // itemLocationMapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
       // locationManager.startUpdatingLocation()
        //locationManager1.requestLocation()
       // locationManager.stopUpdatingLocation()
        //locationManager.requestAlwaysAuthorization()
        //locationManager.requestAlwaysAuthorization()

    }
    
}
