//
//  Language_copyVC.swift
//  Instafeed
//
//  Created by Eric on 2019/10/15.
//  Copyright © 2019 backstage supporters. All rights reserved.
//

import UIKit
import Alamofire

class Language_copyVC: UIViewController {
    
    @IBOutlet weak var tblview: UITableView!
    
    var locationList = [LocationModel]()
    var cityList = [CityModel]()
    var detailed = false, setLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblview.delegate = self
        tblview.dataSource = self
        tblview.tableFooterView = UIView()
        self.navigationController?.isNavigationBarHidden = true
        
        let url: String = "\(ServerURL.firstpoint)locations"
        self.locationList.removeAll()
        Alamofire.request(url, method: .get, encoding: URLEncoding.default).validate().responseJSON{ response in
            switch response.result {
            case .success:
                if response.result.value != nil {
                    let json_data = response.result.value as! [String: Any]
                    let data = json_data["data"] as! [[String: Any]]
                    for entry in data {
                        let aResult = LocationModel(name: entry["name"] as! String, state: Int(entry["id"] as! String)!)
                        self.locationList.append(aResult)
                    }
                    self.tblview.reloadData()
                }
            case .failure(let error):
                print("failed to load feeddata: \(error.localizedDescription)")
            }
        }
    }
    
    
    @IBAction func searchTapped(_ sender: Any) {
        let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
        navigationController?.pushViewController(move, animated: false)
    }
    
    
    deinit {
        print("languageVC removed")
    }
}

extension Language_copyVC : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if detailed {
            return cityList.count
        }
        return locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as! LanguageCell
        cell.textLabel?.textColor = UIColor.darkGray
        if detailed {
            cell.nameLabel?.text = cityList[indexPath.row].getName() + ", " + cityList[indexPath.row].getState()
            cell.latLabel?.text = String(cityList[indexPath.row].getLatitude())
            cell.lngLabel?.text = String(cityList[indexPath.row].getLongitude())
        } else {
            cell.nameLabel?.text = locationList[indexPath.row].getName()
            cell.tag = locationList[indexPath.row].getStateId()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailed = true
        let cell = tableView.cellForRow(at: indexPath) as! LanguageCell
        self.cityList.removeAll()
        if setLocation {
            let url: String = "\(ServerURL.firstpoint)locations/set-geo"
            guard let UserToken = UserDefaults.standard.value(forKey: "SavedToken") as? String else {return}
            let params : Parameters = ["token": UserToken,
                                       "lat": cell.latLabel.text!,
                                       "long": cell.lngLabel.text!]
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default).validate().responseJSON{ response in
                switch response.result {
                case .success:
                    let storyboard = UIStoryboard(name: "categoryStoryboard", bundle: nil)
                    let move = storyboard.instantiateViewController(withIdentifier: "Mainpagevc") as! Mainpagevc
                    self.present(move, animated: false, completion: nil)
                case .failure(let error):
                    print("failed to load feeddata: \(error.localizedDescription)")
                }
            }
        } else {
            setLocation = true
            let stateId = cell.tag
            let url: String = "\(ServerURL.firstpoint)locations/get-city?state_id=\(stateId)"
            Alamofire.request(url, method: .get, encoding: URLEncoding.default).validate().responseJSON{ response in
                switch response.result {
                case .success:
                    if response.result.value != nil {
                        let json_data = response.result.value as! [String: Any]
                        let data = json_data["data"] as! [[String: Any]]
                        for entry in data {
                            let aResult = CityModel(name: entry["location"] as! String, state: entry["state"] as! String, stateId: Int(entry["state_id"] as! String)!, lat: Double(entry["latitude"] as! String)!, lng: Double(entry["longitude"] as! String)!)
                            self.cityList.append(aResult)
                        }
                        self.tblview.reloadData()
                    }
                case .failure(let error):
                    print("failed to load feeddata: \(error.localizedDescription)")
                }
            }
        }
    }
}
