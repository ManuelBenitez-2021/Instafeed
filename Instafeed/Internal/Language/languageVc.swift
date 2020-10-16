import UIKit

class languageVc: UIViewController {
    
    @IBOutlet weak var tblview: UITableView!
    
    var languages = ["हिन्दी", "English"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblview.delegate = self
        tblview.dataSource = self
        tblview.tableFooterView = UIView()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func searchTapped(_ sender: Any) {
        let move = storyboard?.instantiateViewController(withIdentifier: "CitizenProfile") as! CitizenProfile
        navigationController?.pushViewController(move, animated: false)
    }
    

    deinit {
        print("languageVC removed")
    }

}

extension languageVc : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as! LanguageCell
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.text = languages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            UserDefaults.standard.saveData(data: "2", key: "languageId")
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.currentLanguage = "en"
//            UserDefaults.standard.userLoggedIn(value: false)
            //remove all the vc's
//                if let vc = appDelegate.window?.topMostController() as? ViewController{
//                    vc.navigationController?.viewControllers.removeAll()
//                }
//            constnt.appDelegate.rootlogin()
            }
        } else {
            UserDefaults.standard.saveData(data: "1", key: "languageId")
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                appDelegate.currentLanguage = "hi"

//            UserDefaults.standard.userLoggedIn(value: false)
            //remove all the vc's
//                if let vc = appDelegate.window?.topMostController() as? ViewController{
//                    vc.navigationController?.viewControllers.removeAll()
//                }
//            constnt.appDelegate.rootlogin()
            }
        }
        let move = storyboard?.instantiateViewController(withIdentifier: "HomeVc") as! HomeVc
        self.navigationController?.pushViewController(move, animated: false)
                
    }
    
}

