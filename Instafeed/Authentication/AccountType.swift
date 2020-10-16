//
//  AccountType.swift
//  Instafeed
//
//  Created by gulam ali on 10/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class AccountType: UIViewController {
    
    
//    @IBOutlet weak var heading: UIView!
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var commonview: UIView!
    @IBOutlet weak var brandview: UIView!    
    @IBOutlet weak var superstarview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        heading.text = "Welcome Name\n Choose your account type"
        heading.textColor = UIColor(hexValue: InstafeedColors.titleviolet)
        commonview.layer.cornerRadius = 10.0
        brandview.layer.cornerRadius = 10.0
        superstarview.layer.cornerRadius = 10.0
        
    }
    
    @IBAction func btnCitizenTapAction(_ sender: UIButton) {
        moveToHomeScreen()
    }
    
    @IBAction func btnSuperstarTapAction(_ sender: UIButton) {
    }
    
    @IBAction func btnBrandTapAction(_ sender: UIButton) {
    }
    
    func moveToHomeScreen(){
        let storyboard = UIStoryboard(name: "categoryStoryboard", bundle: nil)
        let move = storyboard.instantiateViewController(withIdentifier: "Mainpagevc") as! Mainpagevc
        self.present(move, animated: false, completion: nil)
    }

}
