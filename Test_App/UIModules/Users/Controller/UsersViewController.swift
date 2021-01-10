//
//  UsersViewController.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 08.01.2021.
//

import UIKit

class UsersViewController: UIViewController, Showable {
    
    @IBOutlet weak var tableView: UITableView!
    let userManager = UserService()
    var selectFriend: FriendsModel?
    let myOpQueue = OperationQueue()
    let friendManager: IFriendsAddService = FriendsService()
    var spinner = UIActivityIndicatorView()
    var completionHandler: ((_ bool: Bool, _ model: FriendsModel?) -> Void)?
    private var usersDataSource = [UsersModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        setupSpinner()
        spinner.startAnimating()
        featchData(with: 400)
    }
    private func configureNavigationBar() {
        title = Constants.listFriendTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
    }
    @objc func backAction() {
        myOpQueue.cancelAllOperations()
        navigationController?.popViewController(animated: true)
    }
    private func featchData(with count: Int) {
        //  Sorry! Если это гавнокод заранее извеняюсь) Увы не работала с многопоточностью((
        myOpQueue.maxConcurrentOperationCount = 2
        let semaphore = DispatchSemaphore(value: 0)
        var i = 0
        while i < count {
            myOpQueue.addOperation {
                self.userManager.fetchData { (users, error) in
                    if let data = users {
                        self.usersDataSource.append(contentsOf: data.data)
                        self.spinner.stopAnimating()
                    } else if let error = error {
                        print(error)
                        self.spinner.stopAnimating()
                    }
                }
               _ = semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 10000000))
            }
            myOpQueue.waitUntilAllOperationsAreFinished()
            
            i += 1
        }
      
    }
    func setupSpinner(){
       spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        spinner.color = UIColor(ciColor: .gray)
       self.spinner.center = CGPoint(x:UIScreen.main.bounds.size.width / 2, y:UIScreen.main.bounds.size.height / 2)
       self.view.addSubview(spinner)
       spinner.hidesWhenStopped = true
   }
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.friendCell)
    }
}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usersDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.friendCell.identifier, for: indexPath) as? FriendCell else { return UITableViewCell() }
        cell.configureCell(user: usersDataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? FriendCell
        let friend = FriendsModel(idFriend: UUID().uuidString, name: usersDataSource[indexPath.row].name, phone: usersDataSource[indexPath.row].phone, email: usersDataSource[indexPath.row].email, imageData: cell?.userImage.image)
        selectFriend = friend
        friendManager.addNewFriend(model: friend) { [weak self] (result, error) in
            if result {
                self?.completionHandler? (result,  self?.selectFriend)
                self?.backAction()
            } else if let error = error {
                self?.showShortError(message: error)
            }
        }
    }
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            featchData(with: 50)
            self.tableView.reloadData()
        }
        
     }
    
}
