//
//  LoginViewController.swift
//  Aircraft
//
//  Created by Admin on 6/27/21.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var client : Client?
    let session = URLSession.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let urlstring = URL(string: "https://www.karobardaily.com/wp-content/uploads/2019/07/1564549144.png")!
        imageView.load(url: urlstring)
    }
    
    @IBAction func login(_ sender: Any) {
        
        client = Client (session: session)
        
        guard let email = txtEmail.text else { return  }
        guard let password = txtPassword.text else { return  }
        let defaults = UserDefaults.standard
        
        client?.login(email: email,password: password, type: Usuario.self, complete: {result in
            
            switch result {
            case .success(let users):
                //print(users.token!)
                //print(users)
                let defaults = UserDefaults.standard
                defaults.set(users.token!, forKey: appConstants.loginTokenKey)
                defaults.set(users.user.nombre!, forKey: appConstants.userNameKey)
                defaults.set(users.user.email!, forKey: appConstants.userEmailKey)
                defaults.set(users.user.img!, forKey: appConstants.userImgKey)
                defaults.synchronize()
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                defaults.removeObject(forKey: appConstants.loginTokenKey)
                defaults.synchronize()
                print(error)
            }
        })
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

struct Usuario: Codable {
    var ok: Bool?
    var user: User
    var token: String?
}

struct User: Codable {
    var nombre:String?
    var uid:String?
    var email:String?
    var role:String?
    var google: Bool?
    var estado: Bool?
    var ok: Bool?
    var token: String?
    var img: String?
}
