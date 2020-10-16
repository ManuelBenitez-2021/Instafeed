//
//  AboutVC.swift
//  Instafeed
//
//  Created by Eric on 2019/10/17.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAppUpdates(_ sender: UIButton) {
        let appUpdateVC = storyboard?.instantiateViewController(withIdentifier: "AppUpdateVCID") as! AppUpdateVC
        navigationController?.pushViewController(appUpdateVC, animated: true)
    }
}
