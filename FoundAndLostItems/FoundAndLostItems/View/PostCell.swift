//
//  PostCell.swift
//  FoundAndLostItems
//
//  Created by Maram F on 22/05/1443 AH.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    
  
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    @IBOutlet weak var postLocationLabel: UILabel!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with post:Post) -> UITableViewCell {
        postTitleLabel.text = post.title
        postDescriptionLabel.text = post.description
        postImageView.loadImageUsingCache(with: post.imageUrl)
        postLocationLabel.text = "\(post.country),\(post.city)"
        postTimeLabel.text = String(describing: post.createdAt)
        return self
    }
    
    override func prepareForReuse() {
        postImageView.image = nil
    }
        // Configure the view for the selected state
    }
    
   
