//
//  contactcell.swift
//  Instafeed
//
//  Created by gulam ali on 14/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

protocol FollowButtonTapped {
    func followTapped(indexpath: Int)
}

class contactcell: UITableViewCell {

    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    var followDelegate: FollowButtonTapped?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgProfilePic.layer.cornerRadius = (self.imgProfilePic.layer.bounds.size.width / 2)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnFollowAction(_ sender: UIButton) {
        followDelegate?.followTapped(indexpath: sender.tag)
    }
    
}
