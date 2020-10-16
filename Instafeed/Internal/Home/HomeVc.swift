//
//  HomeVc.swift
//  Instafeed
//
//  Created by gulam ali on 12/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage
import SafariServices

class HomeVc: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var brand_tblview: UITableView!
    @IBOutlet weak var citizenstoriesview: UIView!
    @IBOutlet weak var brandView: UIView!
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var collview: UICollectionView!
    @IBOutlet weak var citizenlabel: UILabel!
    @IBOutlet weak var superstarline: UILabel!
    @IBOutlet weak var superstarlabel: UILabel!
    @IBOutlet weak var brandline: UILabel!
    @IBOutlet weak var citizenline: UILabel!
    @IBOutlet weak var brandlabel: UILabel!
    //@IBOutlet weak var Sellline: UILabel!
    //@IBOutlet weak var Selllabel: UILabel!
    @IBOutlet weak var tblViewSuperstar: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var langBtn: UIButton!
    @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableSellHere: UITableView!
    @IBOutlet weak var sellHereLabel: UILabel!
    @IBOutlet weak var sellBaseline: UILabel!
    
    var CitizenRecents = [citizenRecentsData]()
    var Citizenfeeds = [citizenFeedsData]()
    var SellHerefeeds = [citizenFeedsData]()
    var superstarFeed = [citizenFeedsData]()
    var superstarRecent = [citizenRecentsData]()
    var BrandFeeds = [brandfeedsData]()
    //var SellFeeds = [SellfeedsData]()
    var AdData = [adData]()
    var loadAd = false
    var limit:Int = 0
    var brandlimit:Int = 0
    var Selllimit:Int = 0
    var superstarlimit: Int = 0
    var FetchMore = false
    var isLikingPost = false
    var isOpeningDetailPage = false
    // var tabtype = String()
    let minOffsetToTriggerRefresh:CGFloat = 50.0
    var selectedTab :String!
    var ViewFlag:String!
    
    var isViewOpening = false
    
    var Pro_response: Profiledata = Profiledata()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table_collection_ViewSetup()
        ViewFlag = "citizen"
        brandView.isHidden = true
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            langBtn.setTitle(appDelegate.currentLanguage, for: .normal)
        }else{
            langBtn.setTitle("En", for: .normal)
        }
        
        showTables(tableCode: 1)
        selectedTab = "1"
        tblViewSuperstar.register(UINib(nibName: "citizentblcell", bundle: nil), forCellReuseIdentifier: "citizentblcell")
        tblview.register(UINib(nibName: "citizentblcell", bundle: nil), forCellReuseIdentifier: "citizentblcell")
        tableSellHere.register(UINib(nibName: "citizentblcell", bundle: nil), forCellReuseIdentifier: "citizentblcell")
        searchText.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(onSwapeRefresh(sender:)), for: .valueChanged)
        tblview.addSubview(refreshControl)
        getData()
    }
    
    @objc func onSwapeRefresh(sender: AnyObject) {
       // Code to refresh table view
        if ViewFlag == "citizen" {
            limit = 0
            Citizenfeeds.removeAll()
            citizentab_getfeeds(count: limit)
        } else if ViewFlag == "sell" {
            Selllimit = 0
            SellHerefeeds.removeAll()
            getSellFeeds(count: superstarlimit)
        } else if ViewFlag == "superstar" {
            superstarlimit = 0
            superstarFeed.removeAll()
            superstartab_getfeeds(count: superstarlimit)
        } else {
            brandlimit = 0
            BrandFeeds.removeAll()
            getBrandFeeds(count: brandlimit)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //self.reset()
    }
    
    func refreshData(){
        if ViewFlag == "citizen"{
            limit = 0
            Citizenfeeds.removeAll()
            citizentab_getfeeds(count: limit)
        }else if ViewFlag == "superstar" {
            superstarlimit = 0
            superstarFeed.removeAll()
            superstartab_getfeeds(count: superstarlimit)
        }else if ViewFlag == "brand" {
            brandlimit = 0
            BrandFeeds.removeAll()
            getBrandFeeds(count: brandlimit)
        }else if ViewFlag == "Sell" {
            Selllimit = 0
            SellHerefeeds.removeAll()
            getSellFeeds(count: Selllimit)
        }
    }
    
    func reset(){
        limit = 0
        brandlimit = 0
        superstarlimit = 0
        Selllimit = 0
        CitizenRecents.removeAll()
        Citizenfeeds.removeAll()
        superstarFeed.removeAll()
        superstarRecent.removeAll()
        BrandFeeds.removeAll()
        SellHerefeeds.removeAll()
    }
    
    func getData(){
        getProfile()
        self.getCitizenRecents()
        self.citizentab_getfeeds(count: self.limit)
        self.superstartab_getfeeds(count: self.superstarlimit)
        self.getSuperstarRecents()
        self.getBrandFeeds(count: self.brandlimit)
        self.getSellFeeds(count: self.Selllimit)
    }
    
    
    fileprivate func Table_collection_ViewSetup(){
        collview.delegate = self
        collview.dataSource = self
        
        tblview.delegate = self
        tblview.dataSource = self
        tblview.tableFooterView = UIView()
        tblview.rowHeight = UITableView.automaticDimension
        
        brand_tblview.delegate = self
        brand_tblview.dataSource = self
        brand_tblview.tableFooterView = UIView()
        brand_tblview.rowHeight = UITableView.automaticDimension
        brand_tblview.estimatedRowHeight = 390
    }
    
    func showTables(tableCode:Int){
        tblViewSuperstar.isHidden = !(tableCode == 2 && tableCode != 1 && tableCode != 3 && tableCode != 4)
        tblview.isHidden = !(tableCode != 2 && tableCode == 1 && tableCode != 3 && tableCode != 4)
        brand_tblview.isHidden = !(tableCode != 2 && tableCode != 1 && tableCode == 3 && tableCode != 4)
        if tableCode != nil && tableCode != 4 {
            tableSellHere.isHidden = true;
        }
        if tableCode == 2{
            tblViewSuperstar.reloadData()
        }else if tableCode == 1{
            tblview.reloadData()
        }else if tableCode == 4{
            tableSellHere.reloadData()
        } else{
            brand_tblview.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isOpeningDetailPage = false
        isViewOpening = false
        self.view.endEditing(true)
        
        self.navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
        
    }
    
    @IBAction func languageBtnSelect(_ sender: Any) {
//        let languageVC = storyboard?.instantiateViewController(withIdentifier: "languageVc") as! languageVc
//        navigationController?.pushViewController(languageVC, animated: true)

        if !isViewOpening {
            isViewOpening = true
            let languageVC = storyboard?.instantiateViewController(withIdentifier: "languageVc") as! languageVc
            navigationController?.pushViewController(languageVC, animated: true)
        }
    }
    
    @IBAction func topbar_btns_action(_ sender: Any) {
        switch ((sender as AnyObject).tag) {
        case 10: //sidemenu btn
            print("sidemenu tap")
            //segue
            
        case 20: //notification
            print("notification")
            showNotificaton()
        case 30: //search
            print("search tap")
            let searchPostVC = storyboard?.instantiateViewController(withIdentifier: "SearchPostVCID") as! SearchPostVC
            navigationController?.pushViewController(searchPostVC, animated: true)
            //            let move = storyboard?.instantiateViewController(withIdentifier: "Bookmarkvc") as! Bookmarkvc
        //            navigationController?.pushViewController(move, animated: true)
        default:
            break
        }
        
    }
    
    fileprivate func showNotificaton(){
        
        if !isViewOpening{
            isViewOpening = true
            let move = storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            navigationController?.pushViewController(move, animated: false)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchText {
            textField.resignFirstResponder()
            
//            if !isViewOpening{
//                isViewOpening = true
//                let searchPostVC = storyboard?.instantiateViewController(withIdentifier: "SearchPostVCID") as! SearchPostVC
//                navigationController?.pushViewController(searchPostVC, animated: true)
//            }
        }
    }
    
    @IBAction func searchBtnClicked(_ sender: UIButton) {
        if !isViewOpening{
            isViewOpening = true
            let searchPostVC = storyboard?.instantiateViewController(withIdentifier: "SearchPostVCID") as! SearchPostVC
            navigationController?.pushViewController(searchPostVC, animated: true)
        }
    }
    
    
    //MARK:>>>> ViewTab action
    @IBAction func viewTabs_Tapped(_ sender: Any) {
        
        switch ((sender as AnyObject).tag) {
        case 100:
            print("citizen tab")
            showCitizenTab()
        case 110:
            showSuperstarTab()
            print("superstar tab")
            
        case 120:
            print("brand tab")
            showBrandTab()
        case 140:
            print("sell tab")
            showSellTab()
        default:
            break
        }
    }
    
    
    func showCitizenTab() {
        loadAd = false
        seeAllButton.isHidden = false
        citizenlabel.textColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        citizenline.backgroundColor = UIColor.red//UIColor(hexValue: InstafeedColors.ThemeOrange)
        superstarlabel.textColor = UIColor.lightGray
        superstarline.backgroundColor = UIColor.white
        brandlabel.textColor = UIColor.lightGray
        brandline.backgroundColor = UIColor.white
        sellHereLabel.textColor = UIColor.lightGray
        sellBaseline.backgroundColor = UIColor.white
        //        Selllabel.textColor = UIColor.lightGray
        //        Sellline.backgroundColor = UIColor.white
        HeightConstraint.constant = tblview.contentOffset.y == 0 ? 181 : 0
        ViewFlag = "citizen"
        brandView.isHidden = true
        citizenstoriesview.isHidden = false
        showTables(tableCode: 1)
        selectedTab = "1"
        collview.reloadData()
        //getCitizenRecents()
    }
    
    func showSuperstarTab() {
        HeightConstraint.constant = 0
        seeAllButton.isHidden = true
        superstarlabel.textColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        superstarline.backgroundColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        citizenlabel.textColor = UIColor.lightGray
        citizenline.backgroundColor = UIColor.white
        brandlabel.textColor = UIColor.lightGray
        brandline.backgroundColor = UIColor.white
        sellHereLabel.textColor = UIColor.lightGray
        sellBaseline.backgroundColor = UIColor.white
        //        Selllabel.textColor = UIColor.lightGray
        //        Sellline.backgroundColor = UIColor.white
        ViewFlag = "superstar"
        print("superstar tab")
        brandView.isHidden = true
        citizenstoriesview.isHidden = false
        showTables(tableCode: 2)
        selectedTab = "2"
        //self.getSuperstarRecents(reloadCollectionView: true)
        //        self.getAdData()
    }
    
    
    func showBrandTab() {
        HeightConstraint.constant = 0
        seeAllButton.isHidden = true
        citizenlabel.textColor = UIColor.gray
        citizenline.backgroundColor = UIColor.white
        superstarlabel.textColor = UIColor.lightGray
        superstarline.backgroundColor = UIColor.white
        sellHereLabel.textColor = UIColor.lightGray
        sellBaseline.backgroundColor = UIColor.white
        //        Selllabel.textColor = UIColor.lightGray
        //        Sellline.backgroundColor = UIColor.white
        brandlabel.textColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        brandline.backgroundColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        ViewFlag = "brand"
        brandView.isHidden = false
        citizenstoriesview.isHidden = false
        showTables(tableCode: 3)
        selectedTab = "3"
        //        self.getAdData()
    }
    
    func showSellTab() {
        HeightConstraint.constant = 0
        //loadAd = false
        seeAllButton.isHidden = true
        citizenlabel.textColor = UIColor.lightGray
        citizenline.backgroundColor = UIColor.white//UIColor(hexValue: InstafeedColors.ThemeOrange)
        superstarlabel.textColor = UIColor.lightGray
        superstarline.backgroundColor = UIColor.white
        brandlabel.textColor = UIColor.lightGray
        brandline.backgroundColor = UIColor.white
        sellHereLabel.textColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        sellBaseline.backgroundColor = UIColor.red
        //        Selllabel.textColor = UIColor.lightGray
        //        Sellline.backgroundColor = UIColor.white
        
        ViewFlag = "Sell"
        brandView.isHidden = true
        citizenstoriesview.isHidden = true
        showTables(tableCode: 4)
        selectedTab = "4"
        //getCitizenRecents()
    }

    
    /// Removed from story board and
    /// commenting code for sell here section
    
    //    func showSellTab(){
    //        citizenlabel.textColor = UIColor.gray
    //        citizenline.backgroundColor = UIColor.white
    //        superstarlabel.textColor = UIColor.lightGray
    //        superstarline.backgroundColor = UIColor.white
    //        brandlabel.textColor = UIColor.lightGray
    //        brandline.backgroundColor = UIColor.white
    //        Selllabel.textColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
    //        Sellline.backgroundColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
    //        ViewFlag = "Sell"
    //        brandView.isHidden = false
    //        citizenstoriesview.isHidden = true
    //        showTables(tableCode: 3)
    //    }
    
    //MARK;>>>>>>>>> API Calls
    fileprivate func getProfile() {
        let api = ServerURL.firstpoint + ServerURL.Getprofile
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken] as [String:Any]
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result:ProfileDataModel) in
            if result.message == "success"{
                guard let response = result.data else {return}
                self.Pro_response = response
                DispatchQueue.main.async {
                    print(response)
                    UserDefaults.standard.saveData(data: "\(response.first_name!)", key: "UserName")
                    UserDefaults.standard.saveData(data: response.avatar ?? "", key: "ProfileImage")
                    UserDefaults.standard.saveData(data: response.user_id ?? "", key: "user_id")
                    
                    self.getCitizenRecents()
                    self.citizentab_getfeeds(count: self.limit)
                    self.superstartab_getfeeds(count: self.superstarlimit)
                    self.getSuperstarRecents()
                    self.getBrandFeeds(count: self.brandlimit)
                    self.getSellFeeds(count: self.Selllimit)
                }
            } else {
                CommonFuncs.AlertWithOK(msg: "Something went wrong while getting profile", vc: self)
                return
            }
        }
    }
    
    //MARK:>>>>> CITIZEN TAB RECENTS
    fileprivate func getCitizenRecents() {
        loadAd = false
        seeAllButton.isHidden = false
        
        let serverurl = ServerURL.firstpoint + ServerURL.citizenRecents
        
        networking.MakeRequest(Url: serverurl, Param: nil, vc: self) { (response:citizenRecents) in
            print(response)
            if response.message == "success"{
                if let recentsArray = response.data{
                    self.CitizenRecents = recentsArray.map{$0}
                    print("your array -> \(self.CitizenRecents)")
                    DispatchQueue.main.async {
                        self.collview.reloadData()
                    }
                }
            } else {
                print("not success")
            }
        }
    }
    
    fileprivate func getSuperstarRecents(reloadCollectionView: Bool = false){
        let serverurl = ServerURL.firstpoint + ServerURL.citizenRecents
        
        if reloadCollectionView{
            self.collview.reloadData()
        } else {
            networking.MakeRequest(Url: serverurl, Param: nil, vc: self) { (response:citizenRecents) in
                print(response)
                if response.message == "success"{
                    
                    if let recentsArray = response.data{
                        self.superstarRecent = recentsArray.map{$0}
                        print("your array -> \(self.CitizenRecents)")
                        DispatchQueue.main.async {
                            self.collview.reloadData()
                        }
                    }
                    
                }else{
                    print("not success")
                }
            }
        }
    }
    
    private func getAdData() {
        let serverurl = ServerURL.firstpoint + ServerURL.adData
        networking.MakeRequestWithGet(Url: serverurl, Param: nil, vc: self) { (response:  adResponse) in
            print(response)
            if response.message == "success" {
                if let recentsArray = response.data {
                    self.AdData = recentsArray.map{$0}
                    DispatchQueue.main.async {
                        self.loadAd = true
                        self.collview.reloadData()
                    }
                }
            } else {
                print("not success")
            }
        }
    }
    
    //MARK:>>>>>> Citizen tab-feeds
    fileprivate func citizentab_getfeeds(count:Int){
        self.loadAd = false
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        let apiURL = "\(ServerURL.firstpoint)citizen/news?&start=\(count)&token=\(UserToken)&lang_id=\(langId)"
        print(apiURL)
        networking.MakeRequest(Url: apiURL, Param: nil, vc: self) { (result:citizenFeeds) in
            print(result)
            if result.message == "success"{
                if let feedsArray = result.data{
                    for data in feedsArray{
                        if !self.Citizenfeeds.contains(where: {$0.id == data.id}){
                            self.Citizenfeeds.append(data)
                        }
                    }
                    print("your array -> \(self.Citizenfeeds)")
                    DispatchQueue.main.async {
                        self.tblview.reloadData()
                    }
                }
            } else {
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func superstartab_getfeeds(count:Int) {
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        let apiURL = "\(ServerURL.firstpoint)star/news?lang_id=1&start=\(count)&token=\(UserToken)&lang_id=\(langId)"
        print(apiURL)
        networking.MakeRequest(Url: apiURL, Param: nil, vc: self) { (result:citizenFeeds) in
            print(result)
            if result.message == "success"{
                if let feedsArray = result.data{
                    for data in feedsArray{
                        if !self.superstarFeed.contains(where: {$0.id == data.id}){
                            self.superstarFeed.append(data)
                        }
                    }
                    print("your array -> \(self.superstarFeed)")
                    DispatchQueue.main.async {
                        self.tblViewSuperstar.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        
        
    }
    
    //MARK:>>>>> Brand tab feeds
    fileprivate func getBrandFeeds(count:Int){
        self.loadAd = false
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        let apiURL = "\(ServerURL.firstpoint)brands/news?lang_id=1&start=\(count)&token=\(UserToken)&lang_id=\(langId)"
        print(apiURL)
        networking.MakeRequest(Url: apiURL, Param: nil, vc: self) { (response:brandfeeds) in
            print(response.message)
            if response.message == "success"{
                if let feedsArray = response.data{
                    for data in feedsArray{
                        if !self.BrandFeeds.contains(where: {$0.id == data.id}){
                            self.BrandFeeds.append(data)
                        }
                    }
                    print("your array -> \(self.BrandFeeds)")
                    DispatchQueue.main.async {
                        self.brand_tblview.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    fileprivate func getSellFeeds(count:Int){
        self.loadAd = false
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let apiURL = "http://13.234.116.90/api/mandi/news"
        print(apiURL)
        networking.MakeRequest(Url: apiURL, Param: nil, vc: self) { (response:SellFeed) in
            print(response.message)
            if response.message == "success"{
                if let feedsArray = response.data{
                    for data in feedsArray{
                        if !self.SellHerefeeds.contains(where: {$0.id == data.id}){
                            self.SellHerefeeds.append(data)
                        }
                    }
                    print("your array -> \(self.SellHerefeeds)")
                    DispatchQueue.main.async {
                        self.brand_tblview.reloadData()
                    }
                }
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }
    
    
    @IBAction func seeallTapped(_ sender: Any) {
        tabBarController?.selectedIndex = 4
    }
    
    deinit {
        print("homevc removed")
    }
    
}


extension HomeVc : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if loadAd {
            return self.AdData.count
        }
        return CitizenRecents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if loadAd {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "adCell", for: indexPath) as! adCell
            
            cell.recents = self.AdData[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "citizencell", for: indexPath) as! citizencell
            
            let index = CitizenRecents[indexPath.row]
            cell.recents = index
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        if loadAd {
            return CGSize(width: self.view.frame.size.width, height: collectionView.frame.size.height)
        } else {
            let leftAndRightPaddings: CGFloat = 20.0
            let numberOfItemsPerRow: CGFloat = 3.0
            
            let width = (collectionView.frame.width-leftAndRightPaddings)/numberOfItemsPerRow
            return CGSize(width: width, height: width) // You can change width and height here as pr your requirement
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if loadAd {
            if let url = URL(string: "https://www.google.co.in/") {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
            }
            
        } else {
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryFeedsViewController") as? CategoryFeedsViewController {
                vc.categoryId = CitizenRecents[indexPath.row].id ?? ""
                vc.categoryName = CitizenRecents[indexPath.row].name ?? ""
                vc.hidesBottomBarWhenPushed = true
                if !isViewOpening{
                    isViewOpening = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        
    }
}


extension HomeVc : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tblview{
            return Citizenfeeds.count
        }
        else if tableView == self.brand_tblview{
            //            if ViewFlag == "Sell"{
            //                return SellFeeds.count
            //            }
            return BrandFeeds.count
        }else if tableView == tableSellHere{
            return SellHerefeeds.count
        } else if tableView == self.tblViewSuperstar{
            return superstarFeed.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tblview{
            let cell = tableView.dequeueReusableCell(withIdentifier: "citizentblcell") as! citizentblcell
            cell.selectionStyle = .none
            if indexPath.row < Citizenfeeds.count{
                cell.myindexpath = indexPath
                cell.delegate = self
                cell.tableobj = tblview
                let feedOnIndex = Citizenfeeds[indexPath.row]
                if feedOnIndex.is_bookmark == "1"{
                    cell.btnBookmark.setImage(UIImage(named: "bookmarked"), for: .normal)
                }else{
                    cell.btnBookmark.setImage(UIImage(named: "Bookmark"), for: .normal)
                }
                cell.Newsfeeds = feedOnIndex
                
//                if !Citizenfeeds[indexPath.row].isExtended{
//                    cell.seemorebtn.setTitle("See more", for: .normal)
//                    cell.feedText.numberOfLines = 2
//
//                }else{
//                    cell.seemorebtn.setTitle("See less", for: .normal)
//                    cell.feedText.numberOfLines = 0
//
////                    cell.isExtended = false
//                }
            }
            return cell
        } else if tableView == tableSellHere{
            let cell = tableView.dequeueReusableCell(withIdentifier: "citizentblcell") as! citizentblcell
            cell.selectionStyle = .none
            if indexPath.row < SellHerefeeds.count{
                cell.myindexpath = indexPath
                cell.delegate = self
                cell.tableobj = tblview
                let feedOnIndex = SellHerefeeds[indexPath.row]
                if feedOnIndex.is_bookmark == "1"{
                    cell.btnBookmark.setImage(UIImage(named: "bookmarked"), for: .normal)
                }else{
                    cell.btnBookmark.setImage(UIImage(named: "Bookmark"), for: .normal)
                }
                cell.Newsfeeds = feedOnIndex
                
                //                if !Citizenfeeds[indexPath.row].isExtended{
                //                    cell.seemorebtn.setTitle("See more", for: .normal)
                //                    cell.feedText.numberOfLines = 2
                //
                //                }else{
                //                    cell.seemorebtn.setTitle("See less", for: .normal)
                //                    cell.feedText.numberOfLines = 0
                //
                ////                    cell.isExtended = false
                //                }
            }
            return cell
        } else if tableView == tblViewSuperstar{
            let cell = tableView.dequeueReusableCell(withIdentifier: "citizentblcell") as! citizentblcell
            cell.selectionStyle = .none
            if indexPath.row < superstarFeed.count{
                cell.myindexpath = indexPath
                cell.delegate = self
                cell.tableobj = tblViewSuperstar
                let feedOnIndex = superstarFeed[indexPath.row]
                if feedOnIndex.is_bookmark == "1"{
                    cell.btnBookmark.setImage(UIImage(named: "bookmarked"), for: .normal)
                }else{
                    cell.btnBookmark.setImage(UIImage(named: "Bookmark"), for: .normal)
                }
                cell.Newsfeeds = feedOnIndex
            }
            return cell
        } else if tableView == self.brand_tblview {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Brandcel") as! Brandcel
            cell.selectionStyle = .none
            
            //            if ViewFlag == "Sell"{
            //                if indexPath.row <= SellFeeds.count{
            //                    cell.tblView = self.brand_tblview
            //                    cell.myIndexpath = indexPath
            //                    cell.delegate = self
            //                    cell.BottomView.isHidden = true
            //                    cell.BuyNowBtn.isHidden = false
            //                    cell.btnFollow.isHidden = true
            //                    cell.SellFeeds = SellFeeds[indexPath.row]
            //                }
            //            }else{
            if indexPath.row < BrandFeeds.count {
                cell.BrandFeeds = BrandFeeds[indexPath.row]
                cell.tblView = self.brand_tblview
                cell.myIndexpath = indexPath
                cell.delegate = self
                cell.BottomView.isHidden = false
                cell.BuyNowBtn.isHidden = true
                cell.btnFollow.isHidden = false
            }
            //}
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == self.tblview{
            guard let videoCell = (cell as? citizentblcell) else { return }
            if (tableView.visibleCells.first != nil){
                videoCell.avplayer.play()
            }else{
                videoCell.avplayer.pause()
            }
        }else if tableView == self.brand_tblview{
            guard let videoCell = (cell as? Brandcel) else { return }
            if (tableView.visibleCells.first != nil){
                //videoCell.soundbtn.isSelected = true
                videoCell.avplayer.play()
            }else{
                videoCell.avplayer.pause()
            }
        }
    }*/
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == self.tblview{
            guard let videoCell = cell as? citizentblcell else { return };
            // videoCell.soundbtn.isSelected = false
            videoCell.avplayer.pause()
            videoCell.avplayer.replaceCurrentItem(with: nil)
            
        }else if tableView == tableSellHere{
            guard let videoCell = cell as? citizentblcell else { return };
            // videoCell.soundbtn.isSelected = false
            videoCell.avplayer.pause()
            videoCell.avplayer.replaceCurrentItem(with: nil)
            
        } else if tableView == self.brand_tblview{
            guard let videoCell = cell as? Brandcel else { return };
            // videoCell.soundbtn.isSelected = false
            videoCell.avplayer.pause()
            videoCell.avplayer.replaceCurrentItem(with: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Articlescreen") as? Articlescreen {
            if tableView == tblview{
                vc.moduleType = "1"
                
                vc.dt_added = self.Citizenfeeds[indexPath.row].dt_added!
                vc.userAvtar = self.Citizenfeeds[indexPath.row].avatar
                vc.feedDetail = self.Citizenfeeds[indexPath.row]
                if let postId = self.Citizenfeeds[indexPath.row].id{
                    vc.postId = postId
                    
                    
                }
            }else if tableView == tableSellHere{
                vc.moduleType = "4"
                
                vc.dt_added = self.SellHerefeeds[indexPath.row].dt_added!
                vc.userAvtar = self.SellHerefeeds[indexPath.row].avatar
                vc.feedDetail = self.SellHerefeeds[indexPath.row]
                if let postId = self.SellHerefeeds[indexPath.row].id{
                    vc.postId = postId
                }
            } else if tableView == brand_tblview {
                vc.moduleType = "3"
                vc.dt_added = self.BrandFeeds[indexPath.row].dt_added!
                vc.userAvtar = self.BrandFeeds[indexPath.row].avatar
                vc.barndDetail = self.BrandFeeds[indexPath.row]
                if let postId = self.BrandFeeds[indexPath.row].id{
                    vc.postId = postId
                }
            } else{
                vc.moduleType = "2"
                vc.dt_added = self.superstarFeed[indexPath.row].dt_added!
                vc.userAvtar = self.superstarFeed[indexPath.row].avatar
                vc.feedDetail = self.superstarFeed[indexPath.row]
                if let postId = self.superstarFeed[indexPath.row].id{
                    vc.postId = postId
                }
            }
            
            if !isOpeningDetailPage{
                isOpeningDetailPage = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        if ViewFlag == "citizen"{
    //            infiniteScroll(scrollView: scrollView)
    //        }else if ViewFlag == "brand"{
    //            infiniteScroll(scrollView: scrollView)
    //        }
    //
    //
    //
    //    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isLikingPost{
            if selectedTab == "1"{
                if tblview.contentOffset.y == 0{
                    HeightConstraint.constant = 181
                } else {
                    HeightConstraint.constant = 0
                }
            } else {
                HeightConstraint.constant = 0
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                self.isLikingPost = false
            })
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if ViewFlag == "citizen"{
            infiniteScroll(scrollView: scrollView)
        }else if ViewFlag == "brand"{
            infiniteScroll(scrollView: scrollView)
        }else if ViewFlag == "superstar"{
            infiniteScroll(scrollView: scrollView)
        }
        //            print("scrollViewDidEndDragging")
        //            if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        //            {
        //                if !isDataLoading{
        //                    isDataLoading = true
        //                    self.pageNo=self.pageNo+1
        //                    self.limit=self.limit+10
        //                    self.offset=self.limit * self.pageNo
        //                    loadCallLogData(offset: self.offset, limit: self.limit)
        //
        //                }
        //            }
    }
    
    private func infiniteScroll(scrollView:UIScrollView){
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0{
            
            if ViewFlag == "citizen" && self.Citizenfeeds.count % 10 == 0{
                limit += 10
                citizentab_getfeeds(count: limit)
            }else if ViewFlag == "superstar" && self.superstarFeed.count % 10 == 0{
                superstarlimit += 10
                superstartab_getfeeds(count: superstarlimit)
            }else if ViewFlag == "brand" && self.BrandFeeds.count % 10 == 0{
                brandlimit += 10
                getBrandFeeds(count: brandlimit)
            }else if ViewFlag == "Sell" && self.SellHerefeeds.count % 10 == 0{
                Selllimit += 10
                getSellFeeds(count: Selllimit)
            }
            //print("begin batch fetch")
        } else {
            if currentOffset <= -minOffsetToTriggerRefresh{
                self.refreshData()
            }
        }
    }
    
}

extension HomeVc : CitizenFeedsProtocols{
    func Sharetap(index: IndexPath, tableView: UITableView) {
        var txt = ""
        if tableView == tblview{
            // text to share
            txt = """
            http://13.234.116.90/news/\(self.BrandFeeds[index.row].slug ?? "")
            
            Download App for more updates
            www.google.com
            """
            // set up activity view controller
        }else{
            // text to share
            txt = "http://13.234.116.90/news/\(self.superstarFeed[index.row].slug ?? "")"
                + """
            Download App for more updates
            www.google.com
            """
        }
        
        let imageToShare = [ txt ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    func userHasLikedThePost(index: IndexPath, tableView: UITableView) {
        if tableView == tblview{
            guard let islikedAlready = Citizenfeeds[index.row].is_like else {return}
            guard let postID = Citizenfeeds[index.row].id else {return}
            if islikedAlready == "0"{
                likePostAPi(postId: postID, index: index, url: ServerURL.likepost)
            }else{
                DislikePostAPi(postId: postID, index: index, url: ServerURL.likepost)
            }
            
        } else {
            guard let islikedAlready = superstarFeed[index.row].is_like else {return}
            guard let postID = superstarFeed[index.row].id else {return}
            if islikedAlready == "0"{
                likePostAPi(postId: postID, index: index, url: ServerURL.starlikepost)
            }else{
                DislikePostAPi(postId: postID, index: index, url: ServerURL.starlikepost)
            }
        }
        
    }
    
    func didTapOnTag(tagValue: String) {
        //        let searchPostVC = storyboard?.instantiateViewController(withIdentifier: "SearchPostVCID") as! SearchPostVC
        //        searchPostVC.searchTextBefore = tagValue
        //        navigationController?.pushViewController(searchPostVC, animated: true)
        let storyBoard = UIStoryboard(name: "sidemenu", bundle: nil)
        let myPostVC = storyBoard.instantiateViewController(withIdentifier: "MyPostsVCID") as! MyPostsVC
        myPostVC.searchTextBefore = tagValue
        myPostVC.searchType = ViewFlag
        if !isViewOpening{
            isViewOpening = true
            navigationController?.pushViewController(myPostVC, animated: true)
        }
    }
    
    func userClickedLikeCountsLabel(index: IndexPath, tableView: UITableView) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "LikesVC") as? LikesVC {
            
            var postID: String = ""
            var feedType: FeedType = .None
            
            if tableView == self.tblview{
                
                if index.row < Citizenfeeds.count {
                    if let postId = Citizenfeeds[index.row].id {
                        if Int(Citizenfeeds[index.row].total_likes ?? "0") ?? 0 > 0 {
                            postID = postId
                            feedType = .Citizen
                        }
                    }
                }
            } else if tableView == tblViewSuperstar {
                
                if index.row < superstarFeed.count {
                    if let postId = superstarFeed[index.row].id {
                        if Int(superstarFeed[index.row].total_likes ?? "0") ?? 0 > 0 {
                            postID = postId
                            feedType = .Star
                        }
                    }
                }
                
            } else if tableView == self.brand_tblview {
                
                if index.row < BrandFeeds.count {
                    if let postId = BrandFeeds[index.row].id {
                        if Int(BrandFeeds[index.row].total_likes ?? "0") ?? 0 > 0 {
                            postID = postId
                            feedType = .Brand
                        }
                    }
                }
            }
            
            if feedType != .None {
                vc.postID = postID
                vc.feedType = feedType
                if !isViewOpening{
                    isViewOpening = true
                self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func writeComment(index: IndexPath, tableView:UITableView) {
        //guard let postID = Citizenfeeds[index.row].short_description else {return}
        let move = storyboard?.instantiateViewController(withIdentifier: "CommentVc") as! CommentVc
        if tableView == self.tblview {
            move.TabType = "citizen"
            move.citizendata = Citizenfeeds[index.row]
        } else {
            move.TabType = "Star"
            move.citizendata = superstarFeed[index.row]
        }
        if !isViewOpening{
            isViewOpening = true
            navigationController?.pushViewController(move, animated: true)
        }
    }
    
    
    func bookmarkTap(index: IndexPath, tableView:UITableView) {
        
        isLikingPost = true
        
        print("bookmark tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        if tableView == tblViewSuperstar{
            guard let id = superstarFeed[index.row].id else {return}
            guard let is_bookmarked = superstarFeed[index.row].is_bookmark else {return}
            if is_bookmarked == "0"{
                CommonFuncs.addbookmark(url: ServerURL.addBookmark,vc: self, postid: id, token: UserToken, moduleId: "2", completionHandler: {resp, err in
                    if resp?.message == "success"{
                        self.superstarFeed[index.row].is_bookmark = "1"
                        //                        self.tblViewSuperstar.reloadData()
                        let indexPath = IndexPath(item: index.row, section: 0)
                        self.tblViewSuperstar.reloadRows(at: [indexPath], with: .none)
                    }
                    
                })
            }else{
                CommonFuncs.addbookmark(url: ServerURL.unbookmark,vc: self, postid: id, token: UserToken, moduleId: "2", completionHandler: {resp, err in
                    if resp?.message == "success"{
                        self.superstarFeed[index.row].is_bookmark = "0"
                        //                        self.tblViewSuperstar.reloadData()
                        let indexPath = IndexPath(item: index.row, section: 0)
                        self.tblViewSuperstar.reloadRows(at: [indexPath], with: .none)
                    }
                    
                })
            }
        }else if tableView == tblview{
            guard let id = Citizenfeeds[index.row].id else {return}
            guard let is_bookmarked = Citizenfeeds[index.row].is_bookmark else {return}
            if is_bookmarked == "0"{
                CommonFuncs.addbookmark(url: ServerURL.addBookmark,vc: self, postid: id, token: UserToken, moduleId: "1", completionHandler: {resp,err in
                    if resp?.message == "success"{
                        self.Citizenfeeds[index.row].is_bookmark = "1"
                        //                        self.tblview.reloadData()
                        let indexPath = IndexPath(item: index.row, section: 0)
                        self.tblview.reloadRows(at: [indexPath], with: .none)
                    }
                })
            }else{
                CommonFuncs.addbookmark(url: ServerURL.unbookmark,vc: self, postid: id, token: UserToken, moduleId: "1", completionHandler: {resp,err in
                    if resp?.message == "success"{
                        self.Citizenfeeds[index.row].is_bookmark = "0"
                        //                        self.tblview.reloadData()
                        let indexPath = IndexPath(item: index.row, section: 0)
                        self.tblview.reloadRows(at: [indexPath], with: .none)
                    }
                })
            }
        }
        
        
    }
    
    func followTap(index: IndexPath, tableView:UITableView) {
        print("follow tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        if tableView == tblViewSuperstar{
            guard let id = superstarFeed[index.row].id else {return}
            guard let username = superstarFeed[index.row].username else {return}
            guard let is_follow = superstarFeed[index.row].is_follow else {return}
            if is_follow == "0"{
                CommonFuncs.addfollow(url: ServerURL.addfollow, username: username,vc: self, postid: id, token: UserToken, moduleId: "2", completionHandler: {resp, err in
                    if resp?.message == "success"{
                        self.superstarFeed[index.row].is_follow = "1"
                        self.tblViewSuperstar.reloadData()
                    }
                    
                })
            }else{
                CommonFuncs.addfollow(url: ServerURL.unfollow,username: username ,vc: self, postid: id, token: UserToken, moduleId: "2", completionHandler: {resp, err in
                    if resp?.message == "success"{
                        self.superstarFeed[index.row].is_follow = "0"
                        self.tblViewSuperstar.reloadData()
                    }
                    
                })
            }
        }else if tableView == tblview{
            guard let id = Citizenfeeds[index.row].id else {return}
            guard let username = Citizenfeeds[index.row].username else {return}
            guard let is_bookmarked = Citizenfeeds[index.row].is_bookmark else {return}
            if is_bookmarked == "0"{
                CommonFuncs.addfollow(url: ServerURL.addfollow,username: username, vc: self, postid: id, token: UserToken, moduleId: "1", completionHandler: {resp,err in
                    if resp?.message == "success"{
                        self.Citizenfeeds[index.row].is_follow = "1"
                        self.tblview.reloadData()
                    }
                })
            }else{
                CommonFuncs.addfollow(url: ServerURL.unfollow,username: username, vc: self, postid: id, token: UserToken, moduleId: "1", completionHandler: {resp,err in
                    if resp?.message == "success"{
                        self.Citizenfeeds[index.row].is_follow = "0"
                        self.tblview.reloadData()
                    }
                })
            }
        }
    }
    
    func citizenTitletapped(index: IndexPath, tableView:UITableView) {
        let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
        var boolIsMove = true
        if tableView == self.tblview{
            move.moduleType = "1"
            guard let username = self.Citizenfeeds[index.row].username else{return}
            if self.Citizenfeeds[index.row].is_anonymous == "y"{
                boolIsMove = false
            }
            move.username = username
            guard let userId = self.Citizenfeeds[index.row].user_id else{return}
            move.userId = userId
        } else {
            move.moduleType = "2"
            guard let username = self.superstarFeed[index.row].username else{return}
            move.username = username
            if self.superstarFeed[index.row].is_anonymous == "y"{
                boolIsMove = false
            }
            guard let userId = self.superstarFeed[index.row].user_id else{return}
            move.userId = userId
        }
        if boolIsMove {
            if !isViewOpening{
                isViewOpening = true
                navigationController?.pushViewController(move, animated: false)
            }
        }
    }
    
    func tappedSeeMore(indexPath:IndexPath, tableView tblView:UITableView) {
//        let cell: citizentblcell = tblView.cellForRow(at: indexPath) as! citizentblcell
//        print("Title -> \(String(describing: cell.seemorebtn.titleLabel?.text))")
        var citizen = Citizenfeeds[indexPath.row]
//        if citizen.isExtended {
//            citizen.isExtended = false
//        }else{
//            citizen.isExtended = true
//        }
        Citizenfeeds.insert(citizen, at: indexPath.row)
//        if cell.seemorebtn.title(for: .normal) == "See less"{
//        if cell.seemorebtn.currentTitle == "See less"{
//            cell.seemorebtn.setTitle("See more", for: .normal)
//            cell.feedText.numberOfLines = 2
//        }else{
//            cell.seemorebtn.setTitle("See less", for: .normal)
//            cell.feedText.numberOfLines = 0
//        }
        tblView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    //MARK:>>>>> Like post api call
    func likePostAPi(postId:String,index:IndexPath, url:String) {
        isLikingPost = true
        
        let apiurl = ServerURL.firstpoint + url
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken, "id":postId, "vote":"u", "type":url.contains("star") ? "2" : "1"] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:likePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if url.contains("star"){
                    
                    let indexx = self.superstarFeed.firstIndex(where: { $0.id == postId })
                    if let indexxx = indexx {
                        self.superstarFeed[indexxx].is_like = "1"
                        if let totalLikesCount = self.superstarFeed[indexxx].total_likes{
                            var totalLikes:Int = Int(totalLikesCount)!
                            totalLikes = totalLikes + 1
                            self.superstarFeed[indexxx].total_likes = String(format: "%ld", totalLikes)
                        }
                        self.tblViewSuperstar.reloadRows(at: [index], with: .none)
                    }
                    
                    
                }else{
                    
                    let indexx = self.Citizenfeeds.firstIndex(where: { $0.id == postId })
                    if let indexxx = indexx{
                        self.Citizenfeeds[indexxx].is_like = "1"
                        if let totalLikesCount = self.Citizenfeeds[indexxx].total_likes{
                            var totalLikes:Int = Int(totalLikesCount)!
                            totalLikes = totalLikes + 1
                            self.Citizenfeeds[indexxx].total_likes = String(format: "%ld", totalLikes)
                        }
                        
                        let indexPath = IndexPath(item: indexxx, section: 0)
                        self.tblview.reloadRows(at: [indexPath], with: .none)
                        
                        //                        let indexPath = IndexPath(item: indexxx, section: 0)
                        //                        if let visibleIndexPaths = self.tblview.indexPathsForVisibleRows?.index(of: indexPath as IndexPath) {
                        //                            if visibleIndexPaths != NSNotFound {
                        //                                self.tblview.reloadRows(at: [indexPath], with: .fade)
                        //                            }
                        //                        }
                        
                        //                        let contentOffset = self.tblview.contentOffset
                        //                        self.tblview.reloadData()
                        //                        self.tblview.layoutIfNeeded()
                        //                        self.tblview.setContentOffset(contentOffset, animated: false)
                    }
                    
                    
                }
            }
        }
    }
    
    
    //MARK:>>>>> Dislike the post
    
    func DislikePostAPi(postId:String,index:IndexPath, url:String){
        
        isLikingPost = true
        
        let apiurl = ServerURL.firstpoint + url
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken, "id":postId, "vote":"d", "type": url.contains("star") ? "2" : "1"] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:dislikePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if url.contains("star"){
                    
                    let index = self.superstarFeed.firstIndex(where: { $0.id == postId })
                    if let index = index{
                        self.superstarFeed[index].is_like = "0"
                        if let totalLikesCount = self.superstarFeed[index].total_likes{
                            var totalLikes:Int = Int(totalLikesCount)!
                            totalLikes = totalLikes - 1
                            self.superstarFeed[index].total_likes = String(format: "%ld", totalLikes)
                        }
                        //                        self.tblViewSuperstar.reloadData()
                        let indexPath = IndexPath(item: index, section: 0)
                        self.tblViewSuperstar.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    
                } else {
                    
                    let indexxx = self.Citizenfeeds.firstIndex(where: { $0.id == postId })
                    if let indexx = indexxx{
                        self.Citizenfeeds[indexx].is_like = "0"
                        if let totalLikesCount = self.Citizenfeeds[indexx].total_likes{
                            var totalLikes:Int = Int(totalLikesCount)!
                            totalLikes = totalLikes - 1
                            self.Citizenfeeds[indexx].total_likes = String(format: "%ld", totalLikes)
                        }
                        
                        //                        let contentOffset = self.tblview.contentOffset
                        
                        let indexPath = IndexPath(item: indexx, section: 0)
                        self.tblview.reloadRows(at: [indexPath], with: .none)
                        
                        //                        let indexPath = IndexPath(item: indexx, section: 0)
                        //                        if let visibleIndexPaths = self.tblview.indexPathsForVisibleRows?.index(of: indexPath as IndexPath) {
                        //                            if visibleIndexPaths != NSNotFound {
                        //                                self.tblview.reloadRows(at: [indexPath], with: .fade)
                        //                            }
                        //                        }
                        
                        //                        self.tblview.reloadData()
                        //                        self.tblview.layoutIfNeeded()
                        //                        self.tblview.setContentOffset(contentOffset, animated: false)
                        
                        //self.tblview.reloadRows(at: [index], with: .top)//reloadData()
                    }
                }
            }
        }
    }
    
    
}

extension HomeVc : BrandcellProtocols {
    
    func likethePost(index: IndexPath) {
        
        isLikingPost = true
        
        guard let postID = BrandFeeds[index.row].id else {return}
        guard let islikedAlready = BrandFeeds[index.row].is_like else {return}
        
        if islikedAlready == "0"{
            //like post
            BrandPostLikeAPi(postId: postID, index: index)
        }else{
            //dislike post
            BrandPostDisLikeAPi(postId: postID, index: index)
        }
    }
    
    func AddaComment(index: IndexPath) {
        let move = storyboard?.instantiateViewController(withIdentifier: "CommentVc") as! CommentVc
        move.TabType = "brand"
        move.brandFeeddata = BrandFeeds[index.row]
        if !isViewOpening{
            isViewOpening = true
            navigationController?.pushViewController(move, animated: true)
        }
    }
    
    
    func Bookmarktap(index: IndexPath, tblView: UITableView) {
        
        isLikingPost = true
        
        guard let isBookmarked = self.BrandFeeds[index.row].is_bookmark else {return}
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let bookmark = UIAlertAction(title: isBookmarked == "1" ? "Remove Bookmark" : "Bookmark", style: .default) { action -> Void in
            guard let postID = self.BrandFeeds[index.row].id else {return}
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            
            if isBookmarked == "0"{
                CommonFuncs.addbookmark(url: ServerURL.addBookmark,vc: self, postid: postID, token: UserToken, moduleId: "3", completionHandler: {resp,err in
                    if resp?.message == "success"{
                        self.BrandFeeds[index.row].is_bookmark = "1"
                        let indexPath = IndexPath(item: index.row, section: 0)
                        self.brand_tblview.reloadRows(at: [indexPath], with: .none)
                        //                        self.brand_tblview.reloadData()
                    }
                })
            }else{
                CommonFuncs.addbookmark(url: ServerURL.unbookmark,vc: self, postid: postID, token: UserToken, moduleId: "3", completionHandler: {resp,err in
                    if resp?.message == "success"{
                        self.BrandFeeds[index.row].is_bookmark = "0"
                        //                        self.brand_tblview.reloadData()
                        let indexPath = IndexPath(item: index.row, section: 0)
                        self.brand_tblview.reloadRows(at: [indexPath], with: .none)
                    }
                })
            }
        }
        
        bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(bookmark)
        
        let More = UIAlertAction(title: "Report", style: .default) { action -> Void in
            self.spamActionSheet(index: index, tblView: tblView)
        }
        
        More.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(More)
        
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        btnCancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(btnCancel)
        
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func spamActionSheet(index: IndexPath, tblView:UITableView){
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let bookmark = UIAlertAction(title:"Spam", style: .default) { action -> Void in
            self.spamTap(index: index, tableView: tblView, reasonId: "1") //reasonId = "1"
        }
        
        bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(bookmark)
        
        let More = UIAlertAction(title: "Inappropriate", style: .default) { action -> Void in
            self.spamTap(index: index, tableView: tblView, reasonId: "2")//reasonId = "2"
        }
        
        More.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(More)
        let speech = UIAlertAction(title: "Racism, Hate speech", style: .default) { action -> Void in
            self.spamTap(index: index, tableView: tblView, reasonId: "3")//reasonId = "3"
        }
        
        speech.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(speech)
        
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        btnCancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(btnCancel)
        
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func TitleTapped(index: IndexPath) {
        let move = storyboard?.instantiateViewController(withIdentifier: "Brandcategories") as! Brandcategories
        if BrandFeeds[index.row].is_anonymous?.uppercased() == "N"{
            move.userId = BrandFeeds[index.row].user_id ?? ""
            move.username = BrandFeeds[index.row].username ?? ""
            if !isViewOpening{
                isViewOpening = true
            navigationController?.pushViewController(move, animated: false)
            }
        }
    }
    
    
    func ShareTapped(index: IndexPath) {
        
        let txt = """
        http://13.234.116.90/news/\(self.BrandFeeds[index.row].slug ?? "")
        
        Download App for more updates
        www.google.com
        """
        
        // set up activity view controller
        let imageToShare = [ txt ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func followBrand(userName:String, index: IndexPath){
        let apiurl = ServerURL.firstpoint + ServerURL.followBrand
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        let params = ["token":UserToken, "username":userName] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:barnddislikePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    for i in 0..<self.BrandFeeds.count{
                        if self.BrandFeeds[i].username == userName{
                            self.BrandFeeds[i].is_follow = "1"
                        }
                    }
                    
                    self.brand_tblview.reloadData()
                }
            }
        }
    }
    
    
    func FollowTap(index: IndexPath) {
        
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        if self.BrandFeeds.count > index.row{
            
            guard let userName = self.BrandFeeds[index.row].username else{return}
            guard let isFollow = self.BrandFeeds[index.row].is_follow else{return}
            let params = ["token":UserToken, "username":userName] as [String:Any]
            print(params)
            if isFollow == "0"{
                let apiurl = ServerURL.firstpoint + ServerURL.followBrand
                networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:barnddislikePost) in
                    print(response)
                    
                    if response.message == "error"{
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }else{
                        if let data = response.data{
                            print(data as Any)
                            for i in 0..<self.BrandFeeds.count{
                                if self.BrandFeeds[i].username == userName{
                                    self.BrandFeeds[i].is_follow = "1"
                                }
                            }
                            self.brand_tblview.reloadData()
                        }
                    }
                }
            }else{
                let apiurl = ServerURL.firstpoint + ServerURL.unfollowBrand
                networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:barnddislikePost) in
                    print(response)
                    
                    if response.message == "error"{
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }else{
                        if let data = response.data{
                            print(data as Any)
                            for i in 0..<self.BrandFeeds.count{
                                if self.BrandFeeds[i].username == userName{
                                    self.BrandFeeds[i].is_follow = "0"
                                }
                            }
                            self.brand_tblview.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func threeDotAction(index: IndexPath, tableView: UITableView) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let bookmark = UIAlertAction(title: "Block", style: .default) { action -> Void in
            self.blockTap(index: index, tableView: tableView)
        }
        //btnCamera.setValue(UIImage(named:"camera-icon"), forKey: "image")
        bookmark.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(bookmark)
        
        let More = UIAlertAction(title: "Report", style: .default) { action -> Void in
            self.spamActionSheet(index: index, tblView: tableView)
        }
        //btnGallery.setValue(UIImage(named:"gallery-icon"), forKey: "image")
        More.setValue(UIColor(hexValue: InstafeedColors.ThemeOrange), forKey: "titleTextColor")
        actionSheetController.addAction(More)
        
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        
        btnCancel.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(btnCancel)
        
        
        //fix for ipad
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func blockTap(index: IndexPath, tableView:UITableView) {
        
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        var uName = String()
        if tableView == tblViewSuperstar{
            guard let userName = self.superstarFeed[index.row].username else{return}
            uName = userName
        }else{
            guard let userName = self.Citizenfeeds[index.row].username else{return}
            uName = userName
        }
        
        let params = ["token":UserToken, "username":uName] as [String:Any]
        print(params)
        let apiurl = ServerURL.firstpoint + ServerURL.blockUser
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:userBlocked) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    if tableView == self.tblViewSuperstar{
                        self.superstarFeed[index.row].is_blocked = "1"
                        for i in 0..<self.superstarFeed.count{
                            if i < self.superstarFeed.count && self.superstarFeed[i].username == uName{
                                self.superstarFeed.remove(at: i)
                            }
                        }
                        
                        self.tblViewSuperstar.reloadData()
                        
                    }else{
                        self.Citizenfeeds[index.row].is_blocked = "1"
                        for i in 0..<self.Citizenfeeds.count{
                            if i < self.Citizenfeeds.count && self.Citizenfeeds[i].username == uName{
                                self.Citizenfeeds.remove(at: i)
                            }
                        }
                        self.tblview.reloadRows(at: [index], with: .none)//reloadData()
                    }
                    
                }
            }
        }
        
        
    }
    
    func spamTap(index: IndexPath, tableView:UITableView,reasonId:String) {
        print("spam tap citizen")
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        if tableView == tblViewSuperstar{
            guard let id = superstarFeed[index.row].id else {return}
            CommonFuncs.spammarked(url: ServerURL.addspam,vc: self, postid: id, token: UserToken, moduleId: "2", reasonId: reasonId, completionHandler: {resp, err in
                if resp?.message == "success"{
                    self.superstarFeed[index.row].is_spamed = "1"
                    self.superstarFeed.remove(at: index.row)
                    self.tblViewSuperstar.reloadData()
                }
            })
            
        }else if tableView == tblview{
            guard let id = Citizenfeeds[index.row].id else {return}
            CommonFuncs.spammarked(url: ServerURL.addspam,vc: self, postid: id, token: UserToken, moduleId: "1", reasonId: reasonId, completionHandler: {resp,err in
                if resp?.message == "success"{
                    self.Citizenfeeds[index.row].is_spamed = "1"
                    self.Citizenfeeds.remove(at: index.row)
                    self.tblview.reloadData()
                }
            })
        }else{
            guard let id = BrandFeeds[index.row].id else {return}
            CommonFuncs.spammarked(url: ServerURL.addspam,vc: self, postid: id, token: UserToken, moduleId: "3", reasonId: reasonId, completionHandler: {resp,err in
                if resp?.message == "success"{
                    self.BrandFeeds[index.row].is_spamed = "1"
                    self.BrandFeeds.remove(at: index.row)
                    self.brand_tblview.reloadData()
                }
            })
        }
    }
    
    
    //MARK:>>>>> Like post api call
    func BrandPostLikeAPi(postId:String,index:IndexPath){
        
        isLikingPost = true
        
        let apiurl = ServerURL.firstpoint + ServerURL.brandlikePost
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken, "id":postId, "vote":"u", "type":"1"] as [String:Any]
        print(params)
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:brandlikePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    self.BrandFeeds[index.row].is_like = "1"
                    //                    self.brand_tblview.reloadData()
                    
                    let indexPath = IndexPath(item: index.row, section: 0)
                    self.brand_tblview.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    
    //MARK:>>>>> Dislike the post
    
    func BrandPostDisLikeAPi(postId:String,index:IndexPath){
        
        isLikingPost = true
        
        let apiurl = ServerURL.firstpoint + ServerURL.brandlikePost
        // let postId = Newsfeeds.id
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken, "id":postId, "vote":"d", "type":"1"] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:barnddislikePost) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                if let data = response.data{
                    print(data as Any)
                    self.BrandFeeds[index.row].is_like = "1"
                    //                    self.brand_tblview.reloadData()
                    
                    let indexPath = IndexPath(item: index.row, section: 0)
                    self.brand_tblview.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    
}
