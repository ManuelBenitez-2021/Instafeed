//
//  TwoFactorViewController.swift
//  Instafeed
//
//  Created by KYC_Mac on 10/23/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit
import ProgressHUD
import Alamofire

class TwoFactorViewController: UIViewController {
    
    @IBOutlet weak var messageUSV: UISwitch!
    @IBOutlet weak var factorUSV: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setData() {
        ProgressHUD.show()
        
        guard let userToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        var type = "p"
        if factorUSV.isOn {
            type = "t"
        }
        
        let params = [
        "token" : userToken,
        "type" : type
            ] as [String : String]
        
        Alamofire.request(ServerURL.twofactor, method: .post, parameters: params).validate().responseJSON { (response) in
            if response.error != nil {
                ProgressHUD.dismiss()
                return
            }
            
            ProgressHUD.dismiss()
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

    @IBAction func backtapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onChangeUSV(_ sender: Any) {
        self.setData()
    }
    
}
