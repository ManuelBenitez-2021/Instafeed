//
//  NotificationVC.swift
//  Instafeed
//
//  Created by gulam ali on 09/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    //http://13.234.116.90/api/notification/getnotify
    @IBOutlet weak var tblview: UITableView!
    
    var notifi_array = [NotificationData]()
    var headings:[String] = ["Alex Edward Martinez","Stark and 15 other liked your post","Amber and 20 other liked your post"]

    var subheading = ["I am intrested on taking your property on rent.","",""]
    var time = ["9.45 AM","yesterday","Now"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblview.delegate = self
        tblview.dataSource = self
        tblview.rowHeight = UITableView.automaticDimension
        tblview.estimatedRowHeight = 150
        navigationBarSetup()
        GetNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    fileprivate func GetNotification(){
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
           print("\(UserToken)")
        
        let apiURL = "\(ServerURL.firstpoint)notification/getnotify?&lang_id=1&token=\(UserToken)"
        print(apiURL)
        networking.MakeRequest(Url: apiURL, Param: nil, vc: self) { (result:Notificationss) in
            print(result)
            if result.message == "success"{
                if let noficationArray = result.data{
                    for data in noficationArray{
                        if !self.notifi_array.contains(where: {$0.id == data.id}){
                            self.notifi_array.append(data)
                        }
                    }
                    print("your array -> \(self.notifi_array.count)")
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tblview.estimatedRowHeight = 150
//        tblview.rowHeight = UITableView.automaticDimension
//    }
    
    //MARK:>>>>> Navigationbar setup
    fileprivate func navigationBarSetup(){
        
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        
       // self.title = "Notifications"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "orangeback"), for: .normal)
        btn1.frame = CGRect(x: 15, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(BackTapped), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.leftBarButtonItem = item1
        
    }
    
    @objc func BackTapped(){
        navigationController?.popViewController(animated: false)
    }
    
    deinit {
        print("notificationVc removed")
    }
    
}

extension NotificationVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifi_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notificationcell") as! Notificationcell
        cell.Notidata = notifi_array[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 102
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Articlescreen") as? Articlescreen{
            let data = notifi_array[indexPath.row]
            vc.postId = data.post_id ?? "0"
            vc.moduleType = data.module_id ?? "1"
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
