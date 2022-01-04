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
    @IBOutlet weak var titleApp1Label: UILabel!{
        didSet{
            titleApp1Label.text = "titleApp1".localized
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
    @IBOutlet weak var titleApp2Label: UILabel!{
        didSet{
            titleApp2Label.text = "titleApp2".localized
        }
    }
  
    var latitude : CLLocationDegrees = 0.0
    var longitude :  CLLocationDegrees = 0.0
    var selectedPost:Post?
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
print("selectedPost.latitude",selectedPost.latitude)
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(selectedPost.latitude, selectedPost.longitude)
            pin.title = "location".localized
            itemLocationMapView.addAnnotation(pin)
        }
    }
    

func setStartingLocation(location: CLLocation, distance: CLLocationDistance){
    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
    itemLocationMapView.setRegion(region, animated: true)
   

}


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
