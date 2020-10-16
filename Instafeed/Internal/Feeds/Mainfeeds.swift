//
//  Mainfeeds.swift
//  Instafeed
//
//  Created by gulam ali on 12/07/19.
//  Copyright © 2019 gulam ali. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker
import CoreLocation
import GooglePlaces
import GoogleMaps
import MobileCoreServices
import MobileCoreServices
import DKImagePickerController
import DKPhotoGallery

class Mainfeeds: UIViewController {
    
    @IBOutlet weak var singleimagetopost: UIImageView!
    
    @IBOutlet weak var draftbtn_otlt: UIButton!
    @IBOutlet weak var feedbtn_otlt: UIButton!
    @IBOutlet weak var backgroundclrview: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var txtview: UITextView!
    @IBOutlet weak var images: UIImageView!
    @IBOutlet weak var collview: UICollectionView!
    @IBOutlet weak var usernme: UILabel!
    @IBOutlet weak var anonymousImages: UIImageView!
    
    @IBOutlet weak var anonymousBtn: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categorylbl: UILabel!
    @IBOutlet weak var mainCategoryView: UIView!
    @IBOutlet weak var mainCategoryTableView: UITableView!

    @IBOutlet weak var sellView: UIView!
    
    @IBOutlet weak var mandiPriceUL: UILabel!
    @IBOutlet weak var mandiChkUIV: UIImageView!
    var isMandi = false
    var mandiPrice = "0"
    
    var response: Profiledata = Profiledata()
    var imagePickerController: UIImagePickerController?
    
    var placeid_OBJ = "1"
    let nc = NotificationCenter.default
    var SelectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    var ResizedImageto1Mb = [UIImage]()
    var locationManager = CLLocationManager()
    var feedType = "text"
    var videoUrl:[URL?] = []
    var audioUrl:URL?
    var anonymous = "n"
    var userType = "citizen"
    var categories = [categorytabdata]()
    var categoryID = ""
    var choseType = "image"
    
    var lastComponentsVideos = [String]()
    var savedVideoPath :String = ""
    
    var lastComponentsImages = [String]()
    var savedImgPath :String = ""
    var cameraImageArray :[String] = []
    
    var counter :Int = 0
    
    var videoUploadArray : [URL]? = []
    
    var moduleType = ""
    var postID = ""
    
    var feed = feedDatadata()
    var video =  [videosdata]()
    var imagearray = [imageData]()
    var videoThumb = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtview.font = UIFont.preferredFont(forTextStyle: .headline)
        txtview.delegate = self
        txtview.isScrollEnabled = false
        txtview.text = NSLocalizedString("What's happening around you?", comment:"")
        txtview.textColor = UIColor.lightGray
        
       // let image = UIImage(named: "imageName")
        profileImg.layer.borderWidth = 1.0
        profileImg.layer.masksToBounds = false
        profileImg.layer.borderColor = UIColor.white.cgColor
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        feedbtn_otlt.layer.cornerRadius = 8.0
        draftbtn_otlt.layer.cornerRadius = 8.0
        
        mandiPriceUL.isHidden = true
        
        backgroundclrview.isHidden = true
        
        collview.delegate = self
        collview.dataSource = self
        feedType = "text"
        imagePickerController = UIImagePickerController()
        getProfile()
        
        self.sellView.addGestureRecognizer(UITapGestureRecognizer(target: self.sellView, action: #selector(dismissSellView)))
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissSellView))
        self.sellView.addGestureRecognizer(gesture)
        
        if constnt.isEditPost {
            getNews(postId: postID)
        }
    }
    
    @objc func dismissSellView(){
        self.sellView.alpha = 0
        self.sellView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        checkLocationServices()
        
        nc.addObserver(self, selector: #selector(chnageimage), name: Notification.Name(NotificationKeys.ticktapped), object: nil)
    }
    
    func showVideoMode(sourceType: UIImagePickerController.SourceType){
        if let imagePicker = imagePickerController{
            self.choseType = "mobilecameraphoto"
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String];
            
            self.present(imagePicker, animated: true, completion: nil)
        }

    }
    
    func showChooseVideoMode(sourceType: UIImagePickerController.SourceType){
        if let imagePicker = imagePickerController{
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //TODO:-
    @objc func chnageimage(){
        singleimagetopost.image = UIImage(named: "dfhoh")
    }
    
    
    @IBAction func crossTapped(_ sender: Any) {
        if (constnt.isEditPost) {
             dismiss(animated: true, completion: nil)
        } else {
            ResizedImageto1Mb.removeAll()
            photoArray.removeAll()
            SelectedAssets.removeAll()
            
            tabBarController?.selectedIndex = 0
            tabBarController?.tabBar.isHidden = false
        }
        constnt.isEditPost = false
    }
    
    @IBAction func bottombar_Actions(_ sender: Any) {
        switch ((sender as AnyObject).tag) {
        case 10: //
            
            feedType = "text"
        case 20: //
            self.photoArray.removeAll()
            
            print(feedType)
            if feedType == "cam" {
                feedType = "cam"
            } else {
                feedType = "gallery"
            }
            openPhotos()
        case 40: //
            if let count = UserDefaults.standard.value(forKey: "increaseCount") as? Int{
                self.counter = count
            }else{
                UserDefaults.standard.set(counter+1, forKey: "increaseCount")
            }
//            counter += 10
            self.photoArray.removeAll()
            self.videoUrl.removeAll()
            feedType = "mobilecameraphoto"
            showVideoMode(sourceType: .camera)
            
        case 50: //
            self.videoUrl.removeAll()
            print("mic")
            feedType = "mic"
            
            self.openRecordCamera();
        case 70: //
            self.videoUrl.removeAll()
            feedType = "cam"
            let pickerController = DKImagePickerController()
            pickerController.assetType = .allVideos
            pickerController.showsCancelButton = true

            pickerController.didSelectAssets = { (assets: [DKAsset]) in

            print(assets)
            print("didSelectAssets")
            if assets.count > 0 {
                for video in assets {
                    let value = self.getVideoUrlFromPHAsset(video.originalAsset!)
                    let savedPath = value.url.deletingLastPathComponent()
                    print(savedPath.absoluteString)
                    print(value.url.lastPathComponent)
                    
                    self.savedVideoPath = savedPath.absoluteString
                    self.lastComponentsVideos.append(value.url.path)
                    
                    self.videoUrl.append(value.url.absoluteURL)
                    self.videoUploadArray?.append(value.url.absoluteURL)
                }
                self.convertVideAssetToImages()
            }
        }
            self.present(pickerController, animated: true) {}

        default:
            break
        }
        
    }
    
    func getVideoUrlFromPHAsset(_ asset:PHAsset)->AVURLAsset {
        let semaphore = DispatchSemaphore(value: 0)
        var videoObj:AVURLAsset? = nil
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager().requestAVAsset(forVideo:asset, options: options, resultHandler: { (avurlAsset, audioMix, dict) in
            videoObj = (avurlAsset as! AVURLAsset)
            semaphore.signal()
        })
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return videoObj!
    }
    
    func openRecordCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            print("Camera Available")
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera UnAvaialable")
        }
    }
    
    let controller = UIImagePickerController()
    func callPhotosSheeet(){
        CommonFuncs.HitactionSheet(vc: self, title1: "Camera", title1action: {
            self.clickimage()
        }, title2: "Photos") {
            self.pickimage()
        }
        
    }
    
    //MARK:>>>> Picking Image from Gallery
    func pickimage(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            controller.delegate = self
            controller.sourceType = .photoLibrary
            controller.allowsEditing = false
            present(controller, animated: true, completion: nil)
        }
    }
    
    //MARK:>>>> Picking Image from Camera
    func clickimage(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.delegate = self
            controller.sourceType = .camera
            controller.allowsEditing = false
            self.present(controller, animated: true, completion: nil)
        }else{
            print("You Dont have a CAMERA")
        }
    }
    
    @IBAction func anonymousTapped(_ sender: Any) {
        
        let btn = sender as! UIButton
        if btn.isSelected {
            anonymousBtn.isSelected = false
            anonymousImages.image = UIImage(named: "Box")
            anonymousImages.backgroundColor = .clear

        } else {
            anonymousBtn.isSelected = true
            anonymousImages.image = UIImage(named: "tick (1)")
            anonymousImages.backgroundColor = .black
        }
    }
    
    //MARK:>>>>> Multiple photos
    fileprivate func openPhotos(){
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 10
        vc.cancelButton.tintColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        vc.doneButton.tintColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        vc.selectionCharacter = "✓"
        
        vc.selectionFillColor = UIColor(hexValue: InstafeedColors.ThemeOrange)
        vc.selectionStrokeColor = UIColor.white
        vc.selectionShadowColor = UIColor.white
        
        vc.selectionTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
        vc.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 2
            case (.compact, .compact): // iPhone5-6 landscape
                return 2
            case (.regular, .regular): // iPad portrait/landscape
                return 3
            default:
                return 3
            }
        }
        
        self.bs_presentImagePickerController(vc, animated: true, select: { (assest: PHAsset) -> Void in
        },
        deselect: { (assest: PHAsset) -> Void in
                                                
        }, cancel: { (assest: [PHAsset]) -> Void in
            
        }, finish: { (assest: [PHAsset]) -> Void in
            
            self.SelectedAssets.removeAll()
//            self.ResizedImageto1Mb.removeAll()
//            self.photoArray.removeAll()
//            self.SelectedAssets.removeAll()
            
            for i in 0..<assest.count
            {
                self.SelectedAssets.append(assest[i])
                print(assest[i])
                assest[i].requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (editingInput, info) in
                  if let input = editingInput, let imgURL = input.fullSizeImageURL {
                    print(imgURL)
                    print(imgURL.lastPathComponent)
                    
                    self.lastComponentsImages.append(imgURL.path)
//                    let imagePath = imgURL.deletingLastPathComponent()
//                    self.savedImgPath = imagePath.absoluteString
//
//                    print(imagePath.absoluteString)
                  }
                }
            }
            
            self.convertAssetToImages()
            
        }, completion: nil)

    }
    
    func convertAssetToImages() -> Void {
        if SelectedAssets.count != 0 {
            for i in 0..<SelectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                
                var thumbnail = UIImage()
                
                option.isSynchronous = true
                
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result,info) -> Void in
                    thumbnail = result!
                })
                
                let data = thumbnail.jpegData(compressionQuality: 0.9)
                let newImage = UIImage(data: data!)
                let resizedimageto1MB = newImage?.resizedTo1MB()
                self.photoArray.append(resizedimageto1MB! as UIImage)
                self.ResizedImageto1Mb.append(resizedimageto1MB! as UIImage)
                
            }
            DispatchQueue.main.async {
                self.choseType = "image"
                self.collview.reloadData()
            }
        }
    }
    
    func convertVideAssetToImages() {
        if videoUrl.count > 0 {
            for videoURL in videoUrl {
                let asset = AVAsset(url: videoURL!)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                do {
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let uiImage = UIImage(cgImage: cgImage)
                
                    let size = uiImage.size
                    let height: CGFloat = 160.0
                    let width  = size.width * 160.0  / size.height
                    let newSize: CGSize = CGSize(width: width, height: height)
                    let rect = CGRect(x: 0, y: 0, width: width, height: height)
                
                    let playIconRect = CGRect(x: (width - 50) / 2.0, y: (height - 50) / 2.0, width: 50, height: 50)
                    let playIcon = UIImage(named: "play")
                
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                    uiImage.draw(in: rect)
                    playIcon?.draw(in: playIconRect)
                    let newImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                
                    let resizedimageto1MB = newImage?.resizedTo1MB()
                    self.ResizedImageto1Mb.append(resizedimageto1MB! as UIImage)
                
                    self.choseType = "video"
                } catch let error {
                    print(error)
                }
            }
            self.collview.reloadData()
        }
        
    }
        
    
    @IBAction func buttons_tapped(_ sender: Any) {
        switch ((sender as AnyObject).tag) {
        case 100: //
            print("privacy")
            let move = storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
            navigationController?.pushViewController(move, animated: true)
        case 200: //
            print("location")
            presentAutocomplete()
        default:
            break
        }
    }
    
    @IBAction func dropDown_Tapped(_ sender: Any) {
        fetchCategory()
    }
    
    //MARK:>>>> API CALL
    private func fetchCategory() {
        
        let uurl = ServerURL.firstpoint + ServerURL.categoryTab
        networking.MakeRequest(Url: uurl, Param: nil, vc: self) { (result:categorytab) in
            print(result)
            if result.message == "success"{
                guard let response = result.data else {return}
                self.categories = response.map{$0}
                // DO UI PART
                self.mainCategoryView.isHidden = false
                self.mainCategoryTableView.reloadData()
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
    }

    
    private func getProfile() {
        let api = ServerURL.firstpoint + ServerURL.Getprofile
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        let params = ["token":UserToken] as [String:Any]
        networking.MakeRequest(Url: api, Param: params, vc: self) { (result:ProfileDataModel) in
            if result.message == "success"{
                guard let response = result.data else {return}
                self.response = response
                DispatchQueue.main.async {
                    print(response)
                    if let fName = response.first_name, let lName = response.last_name {
                        self.usernme.text = "\(fName) \(lName)"
                    }
                    
                    UserDefaults.standard.set(response.type!, forKey: "UserType")

                    self.userType = response.type_name ?? "citizen"
                    
                    if self.userType == "brand" {
                        self.categoryButton.isHidden = false
                        self.categoryView.isHidden = false
                    } else {
                        self.categoryButton.isHidden = true
                        self.categoryView.isHidden = true
                    }
//                    self.images.layer.cornerRadius = self.images.frame.height/2
                    let images1 = URL(string: response.avatar ?? "")
                    let placeholder = UIImage(named: "proo")
                    self.profileImg.contentMode = .scaleAspectFill
                    self.profileImg.sd_setImage(with: images1, placeholderImage: placeholder, options: .progressiveLoad, context: nil)
                }
            } else {
                CommonFuncs.AlertWithOK(msg: "Something went wrong while getting profile", vc: self)
                return
            }
        }
    }
    
    
    //MARK:>>>. CLocation setup
    //MARK:>>>>>> Core Location setup
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            print(location)
            UserCurrentLocation = (locationManager.location?.coordinate)!
            print(UserCurrentLocation)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            print("user turned off the permission")
            AskPermissionForcefully()
        }
    }
    
    
    func AskPermissionForcefully(){
        let alert = UIAlertController(title:"Need Your Location", message: "To assist you better we need your location permission,Please allow permission", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (alertaction) in
            print("ahjgjkahfjkdahfildfj")
            if let bundleId = Bundle.main.bundleIdentifier,
                let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)")
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            AskPermissionForcefully()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        default:
            break
        }
    }
    

    
    //MARK:>>>>> Feeds Tapped
    @IBAction func feedsTapped(_ sender: Any) {
        if constnt.isEditPost {
            if feedType == "text"{
                editTextcheck()
            } else {
                editAllFiles()
            }
        } else {
            if feedType == "text"{
                postTextcheck()
            } else {
                postAllFiles()
            }
        }
    }
    
    private func editAllFiles() {
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        } else {
            let api = ServerURL.firstpoint + ServerURL.feedPost
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            if placeid_OBJ == ""{
                CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
                return
            } else {
                print("good to go bro")
            }
            
            let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
            var is_an = "n"
            if anonymousBtn.isSelected{
                is_an = "y"
            }
            var params = ["token":UserToken
                , "title" : txtview.text!
                , "description" : txtview.text!
                , "location_id" : placeid_OBJ
                , "lat" : "\(UserCurrentLocation.latitude)"
                , "long" : "\(UserCurrentLocation.longitude)"
                , "mod" : "n"
                , "is_an" : is_an
                , "lang_id": langId
                , "post_id": postID
            ] as [String:Any]
            if isMandi {
                params["price"] = mandiPrice;
            }
            if validateCategory() {
                params["category_id"] = self.categoryID
            } else {
                return
            }
            if audioUrl == nil {
                audioUrl = URL(fileURLWithPath: "")
            }
            print(photoArray)
            print(videoUploadArray!)
            var dict : [String:Any] = [:]
            if lastComponentsVideos.count > 0
            {
                dict = ["videoArr":self.lastComponentsVideos]
            }
            if lastComponentsImages.count > 0
            {
                dict["imageArr"] = self.lastComponentsImages
            }
            if cameraImageArray.count > 0 {
                dict["camImgArray"] = self.cameraImageArray
            }
            dict["params"] = params
            print(dict)
            UserDefaults.standard.set(dict, forKey: "OfflineSendData")

            networking.uploadAllfiles(Api: api, params: params as [String : AnyObject], audio: (audioUrl)!, video: videoUploadArray!, imagepost: photoArray) { (result, err) in
                if err != nil{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                } else {
                    guard let msg = result?.message else {return}
                    if msg == "success"{
                        UserDefaults.standard.removeObject(forKey: "OfflineSendData")
                        // CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                        Toast().showToast(message: "Successfully Posted", duration: 2)
                        self.txtview.text = "What's happening around you?"
                        self.txtview.textColor = UIColor.lightGray
                        self.singleimagetopost.image = UIImage(named: "")
                        
                        self.crossTapped(UIButton())
                        return
                    } else {
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }
                }
            }
        }
    }
    
    private func postAllFiles() {
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        } else {
            let api = ServerURL.firstpoint + ServerURL.feedPost
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            if placeid_OBJ == ""{
                CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
                return
            } else {
                print("good to go bro")
            }
            
            let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
            var is_an = "n"
            if anonymousBtn.isSelected{
                is_an = "y"
            }
            var params = ["token":UserToken
                , "title" : txtview.text!
                , "description" : txtview.text!
                , "location_id" : placeid_OBJ
                , "lat" : "\(UserCurrentLocation.latitude)"
                , "long" : "\(UserCurrentLocation.longitude)"
                , "mod" : "n"
                , "is_an" : is_an,
                  "lang_id":langId
            ] as [String:Any]
            if isMandi {
                params["price"] = mandiPrice;
            }
            if validateCategory() {
                params["category_id"] = self.categoryID
            } else {
                return
            }
            if audioUrl == nil {
                audioUrl = URL(fileURLWithPath: "")
            }
            print(photoArray)
            print(videoUploadArray!)
            var dict : [String:Any] = [:]
            if lastComponentsVideos.count > 0
            {
                dict = ["videoArr":self.lastComponentsVideos]
            }
            if lastComponentsImages.count > 0
            {
                dict["imageArr"] = self.lastComponentsImages
            }
            if cameraImageArray.count > 0{
                dict["camImgArray"] = self.cameraImageArray
            }
            dict["params"] = params
            print(dict)
            UserDefaults.standard.set(dict, forKey: "OfflineSendData")

            networking.uploadAllfiles(Api: api, params: params as [String : AnyObject], audio: (audioUrl)!, video: videoUploadArray!, imagepost: photoArray) { (result, err) in
                if err != nil{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                } else {
                    guard let msg = result?.message else {return}
                    if msg == "success"{
                        UserDefaults.standard.removeObject(forKey: "OfflineSendData")
                        // CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                        Toast().showToast(message: "Successfully Posted", duration: 2)
                        self.txtview.text = "What's happening around you?"
                        self.txtview.textColor = UIColor.lightGray
                        self.singleimagetopost.image = UIImage(named: "")
                        
                        let homevc = HomeVc()
                        if let controllers = self.navigationController?.viewControllers{
                            for vc in controllers where vc == homevc{
                                self.dismiss(animated: true, completion: nil)
                            }
                            self.moveToHome()
                        } else {
                            self.moveToHome()
                        }
                        return
                    } else {
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }
                }
            }
        }
    }
    
    func postVideo() {
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        }else{
            //post image
            let api = ServerURL.firstpoint + ServerURL.feedPost
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            if placeid_OBJ == ""{
                CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
                return
            }else{
                print("good to go bro")
            }
            
            let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
            var is_an = "n"
            if anonymousBtn.isSelected{
                is_an = "y"
            }
            var params = ["token":UserToken,"title":txtview.text!,"description":txtview.text!,"location_id":placeid_OBJ,"lat":"\(UserCurrentLocation.latitude)","long":"\(UserCurrentLocation.longitude)","mod":"n","is_an":is_an,"lang_id":langId] as [String:Any]
            
            if validateCategory() {
                params["category_id"] = self.categoryID
            } else {
                return
            }
                        
            print(params)
                    
            networking.uploadVideo(Api: api, params: params as [String : AnyObject], video: videoUploadArray!) { (result, err) in

                if err != nil{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                }
                else{
                    guard let msg = result?.message else {return}
                    if msg == "success"{
                        // CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                        Toast().showToast(message: "Successfully Posted", duration: 2)
                        self.txtview.text = "What's happening around you?"
                        self.txtview.textColor = UIColor.lightGray
                        self.singleimagetopost.image = UIImage(named: "")
                        
                        let homevc = HomeVc()
                        if let controllers = self.navigationController?.viewControllers{
                            for vc in controllers where vc == homevc{
                                self.dismiss(animated: true, completion: nil)
                            }
                            self.moveToHome()
                        }else{
                            self.moveToHome()
                        }
                        // })
                        return
                    }else{
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }
                }
            }
        }
    }
    
    func postVideoAndImage(){
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        }else{
            //post image
            let api = ServerURL.firstpoint + ServerURL.feedPost
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            if placeid_OBJ == ""{
                CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
                return
            } else {
                print("good to go bro")
            }
            
            let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
            var is_an = "n"
            if anonymousBtn.isSelected{
                is_an = "y"
            }
            var params = ["token":UserToken,"title":txtview.text!,"description":txtview.text!,"location_id":placeid_OBJ,"lat":"\(UserCurrentLocation.latitude)","long":"\(UserCurrentLocation.longitude)","mod":"n","is_an":is_an,"lang_id":langId] as [String:Any]
            
            if validateCategory() {
                params["category_id"] = self.categoryID
            } else {
                return
            }
                        
            print(params)
                    
            networking.uploadVideoANDImage(Api: api, params: params as [String : AnyObject], video: videoUploadArray!, imagepost: photoArray) { (result, err) in

                if err != nil{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                }
                else{
                    guard let msg = result?.message else {return}
                    if msg == "success"{
                        // CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                        Toast().showToast(message: "Successfully Posted", duration: 2)
                        self.txtview.text = "What's happening around you?"
                        self.txtview.textColor = UIColor.lightGray
                        self.singleimagetopost.image = UIImage(named: "")
                        
                        let homevc = HomeVc()
                        if let controllers = self.navigationController?.viewControllers{
                            for vc in controllers where vc == homevc{
                                self.dismiss(animated: true, completion: nil)
                            }
                            self.moveToHome()
                        }else{
                            self.moveToHome()
                        }
                        // })
                        return
                    }else{
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }
                }
            }
        }
    }
    
    func validateCategory() -> Bool {
        
        if self.userType == "brand" {
            if categoryID == "" {
                CommonFuncs.AlertWithOK(msg: "Please select category from dropdown", vc: self)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    private func postImage() {
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        }else{
            //post image
            let api = ServerURL.firstpoint + ServerURL.feedPost
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            if placeid_OBJ == ""{
                CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
                return
            }else{
                print("good to go bro")
            }
            
            let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
            var is_an = "n"
            if anonymousBtn.isSelected{
                is_an = "y"
            }
            var params = ["token":UserToken,"title":txtview.text!,"description":txtview.text!,"location_id":placeid_OBJ,"lat":"\(UserCurrentLocation.latitude)","long":"\(UserCurrentLocation.longitude)","mod":"n","is_an":is_an,"lang_id":langId] as [String:Any]
            
            if validateCategory() {
                params["category_id"] = self.categoryID
            } else {
                return
            }
            print(params)
            
            networking.uploadImagesAndData(Api: api, params: params, imagepost: self.photoArray) { (result, err) in //[singleimagetopost.image!]) { (result, err) in
                if err != nil{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                }
                else{
                    guard let msg = result?.message else {return}
                    if msg == "success"{
                       // CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                        Toast().showToast(message: "Successfully Posted", duration: 2)
                            self.txtview.text = "What's happening around you?"
                            self.txtview.textColor = UIColor.lightGray
                            self.singleimagetopost.image = UIImage(named: "")
                            
                            let homevc = HomeVc()
                            if let controllers = self.navigationController?.viewControllers{
                                for vc in controllers where vc == homevc{
                                    self.dismiss(animated: true, completion: nil)
                                }
                                self.moveToHome()
                            }else{
                                self.moveToHome()
                            }
                       // })
                        return
                    }else{
                        CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                        return
                    }
                }
            }
        }
    }
    
    
    private func AudioPost(){
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        }else{
            //post audio
            postAudio()
        }
    }
    
    fileprivate func postAudio(){
        //let params = [:] as [String:Any]
        
        //let url = ServerURL.firstpoint + ServerURL.feedPost
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        /*
         if cam is envoked then mode has Y
         if location is saving or getting the is_an is y
         */
        
        if placeid_OBJ == ""{
            CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
            return
        }else{
            print("good to go bro")
        }
        
        /*
         token,title,category_id,description,image,
         image1,image2,image3,image4,image5,image6,image7,image8,image9,image10,video,video1,
         video2,video3,video4,video5,video6,video7,video8,video9,video10,audio,audio1,audio2,
         audio3,audio4,location_id,lat,long,mod={y,n default is n},is_an={Y,N},lang_id
         */
        
        //gurad let audioFile = RecordedAudio else {return}
        
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        var is_an = "n"
        if anonymousBtn.isSelected{
            is_an = "y"
        }
        var params = ["token":UserToken,"title":txtview.text!,"description":txtview.text!,"location_id":placeid_OBJ,"lat":"\(UserCurrentLocation.latitude)","long":"\(UserCurrentLocation.longitude)","mod":"n","is_an":is_an,"lang_id":langId,"audio":""] as [String:Any]
                
        if validateCategory() {
            params["category_id"] = self.categoryID
        } else {
            return
        }
        print(params)
        
        let api = ServerURL.firstpoint + ServerURL.feedPost
        guard let url = audioUrl else{return}
        
        networking.uploadAudio(Api: api, params: params as [String : AnyObject], audio: url) { (result, err) in
            if err != nil{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
            else{
                guard let msg = result?.message else {return}
                if msg == "success"{
                    print(result!)
                    // CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                    Toast().showToast(message: "Successfully Posted", duration: 2)
                    self.txtview.text = "What's happening around you?"
                    self.txtview.textColor = UIColor.lightGray
                    self.singleimagetopost.image = UIImage(named: "")
                    
                    let homevc = HomeVc()
                    if let controllers = self.navigationController?.viewControllers{
                        for vc in controllers where vc == homevc{
                            self.dismiss(animated: true, completion: nil)
                        }
                        self.moveToHome()
                    }else{
                        self.moveToHome()
                    }
                    // })
                    return
                }else{
                    CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                    return
                }
            }
        }
        
    }
    
    private func editTextcheck(){
        if txtview.text == "" || txtview.text == "What's happening around you?"{
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        } else {
            if ResizedImageto1Mb.count == 0 {
                editOnlyText()
            }
        }
    }
    
    private func postTextcheck(){
        if txtview.text == "" || txtview.text == "What's happening around you?" {
            CommonFuncs.AlertWithOK(msg: "Please write something", vc: self)
            return
        } else {
            if ResizedImageto1Mb.count == 0{
                postOnlyText()
            }
        }
    }
    
    //MARK:>>> Autocomplete view controller
    func presentAutocomplete(){
       // textField.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        let countryFilter = GMSAutocompleteFilter()
       // countryFilter.country = "IN"
        acController.autocompleteFilter = countryFilter
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    
    @IBAction func onClickMandiTag(_ sender: Any) {
        if isMandi {
            isMandi = false
            mandiPriceUL.isHidden = true
            mandiChkUIV.image = UIImage(named: "Box")
            mandiChkUIV.backgroundColor = .clear
        } else {
            let altMessage = UIAlertController(title: "Info", message: "Please input the mandi price.", preferredStyle: .alert)
            altMessage.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Mandi Price"
                textField.keyboardType = .numberPad
            })
            altMessage.addAction(UIAlertAction(title: "Okay", style: .default) { (alertaction) in
                self.isMandi = true
                let textField = altMessage.textFields![0] as UITextField
                self.mandiPriceUL.isHidden = false
                self.mandiPriceUL.text = "(\(textField.text ?? "0") INR)"
                self.mandiChkUIV.image = UIImage(named: "tick (1)")
                self.mandiChkUIV.backgroundColor = .black
                self.mandiPrice = textField.text!
            })
            altMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(altMessage, animated: true, completion: nil)
        }
        
    }
    
    //MARK:>>>>> API calls
    
    fileprivate func editOnlyText() {
        let url = ServerURL.firstpoint + ServerURL.feedEdit
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        /*
         if cam is envoked then mode has Y
         if location is saving or getting the is_an is y
         */
        
        if placeid_OBJ == ""{
            CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
            return
        }else{
            print("good to go bro")
        }
    
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        var is_an = "n"
        if anonymousBtn.isSelected{
            is_an = "y"
        }
        var params = ["token" : UserToken
            , "title" : txtview.text!
            , "description" : txtview.text!
            , "location_id" : placeid_OBJ
            , "lat" : "\(UserCurrentLocation.latitude)"
            , "long" : "\(UserCurrentLocation.longitude)"
            , "mod" : "n"
            , "is_an" : is_an
            , "lang_id" : langId
            , "post_id" : postID
            ] as [String : Any]
        if isMandi {
            params["price"] = mandiPrice;
        }
        if validateCategory() {
            params["category_id"] = self.categoryID
        } else {
            return
        }
        print(params)
        
        UserDefaults.standard.set(params, forKey: "ReUploadTextParams")
        
        networking.MakeRequest(Url: url, Param: params, vc: self) { (result: postfeed) in
            if result.message == "success"{
                UserDefaults.standard.removeObject(forKey: "ReUploadTextParams")
                //successfully posted textual data
                //CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                Toast().showToast(message: "Successfully Posted", duration: 2)
                    self.txtview.text = "What's happening around you?"
                    self.txtview.textColor = UIColor.lightGray
                    self.ResizedImageto1Mb.removeAll()
                    self.photoArray.removeAll()
                    self.SelectedAssets.removeAll()
                    //DispatchQueue.main.async {
                    self.collview.reloadData()
                    //}
                    let homevc = HomeVc()
                    if let controllers = self.navigationController?.viewControllers{
                        for vc in controllers where vc == homevc{
                            self.dismiss(animated: true, completion: nil)
                        }
                        self.moveToHome()
                    }else{
                        self.moveToHome()
                    }
                    //self.dismiss(animated: true, completion: nil)
                //})
                
                
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
        
        
    }
    
    fileprivate func postOnlyText() {
        let url = ServerURL.firstpoint + ServerURL.feedPost
        guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
        
        /*
         if cam is envoked then mode has Y
         if location is saving or getting the is_an is y
         */
        
        if placeid_OBJ == ""{
            CommonFuncs.AlertWithOK(msg: "Please select a location", vc: self)
            return
        }else{
            print("good to go bro")
        }
    
        let langId = UserDefaults.standard.object(forKey: "languageId") as? String ?? "1"
        var is_an = "n"
        if anonymousBtn.isSelected{
            is_an = "y"
        }
        var params = ["token":UserToken,"title":txtview.text!,"description":txtview.text!,"location_id":placeid_OBJ,"lat":"\(UserCurrentLocation.latitude)","long":"\(UserCurrentLocation.longitude)","mod":"n","is_an":is_an,"lang_id":langId] as [String:Any]
        if isMandi {
            params["price"] = mandiPrice;
        }
        if validateCategory() {
            params["category_id"] = self.categoryID
        } else {
            return
        }
        print(params)
        
        UserDefaults.standard.set(params, forKey: "ReUploadTextParams")
        
        networking.MakeRequest(Url: url, Param: params, vc: self) { (result:postfeed) in
            if result.message == "success"{
                UserDefaults.standard.removeObject(forKey: "ReUploadTextParams")
                //successfully posted textual data
                //CommonFuncs.AlertWithOK(msg: "Successfully Posted", vc: self, complitionHandler: {(success) in
                Toast().showToast(message: "Successfully Posted", duration: 2)
                    self.txtview.text = "What's happening around you?"
                    self.txtview.textColor = UIColor.lightGray
                    self.ResizedImageto1Mb.removeAll()
                    self.photoArray.removeAll()
                    self.SelectedAssets.removeAll()
                    //DispatchQueue.main.async {
                    self.collview.reloadData()
                    //}
                    let homevc = HomeVc()
                    if let controllers = self.navigationController?.viewControllers{
                        for vc in controllers where vc == homevc{
                            self.dismiss(animated: true, completion: nil)
                        }
                        self.moveToHome()
                    }else{
                        self.moveToHome()
                    }
                    //self.dismiss(animated: true, completion: nil)
                //})
                
                
            }else{
                CommonFuncs.AlertWithOK(msg: Alertmsg.wentwrong, vc: self)
                return
            }
        }
        
        
    }
    
    func moveToHome(){
        let storyboard = UIStoryboard(name: "categoryStoryboard", bundle: nil)
        let move = storyboard.instantiateViewController(withIdentifier: "Mainpagevc") as! Mainpagevc
        self.present(move, animated: false, completion: nil)
//        self.navigationController?.pushViewController(move, animated: false)
    }
    
    //fileprivate func postImage(){}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nc.removeObserver(NotificationKeys.ticktapped)
    }
    
    deinit {
        print("mainfeeds removed")
    }
    
    func getNews(postId: String) {
        var url = String()
           if moduleType == "1" {
               url = "citizen/posts"
           } else if moduleType == "2" {
               url = "star/posts"
           } else if moduleType == "3" {
               url = "brands/posts"
           } else if moduleType == "4" {
               url = "users/posts"
           } else {
               url = "brands/posts"
           }
        let apiurl = ServerURL.firstpoint + url
        let params = ["id": postId] as [String:Any]
       
        networking.MakeRequest(Url: apiurl, Param: params, vc: self) { (response:feedDescription) in
            print(response)

            if response.message == "error"{
                Toast().showToast(message: "Something went wrong please try again later!!!", duration: 2)
                self.navigationController?.popViewController(animated: true)
            } else {
                if let data = response.data {
                    print(data as Any)
                    self.feed = data[0]
                    if data.count > 1 {
                        self.video = (data[2].videos ?? nil)!
                        if self.video.count > 0 {
                            for videoData in self.video {
                                self.videoUrl.append(URL(string: videoData.video!))
                                self.videoUploadArray?.append(URL(string: videoData.video!)!)
                            }
                            self.convertVideAssetToImages()
                        }
                        if let images = data[1].images {
                            if !images.isEmpty {
                                DispatchQueue.global().async { [weak self] in
                                    self!.imagearray = images
                                    for imageData in images {
                                        if let data = try? Data(contentsOf: URL(string: imageData.image_original!)!) {
                                            if let image = UIImage(data: data) {
                                                DispatchQueue.main.async {
                                                    self?.photoArray.append(image)
                                                    self?.ResizedImageto1Mb.append(image)
                                                    
                                                    self!.collview.reloadData()
                                                }
                                            }
                                        } else if let data = try? Data(contentsOf: URL(string: imageData.image_360x290!)!) {
                                            if let image = UIImage(data: data) {
                                                DispatchQueue.main.async {
                                                    self?.photoArray.append(image)
                                                    self?.ResizedImageto1Mb.append(image)
                                                    
                                                    self!.collview.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.initEditingUI()
                }
            }
        }
    }
    
    func initEditingUI() {
        feedbtn_otlt.setTitle("Edit", for: .normal)
        if feed.is_anonymous != "N" {
            self.anonymousImages.image = UIImage(named: "tick (1)")
            self.anonymousImages.backgroundColor = .black
        }
        txtview.text = feed.description
    }

}

extension Mainfeeds : recordedUrlDelegate{
    func didFinishRecording(audioURL: URL) {
        self.audioUrl = audioURL
        print(audioURL.lastPathComponent)
        let path = audioURL.deletingLastPathComponent()
        print(path)
        self.chnageimage()
    }
    
    
}

extension Mainfeeds : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
       // print(textView.text)
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedHeight = textView.sizeThatFits(size)
        textView.constraints .forEach { (constrain) in
            if constrain.firstAttribute == .height{
                constrain.constant = estimatedHeight.height
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening around you?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func removeAddedImage(sender: UIButton){
        
        print("Sel Asset Count \(SelectedAssets.count)")
        print("ResizedImageto1Mb Count \(ResizedImageto1Mb.count)")
        print("videoUrl Count \(videoUrl.count)")
        
        if self.choseType == "image"{
            
            if SelectedAssets.count >= sender.tag{
                SelectedAssets.remove(at: sender.tag)
            }
            
            if ResizedImageto1Mb.count >= sender.tag{
                
                ResizedImageto1Mb.remove(at: sender.tag)
            }
        }else if self.choseType == "mobilecameraphoto"{
            
            if photoArray.count >= sender.tag{
               photoArray.remove(at: sender.tag)
            }
            
            if ResizedImageto1Mb.count >= sender.tag{
                
                ResizedImageto1Mb.remove(at: sender.tag)
            }
            
        }else{
            
            if videoUrl.count >= sender.tag{
                videoUrl.remove(at: sender.tag)
            }
            
            if ResizedImageto1Mb.count >= sender.tag{
                
                ResizedImageto1Mb.remove(at: sender.tag)
            }
        }
        
        collview.reloadData()
    }
    
    
}

extension Mainfeeds : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ResizedImageto1Mb.count
//        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postcell", for: indexPath) as! postcell
        if indexPath.row < ResizedImageto1Mb.count {
            cell.postimage.image = ResizedImageto1Mb[indexPath.row]
        } else {
            cell.postimage.image = UIImage(named: "+ Icon")
        }
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(removeAddedImage(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collview!.bounds.width/4, height: collview!.bounds.width/4)
        // You can change width and height here as pr your requirement
    }
    
}

//MARK:>>>> CLLocation delegates

extension Mainfeeds : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UserCurrentLocation = manager.location!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

//MARK:>>>> GMSAutocomplete delegates

extension Mainfeeds : GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        //locationlbl.text = place.name!
        placeid_OBJ = place.placeID!
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error while placesAUTOCOMPLETE: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
    
}


extension Mainfeeds : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        self.photoArray.removeAll()
//        self.SelectedAssets.removeAll()
//        self.ResizedImageto1Mb.removeAll()
//        videoUrl.removeAll()
        
        if feedType == "mobilecameraphoto"{
            let thumbnail = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//            let imageurl = info[UIImagePickerController.InfoKey.mediaURL]
//            print(imageurl)
            
            let data = thumbnail.jpegData(compressionQuality: 0.9)
            let newImage = UIImage(data: data!)
            let resizedimageto1MB = newImage?.resizedTo1MB()
            self.photoArray.append(resizedimageto1MB! as UIImage)
//            self.imageUploadArray.append(resizedimageto1MB! as UIImage)
            self.ResizedImageto1Mb.append(resizedimageto1MB! as UIImage)
            self.collview.reloadData()
            
//            if let count = UserDefaults.standard.value(forKey: "increaseCount") as? Int{
//                counter = count
                let savedPath = self.saveImage(imageName: "cameraImage\(counter).jpg", image: thumbnail)
                self.cameraImageArray.append(savedPath.path)
                
                print(savedPath)
//                self.counter += 10
                UserDefaults.standard.set(counter+11, forKey: "increaseCount")
                print(counter)
//            }
            
//            UserDefaults.incrementIntegerForKey(key: "increaseCount")
            
        } else if feedType == "cam"{
//            videoUrl.removeAll()
            if let videoDataURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                videoUrl.append(videoDataURL)
                videoUploadArray?.append(videoDataURL)
            }
            convertVideAssetToImages()
            
        }else if feedType == "mic"{
            
            if let videoDataURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                print(videoDataURL)
                videoUrl.append(videoDataURL)
                videoUploadArray?.append(videoDataURL)
                lastComponentsVideos.append(videoDataURL.path)
            }
            convertVideAssetToImages()
            
            guard
                let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                else {
                    return
                }
            
            // Handle a movie capture
            UISaveVideoAtPathToSavedPhotosAlbum(
                url.path,
                self,
                #selector(video(_:didFinishSavingWithError:contextInfo:)),
                nil)
        }else{
            guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            let imageurl = info[.imageURL] as! URL
            print(imageurl)
            let resizeimage = image.resizedTo1MB()
            
            singleimagetopost.image = resizeimage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func saveImage(imageName: String, image: UIImage)->URL {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return URL(string: "")!}

       let fileName = imageName
       let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else {return URL(string: "")!}

//       Checks if file exists, removes it if so.
       if FileManager.default.fileExists(atPath: fileURL.path) {
           do {
               try FileManager.default.removeItem(atPath: fileURL.path)
               print("Removed old image")
           } catch let removeError {
               print("couldn't remove file at path", removeError)
           }
       }

       do
       {
        try data.write(to: fileURL)
        return fileURL
       } catch let error {
           print("error saving file with error", error)
       }
        return URL(string: "")!
   }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
//        let title = (error == nil) ? "Success" : "Error"
//        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
}

extension Mainfeeds: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath)
        let textLabel = tableViewCell.viewWithTag(1234) as! UILabel
        textLabel.text = categories[indexPath.row].name ?? ""
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoryID = categories[indexPath.row].id ?? ""
        self.mainCategoryView.isHidden = true
    }
}

extension UserDefaults {
    class func incrementIntegerForKey(key:String) {
        let defaults = standard
        let int = defaults.integer(forKey: key)
        defaults.set(int+10, forKey:key)
    }
}
