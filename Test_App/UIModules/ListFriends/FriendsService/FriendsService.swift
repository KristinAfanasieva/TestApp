//
//  FriendsService.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 08.01.2021.
//


import Foundation
import CoreData
import UIKit


protocol IFriendsService: class {
    func fetchData(completion: @escaping FriendsCompletion)
}
protocol IFriendsEditService: class {
    func editUser(model: FriendsModel, completion: @escaping BoolCompletion)
    func changeFriendState(idFriend: String, completion: @escaping BoolCompletion)
}
protocol IFriendsAddService: class {
    func addNewFriend(model: FriendsModel,completion: @escaping BoolCompletion)
}

class FriendsService: IFriendsService {
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func fetchData(completion: @escaping FriendsCompletion) {
        let context = appDelegate.persistentContainer.viewContext
        var dataSource = [FriendsModel]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let isFriend = data.value(forKey: "isFriend") as? Bool {
                    if isFriend {
                        let row = FriendsModel(idFriend: data.value(forKey: "id") as? String, name: data.value(forKey: "name") as? String, phone: data.value(forKey: "phone") as? String, email: data.value(forKey: "email") as? String, imageData: data.value(forKey: "image") as? UIImage)
                        if let imageData = data.value(forKey: "image") as? NSData {
                            if let image = UIImage(data:imageData as Data) {
                                row.imageData = image
                            }
                        }
                        dataSource.append(row)
                    }
                }
                
            }
            DispatchQueue.main.async {
                completion(dataSource, nil)
            }
            
        } catch {
            DispatchQueue.main.async {
                completion([], error.localizedDescription)
            }
        }
    }
    
}
extension FriendsService: IFriendsAddService {
    func addNewFriend(model: FriendsModel, completion: @escaping BoolCompletion) {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Friends", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(model.idFriend, forKey: "id")
        newUser.setValue(model.name, forKey: "name")
        newUser.setValue(model.email, forKey: "email")
        newUser.setValue(model.phone, forKey: "phone")
        newUser.setValue(true, forKey: "isFriend")
        if let image = model.imageData {
            let imgData = image.jpegData(compressionQuality: 1)
            newUser.setValue(imgData, forKey: "image")
        }
        
        do {
            try context.save()
            DispatchQueue.main.async {
                completion(true, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(false, error.localizedDescription)
            }
        }
    }
}
extension FriendsService: IFriendsEditService {
    func changeFriendState(idFriend: String, completion: @escaping BoolCompletion) {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                guard let row = results?.first(where: { $0.value(forKey: "id") as? String == idFriend }) else { return }
                row.setValue(false, forKey: "isFriend")
            }
        } catch {
            completion(false, error.localizedDescription)
        }
        do {
            try context.save()
            completion(true, nil)
        }
        catch {
            completion(true, error.localizedDescription)
        }
    }
    
    func editUser(model: FriendsModel, completion: @escaping BoolCompletion) {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                guard let row = results?.first(where: { $0.value(forKey: "id") as? String == model.idFriend }) else { return }
                row.setValue(model.idFriend, forKey: "id")
                row.setValue(model.name, forKey: "name")
                row.setValue(model.email, forKey: "email")
                row.setValue(model.phone, forKey: "phone")
                row.setValue(true, forKey: "isFriend")
                if let image = model.imageData {
                    let imgData = image.jpegData(compressionQuality: 1)
                    row.setValue(imgData, forKey: "image")
                }
                
            }
        } catch {
            completion(false, error.localizedDescription)
        }
        
        do {
            try context.save()
            completion(true, nil)
        }
        catch {
            completion(true, error.localizedDescription)
        }
    }
}
