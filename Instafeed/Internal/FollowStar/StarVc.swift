 //
//  StarVc.swift
//  Instafeed
//
//  Created by gulam ali on 10/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class StarVc: UIViewController {
    
    
  //  @IBOutlet weak var collview: UICollectionView!
    
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var followLine: UILabel!
    @IBOutlet weak var recommendationCollectionView: UICollectionView!
    var starSuggestion = [StarSuggestion]()
    
   // var sectionTitles:[String] = ["Recommended Sources","Recommended Channels","Recommended Superstars"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.navigationBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        //tblview.delegate = self
        //tblview.dataSource = self
        tblview.tableFooterView = UIView()
        self.getRecommendedSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         tabBarController?.tabBar.isHidden = false
         self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func searchTapped(_ sender: Any) {
        
      
        
    }
    
    
    deinit {
        print("starvc removed")
    }
    
    func getRecommendedSource(){
        let serverurl = ServerURL.firstpoint + ServerURL.recomendationUrl
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken] as [String:Any]
        
        networking.MakeRequest(Url: serverurl, Param: params, vc: self) { (response:StarSuggestionModel) in
            print(response)
            if response.message == "success"{
                
                if let recentsArray = response.data{
                    self.starSuggestion = recentsArray.map{$0}
                    print("your array -> \(self.starSuggestion)")
                    DispatchQueue.main.async {
                        self.recommendationCollectionView.reloadData()
                    }
                }
                
            }else{
                print("not success")
            }
        }
    }
    
    func followUser(username:String, index:Int){
        let serverurl = ServerURL.firstpoint + ServerURL.followBrand
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken, "username":username] as [String:Any]
        
        networking.MakeRequest(Url: serverurl, Param: params, vc: self) { (response:FollowUserModel) in
            print(response)
            if response.message == "success"{
                self.starSuggestion.remove(at: index)
                self.recommendationCollectionView.reloadData()
            }else{
                print("not success")
            }
        }
    }

}

/*extension StarVc : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lbl = UILabel()
        lbl.text = sectionTitles[section]
        lbl.backgroundColor = UIColor.white
        lbl.font = lbl.font.withSize(15.0)
        lbl.font = UIFont.boldSystemFont(ofSize: 15.0)
        lbl.textColor = UIColor.lightGray
        return lbl
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Starcell") as! Starcell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    
}*/
 
 


extension StarVc : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.starSuggestion.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCollCell", for: indexPath) as! StarCollCell
        cell.btnFollow.tag = indexPath.row
        cell.sourceData = self.starSuggestion[indexPath.row]
        cell.followDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth =  (collectionView.frame.size.width - 10)
        let squareSizeWidth = itemWidth / 2
        return CGSize(width: squareSizeWidth, height: 165)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        
        return headerView
        
    }

    
}
 extension StarVc : FollowAction{
    func handleFollowTap(index: Int) {
        if let username = self.starSuggestion[index].username{
            self.followUser(username: username, index: index)
        }
    }
 }
 struct StarSuggestion:Decodable{
    var id : String?
    var username:String?
    var first_name : String?
    var last_name : String?
    var avatar:String?
    var user_type : String?
 }
 struct StarSuggestionModel:Decodable {
    var message:String?
    var data:[StarSuggestion]?
 }
 struct FollowUserModel:Decodable {
    var message:String?
 }
