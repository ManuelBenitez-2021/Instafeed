//
//  CommentVc.swift
//  Instafeed
//
//  Created by gulam ali on 31/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class CommentVc: UIViewController {
    
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var commenttxtview: UITextView!
    @IBOutlet weak var commentbox: UIView!
    
    
    var TabType = ""
    var brandFeeddata : brandfeedsData!
    var postId = String()
    var replyId = ""
    var citizendata : citizenFeedsData!
    var CitizenCommentList = [citizenCommentListdata]()
    var starCommentList = [citizenCommentListdata]()
    var brandcommentList = [brandCommentListdata]()
    
    @IBOutlet var bottomImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print(brandFeeddata)
        tblview.delegate = self
        tblview.dataSource = self
        tblview.rowHeight = UITableView.automaticDimension
        tblview.estimatedRowHeight = 200
        
        
       commentbox.layer.borderColor = UIColor.orange.cgColor
        commentbox.layer.borderWidth = 1
        commentbox.layer.cornerRadius = commentbox.frame.height/2
        
        commenttxtview.font = UIFont.preferredFont(forTextStyle: .headline)
        commenttxtview.delegate = self
        
        let userName = (UserDefaults.standard.value(forKey: "UserName") as! String)
        commenttxtview.text = "Comment as \(userName)"
        commenttxtview.textColor = UIColor.lightGray
        
        callList()
        bottomImage.layer.cornerRadius = bottomImage.frame.size.height / 2
        bottomImage.clipsToBounds = true
        if let userURL = URL(string: UserDefaults.standard.value(forKey: "ProfileImage") as! String) {
            bottomImage.sd_setImage(with: userURL, completed: nil)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        tabBarController?.tabBar.isHidden = true
    }

    @IBAction func backbtnTapped(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isBackFromComment = true
        navigationController?.popViewController(animated: true)
    }

    
    func callList(){
        if postId.isEmpty {
            if TabType == "citizen" {
                //citizendata
                guard let data = citizendata else {return}
                let id = data.id
                guard let postid = id else {return}
                getCommentList(postId: postid)
                postId = postid
            }else if TabType == "Star" {
                guard let data = citizendata else {return}
                let id = data.id
                guard let postid = id else {return}
                 getStarList(postId: postid)
                postId = postid
            }else{
                guard let data = brandFeeddata else {return}
                let id = data.id
                guard let postid = id else {return}
                BrandgetCommentList(postId: postid)
                postId = postid
            }
        }else{
            if TabType == "citizen" {
                //citizendata
                getCommentList(postId: postId)
            }else if TabType == "Star" {
                getStarList(postId: postId)
            }else{
                BrandgetCommentList(postId: postId)
            }
        }
        
    }
    
    //MARK:>>>>> Citizen Comment List
    fileprivate func getCommentList(postId:String) {
        let apiurl = ServerURL.firstpoint + ServerURL.citizenCommentList + "?id=\(postId)"
        let params = ["id":postId] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (result:citizenCommentList) in
            print(result.message)
            
            if result.message == "success"{
                if let response = result.data{
                    print(response)
                    self.CitizenCommentList = response.map{$0}
                    print("your array -> \(self.CitizenCommentList)")
                    DispatchQueue.main.async {
                        self.tblview.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    //MARK:>>>>> Citizen Comment List
    fileprivate func getStarList(postId:String){
        let apiurl = ServerURL.firstpoint + ServerURL.starCommentList + "?id=\(postId)"
        let params = ["id":postId] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (result:citizenCommentList) in
            print(result.message)
            
            if result.message == "success"{
                if let response = result.data{
                    print(response)
                    self.starCommentList = response.map{$0}
                    print("your array -> \(self.CitizenCommentList)")
                    DispatchQueue.main.async {
                        self.tblview.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    
    //MARK:>>>>> Brand Comment List
    private func BrandgetCommentList(postId:String) {
        let apiurl = ServerURL.firstpoint + ServerURL.brandCommentList + "?id=\(postId)"
        let params = ["id":postId] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (result:brandCommentList) in
            print(result.message)
            
            if result.message == "success"{
                if let response = result.data{
                    print(response)
                    self.brandcommentList = response.map{$0}
                    print("your array -> \(self.brandcommentList)")
                    DispatchQueue.main.async {
                        self.tblview.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    
    //MARK:>>>> Add comment in brand tab
    
    private func Addcomment_Brand(postID:String){
        let api = ServerURL.firstpoint + ServerURL.brandaddcomment
         guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken,"id":postID,"comment":commenttxtview.text!] as [String:Any]
        
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result:addcommentBRAND) in
            print(result.message)
            
            if result.message == "success" {
                if let response = result.data {
                    guard let staus = response.status else {return}
                    if staus == "A"{
                        //comment successfully addded
                        self.commenttxtview.text = ""
                        self.BrandgetCommentList(postId: postID)
                    }else{
                        print("else cased")
                        return
                    }
                    
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    
    //MARK:>>>> Add comment in citizen tab
    
    private func Addcomment_Citizen(postID: String) {
        let api = ServerURL.firstpoint + ServerURL.citizenAddComment
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken,"id":postID,"comment":commenttxtview.text!,"reply_id":self.replyId] as [String:Any]
        
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result:addcommentCITIZEN) in
            print(result.message)
            
            if result.message == "success"{
                if let response = result.data{
                    guard let staus = response.status else {return}
                    if staus == "A"{
                        //comment successfully addded
                        self.replyId = ""
                        self.commenttxtview.text = ""
                        self.getCommentList(postId: postID)
                    }else{
                        print("else cased")
                        return
                    }
                    
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    private func Add_Reply_Citizen(postID:String, commentId: String) {
           let api = ServerURL.firstpoint + ServerURL.citizenAddComment
           guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
           let params = ["token":UserToken,"id":postID,"comment":commenttxtview.text!] as [String:Any]
           
           networking.MakeRequest(Url: api, Param: params, vc: self) { (result:addcommentCITIZEN) in
               print(result.message)
               
               if result.message == "success"{
                   if let response = result.data{
                       guard let staus = response.status else {return}
                       if staus == "A"{
                           //comment successfully addded
                           self.commenttxtview.text = ""
                           self.getCommentList(postId: postID)
                       }else{
                           print("else cased")
                           return
                       }
                       
                   }
               }else{
                   CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                   return
               }
           }
       }
       
    
    fileprivate func Addcomment_star(postID:String){
        let api = ServerURL.firstpoint + ServerURL.starAddComment
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken,"id":postID,"comment":commenttxtview.text!] as [String:Any]
        
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result:addcommentCITIZEN) in
            print(result.message)
            
            if result.message == "success"{
                if let response = result.data{
                    guard let staus = response.status else {return}
                    if staus == "A"{
                        //comment successfully addded
                        self.commenttxtview.text = ""
                        self.getCommentList(postId: postID)
                    }else{
                        print("else cased")
                        return
                    }
                    
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    
    func getParams_brandfeeds() {
       // print(brandFeeddata)
//        guard let data = brandFeeddata else {return}
//        let id = data.id
//        guard let postid = id else {return}
        Addcomment_Brand(postID: self.postId)
    }
    
    
    func getParams_citizenfeeds() {
//        guard let data = citizendata else {return}
//        let id = data.id
//        guard let postid = id else {return}
        
        
        Addcomment_Citizen(postID: self.postId)
    }
    func getParams_Starfeeds(){
//        guard let data = citizendata else {return}
//        let id = data.id
//        guard let postid = id else {return}
        Addcomment_star(postID: self.postId)
    }
    
    @IBAction func postComment(_ sender: Any) {
        
        let userName = (UserDefaults.standard.value(forKey: "UserName") as! String)
        if commenttxtview.text == "" || commenttxtview.text == "Comment as \(userName)" {
          //show alert
            CommonFuncs.AlertWithOK(msg: "Write a comment to post", vc: self)
            return
        }else{
            if TabType == "citizen" {
                getParams_citizenfeeds()
            } else if TabType == "Star" {
                getParams_Starfeeds()
            } else {
               getParams_brandfeeds()
            }
        }
    }
    
    @IBAction func btnReplyClicked(_ sender: Any) {        
        let replyButton = sender as! UIButton
        commenttxtview.becomeFirstResponder()
        if let cell = replyButton.superview?.superview as? commentCell {
            let iP = tblview.indexPath(for: cell)
            
            
            if TabType == "citizen" {
                replyId = CitizenCommentList[iP?.row ?? 0].id ?? "0"
            }else if TabType == "Star" {
                replyId = starCommentList[iP?.row ?? 0].id ?? "0"
            } else {
                replyId = brandcommentList[iP?.row ?? 0].id ?? "0"
            }
        }
    }
    
    deinit {
        print("commentvc removed")
    }
    
}

extension CommentVc : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TabType == "citizen"{
            return CitizenCommentList.count
        }else if TabType == "Star"{
            return starCommentList.count
        } else{
            return brandcommentList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        if TabType == "citizen"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! commentCell
            cell.profile.tag = (indexPath.row)
            cell.profile.addGestureRecognizer(tap)
            cell.citizenlist = CitizenCommentList[indexPath.row]
            cell.didtapedit = {
                let alert = UIAlertController(title: nil, message: "Edit comment", preferredStyle: .alert)
                alert.addTextField { (txtComment) in
                    txtComment.text = self.CitizenCommentList[indexPath.row].comment
                }
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
                    let comment = alert.textFields![0].text
                    if comment != nil && comment!.count > 0 {
                        self.Edit_comment(postID: self.CitizenCommentList[indexPath.row].id!, postType: "Citizen", newComment: comment!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            cell.didtapDelete = {
                self.Delete_comment(postID:self.CitizenCommentList[indexPath.row].id!, postType: "Citizen")
            }
            cell.delegate = self
            return cell
        } else if TabType == "Star" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! commentCell
            cell.profile.tag = (indexPath.row)
            cell.profile.addGestureRecognizer(tap)
            cell.citizenlist = starCommentList[indexPath.row]
            cell.didtapedit = {
                let alert = UIAlertController(title: nil, message: "Edit comment", preferredStyle: .alert)
                alert.addTextField { (txtComment) in
                    txtComment.text = self.starCommentList[indexPath.row].comment
                }
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
                    let comment = alert.textFields![0].text
                    if comment != nil && comment!.count > 0 {
                       self.Edit_comment(postID: self.starCommentList[indexPath.row].id!, postType: "Star", newComment: comment!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            cell.didtapDelete = {
                self.Delete_comment(postID:self.starCommentList[indexPath.row].id!, postType: "Star")
            }
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! commentCell
            cell.brandlist = brandcommentList[indexPath.row]
            cell.profile.tag = (indexPath.row)
            cell.profile.addGestureRecognizer(tap)
            cell.didtapedit = {
                let alert = UIAlertController(title: nil, message: "Edit comment", preferredStyle: .alert)
                alert.addTextField { (txtComment) in
                    txtComment.text = self.brandcommentList[indexPath.row].comment
                }
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
                    let comment = alert.textFields![0].text
                    if comment != nil && comment!.count > 0 {
                       self.Edit_comment(postID: self.brandcommentList[indexPath.row].id!, postType: "Brand", newComment: comment!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            cell.didtapDelete = {
                self.Delete_comment(postID:self.brandcommentList[indexPath.row].id!, postType: "Brand")
            }
            cell.delegate = self
            return cell
        }
       
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView{
            if TabType == "citizen"{
                if let user_id = CitizenCommentList[imageView.tag].user_id, let username = CitizenCommentList[imageView.tag].username {
                    let story = UIStoryboard(name: "categoryStoryboard", bundle: nil)
                    let move = story.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
                    move.userId = user_id
                    move.username = username
                    navigationController?.pushViewController(move, animated: true)
                }
            } else if TabType == "Star"{
                if let user_id = starCommentList[imageView.tag].user_id, let username = CitizenCommentList[imageView.tag].username{
                    let story = UIStoryboard(name: "categoryStoryboard", bundle: nil)
                    let move = story.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
                    move.userId = user_id
                    move.username = username
                    navigationController?.pushViewController(move, animated: true)
                }
            }else {
                if let user_id = brandcommentList[imageView.tag].id, let username = CitizenCommentList[imageView.tag].username {
                let story = UIStoryboard(name: "categoryStoryboard", bundle: nil)
                let move = story.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
                move.userId = user_id
                move.username = username
                navigationController?.pushViewController(move, animated: true)
                }
            }
        }
    }
    
    fileprivate func Delete_comment(postID:String, postType: String){
        
        var api = ServerURL.firstpoint + ServerURL.starAddComment
        if postType == "Citizen"{
            api = "\(ServerURL.firstpoint)citizen/comment/delete"
        }else if postType == "Star"{
            api = "\(ServerURL.firstpoint)star/comment/delete"
        }else{
            api = "\(ServerURL.firstpoint)brands/comment/delete"
        }
           guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
           let params = ["token":UserToken,"id":postID,"comment":commenttxtview.text!] as [String:Any]
           
           networking.MakeRequest(Url: api, Param: params, vc: self) { (result:addcommentCITIZEN) in
               print(result.message)
               
               if result.message == "success"{
                self.getCommentList(postId: postID)
                      if self.TabType == "citizen"{
                            guard let data = self.citizendata else {return}
                            let id = data.id
                            guard let postid = id else {return}
                            self.getCommentList(postId: postid)
                     }else if self.TabType == "Star"{
                            guard let data = self.citizendata else {return}
                            let id = data.id
                            guard let postid = id else {return}
                            self.getStarList(postId: postid)
                    }else{
                            guard let data = self.brandFeeddata else {return}
                            let id = data.id
                            guard let postid = id else {return}
                            self.BrandgetCommentList(postId: postid)
                    }
               }else{
                   CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                   return
               }
           }
       }
    
    fileprivate func Edit_comment(postID:String, postType: String,newComment: String){
     
     var api = ServerURL.firstpoint + ServerURL.starAddComment
     if postType == "Citizen"{
         api = "\(ServerURL.firstpoint)citizen/comment/edit"
     }else if postType == "Star"{
         api = "\(ServerURL.firstpoint)star/comment/edit"
     }else{
         api = "\(ServerURL.firstpoint)brands/comment/edit"
     }
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken,"id":postID,"comment":newComment] as [String:Any]
        
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result:addcommentCITIZEN) in
            print(result.message)
            
            if result.message == "success"{
//                self.callList()
                   if self.TabType == "citizen"{
                         guard let data = self.citizendata else {return}
                         let id = data.id
                         guard let postid = id else {return}
                         self.getCommentList(postId: postid)
                  }else if self.TabType == "Star"{
                         guard let data = self.citizendata else {return}
                         let id = data.id
                         guard let postid = id else {return}
                         self.getStarList(postId: postid)
                 }else{
                         guard let data = self.brandFeeddata else {return}
                         let id = data.id
                         guard let postid = id else {return}
                         self.BrandgetCommentList(postId: postid)
                 }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    
}


extension CommentVc : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            let userName = (UserDefaults.standard.value(forKey: "UserName") as! String)
            textView.text = "Comment as \(userName)"
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension CommentVc: CommentCellDelegate {
    
    func onClickCommentCell(sup: IndexPath, sub: String) {
        let alert = UIAlertController(title: nil, message: "Reply comment", preferredStyle: .alert)
        alert.addTextField { (txtComment) in
            txtComment.text = sub
        }
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
            let comment = alert.textFields![0].text
            if comment != nil && comment!.count > 0 {
               //
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension String {

    func retrieveTextHeight (width: CGFloat) -> CGFloat {
        let attributedText = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica Neue", size: 15.0)!])

        let rect = attributedText.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)

        return ceil(rect.size.height)
    }

}
