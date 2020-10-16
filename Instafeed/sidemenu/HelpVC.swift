//
//  HelpVC.swift
//  Instafeed
//
//  Created by Eric on 2019/10/17.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {
    
    @IBOutlet var mainUV: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mainTap = UITapGestureRecognizer(target: self, action: #selector(self.handleMainTap(_:)))
        mainUV.addGestureRecognizer(mainTap)
        
    }
    
    @objc func handleMainTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
}
