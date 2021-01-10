//
//  Aliases.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 08.01.2021.
//

import Foundation

typealias FriendsCompletion = ([FriendsModel], String?) -> Void
typealias BoolCompletion = (Bool, String?) -> Void
typealias DefaultCompletion = (() -> Void)
typealias RandomUserCompletion = (RandomUserModel?, String?) -> Void
