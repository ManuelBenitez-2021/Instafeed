//
//  Brandcategories.swift
//  Instafeed
//
//  Created by gulam ali on 10/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import CarbonKit
import SDWebImage
import Alamofire

class Brandcategories: UIViewController {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var headtitle: UILabel!
    
    @IBOutlet weak var lblStoriesCount: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var profilephoto: UIImageView!
    @IBOutlet weak var tabsView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var orangeColor = UIColor.init(red: 241/255.0, green: 126/255.0, blue: 58/255.0, alpha: 1.0)
    var selectionCategoryIndex:Int = 0
    var BrandCategories = [profilecategoryData]()
    var profileResponse = profileData()
    var categoryFeedData = [categoryfeedData]()
    var TabNames = ["All Categories"]
    var username = String()
    var userId = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        profilephoto.layer.cornerRadius = (profilephoto.frame.size.width/2)
        profilephoto.layer.masksToBounds = true
        tblView.register(UINib(nibName: "BrandCategoryFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "BrandCategoryFeedTableViewCell")
//        categoryCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
//        categoryCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationBarSetup()
        tabMenusetup()
        getProfile(userId: self.userId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.selectionCategoryIndex = 0
    }
    
    //customise nav bar title.left bar item
    fileprivate func navigationBarSetup(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.title = ""
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "orangeback"), for: .normal)
        btn1.frame = CGRect(x: 15, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(tapSideMenu), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.leftBarButtonItem = item1
    }
    
    fileprivate func tabMenusetup(){
        getProfileCategories(userId: self.userId)
    }
    
    @objc func tapSideMenu(){
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:>>>> Api call
    //for profile information
    func getProfile(userId: String) {
        print("single news")
        let apiurl = ServerURL.firstpoint + ServerURL.brandprofile
        let params = ["id":userId] as [String:Any]
        print(params)
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:profile) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    self.profileResponse = data

                    self.headtitle.text = "\(String(describing: self.profileResponse.first_name)) \(String(describing: self.profileResponse.last_name))"
                    self.profilephoto.sd_setImage(with: URL(string: self.profileResponse.avatar ?? ""), placeholderImage: UIImage(named: "proo"), options: .highPriority, completed: nil)
                    
                    self.lblStoriesCount.text = "\(String(describing: self.profileResponse.total_stories)) Stories"
                    self.lblFollowersCount.text = "\(String(describing: self.profileResponse.total_followers)) Followers"
                    self.headtitle.text = "\(self.profileResponse.first_name ?? "") \(self.profileResponse.last_name ?? "")"
                    self.profilephoto.sd_setImage(with: URL(string: self.profileResponse.avatar ?? ""), placeholderImage: UIImage(named: "proo"), options: .highPriority, completed: nil)
                    
                    self.lblStoriesCount.text = "\(self.profileResponse.total_stories ?? "") Stories"
                    self.lblFollowersCount.text = "\(self.profileResponse.total_followers ?? "") Followers"
                }
            }
        }
        
    }
    
//    for profile categories
    func getProfileCategories(userId: String) {
        print("single news")
        let apiurl = ServerURL.firstpoint + ServerURL.brandcategory
        let params = ["id":userId] as [String:Any]
        print(params)
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:profilecategory) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    self.BrandCategories = data
                    if self.BrandCategories.count > 0{
                        self.getProfileCategoriesfeed(userId: self.userId, categoryId: self.BrandCategories[0].category_id ?? "")
                        self.categoryCollectionView.reloadData()
                    }
                }
            }
        }
        
    }
    
    // get feed of the category
    func getProfileCategoriesfeed(userId: String, categoryId: String) {
        print("single news")
        let apiurl = ServerURL.firstpoint + ServerURL.brandcategoryfeed + "?cat_id=\(categoryId)"
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"

        let params = ["id":userId, "lang_id":langId, "cat_id":categoryId, "start":0] as [String:Any]
        print(params)
        
        Alamofire.request(apiurl, method: .post, parameters: nil).responseJSON { response in
            if let _ = response.result.value,let statusCode = response.response?.statusCode  {
                if(statusCode == 200)
                {
//                    categoryfeedData
                    let result = response.result.value as? [String:Any]
                    if result != nil {
                        let datas = result!["data"] as? [[String:String?]]
                        if datas != nil {
                            self.categoryFeedData.removeAll()
                            for data in datas! {
                                let catdata = categoryfeedData(brand_category_id: data["brand_category_id"] ?? nil, id: data["id"] ?? nil, short_description: data["short_description"] ?? nil, title: data["title"] ?? nil, image_360x290: (data["image_360x290"] as? String ?? ""), video_thumb: (data["video_thumb"] as? String ?? ""))
                                self.categoryFeedData.append(catdata)
                                self.tblView.reloadData()
                            }
                        }
                    }
//                    delegate.didReceiveResult(results: responseJson,request: (response.request?.url!)!)
                }
                else
                {
//                    var dicMessage = responseJson as! [String:Any]
//                    dicMessage["Status"] = false
//                    delegate.didReceiveResult(results: dicMessage,request: (response.request?.url!)!)
                }
            }
            else{
//                let dicMessage = ["Status":"0","Message":noInternetConnection]
//                delegate.didReceiveResult(results: dicMessage,request: (response.request?.url!)!)
            }
        }
        /*
        networking.MakeGetRequest(Url: apiurl, Param: nil, vc: self) { (response:categoryfeed) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    self.categoryFeedData = data
                    self.tblView.reloadData()
                }
            }
        }*/
        
    }
}

extension Brandcategories: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BrandCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.lblCategoryName.text = BrandCategories[indexPath.row].category_name
        cell.imgSelection.backgroundColor = self.selectionCategoryIndex == indexPath.item ? orangeColor : .clear
        return cell 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectionCategoryIndex = indexPath.item
        self.getProfileCategoriesfeed(userId: self.userId, categoryId: BrandCategories[indexPath.item].category_id ?? "")
        self.categoryCollectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let str:String = self.BrandCategories[indexPath.row].category_name ?? ""
        let width = UILabel.textWidth(font: UIFont.systemFont(ofSize: 14), text: str)
        return CGSize(width: width + 5 + 5, height: 55)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmarks = categoryFeedData[indexPath.row]
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Articlescreen") as? Articlescreen {
            vc.postId = bookmarks.id!
            vc.moduleType = "3"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
}

extension Brandcategories: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryFeedData.count
    }
    		
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "BrandCategoryFeedTableViewCell") as? BrandCategoryFeedTableViewCell{
            cell.selectionStyle = .none
            cell.lblTitle.text = categoryFeedData[indexPath.row].title
//            cell.lblDate.text = categoryFeedData[indexPath.row].date
            cell.imgPost.sd_setImage(with: URL(string: categoryFeedData[indexPath.row].image_360x290.contains("default") ?  categoryFeedData[indexPath.row].video_thumb : categoryFeedData[indexPath.row].image_360x290), placeholderImage: UIImage(named: "citizelcell"), options: .highPriority, completed: nil)
            return cell
        }else{
            return UITableViewCell()
        }
    }
}

/*extension Brandcategories: CarbonTabSwipeNavigationDelegate{
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        guard let storyboard = storyboard else { return UIViewController() }
        if index == 0 {
            return storyboard.instantiateViewController(withIdentifier: "allcategories")
        }else if index == 1{
            return storyboard.instantiateViewController(withIdentifier: "home")
        }else if index == 2{
            return storyboard.instantiateViewController(withIdentifier: "politics")
        }else if index == 3{
            return storyboard.instantiateViewController(withIdentifier: "entertainment")
        }else {
            return storyboard.instantiateViewController(withIdentifier: "world")
        }
        
    }
}*/

extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }
    
    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }
    
    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }
    
    class func textWidth(font: UIFont, text: String) -> CGFloat {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(labelSize.width)
    }
}

struct profile:Decodable {
    var message:String
    var data:profileData?
}

struct profilecategory:Decodable {
    var message:String
    var data :[profilecategoryData]?
}

struct profilecategoryData:Decodable {
 
    var category_id:String?
    var category_name:String?
    var description:String?
}

struct categoryfeed:Decodable {
    var message:String
    var data: [categoryfeedData]?
}

struct categoryfeedData:Decodable {
    
    var brand_category_id:String?
    var id:String?
    var short_description:String?
    var title:String?
    var image_360x290:String
    var video_thumb:String
    
    var slug:String?
    var total_likes : String?
    var total_comments : String?
    var dt_added:String?
    var first_name:String?
    var username:String?
    var is_like:String?
    var is_follow: String?
    var avatar: String?
    
    
    init(brand_category_id: String?, id: String?, short_description: String?, title: String?, image_360x290: String = "", slug: String?, total_likes: String?, total_comments: String?, dt_added: String?, first_name: String?, username: String?, is_like: String?, is_follow: String?, avatar: String?, video_thumb:String = "") {
        self.brand_category_id = brand_category_id
        self.id = id
        self.short_description = short_description
        self.title = title
        self.image_360x290 = image_360x290
        self.slug = slug
        self.total_likes = total_likes
        self.total_comments = total_comments
        self.first_name = first_name
        self.username = username
        self.is_like = is_like
        self.is_follow = is_follow
        self.avatar = avatar
        self.video_thumb = video_thumb
    }

    init(brand_category_id: String?, id: String?, short_description: String?, title: String?, image_360x290: String = "", video_thumb:String = "", avatar:String = "") {
        self.brand_category_id = brand_category_id
        self.id = id
        self.short_description = short_description
        self.title = title
        self.image_360x290 = image_360x290
        self.video_thumb = video_thumb
        self.avatar = avatar
    }

    
       
}


struct profileData:Decodable {
    var user_id:String?
    var username:String?
    var type:String?
    var type_name:String?
    var profile_url:String?
    var email:String?
    var avatar:String?
    var first_name:String?
    var last_name:String?
    var birth_date:String?
    var total_news_posts:String?
    var total_followers:String?
    var total_following:String?
    var total_stories:String?
}
