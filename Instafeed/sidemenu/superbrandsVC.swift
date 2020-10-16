//
//  superbrandsVC.swift
//  Instafeed
//
//  Created by gulam ali on 14/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import ProgressHUD
import Alamofire

class superbrandsVC: UIViewController {
    
    @IBOutlet weak var citizentblview: UITableView!
    @IBOutlet weak var heading: UILabel!
   
    @IBOutlet weak var tblview: UITableView!
    
    var type = ""
    var star = 0, brand = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblview.delegate = self
        tblview.dataSource = self
        citizentblview.delegate = self
        citizentblview.dataSource = self
        
        if type == "citizen"{
            heading.text = "Citizen Feeds"
            tblview.isHidden = true
            citizentblview.isHidden = false
        }else{
            heading.text = "Feeds"
            tblview.isHidden = false
            citizentblview.isHidden = true
        }
    }
    
    
    
    @IBAction func backtapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
        
    }
    
}

extension superbrandsVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblview {
            return 2
        }else{
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblview{
            let cell = tableView.dequeueReusableCell(withIdentifier: "superbrandsCell") as! superbrandsCell
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sidecitizencell") as! sidecitizencell
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func onConnectedServer() {
        ProgressHUD.show()
        
        guard let userToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        let params = [
            "token" : userToken,
            "star_type" : "\(star)",
            "brand_type" : "\(brand)"
            ] as [String : String]
        
        Alamofire.request(ServerURL.superbrand, method: .post, parameters: params).validate().responseJSON { (response) in
            if response.error != nil {
                ProgressHUD.dismiss()
                return
            }
            
            ProgressHUD.dismiss()
        }
    }
    
}

extension superbrandsVC: SideCitizenCellDelegate {
    func onSelectedCitizenStatus(row: Int, value: Int) {
        star = value
        onConnectedServer()
    }    
    
}

extension superbrandsVC: SuperBrandsCellDelegate {
    func onSelectedBrandStatus(row: Int, value: Int) {
        brand = value
        onConnectedServer()
    }
    
    
}
