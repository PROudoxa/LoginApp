//
//  NetworkManager.swift
//  LoginScreenTestRB
//
//  Created by Alex Voronov on 16.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class NetworkManager: NSObject {
    
    let serviceName = "https://reqres.in/api/users/2"
    var json: [String : AnyObject]?
    
    // KVO for LoginVC
    dynamic var errorMessage: String?
    dynamic var userHasBeenGot: Bool = false
    
    
    func callToLogIn(login: String, password: String) {
        
        let passwordSHA256 = password.sha256()
        
        let parameters = [
            "login": login,
            "password": passwordSHA256]
        
        let url = NSURL(string: self.serviceName)
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET" // not good idea to use GET for user's credantials
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        self.userHasBeenGot = false
        self.errorMessage = nil
        
        // response imitation
        if (login == "+380961235555") && (password == "testtest") {
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    print(error!.localizedDescription)
                    self.errorMessage = error!.localizedDescription
                    return
                }
                
                guard let data = data else { print("data is nil"); return }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                        self.json = json
                        self.userHasBeenGot = true
                        UserDefaults.standard.setValue("valid_access_token", forKey: "Access-Token")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            
            task.resume()
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // response imitation: error
                self.errorMessage = "Похоже, вы неверно указали номер телефона или пароль"
            }
        }
    }
    
    func getUser() -> User? {
        
        guard let data = self.json?["data"] as? [String : Any] else { return nil }
        
        let id = data["id"] as? NSNumber ?? 0
        let lastName = data["last_name"] as? String
        let firstName = data["first_name"] as? String
        let avatar = data["avatar"] as? String
        
        let loggedUser = User(id: Int(id), firstName: firstName, lastName: lastName, avatar: avatar)
        
        self.saveNewUserToCoreData(userModel: loggedUser)
        
        return loggedUser
    }
    
    private func saveNewUserToCoreData(userModel: User) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserCoreDataModel", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue(Int32(userModel.id), forKey: "id")
        newUser.setValue(userModel.firstName, forKey: "firstName")
        newUser.setValue(userModel.lastName, forKey: "lastName")
        newUser.setValue(userModel.avatar, forKey: "avatarLink")
        
        DispatchQueue.global(qos: .background).async {
            appDelegate.saveContext()
        }
    }
}
