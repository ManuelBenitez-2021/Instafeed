//
//  SearchPostVC.swift
//  Instafeed
//
//  Created by eric on 2019/9/26.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchPostVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchTextField: HSUnderLineTextField!
    @IBOutlet weak var searchPeopleButton: UIButton!
    @IBOutlet weak var searchCitizenButton: UIButton!
    @IBOutlet weak var searchBrandButton: UIButton!
    @IBOutlet weak var searchStarButton: UIButton!
    @IBOutlet weak var noneResultView: UIView!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    var searchQuery = "users"
    var searchCategory = "people"
    var postResult = [PostModel]()
    
    var searchTextBefore:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchPeopleButton.layer.cornerRadius = 5
        noneResultView.isHidden = false
        resultTableView.isHidden = true
        
        searchTextField.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        if searchTextBefore != nil {
            self.searchTextField.text = searchTextBefore
            self.getFeeds(query: "\(searchTextBefore!)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doSelectPeople(_ sender: UIButton) {
//        clearSearchResults()
        searchPeopleButton.layer.cornerRadius = 5
        searchPeopleButton.layer.backgroundColor = UIColor(red: 1, green: 85/255, blue: 45/255, alpha: 1).cgColor
        searchCitizenButton.layer.cornerRadius = 0
        searchCitizenButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchBrandButton.layer.cornerRadius = 0
        searchBrandButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchStarButton.layer.cornerRadius = 0
        searchStarButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchQuery = "users"
        searchCategory = "people"
        
        self.getFeeds(query: "\(searchTextField.text!)")
    }
    
    @IBAction func doSelectCitizen(_ sender: UIButton) {
//        clearSearchResults()
        searchPeopleButton.layer.cornerRadius = 0
        searchPeopleButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchCitizenButton.layer.cornerRadius = 5
        searchCitizenButton.layer.backgroundColor = UIColor(red: 1, green: 85/255, blue: 45/255, alpha: 1).cgColor
        searchBrandButton.layer.cornerRadius = 0
        searchBrandButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchStarButton.layer.cornerRadius = 0
        searchStarButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchQuery = "news"
        searchCategory = "news"
        
        self.getFeeds(query: "\(searchTextField.text!)")
    }
    
    @IBAction func doSelectBrand(_ sender: UIButton) {
//        clearSearchResults()
        searchCitizenButton.layer.cornerRadius = 0
        searchCitizenButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchPeopleButton.layer.cornerRadius = 0
        searchPeopleButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchBrandButton.layer.cornerRadius = 5
        searchBrandButton.layer.backgroundColor = UIColor(red: 1, green: 85/255, blue: 45/255, alpha: 1).cgColor
        searchStarButton.layer.cornerRadius = 0
        searchStarButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchQuery = "news"
        searchCategory = "brands"
        
        self.getFeeds(query: "\(searchTextField.text!)")
    }
    
    @IBAction func doSelectStar(_ sender: UIButton) {
//        clearSearchResults()
        searchPeopleButton.layer.cornerRadius = 0
        searchPeopleButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchStarButton.layer.cornerRadius = 5
        searchStarButton.layer.backgroundColor = UIColor(red: 1, green: 85/255, blue: 45/255, alpha: 1).cgColor
        searchCitizenButton.layer.cornerRadius = 0
        searchCitizenButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchBrandButton.layer.cornerRadius = 0
        searchBrandButton.layer.backgroundColor = UIColor(red: 1, green: 8/255, blue: 3/255, alpha: 1).cgColor
        searchQuery = "news"
        searchCategory = "stars"
        
        self.getFeeds(query: "\(searchTextField.text!)")
    }
    
    func clearSearchResults() {
        searchTextField.text = ""
        postResult.removeAll()
        resultTableView.reloadData()
    }
    
    func getFeeds(query: String){
        let url = "\(ServerURL.firstpoint)search?type=\(searchQuery)&query=\(query)";
        Alamofire.request(url).responseJSON{ response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let data = json["data"].stringValue
                if data == "No Record Found" {
                    self.noneResultView.isHidden = false
                    self.resultTableView.isHidden = true
                    
                    self.postResult.removeAll()
                    self.resultTableView.reloadData()
                    
                } else {
                    if self.searchQuery == "users" {
                        
                        let jsonData = json["data"].arrayValue
                        
                        if jsonData.count > 0 {
                            
                            self.postResult.removeAll()
                            
                            for jsonOne in jsonData {
                                
                                let aResult = PostModel(url: jsonOne["avatar"].stringValue, name: jsonOne["username"].stringValue, postId: jsonOne["id"].stringValue)
                                self.postResult.append(aResult)
                            }
                            
                            self.noneResultView.isHidden = true
                            self.resultTableView.isHidden = false
                            self.resultTableView.reloadData()
                        } else {
                            
                            self.noneResultView.isHidden = false
                            self.resultTableView.isHidden = true
                        }
                    } else {
                        
                        let jsonData = json["data"]
                        let categoryData = jsonData[self.searchCategory].arrayValue
                        if categoryData.count > 0 {
                            self.postResult.removeAll()
                            for jsonOne in categoryData {
                                let aResult = PostModel(url: jsonOne["image"].stringValue, name: jsonOne["title"].stringValue, postId: jsonOne["id"].stringValue)
                                self.postResult.append(aResult)
                            }
                            self.noneResultView.isHidden = true
                            self.resultTableView.isHidden = false
                            self.resultTableView.reloadData()
                        } else {
                            self.noneResultView.isHidden = false
                            self.resultTableView.isHidden = true
                        }
                    }
                }
            case .failure(let error):
                self.noneResultView.isHidden = false
                self.resultTableView.isHidden = true
                print("failed to load feeddata: \(error.localizedDescription)")
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString.length >= 3 {
            
            self.getFeeds(query: "\(newString)")
            
        }else if (newString.length == 0){
            
            self.postResult.removeAll()
            self.resultTableView.reloadData()
            
            self.noneResultView.isHidden = false
            self.resultTableView.isHidden = true
        }
        
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text ?? ""
        
        if query.count < 3{
            getFeeds(query: query)
        }
        
        textField.endEditing(true)
        return true
    }
}

extension SearchPostVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellID", for: indexPath) as! PostCell
        let name = postResult[indexPath.row].getName()
        let url = postResult[indexPath.row].image_360x290.contains("default") ? postResult[indexPath.row].video_thumb : postResult[indexPath.row].image_360x290
        if url != "" {
            print("\n================================\n User Name :- \(name) \n Image URL :- \(url) \n================================\n")
            cell.avatarView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "proo"), options: .progressiveLoad, context: nil)
//            let imgUrl = URL(string: url)
//            let data = try? Data(contentsOf: imgUrl!)
//            cell.avatarView.image = UIImage(data: data!)
        }
        cell.contentLabel.text = name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var moduleType = "0"
        
           if searchCategory == "stars" {
            
                moduleType = "2"
                let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
                move.userId = postResult[indexPath.row].getID()
                move.username = postResult[indexPath.row].getName()
                navigationController?.pushViewController(move, animated: false)

           } else if searchCategory == "brands" {
            
                moduleType = "3"
                let vc = storyboard?.instantiateViewController(withIdentifier: "Articlescreen") as! Articlescreen
                let postId = postResult[indexPath.row].getID()
                vc.moduleType = moduleType
                vc.postId = postId
                self.navigationController?.pushViewController(vc, animated: true)
            
           } else if searchCategory == "news" {
            
                moduleType = "1"
                let vc = storyboard?.instantiateViewController(withIdentifier: "Articlescreen") as! Articlescreen
                let postId = postResult[indexPath.row].getID()
                vc.moduleType = moduleType
                vc.postId = postId
                self.navigationController?.pushViewController(vc, animated: true)
            
           } else if searchCategory == "people" {
            
                moduleType = "1"
                let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
                move.userId = postResult[indexPath.row].getID()
                move.username = postResult[indexPath.row].getName()
                navigationController?.pushViewController(move, animated: false)
            
           }
    }
}

class HSUnderLineTextField: UITextField {
    
    let border = CALayer()
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    @IBInspectable open var lineColor : UIColor = UIColor.black {
        didSet{
            border.borderColor = lineColor.cgColor
        }
    }
    
    @IBInspectable open var selectedLineColor : UIColor = UIColor.black {
        didSet{
        }
    }
    
    
    @IBInspectable open var lineHeight : CGFloat = CGFloat(1.0) {
        didSet{
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    required init?(coder aDecoder: (NSCoder?)) {
        super.init(coder: aDecoder!)
        border.borderColor = lineColor.cgColor
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
    }
}
