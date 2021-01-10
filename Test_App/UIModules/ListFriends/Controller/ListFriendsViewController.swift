//
//  ListUserViewController.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 06.01.2021.
//


import UIKit

class ListFriendsViewController: UIViewController, Showable {
    
    @IBOutlet weak var tableView: UITableView!
    var friendManager: IFriendsService = FriendsService()
    var friendManagerEdit: IFriendsEditService = FriendsService()
    var friendManagerAdd: IFriendsAddService = FriendsService()
    
    private var friendsDataSource = [FriendsModel]() {
        didSet {
            tableView.reloadData()
            friendsDataSource.isEmpty ? updateNoResultsMessageLabelVisibility(false): updateNoResultsMessageLabelVisibility(true)
        }
    }
    lazy var noResultMessageLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.noDocumentAdded
        label.numberOfLines = 0
        label.lineBreakMode = .byClipping
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        DispatchQueue.background(delay: 3.0, background: {
            self.friendManager.fetchData { [weak self] (result, error) in
                if let error = error {
                    self?.showShortError(message: error)
                } else {
                    self?.friendsDataSource = result
                }
            }
        }, completion: {
        })
       

    }
    private func configureNoResultsMessageLabel() {
        
        tableView.addSubview(noResultMessageLabel)
        noResultMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noResultMessageLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            noResultMessageLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 60)
            
        ])
    }
    func updateNoResultsMessageLabelVisibility(_ bool: Bool) {
          DispatchQueue.main.async {
              self.noResultMessageLabel.isHidden = bool
          }
      }
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.friendCell)
        configureNoResultsMessageLabel()
        noResultMessageLabel.isHidden = true
    }
    
    private func configureNavigationBar() {
        title = Constants.listFriendTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showUsersScreen))
    }
    private func updateFriendData(data: FriendsModel) {
        let rowIndex = friendsDataSource.firstIndex(where: {$0.idFriend == data.idFriend})
        guard let index = rowIndex else {
            return
        }
        friendsDataSource[index] = data
        tableView.reloadData()
    }
    
    private func showFriendDetails(model: FriendsModel) {
        guard let friendDetailsScreen = R.storyboard.friendDetails().instantiateInitialViewController() as? FriendDetailsViewController else { return }
        friendDetailsScreen.friendData = model
        friendDetailsScreen.completionHandler = { [weak self] bool, newData in
            if bool {
                guard let newDataRow = newData else { return }
                self?.updateFriendData(data: newDataRow)
            }
        }
        navigationController?.pushViewController(friendDetailsScreen, animated: true)
    }
    @objc func showUsersScreen() {
        guard let listUsers = R.storyboard.usersViewController().instantiateInitialViewController() as? UsersViewController else { return }
        listUsers.completionHandler = { [weak self] bool, friend in
            if bool {
                guard let friendData = friend else { return }
                self?.friendsDataSource.append(friendData)
            }
        }
        navigationController?.pushViewController(listUsers, animated: true)
    
}
}

extension ListFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendsDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.friendCell.identifier, for: indexPath) as? FriendCell else { return UITableViewCell() }
        cell.configureCell(friend: friendsDataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFriendDetails(model: friendsDataSource[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let idFriend = friendsDataSource[indexPath.row].idFriend else { return }
            friendManagerEdit.changeFriendState(idFriend: idFriend) { [weak self] (result, error) in
                if result {
                    self?.friendsDataSource.remove(at: indexPath.row)
                    tableView.reloadData()
                } else if let error = error {
                    self?.showShortError(message: error)
                }
            }
        }
    }
    
}
