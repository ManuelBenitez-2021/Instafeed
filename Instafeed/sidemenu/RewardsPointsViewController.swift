//
//  RewardsPointsViewController.swift
//  Instafeed
//
//  Created by Kumar, Gopesh on 26/08/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import Segmentio


class RewardsPointsViewController: UIViewController {
    
    @IBOutlet weak var collectionViewRewards: UICollectionView!
    @IBOutlet weak var tableViewRewards: UITableView!
    
    let imageArray = ["refer-app", "quality-info", "sharing-is-caring", "watch-video", "rate-instafeed", "gift"]
    let textArray = ["Refer App", "Quality Info", "Sharing is caring", "Watch Video", "Rate Instafeed", "Daily Signin Bonus"]
    let subtextArray = ["Earn 50 bonus points on every successful referral", "Earn 10 bonus points on every quality information you post", "Earn 1 bonus point per share for quality info you share with your peers", "Earn 5 bonus points with every video you watch", "Earn 30 bonus points if you rate us on play store", "Open app daily & earn 5 bonus points"]
    
    var dataDict:RewardGift = RewardGift()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        collectionViewRewards.isHidden = true
        var content = [SegmentioItem]()
        
        let tornadoItem = SegmentioItem(
            title: "EARN POINTS",
            image: nil
        )
        let tornadoItem1 = SegmentioItem(
            title: "REWARDS",
            image: nil
        )
        let tornadoItem2 = SegmentioItem(
            title: "HISTORY",
            image: nil
        )
        content.append(tornadoItem)
        content.append(tornadoItem1)
        content.append(tornadoItem2)
        
        let states =  SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.boldSystemFont(ofSize: 14.0),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.boldSystemFont(ofSize: 14.0),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                titleFont: UIFont.boldSystemFont(ofSize: 14.0),
                titleTextColor: .black
            )
        )
        
        let options = SegmentioOptions(
            backgroundColor: .white,
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .bottom, height: 0.0, color: UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1.0)),
            verticalSeparatorOptions: nil,
            segmentStates: states
        )
        
        var segmentioView: Segmentio!
        
        let segmentioViewRect = CGRect(x: 0, y: 420, width: UIScreen.main.bounds.width, height: 50)
        segmentioView = Segmentio(frame: segmentioViewRect)
        segmentioView.setup(
            content: content,
            style: .onlyLabel,
            options: options
        )
        view.addSubview(segmentioView)
        segmentioView.selectedSegmentioIndex = 0
        
        segmentioView.valueDidChange = {[weak self] segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
            if segmentIndex == 1 || segmentIndex == 2 {
                self?.collectionViewRewards.isHidden = false
                self?.tableViewRewards.isHidden =  true
            } else {
                self?.collectionViewRewards.isHidden = true
                self?.tableViewRewards.isHidden =  false
            }
        }
        
        self.rewardGiftAPi()
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:>>>>> reward gift api call
    func rewardGiftAPi(){
        let apiurl = ServerURL.firstpoint + ServerURL.rewardgift
        
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        print("\(UserToken)")
        
        let params = ["token":UserToken] as [String:Any]
        
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:RewardGift) in
            print(response)
            
            if response.message == "error"{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }else{
                self.dataDict = response
                self.collectionViewRewards.reloadData()
            }
        }
    }

}

extension RewardsPointsViewController: UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        tableViewCell.imageView?.image = UIImage(named: imageArray[indexPath.row])
        tableViewCell.textLabel?.text = textArray[indexPath.row]
        tableViewCell.detailTextLabel?.text = subtextArray[indexPath.row]
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension RewardsPointsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataDict.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewReusableCell", for: indexPath) as! rewardsGiftCollCell
        if self.dataDict.data!.count > 0{
            let profilephoto = URL(string: self.dataDict.data![indexPath.row].image ?? "")
            let placeholder = UIImage(named: "proo")
            collectionViewCell.imgReward.contentMode = .scaleAspectFill
            collectionViewCell.imgReward.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
            
            collectionViewCell.lblTitle.text = self.dataDict.data![indexPath.row].name ?? ""
            collectionViewCell.btnRedeemWith.setTitle("Redeem With \(String(self.dataDict.data![indexPath.row].total_points ?? "")) Pts", for: .normal)
        }
        return collectionViewCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: (UIScreen.main.bounds.width)/2-60/2, height: 213)
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 10.0
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 10.0
       }
    
}
