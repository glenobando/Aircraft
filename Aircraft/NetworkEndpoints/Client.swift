//
//  ClientUser.swift
//  ModuloIOSProyectoFinal
//
//  Created by Admin on 6/18/21.
//

import Foundation
class Client: NetworkGeneric {
    
    var session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func getUsers<T: Decodable>(type: T.Type, complete: @escaping (Result<T, ApiError>) -> Void){
        
        let url = URL(string: "\(appConstants.baseUrl)\(navigationsPath.getUserspath)")
        let defaults = UserDefaults.standard
        let tokenData = defaults.string(forKey: appConstants.loginTokenKey)
        var request = URLRequest(url: url!)
        request.setValue(tokenData, forHTTPHeaderField: "Authorization")
        
        self.fetch(type: T.self, with: request, completion: complete)
    }
    
    func login<T: Decodable>(email:String, password:String, type: T.Type, complete: @escaping (Result<T, ApiError>) -> Void){
        let url = URL(string: "\(appConstants.baseUrl)\(navigationsPath.loginPath)")
        
        let parameters = """
                            {
                                "email":"\(email)",
                                "password":"\(password)"
                            }
                         """
        let bodyData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        self.fetch(type: T.self, with: request, completion: complete)
    }
}
