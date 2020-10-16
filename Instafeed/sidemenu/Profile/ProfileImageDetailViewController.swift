//
//  ProfileImageDetailViewController.swift
//  Instafeed
//
//  Created by Ishika Gupta on 26/09/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit

class ProfileImageDetailViewController: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    var imageURLString: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadImage()
    }
    
    @IBAction func backtapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    func loadImage() {
        self.imgProfile.sd_setImage(with: imageURLString, placeholderImage: UIImage(named: "proo"), options: .highPriority, completed: nil)
    }
    

}
