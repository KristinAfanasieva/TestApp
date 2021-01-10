//
//  FriendDetailsViewController.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 08.01.2021.
//

import UIKit
import AVFoundation

class FriendDetailsViewController: UIViewController, Showable {
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImageButton: UIButton!
    
    @IBOutlet weak var nameLabelError: UILabel!
    @IBOutlet weak var phoneLabelError: UILabel!
    @IBOutlet weak var emailLabelError: UILabel!
    
    var imagePicker: ImagePicker!
    
    var completionHandler: ((_ bool: Bool, _ model: FriendsModel?) -> Void)?
    var friendEditManager: IFriendsEditService = FriendsService()
    var friendData: FriendsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureScreenData()
        initializeHideKeyboard()
        scrollView.alwaysBounceHorizontal = false
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        checkCameraAccess()
    }
    private func configureScreenData() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        guard let friend = friendData else {
            return
        }
        photoView.layer.cornerRadius = 75
        photoView.image = friend.imageData
        nameTextField.text = friend.name
        emailTextField.text = friend.email
        phoneTextField.text = friend.phone
    }
    func initializeHideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard() {
        view.endEditing(true)
    }

    private func configureNavigationBar() {
        title = Constants.detailsFriendTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
    }
    @objc func doneAction() {
        dismissKeyboard()
        let model = FriendsModel(idFriend: friendData?.idFriend, name: nameTextField.text, phone: phoneTextField.text, email: emailTextField.text, imageData: photoView.image)
        friendData = model
        friendEditManager.editUser(model: model) { [weak self] (result, error) in
            if result {
                self?.completionHandler?(result, self?.friendData)
                self?.navigationController?.popViewController(animated: true)
            } else {
                if let error = error {
                    self?.showShortError(message: error)
                }
            }
        }
    }
    @objc func cancelAction() {
        dismissKeyboard()
        let alert = UIAlertController(title: "Are you sure you want to go back?", message: "Your changed data will be lost.", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func changePhotoAction(_ sender: UIButton) {
        guard !nameTextField.isFirstResponder else { return }
       changeAvatarAction()
    }
    private func changeAvatarAction(){
        self.imagePicker.present()
    }
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            presentCameraSettings()
        case .restricted, .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                }
            }
        case .authorized:
            break
            
        @unknown default:
            fatalError()
        }
    }
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Please allow access to use camera", message: "Go to Settings?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                })
            }
        })
        
        present(alertController, animated: true)
    }
    private func isValid(inputText: String, textField: UITextField) -> Bool {
        var  predicateTest = NSPredicate()
        switch textField {
        case emailTextField:
            predicateTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        case nameTextField:
            predicateTest = NSPredicate(format: "SELF MATCHES %@", "^([a-zA-Z]{2,}\\s[a-zA-Z]{1,}’?-?`?'?[a-zA-Z]{1,}\\s?([a-zA-Z ]{1,})?)")
        case phoneTextField:
                predicateTest = NSPredicate(format: "SELF MATCHES %@", "^([0-9-)( ]*)?$")
        default:
            break
        }
        
        return predicateTest.evaluate(with: inputText)
    }
    private func isValidAllFields() -> Bool {
        guard let phone = phoneTextField.text, let email = emailTextField.text, let name = nameTextField.text else { return false }
        if isValid(inputText: phone, textField: phoneTextField), isValid(inputText: name, textField: nameTextField), isValid(inputText: email, textField: emailTextField) {
            return true
        } else {
            return false
        }
    }
}
extension FriendDetailsViewController: PhotoPickerPresentable {
    var photoPickerSourceView: UIView {
        return self.photoImageButton
    }
}
extension FriendDetailsViewController: ImagePickerDelegate {
    func setAvatarImage(image: UIImage?) {
        guard let image = image else { return }
        self.photoView.image = image
    }
}
extension FriendDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextField{
            nameLabelError.isHidden = true
            if let text = textField.text, text.count >= 85, range.location != 84 {
                return false
            }
            return true
        } else if textField == phoneTextField {
            phoneLabelError.isHidden = true
            if let text = textField.text, text.count >= 14, range.location != 13 {
                return false
            }
           
            return true
            
        }  else {
            emailLabelError.isHidden = true
            if let text = textField.text, text.count >= 64, range.location != 63 {
                return false
            }
            return true
            
        }
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let inputText = textField.text else {
            return false
        }
        if isValid(inputText: inputText, textField: textField) {
            if isValidAllFields() {
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
                return true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
                switch textField {
                case phoneTextField:
                    phoneLabelError.isHidden = false
                case emailTextField:
                    emailLabelError.isHidden = false
                case nameTextField:
                    nameLabelError.isHidden = false
                default:
                    break
                }
               
            }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
