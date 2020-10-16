//
//  PrivacyViewController.swift
//  Instafeed
//
//  Created by KYC_Mac on 10/23/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit
import ProgressHUD
import Alamofire

class PrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setServerData() {
        ProgressHUD.show()
        
        guard let userToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        let params = [
            "token" : userToken
            ] as [String : Any]
        
        Alamofire.request(ServerURL.clearhistory, method: .post, parameters: params).validate().responseJSON { (response) in
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
    
    @IBAction func authtapped(_ sender: Any) {
        let move = storyboard?.instantiateViewController(withIdentifier: "TwoFactorViewController") as! TwoFactorViewController
        navigationController?.pushViewController(move, animated: false)
    }
    
    @IBAction func clearhistorytapped(_ sender: Any) {
        let altMessage = UIAlertController(title: "Clear Search History", message: "Are you sure?", preferredStyle: .alert)
        altMessage.addAction(UIAlertAction(title: "YES", style: .default, handler: {
            (UIAlertAction) in
            self.setServerData()
        }))
        
        altMessage.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        self.present(altMessage, animated: true, completion: nil)
    }
    
    @IBAction func changepasstapped(_ sender: Any) {
        let move = storyboard?.instantiateViewController(withIdentifier: "ChangePassViewController") as! ChangePassViewController
        navigationController?.pushViewController(move, animated: false)
    }
    
}
