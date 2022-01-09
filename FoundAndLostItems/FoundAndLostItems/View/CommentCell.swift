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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with comment:Comment) -> UITableViewCell {
        userNameCell.text = comment.user.name + " :"
        commentCell.text = comment.comment
        return self
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
}
