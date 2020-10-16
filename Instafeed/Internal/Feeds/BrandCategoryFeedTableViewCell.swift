//
//  BrandCategoryFeedTableViewCell.swift
//  Instafeed
//
//  Created by A1GEISP7 on 14/09/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class BrandCategoryFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
