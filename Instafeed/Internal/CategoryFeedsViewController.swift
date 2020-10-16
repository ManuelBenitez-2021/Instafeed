//
//  CategoryFeedsViewController.swift
//  Instafeed
//
//  Created by A1GEISP7 on 14/09/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class CategoryFeedsViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var feedData = [categoryfeedData]()
    var categoryId = String()
    var categoryName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.register(UINib(nibName: "BrandCategoryFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "BrandCategoryFeedTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblTitle.text = categoryName
        self.getCategoriesfeed(categoryId: categoryId)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // get feed of the category
    func getCategoriesfeed(categoryId: String) {
        print("single news")
        let apiurl = ServerURL.firstpoint + ServerURL.brandcategoryfeed
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        let params = ["lang_id": langId, "cat_id": categoryId, "start": 0] as [String:Any]
        print(params)
        
        networking.MakeGetRequest(Url: apiurl, Param: params, vc: self) { (response: feedData) in
            print(response)
            
            if response.message == "error" {
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            } else {
                if let data = response.data {
                    print(data as Any)
                    self.feedData = data
                    self.tblView.reloadData()
                }
            }
        }
        
    }
}

extension CategoryFeedsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BrandCategoryFeedTableViewCell") as? BrandCategoryFeedTableViewCell{
            cell.selectionStyle = .none
            cell.lblTitle.text = feedData[indexPath.row].title
//            cell.lblDate.text = feedData[indexPath.row].date
            cell.imgPost.sd_setImage(with: URL(string: feedData[indexPath.row].image_360x290.contains("default") ? feedData[indexPath.row].video_thumb : feedData[indexPath.row].image_360x290), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryFeedsDetailVC") as? CategoryFeedsDetailVC {
            
            let catFeed = self.feedData[indexPath.row]
            
            let detail = citizenFeedsData.init(id: catFeed.id, news_category_id: catFeed.brand_category_id, title: catFeed.title, slug: catFeed.slug, short_description: catFeed.short_description, location_id: "", total_likes: catFeed.total_likes, total_dislikes: "0", total_comments: catFeed.total_comments, total_views: "0", is_blocked: "", total_flags: "", dt_added: catFeed.dt_added, dt_modified: catFeed.dt_added, status: "", user_id: "", first_name: catFeed.first_name, last_name: "", nickname: "", avatar: catFeed.avatar, username: catFeed.username, image: catFeed.avatar, image_360x290: catFeed.image_360x290, video_thumb: "", video_360x290: "", source: "", latitude: "", longitude: "", is_anonymous: "N", is_editable: "", is_like: catFeed.is_like, is_bookmark: "", is_follow: catFeed.is_follow, is_spamed: "")
            
            vc.dt_added = self.feedData[indexPath.row].dt_added!
            vc.userAvtar = self.feedData[indexPath.row].avatar
            vc.feedDetail = detail
            if let postId = self.feedData[indexPath.row].id{
                vc.postId = postId
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

struct feedData:Decodable {
    var message : String
    var data : [categoryfeedData]?
}
