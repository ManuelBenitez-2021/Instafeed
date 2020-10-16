//
//  MyPostsVC.swift
//  Instafeed
//
//  Created by Eric on 2019/10/16.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit
import Alamofire
import ProgressHUD

class MyPostsVC: UIViewController {

    @IBOutlet weak var tblview: UITableView!
    var postList = [MyPostsModel]()
    
    var searchTextBefore:String? = nil
    var searchType:String? = nil
    
    @IBOutlet var lbTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblview.delegate = self
        tblview.dataSource = self
        if searchTextBefore == nil{
            reloadTableView()
        }else{
            getTagData()
            self.lbTitle.isHidden = true
        }
    }
    
    @IBAction func backFromMyPosts(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func editPost(sender: UIButton) {
        var typeValue = "0"
        if let type = UserDefaults.standard.value(forKey: "UserType"){
            typeValue = "\(type)"
        }

        let UserType = Int(typeValue)!

        if UserType > 2 {
            var apiMethod = "3"
            if UserType == 4 {
                apiMethod = "1"
            } else if UserType == 5 {
                apiMethod = "2"
            }
            
            constnt.isEditPost = true
            let storyboard = UIStoryboard(name: "Feeds", bundle: nil)
            let mainfeeds = storyboard.instantiateViewController(withIdentifier: "Mainfeeds") as! Mainfeeds
            mainfeeds.moduleType = apiMethod
            mainfeeds.postID = "\(sender.tag)"
            self.present(mainfeeds, animated: true, completion: nil)
        }
    }
    
    @objc func deletePost(sender: UIButton) {
        
        var typeValue = "0"
        
        if let type = UserDefaults.standard.value(forKey: "UserType"){
            typeValue = "\(type)"
        }

        let UserType = Int(typeValue)!
//        let UserType = type! as! Int
        if UserType > 2 {
            var apiMethod = "brand"
            if UserType == 4 {
                apiMethod = "citizen"
            } else if UserType == 5 {
                apiMethod = "star"
            }
            let url: String = "\(ServerURL.firstpoint)\(apiMethod)/post/delete"
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            let params : Parameters = ["token": UserToken, "id": sender.tag]
            ProgressHUD.show()
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON{ response in
                
                ProgressHUD.dismiss()
                
                switch response.result {
                case .success:
                    self.reloadTableView()
                case .failure(let error):
                    print("failed to load feeddata: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func reloadTableView() {
        print("Data => \(UserDefaults.standard.value(forKey: "UserType") ?? "Blank")")
        let UserType:Int = UserDefaults.standard.integer(forKey: "UserType")
        if UserType > 2 {
            var apiMethod = "brand"
            if UserType == 4 {
                apiMethod = "news"
            } else if UserType == 5 {
                apiMethod = "star"
            }
            let url: String = "\(ServerURL.firstpoint)profile/\(apiMethod)"
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            let params : Parameters = ["token": UserToken]
            self.postList.removeAll()
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON{ response in
                switch response.result {
                case .success:
                    
                    self.postList.removeAll()
                    
                    print("\(response)")
                    
                    let json_data = response.result.value as! [String: Any]
                    let data = json_data["data"] as! [[String: Any]]
                    for entry in data {
                        let aResult = MyPostsModel(id: Int(entry["id"] as! String)!, url: entry["image"] as! String, title: entry["title"] as! String, date: entry["dt_modified"] as! String, image_360x290: entry["image"] as! String, video_thumb: entry["video_thumb"] as! String)
                        self.postList.append(aResult)
                    }
                    self.tblview.reloadData()
                case .failure(let error):
                    print("failed to load feeddata: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getTagData() {
        var url: String = "\(ServerURL.firstpoint)\(searchType!)/hashtags"
        if searchType == "superstar" {
            url = "\(ServerURL.firstpoint)star/hashtags"
        }
        let params : Parameters = ["tag": "#" + searchTextBefore!]
        self.postList.removeAll()
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON{ response in
            print(response.result.value!)
            
            switch response.result {
            case .success:
                let json_data = response.result.value as! [String: Any]
                let data = json_data["data"] as! [[String: Any]]
                for entry in data {
                    let aResult = MyPostsModel(id: Int(entry["id"] as! String)!, url: entry["image"] as! String, title: entry["title"] as! String, date: entry["dt_modified"] as! String, image_360x290: entry["image_360x290"] as! String, video_thumb: entry["video_thumb"] as! String)
                    
                    self.postList.append(aResult)
                }
                self.tblview.reloadData()
            case .failure(let error):
                print("failed to load feeddata: \(error.localizedDescription)")
            }
        }
    }
}

extension MyPostsVC : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostsCellID") as! MyPostsCell
        
//        let imgUrl = URL(string: postList[indexPath.row].getUrl())
//        let data = try? Data(contentsOf: imgUrl!)
//        if let imageData = data {
//            cell.postImage.image = UIImage(data: imageData)
//        }
        
        cell.postImage.sd_setImage(with: URL(string: postList[indexPath.row].image_360x290.contains("default") ?  postList[indexPath.row].video_thumb : postList[indexPath.row].image_360x290), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
        cell.titleLabel.text = postList[indexPath.row].getTitle()
        cell.dateLabel.textColor = UIColor.lightGray
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateInFormat = dateFormatter.date(from: postList[indexPath.row].getDate())
        dateFormatter.dateFormat = "dd MMMM yyyy"
        cell.dateLabel.text = dateFormatter.string(from: dateInFormat!)
        cell.editButton.tag = postList[indexPath.row].getId()
        cell.delButton.tag = postList[indexPath.row].getId()
        cell.editButton.addTarget(self, action: #selector(editPost), for: .touchUpInside)
        cell.delButton.addTarget(self, action: #selector(deletePost), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
