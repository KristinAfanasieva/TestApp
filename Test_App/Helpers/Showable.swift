//
//  Showable.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 08.01.2021.
//

import UIKit

protocol Showable where Self: UIViewController {
    func showShortAlert(title: String, message: String, completion: DefaultCompletion?)
    func showShortError(message: String, completion: DefaultCompletion?)
}

extension Showable where Self: UIViewController {
    func showShortAlert(title: String, message: String, completion: DefaultCompletion? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            completion?()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showShortError(message: String, completion: DefaultCompletion? = nil) {
        self.showShortAlert(title: "Error", message: message, completion: completion)
    }
}
