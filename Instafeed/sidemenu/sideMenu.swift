//
//  sideMenu.swift
//  Instafeed
//
//  Created by gulam ali on 05/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage

class sideMenu: UIViewController {
    
    var isOpeningView = false
    
    @IBOutlet weak var locationlbl: UILabel!
    @IBOutlet weak var usernme: UILabel!
    @IBOutlet weak var profileimg: UIImageView!
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var lblMyPost: UILabel!
    @IBOutlet weak var lblFav: UILabel!
    @IBOutlet weak var lblReward: UILabel!
    
    var response: Profiledata = Profiledata()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if (appDelegate!.currentLanguage == "Hi"){
            self.lblFollow.text = "फॉलो"
            self.lblMyPost.text = "मेरी पोस्ट"
            self.lblFav.text = "मेरे पसंदीदा"
            self.lblReward.text = "पुरस्कार और प्रस्ताव"
        }
        
        self.usernme.text = (UserDefaults.standard.value(forKey: "UserName") as! String)
        let profilephoto = URL(string: UserDefaults.standard.value(forKey: "ProfileImage") as! String)
        self.profileimg.layer.cornerRadius = self.profileimg.frame.height/2
        let placeholder = UIImage(named: "proo")
        self.profileimg.contentMode = .scaleAspectFill
        self.getProfile()
        self.profileimg.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK:>>>> Get Profile
    fileprivate func getProfile(){
        let api = ServerURL.firstpoint + ServerURL.Getprofile
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken] as [String:Any]
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result: ProfileDataModel) in
            if result.message == "success"{
                guard let response = result.data else {return}
                self.response = response
                DispatchQueue.main.async {
                    print(response)
                    self.usernme.text = "\(response.first_name!)"
                    self.locationlbl.text = response.address!
                    
                    self.profileimg.layer.cornerRadius = self.profileimg.frame.height/2
                    let profilephoto = URL(string: response.avatar ?? "")
                    let placeholder = UIImage(named: "proo")
                    self.profileimg.contentMode = .scaleAspectFill
                    self.profileimg.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
                }
            } else {
                CommonFuncs.AlertWithOK(msg: "Something went wrong while getting profile", vc: self)
                return
            }
        }
    }
    
    @IBAction func profiletapped(_ sender: Any) {
        let story = UIStoryboard(name: "categoryStoryboard", bundle: nil)
        let move = story.instantiateViewController(withIdentifier: "ProfileImageDetailViewController") as! ProfileImageDetailViewController
        let profilephoto = URL(string: UserDefaults.standard.value(forKey: "ProfileImage") as! String)
        move.imageURLString = profilephoto
        navigationController?.pushViewController(move, animated: false)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        let move = storyboard?.instantiateViewController(withIdentifier: "Settings") as! Settings
        move.username = "\(usernme.text!)"
        navigationController?.pushViewController(move, animated: false)
    }
    
    @IBAction func btnHomeTapped(_ sender: UIButton) {
        moveToHomeScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("sidemenu removed")
    }
    
    func moveToHomeScreen(){
        let storyboard = UIStoryboard(name: "categoryStoryboard", bundle: nil)
        let move = storyboard.instantiateViewController(withIdentifier: "Mainpagevc") as! Mainpagevc
        self.present(move, animated: false, completion: nil)
    }
    
    @IBAction func btnFavouritesAction(_ sender: UIButton) {
        
        if !isOpeningView{
            isOpeningView = true
            let storyboard = UIStoryboard(name: "categoryStoryboard", bundle: nil)
            let move = storyboard.instantiateViewController(withIdentifier: "Bookmarkvc") as! Bookmarkvc
            navigationController?.pushViewController(move, animated: true)
        }
    }
    
    @IBAction func btnMyPostsAction(_ sender: UIButton) {
        
        if !isOpeningView{
            isOpeningView = true
            let storyboard = UIStoryboard(name: "sidemenu", bundle: nil)
            let move = storyboard.instantiateViewController(withIdentifier: "MyPostsVCID") as! MyPostsVC
            navigationController?.pushViewController(move, animated: true)
        }
    }
}
