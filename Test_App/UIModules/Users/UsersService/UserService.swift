//
//  CoreDataService.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 06.01.2021.
//

import Foundation
import Alamofire


protocol IUserService: class {
 func fetchData(completion: @escaping RandomUserCompletion)

}

class UserService: IUserService {
    func fetchData(completion: @escaping RandomUserCompletion) {
        AF.request("https://randomuser.me/api")
            .validate()
            .responseDecodable(of: RandomUserModel.self) { (response) in
                
                guard let users = response.value else {
                    guard let statusCode = response.response?.statusCode, (200...299).contains(statusCode) else {
                        
                        if let error = response.error {
                            DispatchQueue.main.async {
                                completion(nil, error.localizedDescription)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(nil, nil)
                            }
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(nil, "unnowned error")
                    }
                    return }
                DispatchQueue.main.async {
                    completion(users, nil)
                }
            }
    }
}
    
    

