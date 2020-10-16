//
//  CategoryFeedsDetailVC.swift
//  Instafeed
//
//  Created by Dharmbir Singh on 29/11/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation
import GPVideoPlayer
import FSPagerView
import SDWebImage

class CategoryFeedsDetailVC: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.imagearray.count
    }
    
    var userAvtar:String?
    
    @IBOutlet weak var heig_constraint: NSLayoutConstraint!
    @IBOutlet weak var addcomment_btn: UIButton!
    @IBOutlet weak var heightImgPost: NSLayoutConstraint!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var videoview: UIView!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
    
    //Fixing Multi Videos and Images
    @IBOutlet weak var multiVideoUSV: UIScrollView!
    
    var feed: categoryfeedData!
    var video =  [videosdata]()
    var imageOrg = String()
    var imagearray = [imageData]()
    var videoThumb = String()
    var dt_added = String()
    
    var postId = String()
    var moduleType = String()
    var videoPlayer: GPVideoPlayer?
    
    var videoViews = [UIView]()
    
    var feedDetail:citizenFeedsData? = nil
//    var barndDetail:brandfeedsData? = nil
    
    var isAnymones:String? = "n"
    
    @IBOutlet weak var pageView: FSPagerView! {
        didSet {
            self.pageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pageView.itemSize = FSPagerView.automaticSize
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        countLbl.isHidden = true
        self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.layer.bounds.size.width / 2
        self.imgProfilePic.clipsToBounds = true
        
        if feedDetail != nil {
            isAnymones = feedDetail?.is_anonymous
        }
        
        tabBarController?.tabBar.isHidden = true
        
        pageView.delegate = self
        pageView.dataSource = self
        
        addcomment_btn.layer.cornerRadius = 20.0
        addcomment_btn.GetBorder(border: 1.0)
        
        videoPlayer = GPVideoPlayer.initialize(with: self.videoview.bounds)
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(self.handlePostTap(_:)))
        lblPost.addGestureRecognizer(postTap)
        
    }
    
    @objc func handlePostTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
        
        move.moduleType = "1"
        guard let username = feedDetail?.username else{return}
        
        move.username = username
        guard let userId = feedDetail?.user_id else{return}
        move.userId = userId
        
        navigationController?.pushViewController(move, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if appDelegate.isBackFromComment {
            videoPlayer?.playVideo()
            //            appDelegate.isBackFromComment = false
        }
        
        self.getNews(postId: self.postId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoPlayer?.pauseVideo()
    }
    
    func setLayoutForView() {
//        lblFollowers.text = self.feed.date
        lblTitle.text = self.feedDetail?.title
        lblDate.text = dt_added
        txtViewDescription.text = self.feedDetail?.short_description
        lblLikeCount.text = self.feedDetail?.total_likes ?? "0"
        lblCommentCount.text = self.feedDetail?.total_comments ?? "0"
        btnLike.setImage(UIImage(named: (self.feedDetail?.is_like == "0" || self.feedDetail?.is_like == nil) ? "heart" : "filledHeart"), for: .normal)
        imgPost.sd_setImage(with: URL(string: self.imageOrg as String ), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
        lblTitle.text = self.feedDetail?.title ?? ""
        
        heightImgPost.constant = (moduleType == "3" ? 200 : 55)
        if moduleType == "3" {
            
            if self.feedDetail?.is_follow == "0" {
                
                btnFollow.setImage(UIImage(named: "Follow"), for: .normal)
            } else {
                
                btnFollow.setImage(UIImage(named: "Following"), for: .normal)
            }
        }
        
        if video.count > 0 {
            
            print("Video URL \(video[0].video ?? "")")
            
            self.imgPost.sd_setImage(with: URL(string: videoThumb ), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if !appDelegate.isBackFromComment{
                //                self.playVideo(videoURL: video[0].video ?? "")
            }else{
                appDelegate.isBackFromComment = false
            }
        }
        
        if isAnymones == "n"
        {
            if userAvtar != nil {
                let profileURL = URL(string: userAvtar ?? "")
                if profileURL != nil {
                    print("Profile URL => \(profileURL!)")
                    self.imgProfilePic.sd_setImage(with: profileURL!, placeholderImage: UIImage(named: "proo"), options: .preloadAllFrames, context: nil)
                }
                
                lblPost.text = moduleType == "3" ? self.feedDetail?.username : self.feedDetail?.first_name
            }
        }else{
            lblPost.text = "Anonymous"
        }
    }
    
    func getNews(postId: String) {
        
        
        var url = String()
        
        if moduleType == "1" {
            url = "citizen/posts"
        } else if moduleType == "2" {
            url = "star/posts"
        } else if moduleType == "3" {
            url = "brands/posts"
        } else if moduleType == "4" {
            url = "users/posts"
        } else {
            url = "brands/posts"
        }
        
        let apiurl = ServerURL.firstpoint + url
        let params = ["id":postId] as [String:Any]
        // let params = ["id":"604"] as [String:Any]
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:feedDescription) in
            print(response)
            
            if response.message == "error"{
                Toast().showToast(message: "Something went wrong please try again later!!!", duration: 2)
                self.navigationController?.popViewController(animated: true)
            }else{
                if let data = response.data {
                    print(data as Any)
//                    self.feed = data[0]
                    if data.count > 1 {
                        
                        self.video = (data[2].videos ?? nil)!
                        if data[2].videos?.count ?? 0 > 0 {
                            self.videoThumb = data[2].videos?[0].video_thumb ?? ""
                        }
                        
                    }
                    if data.count > 1 {
                        if let images = data[1].images {
//                            if images.isEmpty == false {
//                                self.imagearray = images
//                                self.imageOrg = images[0].image_264x200 ?? ""
//                                self.pageView.reloadData()
//                                self.countLbl.text = "\("1")/\(self.imagearray.count)"
//                                self.heig_constraint.constant = 400
//                            }else{
//
//                                self.heig_constraint.constant = 50
//                            }
                        }
                        
                        if self.video.count > 0 {
                            self.heig_constraint.constant = 350
                        }
                    }
                    
                    self.onShowVideoAndImageToScrollView()
                    self.countLbl.text = "1 / \(self.imagearray.count + self.video.count)"
                    
                    self.isThisPostLiked()
                    self.setLayoutForView()
                }
            }
        }
    }
    
    func onShowVideoAndImageToScrollView() {
        imgPost.isHidden = true
        pageView.isHidden = true
        
        
        let cnt = imagearray.count + video.count
        let heightUSV = multiVideoUSV.frame.size.height
        let widthUSV = multiVideoUSV.frame.size.width
        multiVideoUSV.contentSize = CGSize(width: widthUSV * CGFloat(cnt), height: heightUSV)
        
        for i in 0..<imagearray.count {
            let strUrl = self.imagearray[i].image_264x200
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i) * widthUSV, y: 0, width: widthUSV, height: heightUSV
            ))
            imageView.sd_setImage(with: URL(string: strUrl ?? ""), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
            imageView.contentMode = .scaleAspectFill
            multiVideoUSV.addSubview(imageView)
        }
        
        for i in 0..<video.count {
            let videoView = UIView(frame: CGRect(x: CGFloat(i + imagearray.count) * widthUSV, y: 0, width: widthUSV, height: heightUSV
            ))
            videoViews.append(videoView)
            multiVideoUSV.addSubview(videoView)
        }
        
        if (imagearray.count == 0 && video.count > 0) {
            self.scrollViewDidEndDecelerating(multiVideoUSV)
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFill
        let strUrl = self.imagearray[index].image_264x200

        cell.imageView!.sd_setImage(with: URL(string: strUrl ?? ""), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
        
        
        return cell
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
//        countLbl.text = "\(targetIndex + 1)/\(self.imagearray.count)"
        
    }
    
    private func playVideo(videoURL:String, view: UIView) {
        videoPlayer?.pauseVideo()
        videoPlayer?.removeFromSuperview()
        
        videoPlayer?.isToShowPlaybackControls = true
        view.addSubview(videoPlayer!)
        let videoUrls = URL(string: videoURL)!
        videoPlayer?.loadVideos(with: [videoUrls])
        videoPlayer?.isToShowPlaybackControls = true
        videoPlayer?.isMuted = false
        videoPlayer?.playVideo()
    }
    
    @IBAction func btnFollowAction(_ sender: UIButton) {
        if moduleType == "3"{
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            guard let userName = self.feedDetail?.username else{return}
            guard let id = self.feed.id else{return}
            CommonFuncs.addfollow(url: self.feed.is_follow == "0" ? ServerURL.addfollow :ServerURL.unfollow ,username: userName,vc: self, postid: id, token: UserToken, moduleId: self.moduleType, completionHandler: {resp, err in
                if resp?.message == "success"{
                    if self.feed.is_follow == "0"{
                        self.feed.is_follow = "1"
                        self.btnFollow.setImage(UIImage(named: "Following"), for: .normal)
                    }else{
                        self.feed.is_follow = "0"
                        self.btnFollow.setImage(UIImage(named: "Follow"), for: .normal)
                    }
                }
            })
        }
    }
    
    @IBAction func btnProfileTab(sender: UIButton){
        let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
        var boolIsMove = false
        if feedDetail != nil {
            move.username = feedDetail!.username!
            move.userId = feedDetail!.user_id!
            if feedDetail?.is_anonymous == "n"{
                boolIsMove = true
            }
        }
        if boolIsMove {
            navigationController?.pushViewController(move, animated: false)
        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMoreAction(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if moduleType != "3"{
            let bookmark = UIAlertAction(title: "Block", style: .default) { action -> Void in
                self.blockTap()
            }
            //btnCamera.setValue(UIImage(named:"camera-icon"), forKey: "image")
            bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
            actionSheetController.addAction(bookmark)
        }
        
        let More = UIAlertAction(title: "Report", style: .default) { action -> Void in
            self.spamActionSheet()
        }
        //btnGallery.setValue(UIImage(named:"gallery-icon"), forKey: "image")
        More.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(More)
        
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        btnCancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(btnCancel)
        
        //fix for ipad
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func btnCommentAction(_ sender: UIButton) {
        let move = storyboard?.instantiateViewController(withIdentifier: "CommentVc") as! CommentVc
        if moduleType == "1"{
            move.TabType = "citizen"
        }else if moduleType == "3"{
            move.TabType = "brand"
        }else{
            move.TabType = "Star"
        }
        guard let id = feedDetail?.id else{return}
        move.postId = id
        navigationController?.pushViewController(move, animated: true)
    }
    
    func isThisPostLiked() {
        var url = String()
        if moduleType == "1" {
            url = "citizen/isvote"
        } else if moduleType == "2" {
            url = "star/isvote"
        } else if moduleType == "3" {
            url = "brands/isvote"
        } else if moduleType == "4" {
            url = "users/isvote"
        } else {
            url = "brands/isvote"
        }
        
        let apiurl = ServerURL.firstpoint + url
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken, "id":postId] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:isPostLiked) in
            print(response)
            
            if response.status == 200 {
                
                if response.data?.message == "Already Up Vote marked" {
                    self.btnLike.setImage(UIImage(named: "filledHeart"), for: .normal)
                    self.feedDetail?.is_like = "1"
                } else {
                    self.btnLike.setImage(UIImage(named: "heart"), for: .normal)
                    self.feedDetail?.is_like = "0"
                }
            } else {
                self.feed.is_like = "0"
                self.btnLike.setImage(UIImage(named: "heart"), for: .normal)
            }
        }
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        
        var url = String()
        if moduleType == "1" {
            
            url = ServerURL.likepost
        }else if moduleType == "2" {
            
            url = ServerURL.starlikepost
        }else{
            
            url = ServerURL.brandlikePost
        }
        
        let apiurl = ServerURL.firstpoint + url
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken, "id":postId, "vote": (self.feedDetail?.is_like == "0" || self.feedDetail?.is_like == nil) ?"u" : "d", "type":moduleType] as [String:Any]
        print(params)
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:likePost) in
            print(response)
            
            if response.message == "error" {
                
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            } else {
                
                if let totalLikesCount = self.feedDetail?.total_likes {
                    var totalLikes:Int = Int(totalLikesCount)!
                    
                    self.lblLikeCount.text = self.feedDetail?.total_likes ?? "0"
                    //                    self.feed.is_like = (self.feed.is_like == "0" || self.feed.is_like == nil) ?  "1" : "0"
                    
                    if (self.feedDetail?.is_like == "0" || self.feedDetail?.is_like == nil){
                        
                        self.feedDetail?.is_like = "1"
                        totalLikes = totalLikes + 1
                        
                    }else{
                        self.feedDetail?.is_like = "0"
                        totalLikes = totalLikes - 1
                    }
                    
                    self.feedDetail?.total_likes = "\(totalLikes)"
                    self.feedDetail?.total_likes = String(format: "%ld", totalLikes)
                    self.lblLikeCount.text = self.feedDetail?.total_likes ?? "0"
                    self.btnLike.setImage(UIImage(named: self.feedDetail?.is_like == "0" ? "heart" : "filledHeart"), for: .normal)
                }
            }
        }
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        let txt = """
        http://13.234.116.90/news/\(self.feedDetail?.slug ?? "")
        
        Download App for more updates
        www.google.com
        """
        
        // set up activity view controller
        let imageToShare = [ txt ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func spamActionSheet(){
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let bookmark = UIAlertAction(title:"Spam", style: .default) { action -> Void in
            self.spamTap(reasonId: "1") //reasonId = "1"
        }
        
        bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(bookmark)
        
        let More = UIAlertAction(title: "Inappropriate", style: .default) { action -> Void in
            self.spamTap(reasonId: "2")//reasonId = "2"
        }
        
        More.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(More)
        let speech = UIAlertAction(title: "Racism, Hate speech", style: .default) { action -> Void in
            self.spamTap(reasonId: "3")//reasonId = "3"
        }
        
        speech.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(speech)
        
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        btnCancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(btnCancel)
        
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func spamTap(reasonId:String) {
        print("spam tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        guard let id = feed.id else {return}
        CommonFuncs.spammarked(url: ServerURL.addspam,vc: self, postid: id, token: UserToken, moduleId: "2", reasonId: reasonId, completionHandler: {resp, err in
            if resp?.message == "success"{
                self.spamSuccess()
            }
        })
    }
    
    func spamSuccess(){
        Toast().showToast(message: "Reported", duration: 2)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func blockTap() {
        
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        guard let userName = self.feedDetail?.username else{return}
        
        let params = ["token":UserToken, "username":userName] as [String:Any]
        print(params)
        let apiurl = ServerURL.firstpoint + ServerURL.blockUser
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:userBlocked) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    Toast().showToast(message: "Blocked", duration: 2)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        
    }
}

extension CategoryFeedsDetailVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if imagearray.count + video.count == 0 {
            return
        }
        let index: Int = Int(multiVideoUSV.contentOffset.x / multiVideoUSV.frame.width)
        if Int(index) > imagearray.count - 1 {
            let videoIndex = index - imagearray.count
            let url = video[videoIndex].video!
            let view = videoViews[videoIndex]
            playVideo(videoURL: url, view: view)
        }
        self.countLbl.text = "\(index + 1) / \(self.imagearray.count + self.video.count)"
    }
    
}

