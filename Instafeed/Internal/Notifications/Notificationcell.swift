//
//  Notificationcell.swift
//  Instafeed
//
//  Created by gulam ali on 09/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class Notificationcell: UITableViewCell {

    @IBOutlet weak var NotiTitle: UILabel!
    @IBOutlet weak var NotiDate: UILabel!
    @IBOutlet weak var NotiDetail: UILabel!
    @IBOutlet weak var UserImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var Notidata: NotificationData! {
        didSet {
            NotiTitle.text = Notidata.notification
            NotiDate.text = Notidata.dt_added
            NotiDetail.text = Notidata.notification

            let profilephoto = URL(string: Notidata.avatar ?? "")
            let placeholder = UIImage(named: "profile-icon")
            UserImage.contentMode = .scaleAspectFill
            UserImage.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
