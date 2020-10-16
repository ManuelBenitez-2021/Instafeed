//
//  CitizenProfile.swift
//  Instafeed
//
//  Created by gulam ali on 11/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class CitizenProfile: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var lblFeedsCount: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var followingUB: UIButton!
    
    var username = String()
    var userId = String()
    var moduleType = String()
    var feeds = [citizenFeedsData]()
    var response: Profiledata = Profiledata()
    var is_following = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSetUpOfView()
        self.imgProfile.layer.cornerRadius = self.imgProfile.layer.bounds.size.width / 2
        
        tblview.delegate = self
        tblview.dataSource = self
        tblview.tableFooterView = UIView()
        tblview.rowHeight = UITableView.automaticDimension
        tblview.register(UINib(nibName: "citizentblcell", bundle: nil), forCellReuseIdentifier: "citizentblcell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getProfile(username: username)
        self.getFollowing(userName: username)
    }
    
    func initSetUpOfView(){
        self.imgProfile.sd_setImage(with: URL(string: self.response.avatar ?? ""), placeholderImage: UIImage(named: "proo"), options: .highPriority, completed: nil)
        self.lblCity.text = self.response.address ?? ""
        self.lblUserName.text = "\(self.response.first_name ?? "") \(self.response.last_name ?? "")"
        if self.response.totals?.total_news_posts == nil {
        self.response.totals?.total_news_posts = "0"

        self.lblFeedsCount.text = self.response.totals?.total_news_posts
        self.lblFollowersCount.text = self.response.totals?.total_followers
        self.lblFollowingCount.text = self.response.totals?.total_following
    }
    }
    
    @IBAction func backtapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func profileImageClicked(_ sender: Any) {
        let story = UIStoryboard(name: "categoryStoryboard", bundle: nil)
        let move = story.instantiateViewController(withIdentifier: "ProfileImageDetailViewController") as! ProfileImageDetailViewController
        move.imageURLString = URL(string: self.response.avatar ?? "")
        navigationController?.pushViewController(move, animated: false)
    }

    deinit {
        print("citizenProfile removed")
    }
    
    func getProfile(username: String) {
        print("single news")
        let apiurl = ServerURL.firstpoint + ServerURL.singleprofile
        let params = ["username":username] as [String:Any]
        print(params)
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response: ProfileDataModel) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
            } else {
                if let data = response.data {
                    print(data as Any)
                    self.response = data
                    if username != "" {
                        self.citizentab_getfeeds(userid: username)
                    }
                    else if data.username != nil {
                        self.citizentab_getfeeds(userid:data.username!)
                    }
                    self.initSetUpOfView()
                }
            }
        }
    }
    
    func getFollowing(userName: String) {
        let apiurl = ServerURL.firstpoint + ServerURL.isFollow

        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        let params = ["token":UserToken, "username":userName] as [String:Any]
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:FollowingStatus) in
            print(response)

            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
            }else{
                if let data = response.data{
                    self.is_following = data.is_following!
                    if self.is_following {
                        self.followingUB.tintColor = UIColor.orange
                    } else {
                        self.followingUB.tintColor = UIColor.lightGray
                    }
                }
            }
        }
    }
    
    fileprivate func citizentab_getfeeds(userid:String){
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        var apiURL = ServerURL.firstpoint;
        if moduleType == "1" {
            apiURL = apiURL + ServerURL.userpost + "?username=\(userid)"
        } else {
            apiURL = apiURL + ServerURL.starpost + "?username=\(userid)"
        }
        let params = ["token":UserToken] as [String:Any]
        print(apiURL)

        networking.MakeRequest(Url: apiURL, Param: params, vc: self) { (result:citizenFeeds) in
            print(result)
            if result.message == "success"{
                if let feedsArray = result.data {
                    self.feeds = feedsArray
                    DispatchQueue.main.async {
                        self.tblview.reloadData()
                    }
                }
            } else {
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
            }
        }
    }
    
    @IBAction func onClickFollowingUB(_ sender: Any) {
        var apiurl = ServerURL.firstpoint
        if is_following {
             apiurl = apiurl + ServerURL.unfollow
        } else {
            apiurl = apiurl + ServerURL.addfollow
        }
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        let params = [
            "token": UserToken,
            "username": username] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response: barnddislikePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            } else {
                if response.data != nil { 
                    self.is_following = !self.is_following
                    if self.is_following {
                        self.followingUB.tintColor = UIColor.orange
                    } else {
                        self.followingUB.tintColor = UIColor.lightGray
                    }
                }
            }
        }
    }
    
    }
    


extension CitizenProfile : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citizentblcell") as! citizentblcell
        cell.selectionStyle = .none
        cell.myindexpath = indexPath
        cell.delegate = self
        cell.tableobj = tblview
        let feedOnIndex = feeds[indexPath.row]
        if feedOnIndex.is_bookmark == "1"{
            cell.btnBookmark.setImage(UIImage(named: "bookmarked"), for: .normal)
        }else{
            cell.btnBookmark.setImage(UIImage(named: "Bookmark"), for: .normal)
        }
        cell.Newsfeeds = feedOnIndex
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = (cell as? citizentblcell) else { return }
        if (tableView.visibleCells.first != nil){
            videoCell.avplayer.play()
        }else{
            videoCell.avplayer.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = cell as? citizentblcell else { return };
        // videoCell.soundbtn.isSelected = false
        videoCell.avplayer.pause()
        videoCell.avplayer.replaceCurrentItem(with: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Articlescreen") as? Articlescreen {
            vc.moduleType = self.moduleType
            if let postId = self.feeds[indexPath.row].id{
                vc.postId = postId
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension CitizenProfile: CitizenFeedsProtocols{
    func tappedSeeMore(indexPath: IndexPath, tableView: UITableView) {
        
    }
    
    func userHasLikedThePost(index: IndexPath, tableView: UITableView) {
        print("follow tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        let feed = feeds[index.row]
        
        guard let id = feed.id else {return}
        let params = [
            "token": UserToken,
            "id": id] as [String:Any]
        let apiurl = ServerURL.firstpoint + ServerURL.citizenLikesURL
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response: barnddislikePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            } else {
                if response.data != nil {
                    self.is_following = !self.is_following
                    if self.is_following {
                        self.followingUB.tintColor = UIColor.orange
                    } else {
                        self.followingUB.tintColor = UIColor.lightGray
                    }
                }
            }
        }
        
    }
    
    func didTapOnTag(tagValue: String) {
           let searchPostVC = storyboard?.instantiateViewController(withIdentifier: "SearchPostVCID") as! SearchPostVC
           navigationController?.pushViewController(searchPostVC, animated: true)
       }
    
    func userClickedLikeCountsLabel(index: IndexPath, tableView: UITableView) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LikesVC") as? LikesVC {
                      
            var postID: String = ""
            var feedType: FeedType = .None
            
            if let postId = feeds[index.row].id {
                postID = postId
                feedType = .Citizen
            }
            
            if feedType != .None {
                vc.postID = postID
                vc.feedType = feedType
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func writeComment(index: IndexPath, tableView: UITableView) {
        let move = storyboard?.instantiateViewController(withIdentifier: "CommentVc") as! CommentVc
        if moduleType == "1"{
            move.TabType = "citizen"
            move.citizendata = feeds[index.row]
        }else{
            move.TabType = "Star"
            move.citizendata = feeds[index.row]
        }
        navigationController?.pushViewController(move, animated: true)
    }
    
    func bookmarkTap(index: IndexPath, tableView: UITableView) {
        print("bookmark tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        guard let id = feeds[index.row].id else {return}
        guard let is_bookmarked = feeds[index.row].is_bookmark else {return}
        if is_bookmarked == "0"{
            CommonFuncs.addbookmark(url: ServerURL.addBookmark,vc: self, postid: id, token: UserToken, moduleId: moduleType, completionHandler: {resp, err in
                if resp?.message == "success"{
                    self.feeds[index.row].is_bookmark = "1"
                    self.tblview.reloadData()
                }
            })
        }else{
            CommonFuncs.addbookmark(url: ServerURL.unbookmark,vc: self, postid: id, token: UserToken, moduleId: moduleType, completionHandler: {resp, err in
                if resp?.message == "success"{
                    self.feeds[index.row].is_bookmark = "0"
                    self.tblview.reloadData()
                }
            })
        }
    }
    
    func citizenTitletapped(index: IndexPath, tableView:UITableView) {
        
    }
    
    func Sharetap(index: IndexPath, tableView: UITableView) {
        let txt = """
        http://instafeed.org/post_details.php?slug=\(self.feeds[index.row].slug ?? "")
        
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
    
    func threeDotAction(index: IndexPath, tableView: UITableView) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let bookmark = UIAlertAction(title: "Block", style: .default) { action -> Void in
            self.blockTap(index: index, tableView: tableView)
        }
        //btnCamera.setValue(UIImage(named:"camera-icon"), forKey: "image")
        bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(bookmark)
        
        let More = UIAlertAction(title: "Report", style: .default) { action -> Void in
            self.spamActionSheet(index: index, tblView: tableView)
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
    
    
    func spamActionSheet(index: IndexPath, tblView:UITableView){
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let bookmark = UIAlertAction(title:"Spam", style: .default) { action -> Void in
            self.spamTap(index: index, tableView: tblView, reasonId: "1") //reasonId = "1"
        }
        
        bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(bookmark)
        
        let More = UIAlertAction(title: "Inappropriate", style: .default) { action -> Void in
            self.spamTap(index: index, tableView: tblView, reasonId: "2")//reasonId = "2"
        }
        
        More.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(More)
        let speech = UIAlertAction(title: "Racism, Hate speech", style: .default) { action -> Void in
            self.spamTap(index: index, tableView: tblView, reasonId: "3")//reasonId = "3"
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
    
    
    func spamTap(index: IndexPath, tableView:UITableView,reasonId:String) {
        print("spam tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        
        guard let id = feeds[index.row].id else {return}
        CommonFuncs.spammarked(url: ServerURL.addspam,vc: self, postid: id, token: UserToken, moduleId: moduleType, reasonId: reasonId, completionHandler: {resp, err in
            if resp?.message == "success"{
                self.feeds[index.row].is_spamed = "1"
                self.feeds.remove(at: index.row)
                self.tblview.reloadData()
            }
        })
    }
    
    func blockTap(index: IndexPath, tableView:UITableView) {

        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        guard let userName = self.feeds[index.row].username else{return}
        
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
                    
                    self.feeds[index.row].is_blocked = "1"
                    for i in 0..<self.feeds.count{
                        if i < self.feeds.count && self.feeds[i].username == userName{
                            self.feeds.remove(at: i)
                        }
                    }
                    
                    self.tblview.reloadData()
                }
            }
        }
    }
}

struct FollowingStatus: Decodable {
    var message: String?
    var data: FollowingUnit?
}

struct FollowingUnit: Decodable {
    var is_following: Bool?
}
