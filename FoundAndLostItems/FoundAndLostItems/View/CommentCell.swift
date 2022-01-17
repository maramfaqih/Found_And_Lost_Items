//
//  CommentCell.swift
//  FoundAndLostItems
//
//  Created by Maram F on 05/06/1443 AH.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userNameCell: UILabel!
    @IBOutlet weak var commentCell: UILabel!
    
    @IBOutlet weak var viewCommentCell: UIView!{
        didSet{
            viewCommentCell.layer.cornerRadius = 15
            viewCommentCell.layer.masksToBounds = true
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with comment:Comment) -> UITableViewCell {
        if comment.userId == comment.publisherUserId{
            userNameCell.text = comment.user.name + "publisher".localized
    }else{
        userNameCell.text = comment.user.name + " :"}

    
        commentCell.text = comment.comment
        return self
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
}
