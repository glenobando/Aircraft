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
    
    var client : Client?
    let session = URLSession.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        
        client = Client (session: session)
        
        guard let email = txtEmail.text else { return  }
        guard let password = txtPassword.text else { return  }
        let defaults = UserDefaults.standard
        
        client?.login(email: email,password: password, type: Usuario.self, complete: {result in
            
            switch result {
            case .success(let users):
                print(users.token!)
                let defaults = UserDefaults.standard
                defaults.set(users.token!, forKey: appConstants.loginTokenKey)
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

struct Usuario: Codable {
    var nombre:String?
    var uid:String?
    var email:String?
    var role:String?
    var google: Bool?
    var estado: Bool?
    var ok: Bool?
    var token: String?
}
