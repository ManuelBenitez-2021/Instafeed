
//
//  commentCell.swift
//  Instafeed
//
//  Created by gulam ali on 31/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage

protocol CommentCellDelegate {
    func onClickCommentCell(sup: IndexPath, sub: String);
}

class commentCell: UITableViewCell {
    @IBOutlet weak var profile: UIImageView!
    
    @IBOutlet weak var commentlbl: UILabel!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var replyTable: UITableView!
    @IBOutlet weak var replyTableHeight: NSLayoutConstraint!
    @IBOutlet var btnProfile: UIButton!
    
    var delegate: CommentCellDelegate?

    var didtapedit : (()-> Void)? =  nil
    var didtapDelete : (()-> Void)? =  nil
    var myindexpath:IndexPath!
    var replyList: [citizenThredListdata]?
    
    var citizenlist:citizenCommentListdata!{
        didSet{
            guard let firstname = citizenlist.first_name else{return}
            guard let comm = citizenlist.comment else{return}
            guard let image = citizenlist.avatar else {return}
            
            replyList = citizenlist.thread
            
            var tableHeight: CGFloat = 0.0
            for reply in replyList ?? [] {
                
                let commentStr = "\(String(describing: reply.first_name))\n\(String(describing: reply.comment))"
                
                tableHeight = tableHeight + (commentStr.retrieveTextHeight(width: replyTable.frame.width - 100) ) + 30
            }
            
            replyTableHeight.constant = tableHeight
            replyTable.delegate = self
            replyTable.dataSource = self
            replyTable.rowHeight = UITableView.automaticDimension
            replyTable.reloadData()
//            replyTable.backgroundColor = UIColor.red
            
            let recentimage = URL(string: image )
            let placeholder = UIImage(named: "profile-icon")

            profile.layer.cornerRadius = 15.0
            if recentimage != nil {
                profile.sd_setImage(with: recentimage!, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
            }

            let fullstr = "\(firstname)\n\(comm)"
            commentlbl.attributedText = attributedText(withString: fullstr, boldString: firstname, font: UIFont(name: "Helvetica Neue", size: 15.0)!)
            
            let myuserID = UserDefaults.standard.value(forKey: "user_id") as! String
            if citizenlist.user_id == myuserID {
                EditBtn.isHidden = false
                deleteBtn.isHidden = false
            }else{
                EditBtn.isHidden = true
                deleteBtn.isHidden = true
            }
        }
    }
    
    @IBAction func EditBtnClicked(_ sender: Any) {
            didtapedit?()
    }
    @IBAction func DeleteBtnClicked(_ sender: Any) {
            didtapDelete?()
    }
    var brandlist:brandCommentListdata!{
        didSet{
            guard let comm = brandlist.comment else {return}
            guard let firstname = brandlist.first_name else {return}
            
            let fullstr = "\(firstname)\n \(comm)"
            commentlbl.attributedText = attributedText(withString: fullstr, boldString: firstname, font: UIFont(name: "Helvetica Neue", size: 17.0)!)
        }
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 15.0)!])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension commentCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell") as! replyCell
            cell.profile.tag = (indexPath.row)
        cell.citizenlist = replyList?[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let reply = citizenlist.thread![indexPath.row] as citizenThredListdata
        
        let commentStr = "\(String(describing: reply.first_name))\n\(reply.comment ?? "")"
        
        let tableHeight = commentStr.retrieveTextHeight(width: replyTable.frame.width - 100) + 30
        
        return tableHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! replyCell
        cell.backgroundView?.backgroundColor = UIColor.orange
        self.delegate?.onClickCommentCell(sup: self.indexPath!, sub: cell.commentlbl.text!)
    }
    
}


class replyCell: UITableViewCell {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet var btnProfile: UIButton!
    
    @IBOutlet weak var commentlbl: UILabel!
    
    var myindexpath:IndexPath!
    
    var citizenlist:citizenThredListdata!{
        didSet{
            guard let firstname = citizenlist.first_name else{return}
            guard let comm = citizenlist.comment else{return}
            guard let image = citizenlist.avatar else {return}
            
            let recentimage = URL(string: image )
            let placeholder = UIImage(named: "profile-icon")

            profile.layer.cornerRadius = 15.0
            if recentimage != nil {
                profile.sd_setImage(with: recentimage!, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
            }

            let fullstr = "\(firstname)\n \(comm)"
            commentlbl.attributedText = attributedText(withString: fullstr, boldString: firstname, font: UIFont(name: "Helvetica Neue", size: 15.0)!)
            
//            var rect = commentlbl.frame
//            rect.size.height = rect.size.height+20
//            commentlbl.frame = rect
//            commentlbl.backgroundColor = UIColor.yellow
        }
        
    }
    
    var brandlist:brandCommentListdata!{
        didSet{
            guard let comm = brandlist.comment else {return}
            guard let firstname = brandlist.first_name else {return}
            
            let fullstr = "\(firstname)\n \(comm)"
            commentlbl.attributedText = attributedText(withString: fullstr, boldString: firstname, font: UIFont(name: "Helvetica Neue", size: 17.0)!)
        }
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 15.0)!])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UITableViewCell {
    var tableView: UITableView? {
        return self.next(of: UITableView.self)
    }

    var indexPath: IndexPath? {
        return self.tableView?.indexPath(for: self)
    }
}

extension UIResponder {
    /**
     * Returns the next responder in the responder chain cast to the given type, or
     * if nil, recurses the chain until the next responder is nil or castable.
     */
    func next<U: UIResponder>(of type: U.Type = U.self) -> U? {
        return self.next.flatMap({ $0 as? U ?? $0.next() })
    }
}
