//
//  Brandcel.swift
//  Instafeed
//
//  Created by gulam ali on 16/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation

protocol BrandcellProtocols:class {
    func likethePost(index:IndexPath)
    func AddaComment(index:IndexPath)
    func Bookmarktap(index:IndexPath, tblView:UITableView)
    func TitleTapped(index:IndexPath)
    func ShareTapped(index:IndexPath)
    func FollowTap(index:IndexPath)
}

class Brandcel: UITableViewCell {
    
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var BuyNowBtn: UIButton!
    @IBOutlet weak var videoview: UIView!
    @IBOutlet weak var totalhearts: UILabel!
    @IBOutlet weak var heartbtn_otlt: UIButton!
    
    @IBOutlet weak var newsimage: UIImageView!
    @IBOutlet weak var newsheadline: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var profile: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var commentbtn_otlt: UIButton!
    
    
    @IBOutlet weak var totalcomments: UILabel!
    
    @IBOutlet weak var sharebtn_otlt: UIButton!
    
    @IBOutlet weak var totalshares: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    
    
    var avplayer = AVPlayer()
    weak var delegate:BrandcellProtocols!
    var myIndexpath:IndexPath!
    var tblView = UITableView()
    
    var BrandFeeds:brandfeedsData!{
        didSet{
            newsheadline.text = BrandFeeds.title
            name.text = BrandFeeds.first_name
            let newDate = UTCToLocal(date: BrandFeeds.dt_added!)
            if newDate != nil {
                date.text = newDate
            }
            
            
            let isalreadyliked = BrandFeeds.is_like
            
            
            if isalreadyliked == "0"{
                //show empty heart
                let image = UIImage(named: "heart")
                heartbtn_otlt.setImage(image, for: .normal)
            }else{
               //show filled hert
                let image = UIImage(named: "filledHeart")
                heartbtn_otlt.setImage(image, for: .normal)
            }
            
            let hasVideo = BrandFeeds.video_360x290
            let postImage = BrandFeeds.image_360x290
            if hasVideo == "" || hasVideo == nil{
                //hide video view
                videoview.isHidden = true
                newsimage.isHidden = false
//                let postimagee = URL(string: postImage ?? "")
//                let place = UIImage(named: "citizelcell")
//                newsimage.sd_setImage(with: postimagee, placeholderImage: place, options: .progressiveLoad, context: nil)
                newsimage.onShowImgWithUrl(link: postImage!)
            } else {
                //show video view
                videoview.isHidden = false
                newsimage.isHidden = true
                playVideo(videoURL: hasVideo!)
            }
            
            totalhearts.text = BrandFeeds.total_likes
            totalcomments.text = BrandFeeds.total_comments
            totalshares.text = BrandFeeds.total_views
            
            let userPic = BrandFeeds.avatar
            let profilephoto = URL(string: userPic ?? "")
            let placeholder = UIImage(named: "proo")
            profile.contentMode = .scaleAspectFill
            
            if BrandFeeds.is_anonymous != nil && BrandFeeds.is_anonymous?.uppercased() == "Y"{
                profile.image = placeholder
                self.name.text = "Anonymous"
            }else{
                 profile.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
            }
           
            guard let is_Following = BrandFeeds.is_follow else{return}
            if is_Following == "1"{
                self.btnFollow.setImage(UIImage(named: "Following"), for: .normal)
            }else{
                self.btnFollow.setImage(UIImage(named: "Follow"), for: .normal)
            }
            
        }
    }
    var SellFeeds:SellfeedsData!{
        didSet{
            newsheadline.text = SellFeeds.title
            name.text = SellFeeds.first_name
//             let strDate = BrandFeeds.dt_added
//               let dataFormate = DateFormatter()
//               dataFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
//               dataFormate.timeZone = TimeZone.init(abbreviation: "UTC")
//               let oldDate = dataFormate.date(from: strDate!)
//               dataFormate.timeZone = TimeZone.current
//               date.text = dataFormate.string(from: oldDate!)
            let newDate = UTCToLocal(date: BrandFeeds.dt_added!)
            if newDate != nil {
                date.text = newDate
            }
            
            let isalreadyliked = SellFeeds.is_like
            
            
            if isalreadyliked == "0"{
                //show empty heart
                let image = UIImage(named: "heart")
                heartbtn_otlt.setImage(image, for: .normal)
            }else{
               //show filled hert
                let image = UIImage(named: "filledHeart")
                heartbtn_otlt.setImage(image, for: .normal)
            }
            
            let hasVideo = SellFeeds.video
            let VideoImage = SellFeeds.video_360x290
            let VideoUrl = SellFeeds.video
            if hasVideo == "" || hasVideo == nil{
                //hide video view
                videoview.isHidden = true
                newsimage.isHidden = false
//                let postimagee = URL(string: VideoImage ?? "")
//                let place = UIImage(named: "citizelcell")
//                newsimage.sd_setImage(with: postimagee, placeholderImage: place, options: .progressiveLoad, context: nil)
                newsimage.onShowImgWithUrl(link: VideoImage!)
            } else {
                //show video view
                videoview.isHidden = false
                newsimage.isHidden = true
                
                playVideo(videoURL: VideoUrl!)
            }
            
            totalhearts.text = SellFeeds.total_likes
            totalcomments.text = SellFeeds.total_comments
            totalshares.text = SellFeeds.total_views
            
            let userPics = SellFeeds.avatar
            let profilephotos = URL(string: userPics ?? "")
            let placeholder = UIImage(named: "proo")
            profile.contentMode = .scaleAspectFill
            profile.sd_setImage(with: profilephotos, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
            
            guard let is_Following = SellFeeds.is_follow else{return}
            if is_Following == "1"{
                self.btnFollow.setImage(UIImage(named: "Following"), for: .normal)
            }else{
                self.btnFollow.setImage(UIImage(named: "Follow"), for: .normal)
            }
            
        }
    }
    
    func UTCToLocal(date:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        if dt != nil{
        return dateFormatter.string(from: dt!)
        }else{
            return nil
        }
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    override func layoutSubviews() {
        profile.layer.cornerRadius = profile.frame.height/2
    }
    
    fileprivate func playVideo(videoURL: String){
        let videoUrl = NSURL(string: videoURL)
        avplayer = AVPlayer(url: videoUrl! as URL)
        let playerlayer = AVPlayerLayer(player: avplayer)
        playerlayer.frame = videoview.bounds
        videoview.layer.addSublayer(playerlayer)
        playerlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avplayer.play()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback)
        }catch{
            print("catched")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func heartTapped(_ sender: Any) {
        delegate.likethePost(index: myIndexpath)
    }
    
    @IBAction func commentTapped(_ sender: Any) {
        delegate.AddaComment(index: myIndexpath)
    }
    
    @IBAction func threedotsTapped(_ sender: Any) {
        delegate.Bookmarktap(index: myIndexpath, tblView: self.tblView)
    }
    
    @IBAction func brandTitlrTapped(_ sender: Any) {
        
        if BrandFeeds.is_anonymous != nil && BrandFeeds.is_anonymous?.uppercased() == "Y"{
            
        }else{
            delegate.TitleTapped(index: myIndexpath)
        }
    }
    
    @IBAction func sharetapped(_ sender: Any) {
        delegate.ShareTapped(index: myIndexpath)
    }
    
    @IBAction func followtapped(_ sender: Any) {
        delegate.FollowTap(index: myIndexpath)
    }
    
}

extension Date {
    func convertToLocalTime(fromTimeZone timeZoneAbbreviation: String) -> Date? {
        if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
            let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
            let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))

            return self.addingTimeInterval(targetOffset - localOffeset)
        }

        return nil
    }
}
