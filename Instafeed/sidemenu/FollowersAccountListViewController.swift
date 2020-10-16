//
//  FollowersAccountListViewController.swift
//  Instafeed
//
//  Created by A1GEISP7 on 11/09/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ProgressHUD

class FollowersAccountListViewController: UIViewController {

    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowingSelected: UILabel!
    @IBOutlet weak var lblFollowersSelected: UILabel!
    @IBOutlet weak var btnFollowers: UIButton!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var tblFollowersList: UITableView!
    
    @IBOutlet weak var searchUTF: UITextField!
    
    var orangeColor = UIColor.init(red: 241/255.0, green: 126/255.0, blue: 58/255.0, alpha: 1.0)
    
    let followersapiurl = "profile/followers"
    let followingapiurl = "profile/following"
    var followerUserList = [UserList]()
    var followerAllList = [UserList]()
    var followingUserList = [UserList]()
    var followingAllList = [UserList]()
    var isFollower = true
    
    var searchStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBtnSelecting(isFollowerSelected: true)
//        followerslist(url: followingapiurl)
        followerslist(url: followersapiurl)
    }
    
    @IBAction func btnFollowerAction(_ sender: UIButton) {
        isFollower = true
        followerslist(url: followersapiurl, isButtontapped: true)
    }
    
    @IBAction func btnFollowingAction(_ sender: UIButton) {
        isFollower = false
        followerslist(url: followingapiurl, isButtontapped: true)
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setBtnSelecting(isFollowerSelected: Bool = false ){
        self.lblFollowers.textColor = isFollowerSelected ? .black : .lightGray
        self.lblFollowing.textColor = !isFollowerSelected ? .black : .lightGray
        
        self.btnFollowers.isSelected = isFollowerSelected
        self.btnFollowing.isSelected = !isFollowerSelected
        self.lblFollowersSelected.backgroundColor = self.btnFollowers.isSelected ? orangeColor : .clear
        self.lblFollowingSelected.backgroundColor = self.btnFollowers.isSelected ? .clear : orangeColor
        self.tblFollowersList.reloadData()
    }
    
    //list of followers
    func followerslist (url:String, isButtontapped:Bool = false) {
        let apiurl = ServerURL.firstpoint + url
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else { return }
        print("\(UserToken)")
        
        let params = ["token" : UserToken]
        
        ProgressHUD.show()
        Alamofire.request(apiurl, method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { (closureResponse) in
            print(closureResponse)
            switch closureResponse.result {
            case .success:
                print("succeess")
                if closureResponse.response?.statusCode != 401 {
                    //hide loader
                    if closureResponse.result.value != nil {
                        ProgressHUD.dismiss()
                        do {
                            if let resp = closureResponse.data {
                                let model = try JSONDecoder().decode(FollowerModel.self, from: resp)
                                if self.isFollower {
                                    self.followerAllList = model.data!
                                    self.onFilterFollowerList(isTap: self.isFollower)
                                } else {
                                    self.followingAllList = model.data!
                                    self.onFilterFollowingList(isTap: self.isFollower)
                                }
                            } else {
                                Toast().showToast(message: "Something went wrong!!!", duration: 2)
                            }
                        } catch {
                            print("catched error in do try")
                            print(error)
                            
                            self.setFollowingCount()
                            self.setBtnSelecting(isFollowerSelected: self.isFollower)
                            self.tblFollowersList.reloadData()
                        }
                    } else {
                        print("values are nil")
                        ProgressHUD.dismiss()
                        CommonFuncs.AlertWithOK(msg: "Got an error, Try again later", vc: self)
                        return
                    }
                }
            case .failure(let err):
                ProgressHUD.dismiss()
                print("got an error while making request -> \(err)")
                CommonFuncs.AlertWithOK(msg: "Got an error, Try again later", vc: self)
            }
        }
    }
    
    func onFilterFollowerList(isTap: Bool) {
//        let searchStr: String = searchUTF.text!
        if searchStr == "" {
            self.followerUserList = followerAllList
        } else {
            followerUserList.removeAll()
            for user in followerAllList {
                if (user.username?.contains(searchStr))! {
                    followerUserList.append(user)
                }
            }
        }
        
        self.setFollowersCount()
        self.setBtnSelecting(isFollowerSelected: true)
        self.tblFollowersList.reloadData()
    }
    
    func onFilterFollowingList(isTap: Bool) {
//        let searchStr:h String = searchUTF.text!
        if searchStr == "" {
            self.followingUserList = followingAllList
        } else {
            followingUserList.removeAll()
            for user in followingAllList {
                if (user.username?.contains(searchStr))! {
                    followingUserList.append(user)
                }
            }
        }
        
        self.setFollowersCount()
        self.setBtnSelecting(isFollowerSelected: false)
        self.tblFollowersList.reloadData()
    }
    
    func setFollowersCount(){
        if self.followerUserList.count == 0{
            self.lblFollowers.text = "FOLLOWER"
        } else if self.followerUserList.count >= 1000{
            let intNum = self.followerUserList.count / 1000
            let decimalNum:Double = Double(self.followerUserList.count % 1000)
            
            self.lblFollowers.text = String(format: "%ld.%.1f FOLLOWERS", intNum,decimalNum)
        } else{
            self.lblFollowers.text = String(format: "%ld FOLLOWERS", self.followerUserList.count)
        }
    }
    
    func setFollowingCount() {
        if self.followingUserList.count == 0{
            self.lblFollowing.text = "FOLLOWING"
        } else if self.followingUserList.count >= 1000{
            let intNum = self.followingUserList.count / 1000
            let decimalNum:Double = Double(self.followingUserList.count % 1000)
            
            self.lblFollowing.text = String(format: "%ld.%.1f FOLLOWINGS", intNum,decimalNum)
        } else{
            self.lblFollowing.text = String(format: "%ld FOLLOWINGS", self.followingUserList.count)
        }
    }
}

extension FollowersAccountListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.btnFollowing.isSelected{
            return self.followingUserList.count
        } else if self.btnFollowers.isSelected{
            return self.followerUserList.count
        } else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contactcell") as? contactcell{
            cell.followDelegate = self
            if self.btnFollowers.isSelected {
                cell.btnFollow.isHidden = true
                cell.btnFollow.tag = (indexPath.row * 100) + 1
                if let username = self.followerUserList[indexPath.row].username{
                    cell.lblUsername.text = username
                } else{
                    cell.lblUsername.text = ""
                }
                if let name = self.followerUserList[indexPath.row].firstname{
                    cell.lblFullName.text = name
                } else{
                    cell.lblFullName.text = ""
                }
                
                if let profile = self.followerUserList[indexPath.row].avatar{
                    cell.imgProfilePic.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "proo"), options: .highPriority, context: nil)
                } else{
                    cell.imgProfilePic.image = UIImage(named: "proo")
                }
                
                if self.followerUserList[indexPath.row].is_follow == "0"{
                    cell.btnFollow.setImage(UIImage(named: "Follow"), for: .normal)
                } else{
                    cell.btnFollow.setImage(UIImage(named: "Following"), for: .normal)
                }
            } else {
                cell.btnFollow.isHidden = false
                cell.btnFollow.tag = (indexPath.row * 100) + 2
                cell.lblUsername.text = self.followingUserList[indexPath.row].username
                cell.lblFullName.text = self.followingUserList[indexPath.row].firstname
                if let profile = self.followingUserList[indexPath.row].avatar{
                    cell.imgProfilePic.sd_setImage(with: URL(string: profile), placeholderImage: UIImage(named: "proo"), options: .highPriority, context: nil)
                } else{
                    cell.imgProfilePic.image = UIImage(named: "proo")
                }
            }
            return cell
        } else{
            return UITableViewCell()
        }
    }
}

extension FollowersAccountListViewController: FollowButtonTapped {
    func followTapped(indexpath: Int) {
        let row = indexpath % 2 == 0 ? ((indexpath - 2) / 100) : ((indexpath - 1) / 100)
        if indexpath % 2 == 0{
            guard let username = self.followerUserList[row].username else{return}
            guard let isFollowing = self.followerUserList[row].is_follow else{return}
            self.FollowTap(username: username, isFollow: isFollowing == "0" ? "1" : "0", row: row)
            
        }else{
            guard let username = self.followingUserList[row].username else{return}
            self.FollowTap(username: username, isFollow: "0", row: row)
        }
        
    }
    
    func FollowTap(username: String, isFollow: String, row: Int) {
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken, "username":username] as [String:Any]
        print(params)
        if isFollow == "0"{
            let apiurl = ServerURL.firstpoint + ServerURL.followBrand
            networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:barnddislikePost) in
                print(response)

                if response.message == "error"{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                }else{
                    if let data = response.data{
                        print(data as Any)
                        self.followerUserList.remove(at: row)
                        self.tblFollowersList.reloadData()
                        self.setFollowersCount()
                    }
                }
            }
        } else {
            let apiurl = ServerURL.firstpoint + ServerURL.unfollowBrand
            networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:barnddislikePost) in
                print(response)
                
                if response.message == "error"{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                }else{
                    if let data = response.data{
                        print(data as Any)
                        self.followingUserList.remove(at: row)
                        self.tblFollowersList.reloadData()
                        self.setFollowingCount()
                    }
                }
            }
        }
        
    }
}

extension FollowersAccountListViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if isFollower {
            onFilterFollowerList(isTap: true)
        } else {
            onFilterFollowingList(isTap: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text: NSString = (textField.text ?? "") as NSString
        searchStr = text.replacingCharacters(in: range, with: string)
        
        if isFollower {
            onFilterFollowerList(isTap: true)
        } else {
            onFilterFollowingList(isTap: false)
        }
        
        return true
    }
    
}

struct FollowerModel:Decodable{
    var message:String?
    var data:[UserList]?
}

struct UserList:Decodable {
    var id:String?
    var username:String?
    var firstname:String?
    var lastname:String?
    var avatar:String?
    var is_follow:String?
}
