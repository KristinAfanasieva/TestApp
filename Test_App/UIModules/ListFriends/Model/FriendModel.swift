//
//  User.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 06.01.2021.
//

import UIKit

class FriendsModel {
    var idFriend: String?
    var name: String?
    var phone: String?
    var email: String?
    var imageData: UIImage?
    
    init(idFriend: String?, name: String?, phone: String?, email: String?, imageData: UIImage?){
        self.idFriend = idFriend
        self.name = name
        self.phone = phone
        self.email = email
        self.imageData = imageData
    }
}
