//
//  DetailsViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 23/05/1443 AH.
//

import UIKit
import CoreLocation
import MapKit
class DetailsViewController: UIViewController {
    var latitude : CLLocationDegrees = 16.88905
    var longitude :  CLLocationDegrees = 42.56461
    var selectedPost:Post?
    var selectedPostImage:UIImage?
    @IBOutlet weak var itemLocationMapView: MKMapView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionTextView: UITextView!
    @IBOutlet weak var country : UILabel!
    @IBOutlet weak var  city : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
          
        // Do any additional setup after loading the view.
        if let selectedPost = selectedPost,
        let selectedImage = selectedPostImage{
            postTitleLabel.text = selectedPost.title
            postDescriptionTextView.text = selectedPost.description
            country.text = selectedPost.country
            country.text = selectedPost.city
            
            postImageView.image = selectedImage
            let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
            setStartingLocation(location: initialLocation, distance: 1000)

            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            pin.title = "Current location"
            itemLocationMapView.addAnnotation(pin)
        }
    }
    

func setStartingLocation(location: CLLocation, distance: CLLocationDistance){
    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
    itemLocationMapView.setRegion(region, animated: true)
   

}


}
