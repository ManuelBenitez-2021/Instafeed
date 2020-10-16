//
//  CategoryCollectionViewCell.swift
//  Instafeed
//
//  Created by A1GEISP7 on 14/09/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var imgSelection: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
