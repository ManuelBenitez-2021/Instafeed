//
//  LikesVC.swift
//  Instafeed
//
//  Created by HKC on 10/19/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit

class LikesVC: UIViewController {

    var postID: String!
    var feedType: FeedType = .None
    var likeList = [likeListdata]()

    @IBOutlet weak var likesTVC: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        likesTVC.register(UINib(nibName: "LikeTableViewCell", bundle: nil), forCellReuseIdentifier: "LikeTableViewCell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLikes()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func getLikes(){
        var apiURL: String = ""
        switch feedType {
        case .Citizen:
            apiURL = ServerURL.firstpoint + ServerURL.citizenLikesURL
            break
        case .Brand:
            apiURL = ServerURL.firstpoint + ServerURL.brandLikesURL
            break
        case .Star:
            apiURL = ServerURL.firstpoint + ServerURL.starLikesURL
            break
        default:
            break
        }
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken, "id":postID!] as [String:Any]
        
        networking.MakeRequest(Url: apiURL, Param: params, vc: self) { (result:likeList) in
            print(result.message)
            
            if result.message == "success" {
                if let response = result.data {
                    print(response)
                    self.likeList = response.map{$0}
                    print("your array -> \(self.likeList)")
                    DispatchQueue.main.async {
                        self.likesTVC.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    

    @IBAction func actionBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension LikesVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeTableViewCell") as! LikeTableViewCell
        cell.like = likeList[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 10.0
    }
}
