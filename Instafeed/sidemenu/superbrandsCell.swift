//
//  superbrandsCell.swift
//  Instafeed
//
//  Created by gulam ali on 14/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

protocol SuperBrandsCellDelegate {
    func onSelectedBrandStatus(row: Int, value: Int)
}

class superbrandsCell: UITableViewCell {
    
    var delegate: SuperBrandsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
    
    @IBAction func onClickOff(_ sender: Any) {
        let row = getIndexPath()?.row
        self.delegate?.onSelectedBrandStatus(row: row!, value: 0)
    }
    
    @IBAction func onClickStar(_ sender: Any) {
        let row = getIndexPath()?.row
        self.delegate?.onSelectedBrandStatus(row: row!, value: 1)
    }
    
    @IBAction func onClickAll(_ sender: Any) {
        let row = getIndexPath()?.row
        self.delegate?.onSelectedBrandStatus(row: row!, value: 2)
    }

}
