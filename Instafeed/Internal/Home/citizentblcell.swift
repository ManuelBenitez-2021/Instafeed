//
//  citizentblcell.swift
//  Instafeed
//
//  Created by gulam ali on 12/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation
import TTTAttributedLabel


protocol CitizenFeedsProtocols: class{
    func userHasLikedThePost(index:IndexPath, tableView:UITableView)
    func userClickedLikeCountsLabel(index:IndexPath, tableView:UITableView)
    func writeComment(index:IndexPath, tableView:UITableView)
    func bookmarkTap(index:IndexPath, tableView:UITableView)
    func citizenTitletapped(index:IndexPath, tableView: UITableView)
    func Sharetap(index:IndexPath, tableView:UITableView)
    func threeDotAction(index:IndexPath, tableView:UITableView)
    func didTapOnTag(tagValue: String)
    func tappedSeeMore(indexPath:IndexPath, tableView:UITableView)
}

class citizentblcell: UITableViewCell, TTTAttributedLabelDelegate {

    @IBOutlet weak var videoview: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var profileimg: UIImageView!
    @IBOutlet weak var seemorebtn: UIButton!
    @IBOutlet weak var feedText: TTTAttributedLabel!
    @IBOutlet weak var feedimage: UIImageView!
    @IBOutlet weak var heartbtn_otlt: UIButton!
    @IBOutlet weak var totslhearts: UILabel!
    @IBOutlet weak var totalcomments: UILabel!
    
    @IBOutlet weak var comment_otlt: UIButton!
    @IBOutlet weak var share_otlt: UIButton!
    @IBOutlet weak var totalshares: UILabel!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var threeDot: UIButton!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
    
    var avplayer = AVPlayer()
    var didtap_SeeMore : ((Int) -> Void)?
    var myindexpath:IndexPath!
    var tableobj:UITableView!
    var isExtended = false
    weak var delegate:CitizenFeedsProtocols!
    
    var Newsfeeds:citizenFeedsData!{
        didSet{
            feedText.text = Newsfeeds.short_description
            let strFullValue = Newsfeeds.short_description
            let nsString = strFullValue! as NSString
            
//            print("FOnt -> \(UIFont.fontNames(forFamilyName: "Roboto"))")
            
            let color = UIColor.init(red: 143/255.0, green: 141/255.0, blue: 141/255.0, alpha: 1)
            
            let atts = [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: color ]
            
            let fullAttributedString = NSAttributedString(string:strFullValue!, attributes: atts as [NSAttributedString.Key : Any])
            
            feedText.textAlignment = .left
            feedText.attributedText = fullAttributedString;
//            feedText.font =NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)

            let linkColor = UIColor(red: (241/255), green: (126/255), blue: (58/255), alpha: 1.0)
            let ppLinkAttributes: [String: Any] = [
                NSAttributedString.Key.foregroundColor.rawValue: linkColor.cgColor,
                NSAttributedString.Key.underlineStyle.rawValue: true,
                ]
            let ppActiveLinkAttributes: [String: Any] = [
                NSAttributedString.Key.foregroundColor.rawValue: linkColor.cgColor,
                NSAttributedString.Key.underlineStyle.rawValue: true,
                ]

            feedText.activeLinkAttributes = ppActiveLinkAttributes
            feedText.linkAttributes = ppLinkAttributes
            
            let arrTags = strFullValue?.split(separator: " ")
            
            for word in arrTags! {
                if word.first == "#" {
                    print("\n===============\n \(word) \n===============\n")
                    let rangeTag = nsString.range(of: String(word))
                    let urlTag = URL(string: "action://\(String(word))")
                    if urlTag != nil {
                        feedText.addLink(to: urlTag, with: rangeTag)
                    }
                }
            }
            feedText.delegate = self;

            seemoreSetup()
            var fulllname = String()
            
            if let name = Newsfeeds.first_name, !name.isEmpty{
                fulllname = name
            } else{
                fulllname = "Anonymous"
            }
            
            /*if let name = Newsfeeds.username, !name.isEmpty{
                fulllname = name
            } else {
                if let name = Newsfeeds.first_name, !name.isEmpty{
                    fulllname = name
                }
            }*/
        
            if let myuserID = UserDefaults.standard.value(forKey: "user_id") as? String{
                if Newsfeeds.user_id == myuserID {
                    threeDot.isHidden = true
                }else{
                    threeDot.isHidden = false
                }
            }else{
                threeDot.isHidden = false
            }
            let totlalikes = Newsfeeds.total_likes
            let totlComments = Newsfeeds.total_comments
            let totalviews = Newsfeeds.total_views
            let userPic = Newsfeeds.avatar
            
            let postImage = (Newsfeeds.image_360x290 != nil) ? Newsfeeds.image_360x290 : Newsfeeds.image
            let posteddate = Newsfeeds.dt_added
            let videoThumb = Newsfeeds.video_thumb
            
            fullname.text = fulllname
            date.text = posteddate
            totslhearts.text = totlalikes
            totalcomments.text = totlComments
            totalshares.text = totalviews
            
            let userhasLiked = Newsfeeds.is_like
            
            if userhasLiked == "0"{
                let image = UIImage(named: "heart")
                heartbtn_otlt.setImage(image, for: .normal)
            } else {
                //show red heart filledHeart
                let image = UIImage(named: "filledHeart")
                heartbtn_otlt.setImage(image, for: .normal)
            }
            
            let profilephoto = URL(string: userPic ?? "")
            let placeholder = UIImage(named: "profile-icon")
            profileimg.contentMode = .scaleAspectFill
            if Newsfeeds.is_anonymous != nil && Newsfeeds.is_anonymous?.uppercased() == "Y"{
                profileimg.image = placeholder
                self.fullname.text = "Anonymous"
            }else{
                profileimg.sd_setImage(with: profilephoto, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
            }
            
           let postVideo = Newsfeeds.video_360x290
           if postVideo == "" {
                feedimage.isHidden = false
                playBtn.isHidden = true
                let postimagee = URL(string: postImage ?? "")
                let place = UIImage(named: "citizelcell")
                if postImage!.contains("default_news") {
                    print("exists")
                    feedimage.image = nil
                    HeightConstraint.constant = 0
                    
                } else {
                    feedimage.sd_setImage(with: postimagee, placeholderImage: place, options: .progressiveLoad, context: nil)
                    if postimagee != nil {
                        let data = try? Data(contentsOf: postimagee!)
                        
                        if let imageData = data {
                            if let image = UIImage(data: imageData){
                                let newHeight = feedimage.frame.width * image.size.height / image.size.width
                                HeightConstraint.constant = newHeight
                                feedimage.image = self.imageWithImage(sourceImage: image, scaledToWidth: UIScreen.main.bounds.size.width)
                            }
                        }
                    }
                }
            } else {
                playBtn.isHidden = false
                feedimage.isHidden = false
                let postimagee = URL(string: videoThumb ?? "")
                let place = UIImage(named: "citizelcell")
            
                if videoThumb!.contains("default_news") {
                    feedimage.image = nil
                    HeightConstraint.constant = 0
                    print("exists")
                } else {
                    feedimage?.sd_setImage(with: postimagee, placeholderImage: place, options: .progressiveLoad, context: nil)
                    if postimagee != nil{
                        let data = try? Data(contentsOf: postimagee!)
//
                        if let imageData = data {
    if let image = UIImage(data: imageData){
        let newHeight = feedimage.frame.width * image.size.height / image.size.width
        HeightConstraint.constant = newHeight
        feedimage.image = self.imageWithImage(sourceImage: image, scaledToWidth: UIScreen.main.bounds.size.width)
    }
}

                    }
                }
            }
            
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
        profileimg.layer.cornerRadius = profileimg.frame.height / 2
    }
    
    
    private func playVideo (videoURL:String) {
        let videoUrl = NSURL(string: videoURL)
        avplayer = AVPlayer(url: videoUrl! as URL)
        let playerlayer = AVPlayerLayer(player: avplayer)
        playerlayer.frame = videoview.bounds
        videoview.layer.addSublayer(playerlayer)
        playerlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avplayer.play()
//        self?.tableobj.reloadRows(at: [self!.myindexpath], with: .none)
    }
    
    //MARK::>>>> SEE NORE OR SEE LESS ADJUSTMENTS
    private func seemoreSetup() {
        if feedText.CountLabel(label: feedText) > 2{
            seemorebtn.isHidden = false
            
            didtap_SeeMore = { [weak self] index in
                
                if self?.seemorebtn.titleLabel?.text == "See less"{
                    self?.seemorebtn.setTitle("See more", for: .normal)
                    self?.feedText.numberOfLines = 2
                }else{
                    self?.seemorebtn.setTitle("See less", for: .normal)
                    self?.feedText.numberOfLines = 0
                }
                
//                self?.tableobj.reloadRows(at: [self!.myindexpath], with: .none)
                
//                self?.tableobj.reloadData()
                
            }
            
        }else{
            seemorebtn.isHidden = true
        }
    }
    
    
    func updateSeeMore()  {
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback)
            //try AVAudioSession.sharedInstance().setCategory(.playback)
        }catch{
            print("catched")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func seemore_tapped(_ sender: Any) {
//         didtap_SeeMore?(myindexpath.row)
        print("Index Path \(String(describing: myindexpath?.row))")
        delegate.tappedSeeMore(indexPath: myindexpath, tableView: tableobj)
    }
    
    
    
    @IBAction func heartTapped(_ sender: Any) {
        delegate.userHasLikedThePost(index: myindexpath, tableView: tableobj)
    }
    
    @IBAction func likeLabelTapped(_ sender: Any) {
        delegate.userClickedLikeCountsLabel(index: myindexpath, tableView: tableobj)
    }
    
    @IBAction func commentTapped(_ sender: Any) {
        delegate.writeComment(index: myindexpath, tableView: tableobj)
    }
    
    
    
    @IBAction func bookmarkTapped(_ sender: Any) {
        delegate.bookmarkTap(index: myindexpath, tableView: tableobj)
    }
    
    
    
    @IBAction func titleTapped(_ sender: Any) {
        
        if Newsfeeds.is_anonymous != nil && Newsfeeds.is_anonymous?.uppercased() == "Y"{
           
        }else{
        
            delegate.citizenTitletapped(index: myindexpath, tableView: tableobj)
        }
    }
    
    
    @IBAction func sharetapped(_ sender: Any) {
        delegate.Sharetap(index: myindexpath, tableView: tableobj)
    }
    
    @IBAction func threeDottapped(_ sender: Any) {
        delegate.threeDotAction(index: myindexpath, tableView: tableobj)
    }
    
    //MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        var absString = url.absoluteString
        absString = absString.replacingOccurrences(of: "action://#", with: "")
        if absString.count > 0 {
            delegate.didTapOnTag(tagValue: absString)
        }
    }
}




