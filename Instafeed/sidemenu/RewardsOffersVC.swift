//
//  RewardsOffersVC.swift
//  Instafeed
//
//  Created by Kumar, Gopesh on 24/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage
import SafariServices

class RewardsOffersVC: UIViewController {
    @IBOutlet weak var rewardsBtn: UIButton!
    @IBOutlet weak var offersBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var backgroundLbl: UILabel!
    
    var faqLink = "https://www.instafeed.org/info/privacy-policy"
    override func viewDidLoad() {
        backgroundLbl.roundedLabelWithShadow()
//        backgroundLbl.sendSubviewToBack(self.view)
        self.view.sendSubviewToBack(backgroundLbl)
        rewardsBtn.roundedButton(bgColor: UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1.0))
        offersBtn.roundedButton(bgColor: UIColor.white)
        infoBtn.roundedButton(bgColor: UIColor.white)
        
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func faqClicked(_ sender: Any) {
        showFaq()
    }
    
    func showFaq() {
        if let url = URL(string: faqLink) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
}
