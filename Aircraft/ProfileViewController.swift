//
//  ProfileViewController.swift
//  Aircraft
//
//  Created by Glen Obando on 30/6/21.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        nameLabel.text = defaults.object(forKey: appConstants.userNameKey) as? String
        emailLabel.text = defaults.object(forKey: appConstants.userEmailKey) as? String
        let urlstring = URL(string: (defaults.object(forKey: appConstants.userImgKey) as? String)!)!
        userImgView.load(url: urlstring)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
