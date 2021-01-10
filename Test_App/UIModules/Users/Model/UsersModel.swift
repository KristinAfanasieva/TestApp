//
//  UsersModel.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 08.01.2021.
//


import UIKit

class UsersModel {
    var idFriend: String?
    var name: String?
    var phone: String?
    var email: String?
    var imageDataUrl: String?
    
    init(idFriend: String?, name: String?, phone: String?, email: String?, imageDataUrl: String?){
        self.idFriend = idFriend
        self.name = name
        self.phone = phone
        self.email = email
        self.imageDataUrl = imageDataUrl
    }
}
