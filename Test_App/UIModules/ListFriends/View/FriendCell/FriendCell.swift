//
//  FriendCell.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 06.01.2021.
//

import UIKit
import Kingfisher

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        userImage.layer.cornerRadius = 30
        
    }
    
    func configureCell(friend: FriendsModel) {
        userNameLabel.text = friend.name
        userImage.image = friend.imageData ?? R.image.userDefImage()
    }
    func configureCell(user: UsersModel) {
        userNameLabel.text = user.name
        if let stringUrl = user.imageDataUrl, let imageURL = URL(string: stringUrl) {
            userImage.kf.setImage(with: imageURL, placeholder: R.image.userDefImage())
        }
    }
}
