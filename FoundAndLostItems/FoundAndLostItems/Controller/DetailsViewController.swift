//
//  DetailsViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 23/05/1443 AH.
//

import UIKit

class DetailsViewController: UIViewController {
    var selectedPost:Post?
    var selectedPostImage:UIImage?
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
        }
    }
    }



