//
//  YourActivityViewController.swift
//  Instafeed
//
//  Created by JinYZ on 12/11/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit

class YourActivityViewController: UIViewController {
    
    @IBOutlet weak var listUTV: UITableView!
    
    var histories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initDatas()
    }
    
    func initDatas() {
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let apiURL = "\(ServerURL.firstpoint)settings/activity?token=\(UserToken)"
        print(apiURL)
        
        networking.MakeRequest(Url: apiURL, Param: nil, vc: self) { (result:HistoryItem) in
            print(result)
            if result.message == "success"{
                self.histories = result.data
                self.listUTV.reloadData()
            } else {
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
}

extension YourActivityViewController: UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        cell.textLabel?.text = histories[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        return cell
    }
    
}

extension YourActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}

class HistoryItem: Decodable {
    var message: String!
    var data: [String]!
}
