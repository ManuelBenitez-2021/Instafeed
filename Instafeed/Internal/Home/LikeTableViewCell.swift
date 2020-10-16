//
//  LikeTableViewCell.swift
//  Instafeed
//
//  Created by HKC on 10/19/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit

protocol LikeTableViewCellDelegate: class{
    func userHasClickedFollowButton(index:IndexPath)
}

class LikeTableViewCell: UITableViewCell {

    var cellIndexPath: IndexPath!
    weak var delegate: LikeTableViewCellDelegate!

    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var profileimg: UIImageView!
    @IBOutlet weak var buttonFollow: IFRoundBorderButton!
    
    var like: likeListdata!{
        didSet{
           
            fullname.text = like.username
            
            let profilephoto = URL(string: like.avatar ?? "")
            let placeholder = UIImage(named: "profile-icon")
            profileimg.contentMode = .scaleAspectFill
            profileimg.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        profileimg.layer.cornerRadius = profileimg.frame.height / 2
    }
    
    @IBAction func actionFollow(_ sender: Any) {
        delegate.userHasClickedFollowButton(index: cellIndexPath)
    }
}
