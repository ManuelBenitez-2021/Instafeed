//
//  StarCollCell.swift
//  Instafeed
//
//  Created by gulam ali on 10/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage

protocol FollowAction {
    func handleFollowTap(index:Int)
}

class StarCollCell: UICollectionViewCell {
    
    @IBOutlet weak var myview: UIView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var lblSourceName: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    var followDelegate:FollowAction?
    
    var sourceData:StarSuggestion?{
        didSet{
            myview.layer.shadowColor = UIColor.black.cgColor
            myview.layer.shadowOpacity = 0.6
            myview.layer.shadowOffset = CGSize(width: 2, height: 4)
            myview.layer.shadowRadius = 3
            //myview.layer.shadowPath = UIBezierPath(rect: myview.bounds).cgPath
            
            btnFollow.layer.borderColor = UIColor.init(displayP3Red: 241/255, green: 126/255, blue: 58/255, alpha: 1.0).cgColor
            btnFollow.layer.borderWidth = 1
            btnFollow.layer.cornerRadius = 4
            
            if let userImage = sourceData?.avatar{
                let imgURL = URL(string: userImage)
                self.imgSource?.sd_setImage(with: imgURL, placeholderImage: nil, options: .progressiveLoad, context: nil)
                //.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "Account"), options: .highPriority, completed: nil)
            }else{
                self.imgSource.image = UIImage(named: "profile-icon")
            }
            if let name = sourceData?.first_name, !name.isEmpty{
                self.lblSourceName.text = name
            }else{
                if let name = sourceData?.username, !name.isEmpty{
                    self.lblSourceName.text = name
                }else{
                    self.lblSourceName.text = ""
                }
            }
        }
    }
    
    @IBAction func btnFollowAction(_ sender: UIButton) {
        followDelegate?.handleFollowTap(index: sender.tag)
    }
}
