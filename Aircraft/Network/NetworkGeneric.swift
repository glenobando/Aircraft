//
//  NetworkGeneric.swift
//  Aircraft
//
//  Created by Admin on 6/27/21.
//

import Foundation


protocol NetworkGeneric {
    var session: URLSession { get }
    
    func fetch<T: Decodable>(type: T.Type, with request: URLRequest, completion: @escaping (Result<T, ApiError>) -> Void)
}

extension NetworkGeneric {
    
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, complete:@escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) {data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                complete(.failure(.requestFailed(description: error.debugDescription)))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                complete(.failure(.responseInvalid (description: "status code = \(httpResponse.statusCode)")))
                return
            }
            
            guard let data = data else {
                complete(.failure(.invalidData))
                return
            }
            
            do {
                print(String(data: data, encoding: .utf8)!)
                let decoder = JSONDecoder()
                let genericModel = try decoder.decode(T.self, from: data)
                complete(.success(genericModel))
            }catch let error {
                complete(.failure(.jsonConversionFailure(description: error.localizedDescription)))
            }
        }
        return task
    }
    
    func fetch<T: Decodable>(type: T.Type, with request: URLRequest, completion: @escaping (Result<T, ApiError>) -> Void) {
        let task = decodingTask(with: request, decodingType: T.self) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }
}

