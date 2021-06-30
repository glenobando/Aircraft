//
//  ViewController.swift
//  Aircraft
//
//  Created by Christian Monge on 22/6/21.
//

import SafariServices
import UIKit

class ViewController: UIViewController, SFSafariViewControllerDelegate {

    var client : Client?
    let session = URLSession.shared
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        presentLoginView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        client = Client (session: session)
        client?.getUsers(type: UserList.self,  complete: {result in

            switch result {
            case .success(let users):
                print(users)
            case .failure(let error):
                print(error)
                self.defaults.removeObject(forKey: appConstants.loginTokenKey)
                self.defaults.synchronize()
                self.presentLoginView()
            }
        })
        
    }
    
    func presentLoginView()  {
        guard let _ = defaults.object(forKey: appConstants.loginTokenKey) else {
            let loginVc = self.storyboard?.instantiateViewController(identifier: "login") as? LoginViewController
            loginVc?.modalPresentationStyle = .fullScreen
            self.present(loginVc!, animated: true, completion: nil)
            return
        }
        
    }
}


struct UserList: Codable {
    var usuarios:[User]
}
