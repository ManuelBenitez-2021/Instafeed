//
//  ChangePassViewController.swift
//  Instafeed
//
//  Created by KYC_Mac on 10/23/19.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit
import ProgressHUD
import Alamofire

class ChangePassViewController: UIViewController {

    @IBOutlet weak var cPassUTF: UITextField!
    @IBOutlet weak var nPassUTF: UITextField!
    @IBOutlet weak var rPassUTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func checktapped(_ sender: Any) {
        let cPassStr: String = cPassUTF.text!
        if cPassStr == "" {
            let alert = UIAlertController(title: "Error", message: "The current password is empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let nPassStr: String = nPassUTF.text!
        if nPassStr == "" {
            let alert = UIAlertController(title: "Error", message: "The new password is empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let rPassStr: String = rPassUTF.text!
        if nPassStr != rPassStr {
            let alert = UIAlertController(title: "Error", message: "The new password is not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        ProgressHUD.show()
        
        guard let userToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}

        let params = [
        "token" : userToken,
        "password" : cPassStr,
        "confirm_password" : nPassStr
            ] as [String : String]
        
        Alamofire.request(ServerURL.changepass, method: .post, parameters: params).validate().responseJSON { (response) in
            if response.error != nil {
                ProgressHUD.dismiss()
                let alert = UIAlertController(title: "Error", message: "Faid the change password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Success", message: "Successed the changed password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
                (UIAlertAction) in
                self.navigationController?.popViewController(animated: false)
            }))
            self.present(alert, animated: true, completion: nil)
            ProgressHUD.dismiss()
        }
        
    }
    
}
