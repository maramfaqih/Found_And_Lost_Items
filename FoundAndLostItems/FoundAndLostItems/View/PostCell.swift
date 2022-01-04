//
//  PostCell.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import SwiftUI
class PostCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!

    
    @IBOutlet weak var shadowViewCell: UIView!
    
    @IBOutlet weak var backgroundViewCell: UIView!
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    @IBOutlet weak var postLocationLabel: UILabel!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    
    @IBOutlet weak var postFoundView: UIView!
    @IBOutlet weak var postFoundLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with post:Post) -> UITableViewCell {
       // backgroundViewCell.backgroundColor = .systemGray6
        backgroundViewCell.layer.cornerRadius = 15
        backgroundViewCell.layer.masksToBounds = true
        shadowViewCell.layer.cornerRadius = 15
        shadowViewCell.layer.masksToBounds = true
        shadowViewCell.layer.shadowOpacity = 0.15
        shadowViewCell.layer.shadowRadius = 4
        shadowViewCell.layer.masksToBounds = false
       
        postFoundLabel.text = post.found.localized
        postTitleLabel.text = post.title
        postDescriptionLabel.text = post.description
        postImageView.loadImageUsingCache(with: post.imageUrl)
        postLocationLabel.text = "\(post.country),\(post.city)"
        if let createdAt = post.createdAt {
        postTimeLabel.text = String(describing: createdAt.dateValue().timeAgoDisplay())
        }
        if postFoundLabel.text == "found" || postFoundLabel.text == "موجود" {
            postFoundView.backgroundColor = .systemGreen
        }else{
            postFoundView.backgroundColor = .systemRed
        }
        return self
    }
    
    override func prepareForReuse() {
        postImageView.image = nil
    }
        // Configure the view for the selected state
    }
    
   

extension Date {
   func timeAgoDisplay() -> String {
 let secondsAgo = Int(Date().timeIntervalSince(self))

 let minute = 60
 let hour = 60 * minute
 let day = 24 * hour
 let week = 7 * day

 if secondsAgo < minute {
     return "from".localized+"\(secondsAgo)"+"secAgo".localized
 } else if secondsAgo < hour {
     return "from".localized+"\(secondsAgo / minute)"+"minAgo".localized
 } else if secondsAgo < day {
     return "from".localized+"\(secondsAgo / hour)"+"hrsAgo"
 } else if secondsAgo < week {
     return "from".localized+"\(secondsAgo / day)"+"daysAgo".localized
 }

       return "from".localized+"\(secondsAgo / week)"+"weeksAgo".localized
}
}

